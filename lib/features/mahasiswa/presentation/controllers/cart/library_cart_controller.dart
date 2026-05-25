import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/shared/models/book/cart_book_model.dart';

class LibraryCartController extends GetxController {
  static const int maxBorrowDays = 14;

  final RxList<LibraryCartBook> cartItems = <LibraryCartBook>[
    const LibraryCartBook(
      id: 'book-clean-code',
      title: 'Clean Code',
      author: 'Robert C. Martin',
      isAvailable: true,
      libraryId: 'lib-central',
      libraryName: 'Perpustakaan Pusat Kampus',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCjEA70cTqnppASeqZK2teqNXmlGiA6iO3o5CzXTzDHhkwwSsBApz43TNsLfq5D9l4JRclzaJmAJH6GzQkTMHEMb2f1t2J4M897NfjIf01rWDsgcTYYMJD_SVs8x5OLALbq7l-wxVmIh2fz-rAwiXAFyLnLE5h_P2HiC-jFt51z7dtqIQqYr5bvcValaXN939BjTYO09S4syh7KXN0siI7yXd12f98i-E8n4k6uYjKiXaZ4g4xhlbDXU8sRQdUNuU3eMbtBF-1TuInE',
    ),
    const LibraryCartBook(
      id: 'book-design-everyday',
      title: 'The Design of Everyday Things',
      author: 'Don Norman',
      isAvailable: true,
      libraryId: 'lib-central',
      libraryName: 'Perpustakaan Pusat Kampus',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBHKRu2AsQKC7EiivPJpTyRtkfn4O3_lBWnrRZK1bpZ8W0g_KBJV9kKpHXSTXvIj0DuK1ykqr088qGMYfVeM5F_EZ49_LNeSlmVB9rx043jDcCdMSpgZtCcHZYXyAH3Ol1sjxyB9C4H4ZlmSt989OpFUUeHLEOouA25Ircoh47YUvKTRWU3kEeRy783N8rjJgbs40a5mXuzLjsNATPKjhq8moDdq1w8h1wHlHlkWY6i3oAfhXWmgQT3HMZQpyzHyM7mdhKCUpGUNvtS',
    ),
    const LibraryCartBook(
      id: 'book-design-systems',
      title: 'Design Systems',
      author: 'Alla Kholmatova',
      isAvailable: true,
      libraryId: 'lib-tech',
      libraryName: 'Perpustakaan Fakultas Teknologi',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCt8a67IlFBQerwKB0PDjSrQqdKJUed0gyR2ZarTsUSc78sYeA379SWhrUc7hRyDx1RJeGUK962FN_F3tbt8GBEEWlZJN_XW0Q01A6dw-ejSZAtCJqUKj6yUSiDpVY7pSYOlS_luWY-DHPCKld-N7WqwgKNIPa4D4i0e15or1UaTXqfs2bZEWKAxDxvxo_sOOP_NGyFGDktxxJIFr8xvDTcEmjTdydcL4pEhJ1ftDE50__9pvTV0ppdOdfxWnGTHLehz0Yqta9YmavH',
    ),
    const LibraryCartBook(
      id: 'book-sapiens',
      title: 'Sapiens',
      author: 'Yuval Noah Harari',
      isAvailable: true,
      libraryId: 'lib-journal',
      libraryName: 'Ruang Jurnal & Referensi',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAOGdF3QY5G89jhgdZoszYTVtgwR3oxR_MjOcbuc9zoWw-ykYzpq2GdDFwhRsEmV6I6fcwVxAKt3mlKBT8EzWVNGGm3Oa33rYDpFZstTXu_npFRx8Nu7h8b_mqoxj66VbH6Jf8JfD6LCfAdFF0nR8LonDJqbUPoGhwdZhDjlXMbFuZqCvC6KZy6AtDhrCu-vgkdYnqpqsXXy4gAgNc54k6dPS7OsMAZuIdjGaslY26YvCIMaaWv4nK6tkq3NoRi6meFwbrhSHY_t2w8',
    ),
    const LibraryCartBook(
      id: 'book-intro-algorithms',
      title: 'Introduction to Algorithms',
      author: 'Thomas H. Cormen',
      isAvailable: false,
      libraryId: 'lib-tech',
      libraryName: 'Perpustakaan Fakultas Teknologi',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAoj4Z8IoRSbMHxcHtyF5zv-vftPDK9cEmIt5CWpIbIFF8FfnDsdsfP2nupFnCUXvVFO0sGmQMrS54Pl5r3bcrbX99lI6PlUkykcO4_Oy5osY70WvrPRu1-n4mm-8QPO8-_-MryX6sBF6WTpzN2CKv2qRPml7NF3AHYHAo8ztQeeI3blkxqWgZbKDPMbJHL5Oo6VagMzspuZHBK5eRcUxU9ec9PvU7LyrOKGPxx6enE-rZYQlaFdH3n9XA22wcQT2t2PuZLIT8TtLIU',
    ),
  ].obs;

  final RxSet<String> checkedBookIds = <String>{
    'book-clean-code',
    'book-design-everyday',
  }.obs;

  final Rx<DateTime> borrowDate = DateTime.now().obs;
  final Rx<DateTime> returnDate =
      DateTime.now().add(const Duration(days: maxBorrowDays)).obs;

  LibraryCartBook? _findBookById(String bookId) {
    for (final item in cartItems) {
      if (item.id == bookId) return item;
    }

    return null;
  }

  List<LibraryCartBook> get checkedItems {
    return cartItems.where((item) {
      return item.isAvailable && checkedBookIds.contains(item.id);
    }).toList(growable: false);
  }

  int get checkedCount => checkedItems.length;

  int get availableCount {
    return cartItems.where((item) => item.isAvailable).length;
  }

  bool get hasItems => cartItems.isNotEmpty;

  bool get hasCheckedItems => checkedCount > 0;

  String? get selectedLibraryId {
    if (checkedItems.isEmpty) return null;

    return checkedItems.first.libraryId;
  }

  String? get selectedLibraryName {
    if (checkedItems.isEmpty) return null;

    return checkedItems.first.libraryName;
  }

  bool get isAllAvailableChecked {
    final activeLibraryId = selectedLibraryId;

    if (activeLibraryId == null || activeLibraryId.isEmpty) {
      return false;
    }

    return isAllAvailableCheckedForLibrary(activeLibraryId);
  }

  bool canSelectLibrary(String libraryId) {
    final activeLibraryId = selectedLibraryId;

    if (activeLibraryId == null || activeLibraryId.isEmpty) return true;

    return activeLibraryId == libraryId;
  }

  bool isBookDisabledByLibraryRule(String bookId) {
    final item = _findBookById(bookId);

    if (item == null) return true;
    if (!item.isAvailable) return true;
    if (checkedBookIds.contains(item.id)) return false;

    return !canSelectLibrary(item.libraryId);
  }

  int availableCountForLibrary(String libraryId) {
    return cartItems.where((item) {
      return item.libraryId == libraryId && item.isAvailable;
    }).length;
  }

  int checkedCountForLibrary(String libraryId) {
    return cartItems.where((item) {
      return item.libraryId == libraryId && checkedBookIds.contains(item.id);
    }).length;
  }

  bool isAllAvailableCheckedForLibrary(String libraryId) {
    final availableItems = cartItems.where((item) {
      return item.libraryId == libraryId && item.isAvailable;
    }).toList(growable: false);

    if (availableItems.isEmpty) return false;

    return availableItems.every((item) {
      return checkedBookIds.contains(item.id);
    });
  }

  DateTime get latestReturnDate {
    return DateUtils.dateOnly(
      borrowDate.value.add(const Duration(days: maxBorrowDays)),
    );
  }

  int get borrowDurationDays {
    final start = DateUtils.dateOnly(borrowDate.value);
    final end = DateUtils.dateOnly(returnDate.value);

    return end.difference(start).inDays;
  }

  bool get isBorrowRangeValid {
    return borrowDurationDays > 0 && borrowDurationDays <= maxBorrowDays;
  }

  void toggleBookChecked(String bookId) {
    toggleBookCheckedWithLibraryRule(bookId);
  }

  void toggleBookCheckedWithLibraryRule(String bookId) {
    final item = _findBookById(bookId);

    if (item == null) return;

    if (!item.isAvailable) {
      showUnavailableBookWarning();
      return;
    }

    final isAlreadyChecked = checkedBookIds.contains(item.id);

    if (isAlreadyChecked) {
      checkedBookIds.remove(item.id);
      checkedBookIds.refresh();
      return;
    }

    final activeLibraryId = selectedLibraryId;

    if (activeLibraryId != null &&
        activeLibraryId.isNotEmpty &&
        activeLibraryId != item.libraryId) {
      showDifferentLibraryWarning(
        activeLibraryName: selectedLibraryName ?? 'perpustakaan lain',
        targetLibraryName: item.libraryName,
      );
      return;
    }

    checkedBookIds.add(item.id);
    checkedBookIds.refresh();
  }

  void toggleSelectAllAvailable() {
    final activeLibraryId = selectedLibraryId;

    if (activeLibraryId != null && activeLibraryId.isNotEmpty) {
      toggleSelectAllAvailableForLibrary(activeLibraryId);
      return;
    }

    final firstAvailableItem = cartItems.firstWhereOrNull(
      (item) => item.isAvailable,
    );

    if (firstAvailableItem == null) return;

    toggleSelectAllAvailableForLibrary(firstAvailableItem.libraryId);
  }

  void toggleSelectAllAvailableForLibrary(String libraryId) {
    final availableItems = cartItems.where((item) {
      return item.libraryId == libraryId && item.isAvailable;
    }).toList(growable: false);

    if (availableItems.isEmpty) return;

    final targetLibraryName = availableItems.first.libraryName;
    final activeLibraryId = selectedLibraryId;

    if (activeLibraryId != null &&
        activeLibraryId.isNotEmpty &&
        activeLibraryId != libraryId) {
      showDifferentLibraryWarning(
        activeLibraryName: selectedLibraryName ?? 'perpustakaan lain',
        targetLibraryName: targetLibraryName,
      );
      return;
    }

    final isAllChecked = availableItems.every((item) {
      return checkedBookIds.contains(item.id);
    });

    if (isAllChecked) {
      for (final item in availableItems) {
        checkedBookIds.remove(item.id);
      }

      checkedBookIds.refresh();
      return;
    }

    for (final item in availableItems) {
      checkedBookIds.add(item.id);
    }

    checkedBookIds.refresh();
  }

  void removeBook(String bookId) {
    cartItems.removeWhere((item) => item.id == bookId);
    checkedBookIds.remove(bookId);
    checkedBookIds.refresh();
  }

  void clearCheckedItems() {
    checkedBookIds.clear();
    checkedBookIds.refresh();
  }

  void removeCheckedItems() {
    final ids = checkedBookIds.toSet();

    cartItems.removeWhere((item) => ids.contains(item.id));
    checkedBookIds.clear();
    checkedBookIds.refresh();
  }

  void addBook(LibraryCartBook book) {
    final existingIndex = cartItems.indexWhere((item) => item.id == book.id);

    if (existingIndex >= 0) {
      Get.snackbar(
        'Buku Sudah Ada',
        '${book.title} sudah ada di keranjang.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    cartItems.add(book);
  }

  Future<void> pickBorrowDateRange(BuildContext context) async {
    final initialStart = DateUtils.dateOnly(borrowDate.value);
    final initialEnd = DateUtils.dateOnly(returnDate.value);

    final selectedRange = await showDateRangePicker(
      context: context,
      firstDate: DateUtils.dateOnly(
        DateTime.now().subtract(const Duration(days: 1)),
      ),
      lastDate: DateUtils.dateOnly(
        DateTime.now().add(const Duration(days: 365)),
      ),
      initialDateRange: DateTimeRange(
        start: initialStart,
        end: initialEnd.isAfter(initialStart)
            ? initialEnd
            : initialStart.add(const Duration(days: maxBorrowDays)),
      ),
      helpText: 'Pilih Periode Peminjaman',
      saveText: 'Pilih',
      cancelText: 'Batal',
      fieldStartLabelText: 'Tanggal Pinjam',
      fieldEndLabelText: 'Tanggal Kembali',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF031632),
                  secondary: const Color(0xFF006C49),
                ),
          ),
          child: child!,
        );
      },
    );

    if (selectedRange == null) return;

    final start = DateUtils.dateOnly(selectedRange.start);
    final end = DateUtils.dateOnly(selectedRange.end);
    final duration = end.difference(start).inDays;

    borrowDate.value = start;

    if (duration <= 0) {
      returnDate.value = start.add(const Duration(days: 1));
      Get.snackbar(
        'Tanggal Tidak Valid',
        'Tanggal pengembalian harus setelah tanggal pinjam.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (duration > maxBorrowDays) {
      returnDate.value = start.add(const Duration(days: maxBorrowDays));
      Get.snackbar(
        'Durasi Disesuaikan',
        'Durasi maksimal peminjaman adalah $maxBorrowDays hari. Tanggal kembali otomatis disesuaikan.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    returnDate.value = end;
  }

  void showNoCheckedWarning() {
    Get.snackbar(
      'Pilih Buku',
      'Centang minimal satu buku untuk lanjut ke checkout.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  void showUnavailableBookWarning() {
    Get.snackbar(
      'Buku Tidak Tersedia',
      'Buku ini sedang tidak tersedia untuk dipinjam.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  void showDifferentLibraryWarning({
    required String activeLibraryName,
    required String targetLibraryName,
  }) {
    Get.snackbar(
      'Tidak bisa memilih dari 2 perpustakaan',
      'Anda sudah memilih buku dari $activeLibraryName. Hapus pilihan tersebut jika ingin memilih dari $targetLibraryName.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(milliseconds: 2600),
    );
  }

  void confirmBorrowing() {
    if (!hasCheckedItems) {
      showNoCheckedWarning();
      return;
    }

    if (!isBorrowRangeValid) {
      Get.snackbar(
        'Periode Tidak Valid',
        'Pastikan durasi peminjaman tidak lebih dari $maxBorrowDays hari.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    Get.snackbar(
      'Berhasil',
      'Pengajuan peminjaman $checkedCount buku dari ${selectedLibraryName ?? 'perpustakaan'} berhasil dibuat.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }
}