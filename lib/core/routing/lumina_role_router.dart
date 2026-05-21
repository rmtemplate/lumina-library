import 'package:get/get.dart';

import '../../features/mahasiswa/presentation/pages/library_home_page.dart';
import '../../features/staff/presentation/pages/library_staff_home_page.dart';

enum LuminaUserRole {
  mahasiswa,
  staff,
  librarian,
  admin,
}

class LuminaRoleRouter {
  const LuminaRoleRouter._();

  static void navigateAfterLogin(String role) {
    final normalizedRole = role.trim().toUpperCase();

    if (normalizedRole == 'PETUGAS' ||
        normalizedRole == 'STAFF' ||
        normalizedRole == 'LIBRARIAN' ||
        normalizedRole == 'ADMIN') {
      Get.offAll(
        () => const LibraryStaffHomePage(),
        transition: Transition.fadeIn,
      );
      return;
    }

    Get.offAll(
      () => const LibraryHomePage(),
      transition: Transition.fadeIn,
    );
  }
}
