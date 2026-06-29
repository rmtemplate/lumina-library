import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:lumina_library/core/services/websocket/websocket_event.dart';
import 'package:lumina_library/core/services/websocket/websocket_service.dart';
import 'package:lumina_library/features/staff/data/services/staff_api_service.dart';
import 'package:lumina_library/features/staff/presentation/controllers/home/staff_home_controller.dart';
import 'package:lumina_library/features/staff/presentation/pages/member/staff_member_registration_page.dart';
import 'package:lumina_library/features/staff/presentation/pages/scan/staff_scan_page.dart';

import '../../../../../core/theme/lumina_colors.dart';
import '../../../../../shared/widgets/feedback/lumina_toast.dart';
import '../../models/staff_dashboard_model.dart';
import '../../../data/models/staff_dashboard_summary_model.dart';

class LibraryStaffDashboardController extends GetxController {
  static const String avatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuA1po-tORCqikYV7HsBNe5UI4EHzFgRnoAk0TLYuSXvPn_edw-_dVeMvafb9Z6mZO8O9JpLcWADq481YzkpMoXZf18v0NNFks98-FyWjn_HmppUMLmjJl8qKTXfrB9mmiPV8BlY5n4b4Yt6xeCfWi3pn6JRtz0SU5OWELm7dMsiY1_kCMB59IVGB15-wZ-Vs4BxmcCgy22G7dlZKVb1UIxQcv0s32ktfhayAbyIs6V33qIhg9zVr5N0XsklheER8RpuXiPwhMghRCK9';

  final RxString staffName = ''.obs;
  final RxString staffAvatarUrl = avatarUrl.obs;
  final RxString branchName = ''.obs;
  final RxString todayText = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()).obs;
  final RxBool hasNotification = false.obs;
  final RxBool isLoading = true.obs;

  final RxList<StaffDashboardStatModel> stats = <StaffDashboardStatModel>[].obs;
  final RxList<StaffDashboardActivityModel> recentActivities = <StaffDashboardActivityModel>[].obs;
  final RxList<StaffRecentActivityModel> richActivities = <StaffRecentActivityModel>[].obs;
  final RxList<StaffPopularBookModel> popularBooks = <StaffPopularBookModel>[].obs;
  final RxList<StaffRackOverviewModel> rackOverview = <StaffRackOverviewModel>[].obs;
  final Rx<StaffDashboardChartsModel?> charts = Rx<StaffDashboardChartsModel?>(null);

  // ponytail: kept but not rendered in the new page — remove if confirmed unused
  final List<StaffDashboardActionModel> quickActions = const [
    StaffDashboardActionModel(id: 'scan', icon: Icons.qr_code_scanner_rounded, label: 'Scan QR'),
    StaffDashboardActionModel(id: 'borrow', icon: Icons.outbox_rounded, label: 'Borrow Books'),
    StaffDashboardActionModel(id: 'return', icon: Icons.move_to_inbox_rounded, label: 'Return Books'),
    StaffDashboardActionModel(id: 'register_member', icon: Icons.person_add_rounded, label: 'Register Member'),
    StaffDashboardActionModel(id: 'reports', icon: Icons.analytics_rounded, label: 'Reports'),
  ];

  StreamSubscription<WebSocketEvent>? _wsSubscription;
  String? _branchId;

  @override
  void onInit() {
    super.onInit();
    staffName.value = 'Staff';
    _loadDashboard();
  }

  @override
  void onClose() {
    _wsSubscription?.cancel();
    super.onClose();
  }

  Future<void> _loadDashboard() async {
    isLoading.value = true;
    try {
      final summary = await Get.find<StaffApiService>().getDashboard();
      staffName.value = summary.staffFirstName;
      branchName.value = summary.branchName;
      if (summary.staffAvatarUrl?.isNotEmpty == true) {
        staffAvatarUrl.value = summary.staffAvatarUrl!;
      }
      _branchId = summary.branchId;
      charts.value = summary.charts;

      richActivities.assignAll(summary.recentActivities);
      popularBooks.assignAll(summary.popularBooks);
      rackOverview.assignAll(summary.rackOverview);

      stats.assignAll([
        StaffDashboardStatModel(
          id: 'total_books',
          icon: Icons.menu_book_rounded,
          label: 'Total Buku',
          value: '${summary.totalBooksCount}',
          backgroundColor: LuminaColors.primary,
          foregroundColor: LuminaColors.onPrimary,
        ),
        StaffDashboardStatModel(
          id: 'available_books',
          icon: Icons.book_online_rounded,
          label: 'Buku Tersedia',
          value: '${summary.availableBooksCount}',
          backgroundColor: LuminaColors.secondaryContainer,
          foregroundColor: LuminaColors.onSecondaryContainer,
        ),
        StaffDashboardStatModel(
          id: 'active_borrowings',
          icon: Icons.outbox_rounded,
          label: 'Dipinjam Aktif',
          value: '${summary.activeCount}',
          backgroundColor: LuminaColors.primaryContainer,
          foregroundColor: LuminaColors.onPrimaryContainer,
        ),
        StaffDashboardStatModel(
          id: 'today_borrowings',
          icon: Icons.today_rounded,
          label: 'Pinjam Hari Ini',
          value: '${summary.todayBorrowingsCount}',
          backgroundColor: LuminaColors.primaryContainer,
          foregroundColor: LuminaColors.onPrimaryContainer,
        ),
        StaffDashboardStatModel(
          id: 'today_returns',
          icon: Icons.assignment_return_rounded,
          label: 'Kembali Hari Ini',
          value: '${summary.returnedTodayCount}',
          backgroundColor: LuminaColors.secondaryContainer,
          foregroundColor: LuminaColors.onSecondaryContainer,
        ),
        StaffDashboardStatModel(
          id: 'awaiting_pickup',
          icon: Icons.hourglass_top_rounded,
          label: 'Menunggu Ambil',
          value: '${summary.awaitingPickupCount}',
          backgroundColor: LuminaColors.tertiaryContainer,
          foregroundColor: LuminaColors.onTertiaryContainer,
        ),
        StaffDashboardStatModel(
          id: 'overdue',
          icon: Icons.warning_rounded,
          label: 'Terlambat',
          value: '${summary.overdueCount}',
          backgroundColor: LuminaColors.errorContainer,
          foregroundColor: LuminaColors.onErrorContainer,
          borderColor: LuminaColors.error.withOpacity(0.12),
        ),
        StaffDashboardStatModel(
          id: 'pending_payments',
          icon: Icons.payments_rounded,
          label: 'Pembayaran Pending',
          value: '${summary.pendingPaymentsCount}',
          backgroundColor: LuminaColors.errorContainer,
          foregroundColor: LuminaColors.onErrorContainer,
          borderColor: LuminaColors.error.withOpacity(0.12),
        ),
        StaffDashboardStatModel(
          id: 'members',
          icon: Icons.group_rounded,
          label: 'Total Anggota',
          value: '${summary.registeredMembersCount}',
          backgroundColor: LuminaColors.primary,
          foregroundColor: LuminaColors.onPrimary,
        ),
      ]);

      recentActivities.assignAll(summary.recentActivities.map((activity) => StaffDashboardActivityModel(
            id: activity.borrowingId,
            icon: _iconForStatus(activity.status),
            iconBackgroundColor: _colorForStatus(activity.status).withOpacity(0.12),
            iconColor: _colorForStatus(activity.status),
            titlePrefix: activity.memberName,
            highlightText: activity.borrowingCode,
            titleSuffix: '· ${activity.itemsCount} buku',
            timeText: _labelForStatus(activity.status),
            highlightItalic: true,
          )));

      _listenToRealtimeEvents();
    } catch (_) {
      // Keep showing whatever was last loaded (or empty state) — the page
      // itself doesn't block on this, and a toast here would be noisy on
      // every WS-triggered silent refresh.
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDashboard() => _loadDashboard();

  IconData _iconForStatus(String status) => switch (status) {
        'awaiting_pickup' => Icons.hourglass_top_rounded,
        'active' => Icons.menu_book_rounded,
        'overdue' => Icons.warning_rounded,
        'waiting_payment' => Icons.payments_rounded,
        'returned' => Icons.assignment_return_rounded,
        _ => Icons.circle_notifications_rounded,
      };

  Color _colorForStatus(String status) => switch (status) {
        'overdue' || 'waiting_payment' => LuminaColors.error,
        'returned' => LuminaColors.secondary,
        _ => LuminaColors.primary,
      };

  String _labelForStatus(String status) => switch (status) {
        'awaiting_pickup' => 'Menunggu pengambilan',
        'active' => 'Sedang dipinjam',
        'overdue' => 'Terlambat',
        'waiting_payment' => 'Menunggu pembayaran',
        'returned' => 'Sudah dikembalikan',
        _ => status,
      };

  /// Subscribes to this branch's realtime channel so the dashboard updates
  /// automatically on any borrow/return/payment/registration event —
  /// no polling, no manual refresh. Branch ID only becomes known after the
  /// first successful dashboard fetch, so this is wired up there rather
  /// than in onInit().
  void _listenToRealtimeEvents() {
    if (_wsSubscription != null) return;
    if (!Get.isRegistered<WebSocketService>()) return;
    if (_branchId == null || _branchId!.isEmpty) return;

    Get.find<WebSocketService>().subscribeToPrivateChannel('branch.$_branchId');

    _wsSubscription = Get.find<WebSocketService>().events.listen((event) {
      switch (event.name) {
        case 'borrow.success':
        case 'return.success':
        case 'payment.success':
        case 'member.registered':
        case 'book.registered':
        case 'pickup.success':
          unawaited(_loadDashboard());
      }
    });
  }

  void handleNotificationTap() {
    LuminaToast.info('Halaman notifikasi staff belum tersedia.');
  }

  void handleQuickActionTap(StaffDashboardActionModel item) {
    switch (item.id) {
      case 'scan':
      case 'borrow':
      case 'return':
        Get.to(() => const StaffScanPage());
        return;
      case 'register_member':
        Get.to(() => const StaffMemberRegistrationPage());
        return;
      case 'reports':
        if (Get.isRegistered<StaffHomeController>()) {
          Get.find<StaffHomeController>().changeIndex(2);
        }
        return;
      default:
        LuminaToast.info('Fitur "${item.label}" belum tersedia.');
    }
  }

  void handleSeeAllActivityTap() {
    if (Get.isRegistered<StaffHomeController>()) {
      Get.find<StaffHomeController>().changeIndex(2);
    }
  }
}
