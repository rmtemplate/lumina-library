import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:lumina_library/shared/models/book/catalog_book_model.dart';

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

  final RxSet<int> favoriteIndexes = <int>{2}.obs;

  final List<CatalogFilterOption<String>> distanceOptions = const [
    CatalogFilterOption(label: 'Semua jarak', value: 'all'),
    CatalogFilterOption(label: '< 1 km', value: 'under_1'),
    CatalogFilterOption(label: '1 - 3 km', value: '1_3'),
    CatalogFilterOption(label: '3 - 5 km', value: '3_5'),
    CatalogFilterOption(label: '> 5 km', value: 'above_5'),
  ];

  final List<CatalogFilterOption<String>> categoryOptions = const [
    CatalogFilterOption(label: 'Semua kategori', value: 'all'),
    CatalogFilterOption(label: 'Design', value: 'design'),
    CatalogFilterOption(label: 'Technology', value: 'technology'),
    CatalogFilterOption(label: 'Novel', value: 'novel'),
    CatalogFilterOption(label: 'History', value: 'history'),
    CatalogFilterOption(label: 'Psychology', value: 'psychology'),
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

  final List<CatalogBookModel> books = const [
    CatalogBookModel(
      title: 'The Design of Everyday Things',
      author: 'Don Norman',
      rating: '4.8',
      isAvailable: true,
      category: 'design',
      libraryName: 'Lumina Central Library',
      libraryDistanceKm: 0.8,
      publishedYear: 2023,
      borrowCount: 128,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDFtPY08koMch_TVNgxI6NG7PM-FzVmki-eENqsbHPdiuTqJu53S19Rzzuewotosw7fpA0BOHSo8u7rp6esH0z9z5YDAxVCXI_bzCry3t2jfErzsR1AiXaPQXuNq7LbPqn66Y4Etk5eNNFqTyLivYkxyOLMgrY-vZHr9t0bgMIxjpV4YYwLIEArvxee0cMXce9RbIcVXWbU2212IwPLDheL0tnZ9PaKoLvCmeYiUVIvp8QyzcMe0klsbfG_WcUMaUflq3inhdk7qVmg',
    ),
    CatalogBookModel(
      title: 'Clean Code',
      author: 'Robert C. Martin',
      rating: '4.9',
      isAvailable: false,
      category: 'technology',
      libraryName: 'Engineering Library',
      libraryDistanceKm: 2.4,
      publishedYear: 2022,
      borrowCount: 214,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCO34Y508de6iKw_qzLC6_2khlv2bRyBx7h4XorhVHnkzkfFsZrBK2DSPcgTd44O7j5m5-RkYK8pzR8LEimeUNuEwz1stpZtQih_LSmdcghLYsPq2SQ9qjWWab5_2CnsV6Zqq3xuxpo2Oq24iCXn2k0i0lsSg-QZ6iYM_UMoNAFOsE5t6pdyclTmaKDagds72W3NKb4tDwSuaAiebME6HzI6wZi5Wjo71jnzKrk2tUmrhhNjaH8xS2LmGL6n-eW3WasselkmOJZo1N9',
    ),
    CatalogBookModel(
      title: 'Sapiens',
      author: 'Yuval Noah Harari',
      rating: '4.7',
      isAvailable: true,
      category: 'history',
      libraryName: 'Social Science Library',
      libraryDistanceKm: 3.8,
      publishedYear: 2021,
      borrowCount: 176,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDEqwKBnH8vr-PuYXSy-6DZAa4WouAOjyZyx_VITYRgXX4O-V6P91OszSCt6POwHB-N3EqTfV_FxrGpEBPDYWt7aQHuepWAppe-0kAkpYVcV4rW0Xo5oflqor5X0LsySQdvSBetLpMUj--CtpaPsIY0NWRunpbDxpAimtXprYZ9FpWPwVo8A5FkIq0Z2YnX9fno3vayr12fwde3Ls9uIsVOzW54MWruq8G3QgkgleR4gHF4sQFr27d0d-0GU-mILt1lXSU5qQDyErXJ',
    ),
    CatalogBookModel(
      title: 'Thinking, Fast and Slow',
      author: 'Daniel Kahneman',
      rating: '4.8',
      isAvailable: true,
      category: 'psychology',
      libraryName: 'Business Library',
      libraryDistanceKm: 5.6,
      publishedYear: 2024,
      borrowCount: 96,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCKFM0hqygsbsRpvlKPieR5QZ3wUJdUwrrBHNvQ1Xpl_v3ZyA2CmnI00VaWHwip_nSReK2A1rJCVl7vEvj_6GHlAQoJfDpPgTYJqnBXKHXfeIo_c1DzD7QiEgTpXf1ZPg8h8dNHYVz5tcnG1DXoK7rFK6crYXvhdhmP-hrqmjuHxC6QpDXSz83Cw4kbbm66191LxJ0-LCs-MsA7ku1zhR_2-LvjOu3JhVwrvQe_02XnkIyhOq8GzSZroYhnNcYXyffs4Yw7EA2DwGBg',
    ),
  ];

  List<CatalogBookModel> get filteredBooks {
    final distanceKey = selectedDistanceKey.value;
    final categoryKey = selectedCategoryKey.value;
    final availabilityKey = selectedAvailabilityKey.value;
    final publishedYear = selectedPublishedYear.value;
    final sortKey = selectedSortKey.value;

    final result = books.where((book) {
      final distanceMatched = _isDistanceMatched(
        book.libraryDistanceKm,
        distanceKey,
      );

      final categoryMatched =
          categoryKey == defaultCategoryKey || book.category == categoryKey;

      final availabilityMatched = availabilityKey == defaultAvailabilityKey ||
          (availabilityKey == 'available' && book.isAvailable) ||
          (availabilityKey == 'borrowed' && !book.isAvailable);

      final publishedYearMatched =
          publishedYear == null || book.publishedYear == publishedYear;

      return distanceMatched &&
          categoryMatched &&
          availabilityMatched &&
          publishedYearMatched;
    }).toList();

    result.sort((a, b) {
      switch (sortKey) {
        case 'nearby':
          return a.libraryDistanceKm.compareTo(b.libraryDistanceKm);
        case 'rating':
          return _parseRating(b.rating).compareTo(_parseRating(a.rating));
        case 'newest':
          return b.publishedYear.compareTo(a.publishedYear);
        case 'popular':
        default:
          return b.borrowCount.compareTo(a.borrowCount);
      }
    });

    return result;
  }

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

  void setDistanceFilter(String value) {
    selectedDistanceKey.value = value;
  }

  void setCategoryFilter(String value) {
    selectedCategoryKey.value = value;
  }

  void setAvailabilityFilter(String value) {
    selectedAvailabilityKey.value = value;
  }

  void setPublishedYearFilter(int? value) {
    selectedPublishedYear.value = value;
  }

  void setSortFilter(String value) {
    selectedSortKey.value = value;
  }

  void resetFilters() {
    selectedDistanceKey.value = defaultDistanceKey;
    selectedCategoryKey.value = defaultCategoryKey;
    selectedAvailabilityKey.value = defaultAvailabilityKey;
    selectedPublishedYear.value = null;
    selectedSortKey.value = defaultSortKey;
  }

  void toggleFavorite(int index) {
    if (favoriteIndexes.contains(index)) {
      favoriteIndexes.remove(index);
    } else {
      favoriteIndexes.add(index);
    }

    favoriteIndexes.refresh();
  }

  void handleBorrowTap(CatalogBookModel book) {
    debugPrint('Borrow tapped: ${book.title}');
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

  double _parseRating(String value) {
    return double.tryParse(value) ?? 0;
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