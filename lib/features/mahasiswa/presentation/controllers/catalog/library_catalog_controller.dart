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
  static const String defaultSortKey = 'popular';

  final RxString selectedDistanceKey = defaultDistanceKey.obs;
  final RxString selectedCategoryKey = defaultCategoryKey.obs;
  final RxString selectedAvailabilityKey = defaultAvailabilityKey.obs;
  final RxString selectedSortKey = defaultSortKey.obs;
  final RxnInt selectedPublishedYear = RxnInt();

  final RxBool isLoading = false.obs;
  final RxBool isCategoriesLoading = false.obs;
  final RxString errorMessage = ''.obs;

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
    CatalogFilterOption(label: 'Terpopuler', value: 'popular'),
    CatalogFilterOption(label: 'Jarak terdekat', value: 'nearby'),
    CatalogFilterOption(label: 'Rating tertinggi', value: 'rating'),
    CatalogFilterOption(label: 'Terbaru', value: 'newest'),
  ];

  // ── Dynamic category options (dari API) ───────────────────────────────────

  /// Daftar opsi kategori yang selalu sinkron dengan data API.
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

  /// Dipanggil setiap kali user kembali ke tab Catalog.
  /// Me-refresh categories + books dan mereset filter ke default.
  Future<void> refresh() async {
    resetFilters();
    await _loadAll();
  }

  /// Dipanggil dari home page saat navigasi ke Catalog dengan category tertentu
  /// (misalnya dari icon kategori di dashboard).
  void applyInitialCategory(String? slug) {
    if (slug == null || slug.trim().isEmpty) return;
    selectedCategoryKey.value = slug.trim();
  }

  Future<void> loadBooks() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final service = Get.find<HomeApiService>();
      final result = await service.getCatalogBooks(sort: 'trending', limit: 30);
      books.assignAll(result);
      // Sync wishlist state from API response
      favoriteBookIds.clear();
      for (final book in result) {
        if (book.userContext?.isWishlisted == true) {
          favoriteBookIds.add(book.id);
        }
      }
      favoriteBookIds.refresh();
    } on LuminaApiException catch (e) {
      errorMessage.value = e.displayMessage;
    } catch (e) {
      errorMessage.value = 'Gagal memuat buku. Periksa koneksi internet.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCategories() async {
    isCategoriesLoading.value = true;

    try {
      final service = Get.find<HomeApiService>();
      final result = await service.getCategories();
      apiCategories.assignAll(result);

      // Validasi: jika selected category tidak ada lagi di daftar terbaru, reset.
      _validateCategoryFilter();
    } on LuminaApiException catch (_) {
      // Biarkan apiCategories tetap seperti sebelumnya (atau kosong saat pertama).
    } catch (_) {
      // Silent fail — filter tetap tampil (meski dengan data lama).
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  // ── Filtered data ──────────────────────────────────────────────────────────

  List<BookModel> get filteredBooks {
    final distanceKey = selectedDistanceKey.value;
    final categoryKey = selectedCategoryKey.value;
    final availabilityKey = selectedAvailabilityKey.value;
    final publishedYear = selectedPublishedYear.value;
    final sortKey = selectedSortKey.value;

    final result = books.where((book) {
      final distanceMatched = _isDistanceMatched(
        book.branch?.distanceKm ?? 0,
        distanceKey,
      );

      final categoryMatched = categoryKey == defaultCategoryKey ||
          (book.category?.slug ?? '') == categoryKey;

      final availabilityMatched = availabilityKey == defaultAvailabilityKey ||
          (availabilityKey == 'available' && book.isAvailable) ||
          (availabilityKey == 'borrowed' && !book.isAvailable);

      final publishedYearMatched =
          publishedYear == null || book.publishYear == publishedYear;

      return distanceMatched &&
          categoryMatched &&
          availabilityMatched &&
          publishedYearMatched;
    }).toList();

    result.sort((a, b) {
      switch (sortKey) {
        case 'nearby':
          final aDist = a.branch?.distanceKm ?? 0;
          final bDist = b.branch?.distanceKm ?? 0;
          return aDist.compareTo(bDist);
        case 'rating':
          return b.ratingAverage.compareTo(a.ratingAverage);
        case 'newest':
          return (b.publishYear ?? 0).compareTo(a.publishYear ?? 0);
        case 'popular':
        default:
          return b.borrowCount.compareTo(a.borrowCount);
      }
    });

    return result;
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

  void setDistanceFilter(String value) => selectedDistanceKey.value = value;
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

    // Optimistic update
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
      // Rollback
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
    // Jalankan keduanya secara paralel.
    await Future.wait([
      loadCategories(),
      loadBooks(),
    ]);
  }

  void _validateCategoryFilter() {
    final current = selectedCategoryKey.value;
    if (current == defaultCategoryKey) return;

    final validSlugs = apiCategories.map((c) => c.slug).toSet();
    if (!validSlugs.contains(current)) {
      selectedCategoryKey.value = defaultCategoryKey;
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
