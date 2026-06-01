import 'package:get/get.dart';

import 'package:lumina_library/features/mahasiswa/presentation/controllers/my_books/library_my_books_controller.dart';

class LibraryHomeController extends GetxController {
  final RxInt selectedNavIndex = 0.obs;

  /// Index tab My Books di bottom nav.
  static const int _myBooksTabIndex = 2;

  void changeNavIndex(int index) {
    if (selectedNavIndex.value == index) return;
    selectedNavIndex.value = index;

    // Setiap kali user masuk ke tab My Books, reset filter ke "All"
    // agar tidak mewarisi state filter dari sesi atau halaman lain.
    if (index == _myBooksTabIndex &&
        Get.isRegistered<LibraryMyBooksController>()) {
      Get.find<LibraryMyBooksController>().resetFilter();
    }
  }
}
