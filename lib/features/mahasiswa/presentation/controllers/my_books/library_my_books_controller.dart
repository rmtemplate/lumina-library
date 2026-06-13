import 'package:get/get.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/features/mahasiswa/data/services/home_api_service.dart';
import 'package:lumina_library/shared/models/book/library_my_book_item_model.dart';

class LibraryMyBooksController extends GetxController {
  // ── Filter ────────────────────────────────────────────────────────────────

  final RxInt selectedFilterIndex = 0.obs;

  final List<String> filters = const [
    'Semua',
    'Aktif',
    'Segera Kembali',
    'Terlambat',
    'Selesai',
  ];

  // ── Pagination state ──────────────────────────────────────────────────────

  final RxInt _currentPage = 1.obs;
  final RxBool isInitialLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxString errorMessage = ''.obs;

  // ── Data ──────────────────────────────────────────────────────────────────

  final RxList<LibraryMyBookItemModel> _allBooks =
      <LibraryMyBookItemModel>[].obs;

  static const int _perPage = 10;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadInitial();
  }

  // ── Reset filter (dipanggil saat tab dibuka) ──────────────────────────────

  void resetFilter() {
    if (selectedFilterIndex.value != 0) {
      selectedFilterIndex.value = 0;
    }
  }

  // ── Load data ─────────────────────────────────────────────────────────────

  Future<void> _loadInitial() async {
    isInitialLoading.value = true;
    errorMessage.value = '';
    _currentPage.value = 1;
    _allBooks.clear();
    hasMore.value = true;

    await _fetchPage(page: 1);
    isInitialLoading.value = false;
  }

  Future<void> refresh() async {
    if (isRefreshing.value) return;
    isRefreshing.value = true;
    errorMessage.value = '';
    _currentPage.value = 1;
    _allBooks.clear();
    hasMore.value = true;

    await _fetchPage(page: 1);
    isRefreshing.value = false;
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value || isInitialLoading.value) return;
    isLoadingMore.value = true;

    final nextPage = _currentPage.value + 1;
    await _fetchPage(page: nextPage);

    isLoadingMore.value = false;
  }

  Future<void> _fetchPage({required int page}) async {
    try {
      final service = Get.find<HomeApiService>();
      final result = await service.getMyBooks(
        status: _statusQueryParam,
        perPage: _perPage,
        page: page,
      );

      if (page == 1) {
        _allBooks.assignAll(result.items);
      } else {
        _allBooks.addAll(result.items);
      }

      _currentPage.value = page;
      hasMore.value = result.hasMore;
    } on LuminaApiException catch (e) {
      if (page == 1) errorMessage.value = e.displayMessage;
    } catch (_) {
      if (page == 1) errorMessage.value = 'Gagal memuat data buku.';
    }
  }

  String? get _statusQueryParam {
    final filter = filters[selectedFilterIndex.value];
    switch (filter) {
      case 'Aktif':
        return 'active';
      case 'Segera Kembali':
        return 'due_soon';
      case 'Terlambat':
        return 'overdue';
      case 'Selesai':
        return 'returned';
      default:
        // null → backend returns ALL statuses (including pending, awaiting_pickup)
        return null;
    }
  }

  // ── Filtered data ─────────────────────────────────────────────────────────

  List<LibraryMyBookItemModel> get filteredBooks =>
      _allBooks.toList(growable: false);

  // ── Stats ─────────────────────────────────────────────────────────────────

  int get activeCount => _allBooks
      .where((b) =>
          b.status == LibraryMyBookStatus.active ||
          b.status == LibraryMyBookStatus.dueSoon)
      .length;

  int get dueSoonCount =>
      _allBooks.where((b) => b.status == LibraryMyBookStatus.dueSoon).length;

  int get overdueCount =>
      _allBooks.where((b) => b.status == LibraryMyBookStatus.overdue).length;

  int get returnedCount =>
      _allBooks.where((b) => b.status == LibraryMyBookStatus.finished).length;

  int get totalFineAmount =>
      _allBooks.fold(0, (total, b) => total + b.fineAmount);

  LibraryMyBookItemModel? get priorityReminderBook {
    for (final b in _allBooks) {
      if (b.status == LibraryMyBookStatus.overdue) return b;
    }
    for (final b in _allBooks) {
      if (b.status == LibraryMyBookStatus.dueSoon) return b;
    }
    return null;
  }

  // ── Filter action ─────────────────────────────────────────────────────────

  void setFilterIndex(int index) {
    if (index < 0 || index >= filters.length) return;
    if (selectedFilterIndex.value == index) return;
    isInitialLoading.value = true; // show skeleton before filter change triggers inner Obx
    selectedFilterIndex.value = index;
    _loadInitial();
  }
}
