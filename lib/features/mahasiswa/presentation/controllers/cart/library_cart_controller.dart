import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/features/mahasiswa/data/services/home_api_service.dart';
import 'package:lumina_library/shared/models/borrowing/checkout_result_model.dart';
import 'package:lumina_library/shared/models/cart/cart_model.dart';
import 'package:lumina_library/shared/widgets/feedback/lumina_toast.dart';

class LibraryCartController extends GetxController {
  static const int maxBorrowDays = 14;

  final RxBool isLoading = false.obs;
  final RxBool isCheckoutLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final Rx<CartModel> cart = CartModel.empty().obs;
  final RxSet<String> checkedItemIds = <String>{}.obs;

  final Rx<DateTime> borrowDate = DateTime.now().obs;
  final Rx<DateTime> returnDate =
      DateTime.now().add(const Duration(days: maxBorrowDays)).obs;

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  // ── Computed ───────────────────────────────────────────────────────────────

  List<CartItemModel> get allItems => cart.value.allItems;

  List<CartGroupModel> get groups => cart.value.groups;

  bool get hasItems => allItems.isNotEmpty;

  List<CartItemModel> get checkedItems {
    return allItems.where((item) {
      return item.isAvailable && checkedItemIds.contains(item.id);
    }).toList(growable: false);
  }

  int get checkedCount => checkedItems.length;

  int get availableCount => allItems.where((i) => i.isAvailable).length;

  bool get hasCheckedItems => checkedCount > 0;

  String? get selectedBranchId {
    if (checkedItems.isEmpty) return null;
    return checkedItems.first.branchId;
  }

  String? get selectedBranchName {
    if (checkedItems.isEmpty) return null;
    return checkedItems.first.branchName;
  }

  bool get isAllAvailableChecked {
    final branchId = selectedBranchId;
    if (branchId == null || branchId.isEmpty) return false;
    return isAllAvailableCheckedForBranch(branchId);
  }

  bool canSelectBranch(String branchId) {
    final active = selectedBranchId;
    if (active == null || active.isEmpty) return true;
    return active == branchId;
  }

  bool isItemDisabledByBranchRule(String itemId) {
    final item = _findItemById(itemId);
    if (item == null) return true;
    if (!item.isAvailable) return true;
    if (checkedItemIds.contains(item.id)) return false;
    return !canSelectBranch(item.branchId);
  }

  bool isAllAvailableCheckedForBranch(String branchId) {
    final available = allItems.where((i) => i.branchId == branchId && i.isAvailable).toList();
    if (available.isEmpty) return false;
    return available.every((i) => checkedItemIds.contains(i.id));
  }

  DateTime get latestReturnDate =>
      DateUtils.dateOnly(borrowDate.value.add(const Duration(days: maxBorrowDays)));

  int get borrowDurationDays {
    final start = DateUtils.dateOnly(borrowDate.value);
    final end = DateUtils.dateOnly(returnDate.value);
    return end.difference(start).inDays;
  }

  bool get isBorrowRangeValid =>
      borrowDurationDays > 0 && borrowDurationDays <= maxBorrowDays;

  // ── API ────────────────────────────────────────────────────────────────────

  Future<void> loadCart() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final service = Get.find<HomeApiService>();
      cart.value = await service.getCart();
    } on LuminaApiException catch (e) {
      errorMessage.value = e.displayMessage;
    } catch (_) {
      errorMessage.value = 'Gagal memuat keranjang.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addBook({required String bookId, required String branchId}) async {
    try {
      final service = Get.find<HomeApiService>();
      cart.value = await service.addCartItem(bookId: bookId, branchId: branchId);
      LuminaToast.success('Buku berhasil ditambahkan ke keranjang.');
      return true;
    } on LuminaApiException catch (e) {
      LuminaToast.error(e.displayMessage);
      return false;
    } catch (_) {
      LuminaToast.error('Gagal menambahkan buku ke keranjang.');
      return false;
    }
  }

  Future<void> removeItem(String cartItemId) async {
    final prevCart = cart.value;
    // Optimistic remove
    final newGroups = prevCart.groups
        .map((g) => CartGroupModel(
              branch: g.branch,
              items: g.items.where((i) => i.id != cartItemId).toList(),
              itemsCount: g.items.where((i) => i.id != cartItemId).length,
            ))
        .where((g) => g.items.isNotEmpty)
        .toList();
    cart.value = CartModel(
      id: prevCart.id,
      groups: newGroups,
      totalItems: prevCart.totalItems - 1,
      totalBranches: newGroups.length,
    );
    checkedItemIds.remove(cartItemId);
    checkedItemIds.refresh();

    try {
      await Get.find<HomeApiService>().removeCartItem(cartItemId);
    } on LuminaApiException catch (_) {
      cart.value = prevCart;
    } catch (_) {
      cart.value = prevCart;
    }
  }

  bool isBookInCart(String bookId) {
    return allItems.any((i) => i.bookId == bookId);
  }

  // ── Selection ──────────────────────────────────────────────────────────────

  void toggleItemChecked(String itemId) {
    final item = _findItemById(itemId);
    if (item == null) return;

    if (!item.isAvailable) {
      showUnavailableBookWarning();
      return;
    }

    if (checkedItemIds.contains(item.id)) {
      checkedItemIds.remove(item.id);
      checkedItemIds.refresh();
      return;
    }

    final activeBranch = selectedBranchId;
    if (activeBranch != null && activeBranch.isNotEmpty && activeBranch != item.branchId) {
      showDifferentBranchWarning(
        activeBranchName: selectedBranchName ?? 'perpustakaan lain',
        targetBranchName: item.branchName,
      );
      return;
    }

    checkedItemIds.add(item.id);
    checkedItemIds.refresh();
  }

  void toggleSelectAllAvailable() {
    final activeBranch = selectedBranchId;
    if (activeBranch != null && activeBranch.isNotEmpty) {
      toggleSelectAllAvailableForBranch(activeBranch);
      return;
    }
    final firstAvail = allItems.firstWhereOrNull((i) => i.isAvailable);
    if (firstAvail == null) return;
    toggleSelectAllAvailableForBranch(firstAvail.branchId);
  }

  void toggleSelectAllAvailableForBranch(String branchId) {
    final available = allItems.where((i) => i.branchId == branchId && i.isAvailable).toList();
    if (available.isEmpty) return;

    final activeBranch = selectedBranchId;
    if (activeBranch != null && activeBranch.isNotEmpty && activeBranch != branchId) {
      showDifferentBranchWarning(
        activeBranchName: selectedBranchName ?? 'perpustakaan lain',
        targetBranchName: available.first.branchName,
      );
      return;
    }

    final allChecked = available.every((i) => checkedItemIds.contains(i.id));
    if (allChecked) {
      for (final i in available) {
        checkedItemIds.remove(i.id);
      }
    } else {
      for (final i in available) {
        checkedItemIds.add(i.id);
      }
    }
    checkedItemIds.refresh();
  }

  void clearCheckedItems() {
    checkedItemIds.clear();
    checkedItemIds.refresh();
  }

  // ── Date ──────────────────────────────────────────────────────────────────

  Future<void> pickBorrowDateRange(BuildContext context) async {
    final initialStart = DateUtils.dateOnly(borrowDate.value);
    final initialEnd = DateUtils.dateOnly(returnDate.value);

    final selectedRange = await showDateRangePicker(
      context: context,
      firstDate: DateUtils.dateOnly(DateTime.now().subtract(const Duration(days: 1))),
      lastDate: DateUtils.dateOnly(DateTime.now().add(const Duration(days: 365))),
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
      LuminaToast.warning('Tanggal pengembalian harus setelah tanggal pinjam.');
      return;
    }

    if (duration > maxBorrowDays) {
      returnDate.value = start.add(const Duration(days: maxBorrowDays));
      LuminaToast.warning('Durasi maksimal peminjaman adalah $maxBorrowDays hari.');
      return;
    }

    returnDate.value = end;
  }

  /// Kirim request checkout ke API.
  /// Navigasi ke halaman sukses dilakukan dari [LibraryCheckoutPage]
  /// setelah future ini selesai (returns [CheckoutResultModel] atau null).
  Future<CheckoutResultModel?> confirmBorrowing() async {
    if (!hasCheckedItems) {
      showNoCheckedWarning();
      return null;
    }

    if (!isBorrowRangeValid) {
      LuminaToast.warning('Pastikan durasi peminjaman tidak lebih dari $maxBorrowDays hari.');
      return null;
    }

    final branchId = selectedBranchId;
    if (branchId == null || branchId.isEmpty) {
      LuminaToast.warning('Perpustakaan tidak terdeteksi. Pilih ulang buku dari keranjang.');
      return null;
    }

    isCheckoutLoading.value = true;

    try {
      final service = Get.find<HomeApiService>();
      final result = await service.checkout(
        branchId: branchId,
        cartItemIds: checkedItems.map((i) => i.id).toList(),
        startDate: DateUtils.dateOnly(borrowDate.value),
        endDate: DateUtils.dateOnly(returnDate.value),
      );

      // Hapus item yang sudah di-checkout dari state lokal
      final checkedIds = checkedItemIds.toSet();
      final newGroups = cart.value.groups
          .map((g) => CartGroupModel(
                branch: g.branch,
                items: g.items.where((i) => !checkedIds.contains(i.id)).toList(),
                itemsCount: g.items.where((i) => !checkedIds.contains(i.id)).length,
              ))
          .where((g) => g.items.isNotEmpty)
          .toList();

      cart.value = CartModel(
        id: cart.value.id,
        groups: newGroups,
        totalItems: newGroups.fold(0, (sum, g) => sum + g.itemsCount),
        totalBranches: newGroups.length,
      );
      checkedItemIds.clear();
      checkedItemIds.refresh();

      return result;
    } on LuminaApiException catch (e) {
      LuminaToast.error(e.displayMessage);
      return null;
    } catch (_) {
      LuminaToast.error('Checkout gagal. Silakan coba lagi.');
      return null;
    } finally {
      isCheckoutLoading.value = false;
    }
  }

  // ── Warnings ───────────────────────────────────────────────────────────────

  void showNoCheckedWarning() {
    LuminaToast.warning('Centang minimal satu buku untuk lanjut ke checkout.');
  }

  void showUnavailableBookWarning() {
    LuminaToast.warning('Buku ini sedang tidak tersedia untuk dipinjam.');
  }

  void showDifferentBranchWarning({
    required String activeBranchName,
    required String targetBranchName,
  }) {
    LuminaToast.warning(
      'Anda sudah memilih buku dari $activeBranchName. Hapus pilihan tersebut jika ingin memilih dari $targetBranchName.',
      duration: const Duration(milliseconds: 3000),
    );
  }

  // ── Private ────────────────────────────────────────────────────────────────

  CartItemModel? _findItemById(String id) {
    for (final item in allItems) {
      if (item.id == id) return item;
    }
    return null;
  }
}
