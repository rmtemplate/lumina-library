import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina_library/features/staff/presentation/pages/profile/staff_profile_page.dart';

import '../../../../../core/theme/lumina_colors.dart';
import '../../../../../core/theme/lumina_spacing.dart';
import '../../controllers/dashboard/library_staff_dashboard_controller.dart';
import '../../widgets/dashboard/library_staff_dashboard_widgets.dart';

class LibraryStaffDashboardPage extends StatelessWidget {
  const LibraryStaffDashboardPage({
    super.key,
  });

  LibraryStaffDashboardController get controller {
    if (Get.isRegistered<LibraryStaffDashboardController>()) {
      return Get.find<LibraryStaffDashboardController>();
    }

    return Get.put(LibraryStaffDashboardController());
  }

  @override
  Widget build(BuildContext context) {
    final dashboardController = controller;

    return ColoredBox(
      color: LuminaColors.background,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1280,
            ),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                top: LuminaSpacing.sm,
                bottom: LuminaSpacing.xl,
              ),
              children: [
                Obx(() {
                  return LibraryStaffDashboardHeader(
                    dateText: dashboardController.todayText.value,
                    staffName: dashboardController.staffName.value,
                    avatarUrl: LibraryStaffDashboardController.avatarUrl,
                    hasNotification:
                        dashboardController.hasNotification.value,
                    onAvatarTap: () {
                      Get.to(StaffProfilePage());
                    },
                  );
                }),

                const SizedBox(height: LuminaSpacing.md),

                LibraryStaffStatGrid(
                  items: dashboardController.stats,
                ),

                const SizedBox(height: LuminaSpacing.md),

                LibraryStaffQuickActionGrid(
                  items: dashboardController.quickActions,
                  onItemTap: dashboardController.handleQuickActionTap,
                ),

                const SizedBox(height: LuminaSpacing.lg),

                LibraryStaffSectionHeader(
                  title: 'Recent Activity',
                  actionLabel: 'Lihat Semua',
                  onActionTap: dashboardController.handleSeeAllActivityTap,
                ),

                const SizedBox(height: LuminaSpacing.md),

                LibraryStaffRecentActivityCard(
                  items: dashboardController.recentActivities,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}