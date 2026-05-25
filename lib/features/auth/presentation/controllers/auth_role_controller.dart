import 'package:get/get.dart';

import 'package:lumina_library/core/routing/lumina_role_router.dart';

class AuthRoleController extends GetxController {
  final Rx<LuminaUserRole> selectedRole = LuminaUserRole.mahasiswa.obs;

  bool get isStaffRole {
    final role = selectedRole.value;
    return role == LuminaUserRole.staff ||
        role == LuminaUserRole.librarian ||
        role == LuminaUserRole.admin;
  }

  void selectRole(LuminaUserRole role) {
    selectedRole.value = role;
  }

  void continueAsSelectedRole() {
    if (isStaffRole) {
      LuminaRoleRouter.goToStaffHome();
      return;
    }

    LuminaRoleRouter.goToMahasiswaHome();
  }
}
