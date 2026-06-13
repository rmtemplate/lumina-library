import 'package:get/get.dart';

import 'package:lumina_library/features/mahasiswa/presentation/controllers/catalog/library_catalog_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/my_books/library_my_books_controller.dart';

class LibraryHomeController extends GetxController {
  final RxInt selectedNavIndex = 0.obs;

  static const int _catalogTabIndex = 1;
  static const int _myBooksTabIndex = 2;

  void changeNavIndex(int index) {
    if (selectedNavIndex.value == index) return;
    selectedNavIndex.value = index;

    if (index == _catalogTabIndex) {
      // Setiap kali user kembali ke tab Catalog: refresh categories + books
      // dan reset semua filter agar tidak ada state yang nyangkut.
      if (Get.isRegistered<LibraryCatalogController>()) {
        Get.find<LibraryCatalogController>().refresh();
      }
    }

    if (index == _myBooksTabIndex) {
      if (Get.isRegistered<LibraryMyBooksController>()) {
        final myBooksCtrl = Get.find<LibraryMyBooksController>();
        // Reset filter ke "All" agar tidak mewarisi state filter sebelumnya.
        myBooksCtrl.resetFilter();
        // Refresh data pinjaman dari backend.
        myBooksCtrl.refresh();
      }
    }
  }
}
