import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/features/mahasiswa/data/services/home_api_service.dart';
import 'package:lumina_library/shared/models/book/book_model.dart';
import 'package:lumina_library/shared/models/category/category_model.dart';
import 'package:lumina_library/shared/widgets/feedback/lumina_toast.dart';

class CatalogFilterOption<T> {
  const CatalogFilterOption({
    required this.label,
    required this.value,
  });

  final String label;
  final T value;
}

class LibraryCatalogController extends GetxController {
  static const String defaultDistanceKey = 'all';
  static const String defaultCategoryKey = 'all';
  static const String defaultAvailabilityKey = 'all';
  static const String defaultSortKey = 'trending';
  static const int _perPage = 15;

  final RxString selectedDistanceKey = defaultDistanceKey.obs;
  final RxString selectedCategoryKey = defaultCategoryKey.obs;
  final RxString selectedAvailabilityKey = defaultAvailabilityKey.obs;
  final RxString selectedSortKey = defaultSortKey.obs;
  final RxnInt selectedPublishedYear = RxnInt();

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isCategoriesLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString loadMoreError = ''.obs;

  // Pagination
  final RxBool hasMorePages = true.obs;
  int _currentPage = 1;

  final RxList<BookModel> books = <BookModel>[].obs;
  final RxList<CategoryModel> apiCategories = <CategoryModel>[].obs;
  final RxSet<String> favoriteBookIds = <String>{}.obs;

  // ── Static filter options ──────────────────────────────────────────────────

  final List<CatalogFilterOption<String>> distanceOptions = const [
    CatalogFilterOption(label: 'Semua jarak', value: 'all'),
    CatalogFilterOption(label: '< 1 km', value: 'under_1'),
    CatalogFilterOption(label: '1 - 3 km', value: '1_3'),
    CatalogFilterOption(label: '3 - 5 km', value: '3_5'),
    CatalogFilterOption(label: '> 5 km', value: 'above_5'),
  ];

  final List<CatalogFilterOption<String>> availabilityOptions = const [
    CatalogFilterOption(label: 'Semua status', value: 'all'),
    CatalogFilterOption(label: 'Tersedia', value: 'available'),
    CatalogFilterOption(label: 'Dipinjam', value: 'borrowed'),
  ];

  final List<CatalogFilterOption<int?>> publishedYearOptions = const [
    CatalogFilterOption<int?>(label: 'Semua tahun', value: null),
    CatalogFilterOption<int?>(label: '2024', value: 2024),
    CatalogFilterOption<int?>(label: '2023', value: 2023),
    CatalogFilterOption<int?>(label: '2022', value: 2022),
    CatalogFilterOption<int?>(label: '2021', value: 2021),
  ];

  final List<CatalogFilterOption<String>> sortOptions = const [
    CatalogFilterOption(label: 'Terpopuler', value: 'trending'),
    CatalogFilterOption(label: 'Jarak terdekat', value: 'nearby'),
    CatalogFilterOption(label: 'Rating tertinggi', value: 'rating'),
    CatalogFilterOption(label: 'Terbaru', value: 'newest'),
  ];

  // ── Dynamic category options (dari API) ───────────────────────────────────

  List<CatalogFilterOption<String>> get categoryOptions {
    final allOption = const CatalogFilterOption<String>(
      label: 'Semua kategori',
      value: 'all',
    );

    if (apiCategories.isEmpty) return [allOption];

    return [
      allOption,
      ...apiCategories.map(
        (cat) => CatalogFilterOption<String>(
          label: cat.name,
          value: cat.slug,
        ),
      ),
    ];
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadAll();
  }

  // ── Public methods ─────────────────────────────────────────────────────────

  @override
  Future<void> refresh() async {
    selectedDistanceKey.value = defaultDistanceKey;
    selectedCategoryKey.value = defaultCategoryKey;
    selectedAvailabilityKey.value = defaultAvailabilityKey;
    selectedPublishedYear.value = null;
    selectedSortKey.value = defaultSortKey;
    await _loadAll();
  }

  void applyInitialCategory(String? slug) {
    if (slug == null || slug.trim().isEmpty) return;
    final newSlug = slug.trim();
    if (selectedCategoryKey.value == newSlug) return;
    selectedCategoryKey.value = newSlug;
    loadBooks();
  }

  /// Called when user taps "Terapkan Filter" in the filter sheet.
  void applyFilters() => loadBooks();

  Future<void> loadBooks() async {
    _currentPage = 1;
    hasMorePages.value = true;
    loadMoreError.value = '';
    isLoading.value = true;
    errorMessage.value = '';
    books.clear();

    try {
      final result = await Get.find<HomeApiService>().getCatalogBooksPage(
        page: 1,
        perPage: _perPage,
        sort: _apiSort,
        categorySlug: selectedCategoryKey.value == defaultCategoryKey
            ? null
            : selectedCategoryKey.value,
        status: selectedAvailabilityKey.value == defaultAvailabilityKey
            ? null
            : selectedAvailabilityKey.value,
        year: selectedPublishedYear.value,
      );
      books.addAll(result.items);
      hasMorePages.value = result.hasMorePages;
      _syncWishlist(result.items);
    } on LuminaApiException catch (e) {
      errorMessage.value = e.displayMessage;
    } catch (_) {
      errorMessage.value = 'Gagal memuat buku. Periksa koneksi internet.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreBooks() async {
    if (!hasMorePages.value || isLoadingMore.value || isLoading.value) return;
    loadMoreError.value = '';
    isLoadingMore.value = true;
    _currentPage++;

    final before = books.length;
    debugPrint(
      '[PAGINATION][CATALOG] nextPageRequest=$_currentPage itemsLoaded=$before',
    );

    try {
      final result = await Get.find<HomeApiService>().getCatalogBooksPage(
        page: _currentPage,
        perPage: _perPage,
        sort: _apiSort,
        categorySlug: selectedCategoryKey.value == defaultCategoryKey
            ? null
            : selectedCategoryKey.value,
        status: selectedAvailabilityKey.value == defaultAvailabilityKey
            ? null
            : selectedAvailabilityKey.value,
        year: selectedPublishedYear.value,
      );
      books.addAll(result.items);
      hasMorePages.value = result.hasMorePages;
      _syncWishlist(result.items);
      debugPrint(
        '[PAGINATION][CATALOG] appended=${result.items.length} '
        'itemsAfterAppend=${books.length} hasMorePages=${hasMorePages.value}',
      );
    } on LuminaApiException catch (e) {
      _currentPage--;
      loadMoreError.value = e.displayMessage;
    } catch (_) {
      _currentPage--;
      loadMoreError.value = 'Gagal memuat lebih banyak buku.';
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> loadCategories() async {
    isCategoriesLoading.value = true;

    try {
      final result = await Get.find<HomeApiService>().getCategories();
      apiCategories.assignAll(result);
      _validateCategoryFilter();
    } on LuminaApiException catch (_) {
      // silent — filter UI shows with whatever data we have
    } catch (_) {
      // silent
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  // ── Filtered data (distance is client-side only) ───────────────────────────

  List<BookModel> get filteredBooks {
    if (selectedDistanceKey.value == defaultDistanceKey) return books.toList();
    return books
        .where((b) => _isDistanceMatched(
              b.branch?.distanceKm ?? 0,
              selectedDistanceKey.value,
            ))
        .toList();
  }

  // ── Filter state ───────────────────────────────────────────────────────────

  int get activeFilterCount {
    var count = 0;
    if (selectedDistanceKey.value != defaultDistanceKey) count++;
    if (selectedCategoryKey.value != defaultCategoryKey) count++;
    if (selectedAvailabilityKey.value != defaultAvailabilityKey) count++;
    if (selectedPublishedYear.value != null) count++;
    if (selectedSortKey.value != defaultSortKey) count++;
    return count;
  }

  bool get hasActiveFilter => activeFilterCount > 0;

  String get filterSummary {
    final category = _findLabel(categoryOptions, selectedCategoryKey.value);
    final distance = _findLabel(distanceOptions, selectedDistanceKey.value);
    final availability =
        _findLabel(availabilityOptions, selectedAvailabilityKey.value);
    final publishedYear = selectedPublishedYear.value == null
        ? 'Semua tahun'
        : selectedPublishedYear.value.toString();
    final sort = _findLabel(sortOptions, selectedSortKey.value);

    return '$category • $distance • $availability • $publishedYear • $sort';
  }

  // ── Filter setters ─────────────────────────────────────────────────────────

  // Distance is client-side — no server reload needed.
  void setDistanceFilter(String value) => selectedDistanceKey.value = value;

  // The rest update UI state only; applyFilters() triggers the server reload.
  void setCategoryFilter(String value) => selectedCategoryKey.value = value;
  void setAvailabilityFilter(String value) =>
      selectedAvailabilityKey.value = value;
  void setPublishedYearFilter(int? value) => selectedPublishedYear.value = value;
  void setSortFilter(String value) => selectedSortKey.value = value;

  void resetFilters() {
    selectedDistanceKey.value = defaultDistanceKey;
    selectedCategoryKey.value = defaultCategoryKey;
    selectedAvailabilityKey.value = defaultAvailabilityKey;
    selectedPublishedYear.value = null;
    selectedSortKey.value = defaultSortKey;
  }

  Future<void> toggleFavorite(String bookId) async {
    final isCurrentlyFav = favoriteBookIds.contains(bookId);

    if (isCurrentlyFav) {
      favoriteBookIds.remove(bookId);
    } else {
      favoriteBookIds.add(bookId);
    }
    favoriteBookIds.refresh();

    try {
      await Get.find<HomeApiService>().toggleWishlist(bookId);
      LuminaToast.success(
        isCurrentlyFav ? 'Dihapus dari wishlist' : 'Ditambahkan ke wishlist',
      );
    } catch (_) {
      if (isCurrentlyFav) {
        favoriteBookIds.add(bookId);
      } else {
        favoriteBookIds.remove(bookId);
      }
      favoriteBookIds.refresh();
      LuminaToast.error('Gagal mengubah status wishlist.');
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _loadAll() async {
    await Future.wait([
      loadCategories(),
      loadBooks(),
    ]);
  }

  void _syncWishlist(List<BookModel> newItems) {
    for (final book in newItems) {
      if (book.userContext?.isWishlisted == true) {
        favoriteBookIds.add(book.id);
      }
    }
    favoriteBookIds.refresh();
  }

  void _validateCategoryFilter() {
    final current = selectedCategoryKey.value;
    if (current == defaultCategoryKey) return;
    final validSlugs = apiCategories.map((c) => c.slug).toSet();
    if (!validSlugs.contains(current)) {
      selectedCategoryKey.value = defaultCategoryKey;
    }
  }

  String get _apiSort {
    switch (selectedSortKey.value) {
      case 'nearby':
        return 'nearest';
      case 'rating':
        return 'rating';
      case 'newest':
        return 'newest';
      case 'trending':
        return 'trending';
      default:
        return 'trending';
    }
  }

  bool _isDistanceMatched(double distanceKm, String distanceKey) {
    switch (distanceKey) {
      case 'under_1':
        return distanceKm < 1;
      case '1_3':
        return distanceKm >= 1 && distanceKm <= 3;
      case '3_5':
        return distanceKm > 3 && distanceKm <= 5;
      case 'above_5':
        return distanceKm > 5;
      case defaultDistanceKey:
      default:
        return true;
    }
  }

  String _findLabel<T>(List<CatalogFilterOption<T>> options, T value) {
    return options
        .firstWhere(
          (option) => option.value == value,
          orElse: () => options.first,
        )
        .label;
  }
}
