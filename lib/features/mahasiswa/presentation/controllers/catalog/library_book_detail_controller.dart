import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/features/mahasiswa/data/services/home_api_service.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/cart/library_cart_controller.dart';
import 'package:lumina_library/shared/models/book/book_model.dart';
import 'package:lumina_library/shared/widgets/feedback/lumina_toast.dart';

class LibraryBookDetailController extends GetxController {
  final RxBool isSynopsisExpanded = false.obs;
  final RxBool isBookmarked = false.obs;
  final RxBool isBookmarkLoading = false.obs;
  final RxBool isInCart = false.obs;
  final RxBool isCartLoading = false.obs;
  final RxBool isLoading = false.obs;

  final Rx<BookModel?> currentBook = Rx<BookModel?>(null);

  void setBook(BookModel book) {
    currentBook.value = book;
    isBookmarked.value = book.userContext?.isWishlisted ?? false;
    _syncCartState(book.id);
  }

  void _syncCartState(String bookId) {
    if (Get.isRegistered<LibraryCartController>()) {
      isInCart.value = Get.find<LibraryCartController>().isBookInCart(bookId);
    }
  }

  Future<void> loadBookDetail(String bookId, String branchId) async {
    isLoading.value = true;
    try {
      final service = Get.find<HomeApiService>();
      final book = await service.getBookDetail(bookId, branchId);
      setBook(book);
    } on LuminaApiException catch (_) {
      // keep whatever was already set via setBook
    } catch (_) {
      // keep whatever was already set via setBook
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleBookmark() async {
    final book = currentBook.value;
    if (book == null) return;

    final prev = isBookmarked.value;
    isBookmarked.value = !prev; // optimistic
    isBookmarkLoading.value = true;

    try {
      final newState = await Get.find<HomeApiService>().toggleWishlist(book.id);
      isBookmarked.value = newState;
      LuminaToast.success(
        newState ? 'Ditambahkan ke wishlist' : 'Dihapus dari wishlist',
      );
    } on LuminaApiException catch (e) {
      isBookmarked.value = prev; // rollback
      LuminaToast.error(e.displayMessage);
    } catch (_) {
      isBookmarked.value = prev;
    } finally {
      isBookmarkLoading.value = false;
    }
  }

  Future<void> toggleCart() async {
    final book = currentBook.value;
    if (book == null) return;

    if (isInCart.value) {
      final cartCtrl = Get.find<LibraryCartController>();
      final cartItem = cartCtrl.allItems.firstWhereOrNull((i) => i.bookId == book.id);
      if (cartItem != null) {
        isCartLoading.value = true;
        await cartCtrl.removeItem(cartItem.id);
        isInCart.value = false;
        isCartLoading.value = false;
        LuminaToast.info('Buku dihapus dari keranjang');
      }
      return;
    }

    final branchId = book.branch?.id;
    if (branchId == null || branchId.isEmpty) {
      LuminaToast.warning('Informasi perpustakaan tidak tersedia.');
      return;
    }

    isCartLoading.value = true;
    final cartCtrl = Get.find<LibraryCartController>();
    final success = await cartCtrl.addBook(bookId: book.id, branchId: branchId);
    if (success) isInCart.value = true;
    isCartLoading.value = false;
  }

  void toggleSynopsis() => isSynopsisExpanded.toggle();

  /// Tombol utama "Pinjam Buku":
  /// - Jika buku sudah di keranjang → return false (page navigates to cart).
  /// - Jika belum → tambah ke keranjang, return true (page shows confirmation sheet).
  Future<bool> handleBorrowBook() async {
    final book = currentBook.value;
    if (book == null) return false;

    // Sudah di keranjang — beri sinyal ke page untuk navigasi langsung
    if (isInCart.value) return false;

    final branchId = book.branch?.id;
    if (branchId == null || branchId.isEmpty) {
      LuminaToast.warning('Informasi perpustakaan tidak tersedia.');
      return false;
    }

    isCartLoading.value = true;
    final cartCtrl = Get.find<LibraryCartController>();
    final success = await cartCtrl.addBook(bookId: book.id, branchId: branchId);
    isCartLoading.value = false;

    if (!success) return false;

    isInCart.value = true;
    return true; // buku baru saja ditambahkan → tampilkan bottom sheet
  }
}
