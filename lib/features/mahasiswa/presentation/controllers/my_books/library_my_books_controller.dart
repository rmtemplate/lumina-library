import 'package:get/get.dart';

import 'package:lumina_library/shared/models/book/library_my_book_item_model.dart';

class LibraryMyBooksController extends GetxController {
  // ── Filter ────────────────────────────────────────────────────────────────

  final RxInt selectedFilterIndex = 0.obs;

  final List<String> filters = const [
    'All',
    'Active',
    'Due Soon',
    'Overdue',
    'Returned',
  ];

  // ── Pagination state ──────────────────────────────────────────────────────

  /// Halaman yang sedang dimuat (1-based).
  final RxInt _currentPage = 1.obs;

  /// Loading pertama kali (menampilkan skeleton full).
  final RxBool isInitialLoading = true.obs;

  /// Loading saat pull-to-refresh.
  final RxBool isRefreshing = false.obs;

  /// Loading saat load more (infinite scroll).
  final RxBool isLoadingMore = false.obs;

  /// Masih ada data berikutnya atau tidak.
  final RxBool hasMore = true.obs;

  // ── Data ──────────────────────────────────────────────────────────────────

  final RxList<LibraryMyBookItemModel> _allBooks =
      <LibraryMyBookItemModel>[].obs;

  // Semua data dummy disimpan di sini. Pada integrasi API, ini diganti dengan
  // RxList yang diisi dari server, page per page.
  static final List<LibraryMyBookItemModel> _dummyPage1 = [
    const LibraryMyBookItemModel(
      loanId: 'LMN-8472-91A',
      bookCode: 'BK-UX-001',
      title: 'Modern UX Design',
      author: 'Alicia Hart',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAzpmqkX7zqHxIffZ3d25pq1X0JZ36S4TdlP5S_lziXjjh2fnLIBwyAtQgksQ_Nwm-Hfa8PcMVjqFuezchn1dMKEXAzbWz0TVhFj08xJ02GyhWZHLO9HRed1fqWekOtGU82Z0xC6Tr6YKrUiyJ3AGUYHUyr_j0zzjlevLyx3quxeacgbENLWHPvVLMZbuP31umrxALb9UNCd3NNlBdPr4Kd8YLauEHyyO0UEkY6YstIZXHoPsGzbF_ILS2AOoJfRyn-IOncMLCHvV7K',
      libraryName: 'Lumina Library - Central',
      libraryAddress: 'Jl. Merdeka No. 12, Jakarta',
      returnLocationName: 'Lumina Library - Central',
      returnLocationDetail: 'Main Desk, Ground Floor',
      destinationLatitude: -6.175392,
      destinationLongitude: 106.827153,
      borrowDateText: '20 May 2026',
      borrowTimeText: '10:45',
      dueDateText: '30 May 2026',
      dueTimeText: '23:59',
      remainingDays: 2,
      status: LibraryMyBookStatus.dueSoon,
      isbn: '978-602-1234-001',
      category: 'Design',
      notes: 'Show your return QR code to the librarian at the return desk.',
    ),
    const LibraryMyBookItemModel(
      loanId: 'LMN-8472-91B',
      bookCode: 'BK-ARCH-004',
      title: 'Clean Architecture',
      author: 'Robert C. Martin',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAuLblMAj5-Sc853TMVBkmebmIs-PlqkXA2dmSvr6np_PuAApRlgf0J9jxiwcJG-BsSUs9oKsn9ksyb3dfmzQtUydS6lc_1Emw_aOukz22O2jzIOC5ET0JGAZPFPxzTDSKEO6OxtFcm8Y1QzTh_5wPP2qQnP16DxscNnWv0X2BEi3lbQy24UysKZ_Nlcp3o9laV40glwhEHh3O_B_WOOlWdZaJyeJ0CcHF3IAk6jCbHn4pSCtzT110s7C5aIff8AVMeosutYK3qGFaj',
      libraryName: 'Engineering Library',
      libraryAddress: 'Engineering Building, 2nd Floor, Jakarta',
      returnLocationName: 'Engineering Library',
      returnLocationDetail: 'Circulation Desk, 2nd Floor',
      destinationLatitude: -6.361945,
      destinationLongitude: 106.824211,
      borrowDateText: '20 May 2026',
      borrowTimeText: '13:20',
      dueDateText: '3 June 2026',
      dueTimeText: '23:59',
      remainingDays: 8,
      status: LibraryMyBookStatus.active,
      isbn: '978-0134494166',
      category: 'Computer Science',
      notes: 'Please keep the book in good condition before returning it.',
    ),
  ];

  static final List<LibraryMyBookItemModel> _dummyPage2 = [
    const LibraryMyBookItemModel(
      loanId: 'LMN-8472-91C',
      bookCode: 'BK-PSY-010',
      title: 'Atomic Habits',
      author: 'James Clear',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCKFM0hqygsbsRpvlKPieR5QZ3wUJdUwrrBHNvQ1Xpl_v3ZyA2CmnI00VaWHwip_nSReK2A1rJCVl7vEvj_6GHlAQoJfDpPgTYJqnBXKHXfeIo_c1DzD7QiEgTpXf1ZPg8h8dNHYVz5tcnG1DXoK7rFK6crYXvhdhmP-hrqmjuHxC6QpDXSz83Cw4kbbm66191LxJ0-LCs-MsA7ku1zhR_2-LvjOu3JhVwrvQe_02XnkIyhOq8GzSZroYhnNcYXyffs4Yw7EA2DwGBg',
      libraryName: 'Lumina Library - Central',
      libraryAddress: 'Jl. Merdeka No. 12, Jakarta',
      returnLocationName: 'Lumina Library - Central',
      returnLocationDetail: 'Main Desk, Ground Floor',
      destinationLatitude: -6.175392,
      destinationLongitude: 106.827153,
      borrowDateText: '1 May 2026',
      borrowTimeText: '09:10',
      dueDateText: '15 May 2026',
      dueTimeText: '23:59',
      overdueDays: 10,
      finePerDay: 2000,
      fineAmount: 20000,
      status: LibraryMyBookStatus.overdue,
      isbn: '978-0735211292',
      category: 'Psychology',
      notes: 'This loan is overdue. The fine must be paid when returning.',
    ),
    const LibraryMyBookItemModel(
      loanId: 'LMN-8472-91D',
      bookCode: 'BK-HIS-002',
      title: 'Sapiens',
      author: 'Yuval Noah Harari',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAOGdF3QY5G89jhgdZoszYTVtgwR3oxR_MjOcbuc9zoWw-ykYzpq2GdDFwhRsEmV6I6fcwVxAKt3mlKBT8EzWVNGGm3Oa33rYDpFZstTXu_npFRx8Nu7h8b_mqoxj66VbH6Jf8JfD6LCfAdFF0nR8LonDJqbUPoGhwdZhDjlXMbFuZqCvC6KZy6AtDhrCu-vgkdYnqpqsXXy4gAgNc54k6dPS7OsMAZuIdjGaslY26YvCIMaaWv4nK6tkq3NoRi6meFwbrhSHY_t2w8',
      libraryName: 'Social Science Library',
      libraryAddress: 'Social Humanities Building, Jakarta',
      returnLocationName: 'Social Science Library',
      returnLocationDetail: 'Return Counter, Lobby Area',
      destinationLatitude: -6.362543,
      destinationLongitude: 106.826721,
      borrowDateText: '4 April 2026',
      borrowTimeText: '15:35',
      dueDateText: '18 April 2026',
      dueTimeText: '23:59',
      returnedDateText: '17 April 2026',
      returnedTimeText: '11:20',
      status: LibraryMyBookStatus.finished,
      isbn: '978-0062316097',
      category: 'History',
      notes: 'The book was returned on time.',
    ),
  ];

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadInitial();
  }

  // ── Reset (dipanggil saat tab My Books dibuka) ────────────────────────────

  /// Reset filter ke "All". Dipanggil dari [LibraryHomeController]
  /// setiap kali user berpindah ke tab My Books.
  void resetFilter() {
    if (selectedFilterIndex.value != 0) {
      selectedFilterIndex.value = 0;
    }
  }

  // ── Load data ─────────────────────────────────────────────────────────────

  Future<void> _loadInitial() async {
    isInitialLoading.value = true;
    _currentPage.value = 1;
    _allBooks.clear();
    hasMore.value = true;

    await _simulateFetch(page: 1);
    isInitialLoading.value = false;
  }

  Future<void> refresh() async {
    if (isRefreshing.value) return;
    isRefreshing.value = true;
    _currentPage.value = 1;
    _allBooks.clear();
    hasMore.value = true;

    await _simulateFetch(page: 1);
    isRefreshing.value = false;
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value || isInitialLoading.value) return;
    isLoadingMore.value = true;

    final nextPage = _currentPage.value + 1;
    await _simulateFetch(page: nextPage);

    isLoadingMore.value = false;
  }

  // Simulasi fetch — ganti dengan API call saat integrasi backend.
  Future<void> _simulateFetch({required int page}) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (page == 1) {
      _allBooks.assignAll(_dummyPage1);
      _currentPage.value = 1;
    } else if (page == 2) {
      _allBooks.addAll(_dummyPage2);
      _currentPage.value = 2;
      hasMore.value = false; // tidak ada page 3
    } else {
      hasMore.value = false;
    }
  }

  // ── Filtered data ─────────────────────────────────────────────────────────

  List<LibraryMyBookItemModel> get filteredBooks {
    final selectedFilter = filters[selectedFilterIndex.value];
    if (selectedFilter == 'All') return _allBooks.toList(growable: false);

    return _allBooks.where((book) {
      switch (selectedFilter) {
        case 'Active':
          return book.status == LibraryMyBookStatus.active;
        case 'Due Soon':
          return book.status == LibraryMyBookStatus.dueSoon;
        case 'Overdue':
          return book.status == LibraryMyBookStatus.overdue;
        case 'Returned':
          return book.status == LibraryMyBookStatus.finished;
        default:
          return true;
      }
    }).toList(growable: false);
  }

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
    selectedFilterIndex.value = index;
  }
}
