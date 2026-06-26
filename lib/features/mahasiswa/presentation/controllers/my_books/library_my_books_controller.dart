import 'dart:async';

import 'package:get/get.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/core/services/websocket/websocket_event.dart';
import 'package:lumina_library/core/services/websocket/websocket_service.dart';
import 'package:lumina_library/features/mahasiswa/data/services/home_api_service.dart';
import 'package:lumina_library/shared/models/book/library_my_book_item_model.dart';
import 'package:lumina_library/shared/widgets/popups/borrowing_expired_popup.dart';
import 'package:lumina_library/shared/widgets/popups/pickup_failed_popup.dart';
import 'package:lumina_library/shared/widgets/popups/pickup_success_popup.dart';

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

  // ── Realtime (WebSocket) ──────────────────────────────────────────────────

  StreamSubscription<WebSocketEvent>? _wsSubscription;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadInitial();
    _listenToRealtimeEvents();
  }

  @override
  void onClose() {
    _wsSubscription?.cancel();
    super.onClose();
  }

  /// Subscribes to the WebSocketService firehose and reacts to every event
  /// that affects a borrowing this list shows — pickup success/failure, QR
  /// lifecycle, and auto-expiry. No polling: the list only refetches when
  /// the backend actually pushes something, via [refresh].
  void _listenToRealtimeEvents() {
    if (!Get.isRegistered<WebSocketService>()) return;

    _wsSubscription = Get.find<WebSocketService>().events.listen((event) {
      switch (event.name) {
        case 'pickup.success':
          _onPickupSuccess(event);
        case 'pickup.failed':
          _onPickupFailed(event);
        case 'borrowing.expired':
          _onBorrowingExpired(event);
        case 'qr.generated':
        case 'qr.refreshed':
        case 'qr.expired':
          // QR state changed server-side for some borrowing in this list —
          // refetch so status/QR-derived fields stay accurate. The QR
          // bottom sheet itself (library_my_book_detail_page.dart) listens
          // independently for its own live countdown/image updates.
          unawaited(refresh());
      }
    });
  }

  LibraryMyBookItemModel? _findByBorrowingId(String? borrowingId) {
    if (borrowingId == null) return null;
    for (final book in _allBooks) {
      if (book.loanId == borrowingId) return book;
    }
    return null;
  }

  void _onPickupSuccess(WebSocketEvent event) {
    final book = _findByBorrowingId(event.borrowingId);
    unawaited(refresh());

    final context = Get.context;
    if (context == null) return;

    final pickedAtRaw = event.data['picked_at'] as String?;
    final pickedAt = pickedAtRaw != null
        ? (DateTime.tryParse(pickedAtRaw)?.toLocal() ?? DateTime.now())
        : DateTime.now();

    unawaited(
      PickupSuccessPopup.show(
        context,
        bookCoverUrl: book?.imageUrl,
        bookTitle: book?.title,
        borrowingCode:
            (event.data['borrowing_code'] as String?) ?? book?.bookCode ?? '',
        pickedAt: pickedAt,
      ).catchError((error, stackTrace) {
        // optional debug log
      }),
    );
  }


  void _onPickupFailed(WebSocketEvent event) {
    final context = Get.context;
    if (context == null) return;

    unawaited(PickupFailedPopup.show(
      context,
      borrowingCode: event.data['borrowing_code'] as String?,
      reason: (event.data['reason'] as String?) ?? 'QR tidak dapat diproses.',
    ));
  }

  void _onBorrowingExpired(WebSocketEvent event) {
    final book = _findByBorrowingId(event.borrowingId);
    unawaited(refresh());

    final context = Get.context;
    if (context == null) return;

    unawaited(BorrowingExpiredPopup.show(
      context,
      bookCoverUrl: book?.imageUrl,
      bookTitle: book?.title,
      borrowingCode: (event.data['borrowing_code'] as String?) ?? book?.bookCode ?? '',
    ));
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

  @override
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
