import 'package:get/get.dart';

import 'package:lumina_library/features/mahasiswa/presentation/pages/home/library_home_page.dart';
import 'package:lumina_library/features/staff/presentation/pages/home/library_staff_home_page.dart';

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
      goToStaffHome();
      return;
    }

    goToMahasiswaHome();
  }

  static void goToMahasiswaHome() {
    Get.offAll(
      () => const LibraryHomePage(),
      transition: Transition.fadeIn,
    );
  }

  static void goToStaffHome() {
    Get.offAll(
      () => const LibraryStaffHomePage(),
      transition: Transition.fadeIn,
    );
  }
}
