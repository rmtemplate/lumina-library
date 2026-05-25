import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/features/staff/presentation/controllers/home/staff_home_controller.dart';
import 'package:lumina_library/features/staff/presentation/pages/dashboard/library_staff_dashboard_page.dart';
import 'package:lumina_library/features/staff/presentation/pages/qr_scanner/staff_qr_scanner_page.dart';
import 'package:lumina_library/features/staff/presentation/pages/report/staff_report_page.dart';
import 'package:lumina_library/features/staff/presentation/widgets/navigation/library_staff_bottom_nav_bar.dart';

class LibraryStaffHomePage extends StatelessWidget {
  const LibraryStaffHomePage({super.key});

  StaffHomeController get controller => Get.isRegistered<StaffHomeController>()
      ? Get.find<StaffHomeController>()
      : Get.put(StaffHomeController(), permanent: true);

  Future<void> _goToQrScannerPage(BuildContext context) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const StaffQrScannerPage(),
      ),
    );

    if (result == null || result.trim().isEmpty) return;

    debugPrint('QR scan result: $result');
  }

  Widget _buildCurrentPage(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return const LibraryStaffDashboardPage();
      case 2:
        return const StaffReportPage();
      default:
        return const LibraryStaffDashboardPage();
    }
  }

  void _onNavigationChanged(BuildContext context, int index) {
    if (index == 1) {
      _goToQrScannerPage(context);
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
