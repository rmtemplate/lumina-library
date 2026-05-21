import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/models/book/cart_book_model.dart';

class LibraryCartController extends GetxController {
  static const int maxBorrowDays = 14;

  final RxList<LibraryCartBook> cartItems = <LibraryCartBook>[
    const LibraryCartBook(
      id: 'book-clean-code',
      title: 'Clean Code',
      author: 'Robert C. Martin',
      isAvailable: true,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCjEA70cTqnppASeqZK2teqNXmlGiA6iO3o5CzXTzDHhkwwSsBApz43TNsLfq5D9l4JRclzaJmAJH6GzQkTMHEMb2f1t2J4M897NfjIf01rWDsgcTYYMJD_SVs8x5OLALbq7l-wxVmIh2fz-rAwiXAFyLnLE5h_P2HiC-jFt51z7dtqIQqYr5bvcValaXN939BjTYO09S4syh7KXN0siI7yXd12f98i-E8n4k6uYjKiXaZ4g4xhlbDXU8sRQdUNuU3eMbtBF-1TuInE',
    ),
    const LibraryCartBook(
      id: 'book-design-everyday',
      title: 'The Design of Everyday Things',
      author: 'Don Norman',
      isAvailable: true,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBHKRu2AsQKC7EiivPJpTyRtkfn4O3_lBWnrRZK1bpZ8W0g_KBJV9kKpHXSTXvIj0DuK1ykqr088qGMYfVeM5F_EZ49_LNeSlmVB9rx043jDcCdMSpgZtCcHZYXyAH3Ol1sjxyB9C4H4ZlmSt989OpFUUeHLEOouA25Ircoh47YUvKTRWU3kEeRy783N8rjJgbs40a5mXuzLjsNATPKjhq8moDdq1w8h1wHlHlkWY6i3oAfhXWmgQT3HMZQpyzHyM7mdhKCUpGUNvtS',
    ),
    const LibraryCartBook(
      id: 'book-design-systems',
      title: 'Design Systems',
      author: 'Alla Kholmatova',
      isAvailable: true,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCt8a67IlFBQerwKB0PDjSrQqdKJUed0gyR2ZarTsUSc78sYeA379SWhrUc7hRyDx1RJeGUK962FN_F3tbt8GBEEWlZJN_XW0Q01A6dw-ejSZAtCJqUKj6yUSiDpVY7pSYOlS_luWY-DHPCKld-N7WqwgKNIPa4D4i0e15or1UaTXqfs2bZEWKAxDxvxo_sOOP_NGyFGDktxxJIFr8xvDTcEmjTdydcL4pEhJ1ftDE50__9pvTV0ppdOdfxWnGTHLehz0Yqta9YmavH',
    ),
  ].obs;

  final RxSet<String> checkedBookIds = <String>{
    'book-clean-code',
    'book-design-everyday',
  }.obs;

  final Rx<DateTime> borrowDate = DateTime.now().obs;
  final Rx<DateTime> returnDate =
      DateTime.now().add(const Duration(days: maxBorrowDays)).obs;

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

  bool get isAllAvailableChecked {
    final availableIds = cartItems
        .where((item) => item.isAvailable)
        .map((item) => item.id)
        .toSet();

    if (availableIds.isEmpty) return false;

    return checkedBookIds.containsAll(availableIds);
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
    if (checkedBookIds.contains(bookId)) {
      checkedBookIds.remove(bookId);
    } else {
      checkedBookIds.add(bookId);
    }
  }

  void toggleSelectAllAvailable() {
    if (isAllAvailableChecked) {
      checkedBookIds.clear();
      return;
    }

    checkedBookIds
      ..clear()
      ..addAll(
        cartItems
            .where((item) => item.isAvailable)
            .map((item) => item.id)
            .toList(growable: false),
      );
  }

  void removeBook(String bookId) {
    cartItems.removeWhere((item) => item.id == bookId);
    checkedBookIds.remove(bookId);
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

  void confirmBorrowing() {
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
      'Pengajuan peminjaman $checkedCount buku berhasil dibuat.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }
}
