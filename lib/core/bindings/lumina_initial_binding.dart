import 'package:get/get.dart';

import 'package:lumina_library/features/auth/data/controllers/auth_role_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/cart/library_cart_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/catalog/library_catalog_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/catalog/library_book_detail_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/home/library_dashboard_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/home/library_home_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/library_location/library_location_detail_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/my_books/library_my_books_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/search/library_search_controller.dart';
import 'package:lumina_library/features/staff/presentation/controllers/home/staff_home_controller.dart';
import 'package:lumina_library/features/staff/presentation/controllers/report/staff_report_controller.dart';

class LuminaInitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRoleController>(() => AuthRoleController(), fenix: true);
    Get.lazyPut<LibraryHomeController>(() => LibraryHomeController(), fenix: true);
    Get.lazyPut<LibraryDashboardController>(() => LibraryDashboardController(), fenix: true);
    Get.lazyPut<LibraryCatalogController>(() => LibraryCatalogController(), fenix: true);
    Get.lazyPut<LibraryBookDetailController>(() => LibraryBookDetailController(), fenix: true);
    Get.lazyPut<LibraryMyBooksController>(() => LibraryMyBooksController(), fenix: true);
    Get.lazyPut<LibraryLocationDetailController>(() => LibraryLocationDetailController(), fenix: true);
    Get.lazyPut<LibraryCartController>(() => LibraryCartController(), fenix: true);
    Get.lazyPut<LibrarySearchController>(() => LibrarySearchController(), fenix: true);
    Get.lazyPut<StaffHomeController>(() => StaffHomeController(), fenix: true);
    Get.lazyPut<StaffReportController>(() => StaffReportController(), fenix: true);
  }
}
