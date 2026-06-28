import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/features/staff/presentation/controllers/home/staff_home_controller.dart';
import 'package:lumina_library/features/staff/presentation/pages/dashboard/library_staff_dashboard_page.dart';
import 'package:lumina_library/features/staff/presentation/pages/profile/staff_profile_page.dart';
import 'package:lumina_library/features/staff/presentation/pages/report/staff_report_page.dart';
import 'package:lumina_library/features/staff/presentation/pages/scan/staff_scan_page.dart';
import 'package:lumina_library/features/staff/presentation/widgets/navigation/library_staff_bottom_nav_bar.dart';

class LibraryStaffHomePage extends StatelessWidget {
  const LibraryStaffHomePage({super.key});

  StaffHomeController get controller => Get.isRegistered<StaffHomeController>()
      ? Get.find<StaffHomeController>()
      : Get.put(StaffHomeController(), permanent: true);

  Widget _buildCurrentPage(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return const LibraryStaffDashboardPage();
      case 2:
        return const StaffReportPage();
      case 3:
        return const StaffProfilePage();
      default:
        return const LibraryStaffDashboardPage();
    }
  }

  void _onNavigationChanged(BuildContext context, int index) {
    // Index 1 is the center "Scan" action — the Universal QR Scanner is a
    // full-screen flow, not a tab body, so it's pushed instead of swapping
    // the IndexedStack content (selectedIndex stays on whatever tab the
    // staff was on before scanning).
    if (index == 1) {
      Get.to(() => const StaffScanPage());
      return;
    }

    controller.changeIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final staffHomeController = controller;

    return Obx(
      () => Scaffold(
        backgroundColor: LuminaColors.background,
        body: _buildCurrentPage(staffHomeController.selectedIndex.value),
        bottomNavigationBar: LibraryStaffBottomNavBar(
          currentIndex: staffHomeController.selectedIndex.value,
          onChanged: (index) => _onNavigationChanged(context, index),
        ),
      ),
    );
  }
}
