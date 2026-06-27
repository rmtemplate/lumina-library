import 'package:get/get.dart';

import 'package:lumina_library/core/network/lumina_api_client.dart';
import 'package:lumina_library/core/services/websocket/websocket_service.dart';
import 'package:lumina_library/features/auth/data/controllers/auth_role_controller.dart';
import 'package:lumina_library/features/auth/data/services/auth_api_service.dart';
import 'package:lumina_library/features/mahasiswa/data/services/home_api_service.dart';
import 'package:lumina_library/features/mahasiswa/data/services/payment_api_service.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/cart/library_cart_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/catalog/library_catalog_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/catalog/library_book_detail_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/home/library_dashboard_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/home/library_home_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/library_location/library_location_detail_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/my_books/library_my_books_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/notification/library_notification_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/search/library_search_controller.dart';
import 'package:lumina_library/features/staff/presentation/controllers/home/staff_home_controller.dart';
import 'package:lumina_library/features/staff/presentation/controllers/report/staff_report_controller.dart';

class LuminaInitialBinding extends Bindings {
  @override
  void dependencies() {
    // ── Network & Auth ─────────────────────────────────────────────────────
    Get.put(const LuminaApiClient(), permanent: true);
    Get.put(WebSocketService(), permanent: true);
    Get.put(
      AuthApiService(Get.find<LuminaApiClient>()),
      permanent: true,
    );
    Get.put(
      HomeApiService(Get.find<LuminaApiClient>()),
      permanent: true,
    );
    Get.put(
      PaymentApiService(Get.find<LuminaApiClient>()),
      permanent: true,
    );

    // ── Feature controllers ────────────────────────────────────────────────
    Get.lazyPut<AuthRoleController>(() => AuthRoleController(), fenix: true);
    Get.lazyPut<LibraryHomeController>(() => LibraryHomeController(), fenix: true);
    Get.lazyPut<LibraryDashboardController>(() => LibraryDashboardController(), fenix: true);
    Get.lazyPut<LibraryCatalogController>(() => LibraryCatalogController(), fenix: true);
    Get.lazyPut<LibraryBookDetailController>(() => LibraryBookDetailController(), fenix: true);
    Get.lazyPut<LibraryMyBooksController>(() => LibraryMyBooksController(), fenix: true);
    Get.lazyPut<LibraryLocationDetailController>(() => LibraryLocationDetailController(), fenix: true);
    Get.lazyPut<LibraryCartController>(() => LibraryCartController(), fenix: true);
    Get.lazyPut<LibrarySearchController>(() => LibrarySearchController(), fenix: true);
    Get.lazyPut<LibraryNotificationController>(() => LibraryNotificationController(), fenix: true);
    Get.lazyPut<StaffHomeController>(() => StaffHomeController(), fenix: true);
    Get.lazyPut<StaffReportController>(() => StaffReportController(), fenix: true);
  }
}
