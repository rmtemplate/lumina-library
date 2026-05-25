import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class LibraryBookDetailController extends GetxController {
  final RxBool isSynopsisExpanded = false.obs;
  final RxBool isBookmarked = false.obs;
  final RxBool isInCart = false.obs;

  void toggleSynopsis() {
    isSynopsisExpanded.toggle();
  }

  void toggleBookmark() {
    isBookmarked.toggle();
  }

  void toggleCart() {
    isInCart.toggle();
  }

  void handleBorrowBook() {
    debugPrint('Borrow book tapped');
  }
}
