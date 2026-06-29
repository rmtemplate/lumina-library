import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina_library/features/staff/presentation/pages/profile/staff_profile_page.dart';

import '../../../../../core/theme/lumina_colors.dart';
import '../../../../../core/theme/lumina_spacing.dart';
import '../../controllers/dashboard/library_staff_dashboard_controller.dart';
import '../../widgets/dashboard/staff_chart_card.dart';
import '../../widgets/dashboard/staff_dashboard_header.dart';
import '../../widgets/dashboard/staff_popular_book_card.dart';
import '../../widgets/dashboard/staff_rack_overview_card.dart';
import '../../widgets/dashboard/staff_recent_activity_card.dart';
import '../../widgets/dashboard/staff_statistic_card.dart';

class LibraryStaffDashboardPage extends StatelessWidget {
  const LibraryStaffDashboardPage({super.key});

  LibraryStaffDashboardController get controller {
    if (Get.isRegistered<LibraryStaffDashboardController>()) {
      return Get.find<LibraryStaffDashboardController>();
    }
    return Get.put(LibraryStaffDashboardController());
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return ColoredBox(
      color: LuminaColors.background,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: RefreshIndicator(
            onRefresh: c.refreshDashboard,
            child: Obx(() {
              final isLoading = c.isLoading.value;
              final charts = c.charts.value;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  // ── Header (consumes safe area internally) ────────────
                  SliverToBoxAdapter(
                    child: StaffDashboardHeader(
                      staffName: c.staffName.value,
                      branchName: c.branchName.value,
                      dateText: c.todayText.value,
                      avatarUrl: c.staffAvatarUrl.value,
                      hasNotification: c.hasNotification.value,
                      onAvatarTap: () => Get.to(StaffProfilePage()),
                      onNotificationTap: c.handleNotificationTap,
                    ),
                  ),

                  // ── Loading indicator ─────────────────────────────────
                  if (isLoading)
                    const SliverToBoxAdapter(
                      child: LinearProgressIndicator(minHeight: 2),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: LuminaSpacing.md)),

                  // ── Statistics ────────────────────────────────────────
                  SliverToBoxAdapter(child: _SectionLabel(title: 'Statistik Hari Ini')),
                  const SliverToBoxAdapter(child: SizedBox(height: LuminaSpacing.sm)),
                  SliverToBoxAdapter(
                    child: StaffStatisticRow(items: c.stats),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: LuminaSpacing.md)),

                  // ── Charts ────────────────────────────────────────────
                  if (charts != null) ...[
                    SliverToBoxAdapter(child: _SectionLabel(title: 'Analitik')),
                    const SliverToBoxAdapter(child: SizedBox(height: LuminaSpacing.sm)),
                    SliverToBoxAdapter(
                      child: StaffChartSection(charts: charts),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: LuminaSpacing.md)),
                  ],

                  // ── Popular Books ─────────────────────────────────────
                  if (c.popularBooks.isNotEmpty) ...[
                    SliverToBoxAdapter(child: _SectionLabel(title: 'Buku Populer')),
                    const SliverToBoxAdapter(child: SizedBox(height: LuminaSpacing.sm)),
                    SliverToBoxAdapter(
                      child: StaffPopularBooksSection(books: c.popularBooks),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: LuminaSpacing.md)),
                  ],

                  // ── Rack Overview ─────────────────────────────────────
                  if (c.rackOverview.isNotEmpty) ...[
                    SliverToBoxAdapter(child: _SectionLabel(title: 'Ikhtisar Rak')),
                    const SliverToBoxAdapter(child: SizedBox(height: LuminaSpacing.sm)),
                    SliverToBoxAdapter(
                      child: StaffRackOverviewSection(racks: c.rackOverview),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: LuminaSpacing.md)),
                  ],

                  // ── Recent Activity ───────────────────────────────────
                  SliverToBoxAdapter(
                    child: _SectionLabel(
                      title: 'Aktivitas Terkini',
                      trailing: TextButton(
                        onPressed: c.handleSeeAllActivityTap,
                        style: TextButton.styleFrom(
                          foregroundColor: LuminaColors.primary,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Lihat Semua',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: LuminaColors.primary,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: LuminaSpacing.sm)),
                  SliverToBoxAdapter(
                    child: StaffRecentActivitySection(activities: c.richActivities),
                  ),

                  // ── Bottom padding (nav bar safe area) ────────────────
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: LuminaSpacing.xl + MediaQuery.of(context).padding.bottom,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.marginMobile),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: LuminaColors.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          if (trailing != null) ...[const Spacer(), trailing!],
        ],
      ),
    );
  }
}
