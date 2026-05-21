import 'package:get/get.dart';

class LibrarySearchController extends GetxController {
  final RxString keyword = ''.obs;

  final RxList<String> recentSearches = <String>[
    'Clean Code',
    'Design Systems',
    'Sapiens',
  ].obs;

  /// Nanti bisa diganti dari API trending search.
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

  /// Nanti bisa diganti dari API last viewed.
  final RxList<LibrarySearchBook> lastViewedBooks = <LibrarySearchBook>[
    const LibrarySearchBook(
      title: 'Thinking, Fast and Slow',
      author: 'Daniel Kahneman',
      rating: '4.8',
      isAvailable: true,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCKFM0hqygsbsRpvlKPieR5QZ3wUJdUwrrBHNvQ1Xpl_v3ZyA2CmnI00VaWHwip_nSReK2A1rJCVl7vEvj_6GHlAQoJfDpPgTYJqnBXKHXfeIo_c1DzD7QiEgTpXf1ZPg8h8dNHYVz5tcnG1DXoK7rFK6crYXvhdhmP-hrqmjuHxC6QpDXSz83Cw4kbbm66191LxJ0-LCs-MsA7ku1zhR_2-LvjOu3JhVwrvQe_02XnkIyhOq8GzSZroYhnNcYXyffs4Yw7EA2DwGBg',
    ),
    const LibrarySearchBook(
      title: 'Clean Code',
      author: 'Robert C. Martin',
      rating: '4.9',
      isAvailable: false,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCO34Y508de6iKw_qzLC6_2khlv2bRyBx7h4XorhVHnkzkfFsZrBK2DSPcgTd44O7j5m5-RkYK8pzR8LEimeUNuEwz1stpZtQih_LSmdcghLYsPq2SQ9qjWWab5_2CnsV6Zqq3xuxpo2Oq24iCXn2k0i0lsSg-QZ6iYM_UMoNAFOsE5t6pdyclTmaKDagds72W3NKb4tDwSuaAiebME6HzI6wZi5Wjo71jnzKrk2tUmrhhNjaH8xS2LmGL6n-eW3WasselkmOJZo1N9',
    ),
  ].obs;

  /// Nanti bisa diganti dari API trending books.
  final RxList<LibrarySearchBook> trendingBooks = <LibrarySearchBook>[
    const LibrarySearchBook(
      title: 'Clean Architecture',
      author: 'Robert C. Martin',
      rating: '4.8',
      isAvailable: true,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAuLblMAj5-Sc853TMVBkmebmIs-PlqkXA2dmSvr6np_PuAApRlgf0J9jxiwcJG-BsSUs9oKsn9ksyb3dfmzQtUydS6lc_1Emw_aOukz22O2jzIOC5ET0JGAZPFPxzTDSKEO6OxtFcm8Y1QzTh_5wPP2qQnP16DxscNnWv0X2BEi3lbQy24UysKZ_Nlcp3o9laV40glwhEHh3O_B_WOOlWdZaJyeJ0CcHF3IAk6jCbHn4pSCtzT110s7C5aIff8AVMeosutYK3qGFaj',
    ),
    const LibrarySearchBook(
      title: 'The Design of Everyday Things',
      author: 'Don Norman',
      rating: '4.8',
      isAvailable: true,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDFtPY08koMch_TVNgxI6NG7PM-FzVmki-eENqsbHPdiuTqJu53S19Rzzuewotosw7fpA0BOHSo8u7rp6esH0z9z5YDAxVCXI_bzCry3t2jfErzsR1AiXaPQXuNq7LbPqn66Y4Etk5eNNFqTyLivYkxyOLMgrY-vZHr9t0bgMIxjpV4YYwLIEArvxee0cMXce9RbIcVXWbU2212IwPLDheL0tnZ9PaKoLvCmeYiUVIvp8QyzcMe0klsbfG_WcUMaUflq3inhdk7qVmg',
    ),
    const LibrarySearchBook(
      title: 'Sapiens',
      author: 'Yuval Noah Harari',
      rating: '4.7',
      isAvailable: true,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDEqwKBnH8vr-PuYXSy-6DZAa4WouAOjyZyx_VITYRgXX4O-V6P91OszSCt6POwHB-N3EqTfV_FxrGpEBPDYWt7aQHuepWAppe-0kAkpYVcV4rW0Xo5oflqor5X0LsySQdvSBetLpMUj--CtpaPsIY0NWRunpbDxpAimtXprYZ9FpWPwVo8A5FkIq0Z2YnX9fno3vayr12fwde3Ls9uIsVOzW54MWruq8G3QgkgleR4gHF4sQFr27d0d-0GU-mILt1lXSU5qQDyErXJ',
    ),
  ].obs;

  /// Dummy local data untuk search result.
  /// Nanti bisa diganti response API.
  final RxList<LibrarySearchBook> allBooks = <LibrarySearchBook>[
    const LibrarySearchBook(
      title: 'The Design of Everyday Things',
      author: 'Don Norman',
      rating: '4.8',
      isAvailable: true,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDFtPY08koMch_TVNgxI6NG7PM-FzVmki-eENqsbHPdiuTqJu53S19Rzzuewotosw7fpA0BOHSo8u7rp6esH0z9z5YDAxVCXI_bzCry3t2jfErzsR1AiXaPQXuNq7LbPqn66Y4Etk5eNNFqTyLivYkxyOLMgrY-vZHr9t0bgMIxjpV4YYwLIEArvxee0cMXce9RbIcVXWbU2212IwPLDheL0tnZ9PaKoLvCmeYiUVIvp8QyzcMe0klsbfG_WcUMaUflq3inhdk7qVmg',
    ),
    const LibrarySearchBook(
      title: 'Clean Code',
      author: 'Robert C. Martin',
      rating: '4.9',
      isAvailable: false,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCO34Y508de6iKw_qzLC6_2khlv2bRyBx7h4XorhVHnkzkfFsZrBK2DSPcgTd44O7j5m5-RkYK8pzR8LEimeUNuEwz1stpZtQih_LSmdcghLYsPq2SQ9qjWWab5_2CnsV6Zqq3xuxpo2Oq24iCXn2k0i0lsSg-QZ6iYM_UMoNAFOsE5t6pdyclTmaKDagds72W3NKb4tDwSuaAiebME6HzI6wZi5Wjo71jnzKrk2tUmrhhNjaH8xS2LmGL6n-eW3WasselkmOJZo1N9',
    ),
    const LibrarySearchBook(
      title: 'Sapiens',
      author: 'Yuval Noah Harari',
      rating: '4.7',
      isAvailable: true,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDEqwKBnH8vr-PuYXSy-6DZAa4WouAOjyZyx_VITYRgXX4O-V6P91OszSCt6POwHB-N3EqTfV_FxrGpEBPDYWt7aQHuepWAppe-0kAkpYVcV4rW0Xo5oflqor5X0LsySQdvSBetLpMUj--CtpaPsIY0NWRunpbDxpAimtXprYZ9FpWPwVo8A5FkIq0Z2YnX9fno3vayr12fwde3Ls9uIsVOzW54MWruq8G3QgkgleR4gHF4sQFr27d0d-0GU-mILt1lXSU5qQDyErXJ',
    ),
    const LibrarySearchBook(
      title: 'Thinking, Fast and Slow',
      author: 'Daniel Kahneman',
      rating: '4.8',
      isAvailable: true,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCKFM0hqygsbsRpvlKPieR5QZ3wUJdUwrrBHNvQ1Xpl_v3ZyA2CmnI00VaWHwip_nSReK2A1rJCVl7vEvj_6GHlAQoJfDpPgTYJqnBXKHXfeIo_c1DzD7QiEgTpXf1ZPg8h8dNHYVz5tcnG1DXoK7rFK6crYXvhdhmP-hrqmjuHxC6QpDXSz83Cw4kbbm66191LxJ0-LCs-MsA7ku1zhR_2-LvjOu3JhVwrvQe_02XnkIyhOq8GzSZroYhnNcYXyffs4Yw7EA2DwGBg',
    ),
  ].obs;

  List<String> get filteredTrendingKeywords {
    final value = keyword.value.trim().toLowerCase();

    if (value.isEmpty) {
      return trendingKeywords.take(8).toList(growable: false);
    }

    return trendingKeywords.where((item) {
      return item.toLowerCase().contains(value);
    }).toList(growable: false);
  }

  List<LibrarySearchBook> getSearchResults(String searchKeyword) {
    final value = searchKeyword.trim().toLowerCase();

    if (value.isEmpty) return const [];

    return allBooks.where((book) {
      return book.title.toLowerCase().contains(value) ||
          book.author.toLowerCase().contains(value);
    }).toList(growable: false);
  }

  void setKeyword(String value) {
    keyword.value = value;
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
  }

  void removeRecentSearch(String value) {
    recentSearches.remove(value);
  }

  void clearRecentSearches() {
    recentSearches.clear();
  }

  void replaceTrendingKeywords(List<String> values) {
    trendingKeywords.assignAll(values);
  }

  void replaceTrendingBooks(List<LibrarySearchBook> books) {
    trendingBooks.assignAll(books);
  }

  void replaceLastViewedBooks(List<LibrarySearchBook> books) {
    lastViewedBooks.assignAll(books);
  }
}

class LibrarySearchBook {
  const LibrarySearchBook({
    required this.title,
    required this.author,
    required this.rating,
    required this.imageUrl,
    required this.isAvailable,
  });

  final String title;
  final String author;
  final String rating;
  final String imageUrl;
  final bool isAvailable;
}
