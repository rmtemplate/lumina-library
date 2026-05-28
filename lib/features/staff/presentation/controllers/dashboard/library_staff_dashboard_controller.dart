import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina_library/features/staff/presentation/pages/rack/rack_list_page.dart';

import '../../../../../core/theme/lumina_colors.dart';
import '../../models/staff_dashboard_model.dart';

class LibraryStaffDashboardController extends GetxController {
  static const String avatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuA1po-tORCqikYV7HsBNe5UI4EHzFgRnoAk0TLYuSXvPn_edw-_dVeMvafb9Z6mZO8O9JpLcWADq481YzkpMoXZf18v0NNFks98-FyWjn_HmppUMLmjJl8qKTXfrB9mmiPV8BlY5n4b4Yt6xeCfWi3pn6JRtz0SU5OWELm7dMsiY1_kCMB59IVGB15-wZ-Vs4BxmcCgy22G7dlZKVb1UIxQcv0s32ktfhayAbyIs6V33qIhg9zVr5N0XsklheER8RpuXiPwhMghRCK9';

  final RxString staffName = 'Sarah'.obs;
  final RxString todayText = 'Senin, 12 Agustus 2024'.obs;
  final RxBool hasNotification = true.obs;

  final List<StaffDashboardStatModel> stats = [
    StaffDashboardStatModel(
      id: 'borrowed_books',
      icon: Icons.outbox_rounded,
      label: 'Buku Dipinjam',
      value: '320',
      backgroundColor: LuminaColors.primary,
      foregroundColor: LuminaColors.onPrimary,
    ),
    StaffDashboardStatModel(
      id: 'overdue',
      icon: Icons.warning_rounded,
      label: 'Overdue',
      value: '45',
      backgroundColor: LuminaColors.errorContainer,
      foregroundColor: LuminaColors.onErrorContainer,
      borderColor: LuminaColors.error.withOpacity(0.12),
    ),
  ];

  final List<StaffDashboardActionModel> quickActions = const [
    StaffDashboardActionModel(
      id: 'shelf',
      icon: Icons.inventory_2_rounded,
      label: 'Atur Rak',
    ),
    StaffDashboardActionModel(
      id: 'member',
      icon: Icons.badge_rounded,
      label: 'Member',
    ),
    StaffDashboardActionModel(
      id: 'borrower',
      icon: Icons.assignment_ind_rounded,
      label: 'Peminjam',
    ),
  ];

  final List<StaffDashboardActivityModel> recentActivities = [
    StaffDashboardActivityModel(
      id: 'activity-001',
      icon: Icons.menu_book_rounded,
      iconBackgroundColor: LuminaColors.secondaryContainer.withOpacity(0.20),
      iconColor: LuminaColors.secondary,
      titlePrefix: 'Ahmad',
      highlightText: 'Sapiens',
      titleSuffix: 'meminjam',
      timeText: '2 menit yang lalu',
      highlightItalic: true,
    ),
    StaffDashboardActivityModel(
      id: 'activity-002',
      icon: Icons.assignment_return_rounded,
      iconBackgroundColor: LuminaColors.primaryContainer.withOpacity(0.10),
      iconColor: LuminaColors.primary,
      titlePrefix: 'Siti',
      highlightText: 'Clean Code',
      titleSuffix: 'mengembalikan',
      timeText: '15 menit yang lalu',
      highlightItalic: true,
    ),
    StaffDashboardActivityModel(
      id: 'activity-003',
      icon: Icons.person_add_rounded,
      iconBackgroundColor: LuminaColors.tertiaryContainer.withOpacity(0.10),
      iconColor: LuminaColors.tertiaryContainer,
      titlePrefix: 'Anggota baru',
      highlightText: 'Budi Santoso',
      titleSuffix: 'terdaftar',
      timeText: '1 jam yang lalu',
    ),
  ];

  void handleNotificationTap() {
    Get.snackbar(
      'Notifikasi',
      'Belum ada halaman notifikasi.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  void handleQuickActionTap(StaffDashboardActionModel item) {
    switch(item.label) {
      case 'Atur Rak':
        Get.to(
          () => const RackListPage()
        );
        return;
      default:
        Get.snackbar(
          'Aksi Cepat',
          'Fitur untuk "${item.label}" belum tersedia.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );
    }
  }

  void handleSeeAllActivityTap() {
    Get.snackbar(
      'Recent Activity',
      'Halaman aktivitas lengkap belum tersedia.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }
}