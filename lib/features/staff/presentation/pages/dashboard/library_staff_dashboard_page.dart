import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';

import 'package:lumina_library/features/staff/presentation/models/staff_dashboard_model.dart';

class LibraryStaffDashboardPage extends StatelessWidget {
  const LibraryStaffDashboardPage({super.key});

  static const String _avatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuA1po-tORCqikYV7HsBNe5UI4EHzFgRnoAk0TLYuSXvPn_edw-_dVeMvafb9Z6mZO8O9JpLcWADq481YzkpMoXZf18v0NNFks98-FyWjn_HmppUMLmjJl8qKTXfrB9mmiPV8BlY5n4b4Yt6xeCfWi3pn6JRtz0SU5OWELm7dMsiY1_kCMB59IVGB15-wZ-Vs4BxmcCgy22G7dlZKVb1UIxQcv0s32ktfhayAbyIs6V33qIhg9zVr5N0XsklheER8RpuXiPwhMghRCK9';

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: LuminaColors.background,
      child: Column(
        children: [
          _StaffTopBar(
            avatarUrl: _avatarUrl,
            onNotificationTap: () {},
          ),

          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                LuminaSpacing.marginMobile,
                LuminaSpacing.lg,
                LuminaSpacing.marginMobile,
                LuminaSpacing.xl,
              ),
              children: [
                const _StaffSectionTitle(title: 'Overview'),
                const SizedBox(height: LuminaSpacing.md),

                const _OverviewStatsGrid(),

                const SizedBox(height: LuminaSpacing.xl),

                const _StaffSectionTitle(title: 'Quick Actions'),
                const SizedBox(height: LuminaSpacing.md),

                _QuickActionsGrid(
                  items: [
                    StaffQuickActionData(
                      icon: Icons.how_to_reg_rounded,
                      title: 'Verifikasi',
                      subtitle: 'Mahasiswa Baru',
                      iconBackgroundColor: LuminaColors.tertiaryContainer,
                      iconColor: LuminaColors.onTertiaryContainer,
                      onTap: () {},
                    ),
                    StaffQuickActionData(
                      icon: Icons.library_books_rounded,
                      title: 'Manajemen',
                      subtitle: 'Katalog Buku',
                      iconBackgroundColor: LuminaColors.secondaryContainer,
                      iconColor: LuminaColors.onSecondaryContainer,
                      onTap: () {},
                    ),
                    StaffQuickActionData(
                      icon: Icons.shelves,
                      title: 'Atur Rak',
                      subtitle: 'Lokasi Fisik',
                      iconBackgroundColor: LuminaColors.surfaceVariant,
                      iconColor: LuminaColors.onSurfaceVariant,
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: LuminaSpacing.xl),

                _StaffSectionTitle(
                  title: 'Recent Activity',
                  actionLabel: 'Lihat Semua',
                  onActionTap: () {},
                ),

                const SizedBox(height: LuminaSpacing.md),

                const _RecentActivityCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffTopBar extends StatelessWidget {
  const _StaffTopBar({
    required this.avatarUrl,
    this.onNotificationTap,
  });

  final String avatarUrl;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LuminaColors.surface,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: LuminaSpacing.marginMobile,
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: LuminaColors.outlineVariant,
                      width: 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: LuminaColors.surfaceContainerLow,
                        child: const Icon(
                          Icons.person_rounded,
                          color: LuminaColors.primary,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: LuminaSpacing.sm),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Library Admin',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LuminaTextStyles.headlineSm.copyWith(
                          color: LuminaColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Librarian Profile',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LuminaTextStyles.labelMd.copyWith(
                          color: LuminaColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),

                InkWell(
                  onTap: onNotificationTap,
                  borderRadius: BorderRadius.circular(LuminaRadius.full),
                  child: Padding(
                    padding: const EdgeInsets.all(LuminaSpacing.xs),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.notifications_none_rounded,
                          color: LuminaColors.onSurfaceVariant,
                          size: 26,
                        ),
                        Positioned(
                          top: 1,
                          right: 1,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: LuminaColors.error,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: LuminaColors.surface,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewStatsGrid extends StatelessWidget {
  const _OverviewStatsGrid();

  @override
  Widget build(BuildContext context) {
    const items = [
      StaffStatData(
        icon: Icons.group_rounded,
        label: 'Total Mahasiswa',
        value: '1.2k',
        variant: StaffStatVariant.light,
      ),
      StaffStatData(
        icon: Icons.menu_book_rounded,
        label: 'Total Buku',
        value: '5.4k',
        variant: StaffStatVariant.light,
      ),
      StaffStatData(
        icon: Icons.outbox_rounded,
        label: 'Buku Dipinjam',
        value: '320',
        variant: StaffStatVariant.primary,
      ),
      StaffStatData(
        icon: Icons.warning_rounded,
        label: 'Buku Terlambat',
        value: '45',
        variant: StaffStatVariant.error,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = LuminaSpacing.md;
        final crossAxisCount = constraints.maxWidth >= 720 ? 4 : 2;
        final itemWidth =
            (constraints.maxWidth - ((crossAxisCount - 1) * spacing)) /
                crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items.map((item) {
            return SizedBox(
              width: itemWidth,
              child: _StaffStatCard(data: item),
            );
          }).toList(),
        );
      },
    );
  }
}

class _StaffStatCard extends StatelessWidget {
  const _StaffStatCard({
    required this.data,
  });

  final StaffStatData data;

  @override
  Widget build(BuildContext context) {
    final config = data.variant.config;

    return Container(
      height: 122,
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(
          color: LuminaColors.outlineVariant.withOpacity(0.30),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                data.icon,
                color: config.labelColor,
                size: 20,
              ),
              const SizedBox(width: LuminaSpacing.xs),
              Expanded(
                child: Text(
                  data.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: config.labelColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            data.value,
            style: LuminaTextStyles.displayLgMobile.copyWith(
              color: config.valueColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({
    required this.items,
  });

  final List<StaffQuickActionData> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = LuminaSpacing.md;
        final crossAxisCount = constraints.maxWidth >= 720 ? 3 : 1;
        final itemWidth =
            (constraints.maxWidth - ((crossAxisCount - 1) * spacing)) /
                crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items.map((item) {
            return SizedBox(
              width: itemWidth,
              child: _QuickActionCard(data: item),
            );
          }).toList(),
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.data,
  });

  final StaffQuickActionData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LuminaColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(LuminaRadius.xl),
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        child: Container(
          padding: const EdgeInsets.all(LuminaSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LuminaRadius.xl),
            border: Border.all(
              color: LuminaColors.outlineVariant.withOpacity(0.30),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: data.iconBackgroundColor,
                  borderRadius: BorderRadius.circular(LuminaRadius.lg),
                ),
                child: Icon(
                  data.icon,
                  color: data.iconColor,
                  size: 25,
                ),
              ),
              const SizedBox(width: LuminaSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LuminaTextStyles.titleLg.copyWith(
                        color: LuminaColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LuminaTextStyles.bodyMd.copyWith(
                        color: LuminaColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard();

  @override
  Widget build(BuildContext context) {
    const activities = [
      StaffActivityData(
        icon: Icons.book_rounded,
        iconColor: LuminaColors.secondary,
        iconBackgroundColor: LuminaColors.secondaryContainer,
        titlePrefix: 'Ahmad',
        actionText: 'meminjam',
        bookTitle: 'Sapiens',
        timeText: '2 menit yang lalu',
      ),
      StaffActivityData(
        icon: Icons.assignment_return_rounded,
        iconColor: LuminaColors.primary,
        iconBackgroundColor: LuminaColors.primaryFixed,
        titlePrefix: 'Siti',
        actionText: 'mengembalikan',
        bookTitle: 'Clean Code',
        timeText: '15 menit yang lalu',
      ),
      StaffActivityData(
        icon: Icons.person_add_rounded,
        iconColor: LuminaColors.tertiaryContainer,
        iconBackgroundColor: LuminaColors.tertiaryFixed,
        titlePrefix: 'Anggota baru',
        actionText: '',
        bookTitle: 'Budi Santoso terdaftar',
        timeText: '1 jam yang lalu',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(
          color: LuminaColors.outlineVariant.withOpacity(0.30),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(activities.length, (index) {
          final item = activities[index];
          final isLast = index == activities.length - 1;

          return _ActivityTile(
            data: item,
            showDivider: !isLast,
          );
        }),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.data,
    required this.showDivider,
  });

  final StaffActivityData data;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final text = data.actionText.isEmpty
        ? '${data.titlePrefix} ${data.bookTitle}'
        : '${data.titlePrefix} ${data.actionText} ${data.bookTitle}';

    return Container(
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: LuminaColors.outlineVariant.withOpacity(0.20),
                  width: 1,
                ),
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(LuminaSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: data.iconBackgroundColor.withOpacity(0.35),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    data.icon,
                    color: data.iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: LuminaSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: LuminaTextStyles.bodyLg.copyWith(
                          color: LuminaColors.onBackground,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        data.timeText,
                        style: LuminaTextStyles.labelMd.copyWith(
                          color: LuminaColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StaffSectionTitle extends StatelessWidget {
  const _StaffSectionTitle({
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: LuminaTextStyles.titleLg.copyWith(
              color: LuminaColors.onBackground,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(
              actionLabel!,
              style: LuminaTextStyles.labelMd.copyWith(
                color: LuminaColors.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
      ],
    );
  }
}

