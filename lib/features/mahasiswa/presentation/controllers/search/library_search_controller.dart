import 'package:get/get.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/features/mahasiswa/data/services/home_api_service.dart';
import 'package:lumina_library/shared/models/book/book_model.dart';

/// Backend-driven search. Results, pagination and infinite scroll all come from
/// GET /books (global) or GET /public/branches/{id}/books (scoped) via
/// [HomeApiService].
///
/// Refactor note:
/// - Rx tetap dipertahankan agar aman jika ada page lain yang masih memakai Obx.
/// - Untuk page search utama, gunakan GetBuilder agar tidak muncul error:
///   "[Get] the improper use of a GetX has been detected".
/// - Semua perubahan state memanggil update().
class LibrarySearchController extends GetxController {
  static const int _perPage = 15;

  final RxString keyword = ''.obs;

  final RxList<String> recentSearches = <String>[].obs;

  final RxList<String> trendingKeywords = <String>[
    'Clean Architecture',
    'Design Systems',
    'User Experience',
    'Machine Learning',
    'Data Science',
    'Sapiens',
    'Product Design',
    'Artificial Intelligence',
  ].obs;

  // Real trending books from backend.
  final RxBool isTrendingLoading = false.obs;
  final RxList<BookModel> trendingBooks = <BookModel>[].obs;

  // Backend search results + pagination.
  final RxBool isSearching = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxString searchError = ''.obs;
  final RxList<BookModel> results = <BookModel>[].obs;

  int _page = 1;
  int _searchToken = 0;

  String _activeKeyword = '';
  String? _activeBranchId;
  String? _activeStatus;
  String _activeSort = 'trending';

  HomeApiService get _service => Get.find<HomeApiService>();

  @override
  void onInit() {
    super.onInit();
    _loadTrending();
  }

  void _safeUpdate() {
    if (!isClosed) {
      update();
    }
  }

  Future<void> _loadTrending() async {
    isTrendingLoading.value = true;
    _safeUpdate();

    try {
      final books = await _service.getTrendingBooks(limit: 10);
      trendingBooks.assignAll(books);
    } catch (_) {
      // Silent. Section akan hide kalau list kosong.
    } finally {
      isTrendingLoading.value = false;
      _safeUpdate();
    }
  }

  List<String> get filteredTrendingKeywords {
    final value = keyword.value.trim().toLowerCase();
    final items = trendingKeywords.toList(growable: false);

    if (value.isEmpty) {
      return items.take(8).toList(growable: false);
    }

    return items
        .where((item) => item.toLowerCase().contains(value))
        .toList(growable: false);
  }

  void setKeyword(String value) {
    if (keyword.value == value) return;

    keyword.value = value;
    _safeUpdate();
  }

  Future<void> runSearch(
    String kw, {
    String? branchId,
    String? status,
    String sort = 'trending',
  }) async {
    final clean = kw.trim();
    if (clean.isEmpty) return;

    final token = ++_searchToken;

    keyword.value = clean;
    _activeKeyword = clean;
    _activeBranchId = branchId;
    _activeStatus = status;
    _activeSort = sort;

    _page = 1;
    hasMore.value = true;
    searchError.value = '';
    isSearching.value = true;
    isLoadingMore.value = false;
    results.clear();

    _safeUpdate();

    try {
      final result = await _fetchPage(1);

      if (token != _searchToken) return;

      results.assignAll(result.items);
      hasMore.value = result.hasMorePages;
    } on LuminaApiException catch (e) {
      if (token != _searchToken) return;

      searchError.value = e.displayMessage;
      hasMore.value = false;
    } catch (_) {
      if (token != _searchToken) return;

      searchError.value = 'Gagal memuat hasil pencarian.';
      hasMore.value = false;
    } finally {
      if (token == _searchToken) {
        isSearching.value = false;
        _safeUpdate();
      }
    }
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoadingMore.value || isSearching.value) return;
    if (_activeKeyword.trim().isEmpty) return;

    final nextPage = _page + 1;

    isLoadingMore.value = true;
    _safeUpdate();

    try {
      final result = await _fetchPage(nextPage);

      _page = nextPage;
      results.addAll(result.items);
      hasMore.value = result.hasMorePages;
    } on LuminaApiException {
      // Keep current page.
    } catch (_) {
      // Keep current page.
    } finally {
      isLoadingMore.value = false;
      _safeUpdate();
    }
  }

  Future<void> applyStatus(String? status) {
    return runSearch(
      _activeKeyword,
      branchId: _activeBranchId,
      status: status,
      sort: _activeSort,
    );
  }

  Future<void> applySort(String sort) {
    return runSearch(
      _activeKeyword,
      branchId: _activeBranchId,
      status: _activeStatus,
      sort: sort,
    );
  }

  String? get activeStatus => _activeStatus;
  String get activeSort => _activeSort;

  Future<({List<BookModel> items, bool hasMorePages})> _fetchPage(int page) {
    final branchId = _activeBranchId;

    if (branchId != null && branchId.isNotEmpty) {
      return _service.getBranchBooksPage(
        branchId,
        page: page,
        perPage: _perPage,
        sort: _activeSort,
        status: _activeStatus,
        search: _activeKeyword,
      );
    }

    return _service.getCatalogBooksPage(
      page: page,
      perPage: _perPage,
      search: _activeKeyword,
      status: _activeStatus,
      sort: _activeSort,
    );
  }

  void addRecentSearch(String value) {
    final cleanValue = value.trim();
    if (cleanValue.isEmpty) return;

    recentSearches.removeWhere(
      (item) => item.toLowerCase() == cleanValue.toLowerCase(),
    );

    recentSearches.insert(0, cleanValue);

    if (recentSearches.length > 8) {
      recentSearches.removeRange(8, recentSearches.length);
    }

    _safeUpdate();
  }

  void removeRecentSearch(String value) {
    recentSearches.remove(value);
    _safeUpdate();
  }

  void clearRecentSearches() {
    recentSearches.clear();
    _safeUpdate();
  }
}