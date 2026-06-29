import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/lumina_colors.dart';
import '../../../../../core/theme/lumina_spacing.dart';
import '../../../../../core/theme/lumina_text_styles.dart';
import '../../../data/models/staff_dashboard_summary_model.dart';
import '../../models/staff_dashboard_model.dart';

class LibraryStaffDashboardHeader extends StatelessWidget {
  const LibraryStaffDashboardHeader({
    super.key,
    required this.dateText,
    required this.staffName,
    required this.avatarUrl,
    this.branchName = '',
    this.hasNotification = false,
    this.onAvatarTap,
  });

  final String dateText;
  final String staffName;
  final String avatarUrl;
  final String branchName;
  final bool hasNotification;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        LuminaSpacing.marginMobile,
        LuminaSpacing.md,
        LuminaSpacing.marginMobile,
        LuminaSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateText,
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: LuminaColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Halo, $staffName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LuminaTextStyles.displayLgMobile.copyWith(
                    color: LuminaColors.primary,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: LuminaSpacing.md),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onAvatarTap,
              customBorder: const CircleBorder(),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: LuminaColors.surfaceContainerLowest,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
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
                  if (hasNotification)
                    Positioned(
                      top: 1,
                      right: 1,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: LuminaColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: LuminaColors.background,
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
    );
  }
}

class LibraryStaffStatGrid extends StatelessWidget {
  const LibraryStaffStatGrid({
    super.key,
    required this.items,
  });

  final List<StaffDashboardStatModel> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.marginMobile,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = LuminaSpacing.gutterMobile;
          final itemWidth = (constraints.maxWidth - spacing) / 2;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: items.map((item) {
              return SizedBox(
                width: itemWidth,
                child: LibraryStaffStatCard(item: item),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class LibraryStaffStatCard extends StatelessWidget {
  const LibraryStaffStatCard({
    super.key,
    required this.item,
  });

  final StaffDashboardStatModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 110,
      ),
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: item.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: item.borderColor == null
            ? null
            : Border.all(
                color: item.borderColor!,
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: item.backgroundColor.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                item.icon,
                color: item.foregroundColor.withOpacity(0.78),
                size: 20,
              ),
              const SizedBox(width: LuminaSpacing.xs),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: item.foregroundColor.withOpacity(0.78),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          Text(
            item.value,
            style: LuminaTextStyles.displayLgMobile.copyWith(
              color: item.foregroundColor,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}

class LibraryStaffQuickActionGrid extends StatelessWidget {
  const LibraryStaffQuickActionGrid({
    super.key,
    required this.items,
    this.onItemTap,
  });

  final List<StaffDashboardActionModel> items;
  final ValueChanged<StaffDashboardActionModel>? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.marginMobile,
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == items.length - 1 ? 0 : LuminaSpacing.md,
              ),
              child: LibraryStaffQuickActionCard(
                item: item,
                onTap: () => onItemTap?.call(item),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class LibraryStaffQuickActionCard extends StatelessWidget {
  const LibraryStaffQuickActionCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final StaffDashboardActionModel item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LuminaColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 118,
          ),
          padding: const EdgeInsets.all(LuminaSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: LuminaColors.outlineVariant.withOpacity(0.30),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.045),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: LuminaColors.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  color: LuminaColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(height: LuminaSpacing.sm),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: LuminaTextStyles.labelMd.copyWith(
                  color: LuminaColors.onBackground,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LibraryStaffSectionHeader extends StatelessWidget {
  const LibraryStaffSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.marginMobile,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: LuminaTextStyles.titleLg.copyWith(
                color: LuminaColors.onBackground,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onActionTap,
              style: TextButton.styleFrom(
                foregroundColor: LuminaColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: LuminaSpacing.xs,
                  vertical: LuminaSpacing.xs,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionLabel!,
                style: LuminaTextStyles.labelMd.copyWith(
                  color: LuminaColors.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class LibraryStaffRecentActivityCard extends StatelessWidget {
  const LibraryStaffRecentActivityCard({
    super.key,
    required this.items,
  });

  final List<StaffDashboardActivityModel> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.marginMobile,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: LuminaColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: LuminaColors.outlineVariant.withOpacity(0.30),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: List.generate(items.length, (index) {
            final item = items[index];

            return Container(
              decoration: BoxDecoration(
                border: index == 0
                    ? null
                    : Border(
                        top: BorderSide(
                          color: LuminaColors.outlineVariant.withOpacity(0.20),
                          width: 1,
                        ),
                      ),
              ),
              child: LibraryStaffActivityTile(item: item),
            );
          }),
        ),
      ),
    );
  }
}

class LibraryStaffActivityTile extends StatelessWidget {
  const LibraryStaffActivityTile({
    super.key,
    required this.item,
  });

  final StaffDashboardActivityModel item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(LuminaSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: item.iconColor, size: 21),
              ),
              const SizedBox(width: LuminaSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: item.titlePrefix,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          TextSpan(text: ' ${item.titleSuffix} '),
                          TextSpan(
                            text: item.highlightText,
                            style: TextStyle(
                              fontStyle: item.highlightItalic ? FontStyle.italic : FontStyle.normal,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      style: LuminaTextStyles.bodyMd.copyWith(
                        color: LuminaColors.onBackground,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.timeText,
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
    );
  }
}

// ── Today's Summary ───────────────────────────────────────────────────────────

class LibraryStaffTodaySummaryRow extends StatelessWidget {
  const LibraryStaffTodaySummaryRow({
    super.key,
    required this.todayBorrowings,
    required this.todayReturns,
    required this.awaitingPickup,
    required this.pendingPayments,
  });

  final StaffDashboardStatModel todayBorrowings;
  final StaffDashboardStatModel todayReturns;
  final StaffDashboardStatModel awaitingPickup;
  final StaffDashboardStatModel pendingPayments;

  @override
  Widget build(BuildContext context) {
    final tiles = [todayBorrowings, todayReturns, awaitingPickup, pendingPayments];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.marginMobile),
      child: Container(
        decoration: BoxDecoration(
          color: LuminaColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: LuminaColors.outlineVariant.withOpacity(0.30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: List.generate(tiles.length, (i) {
            final showDivider = i < tiles.length - 1;
            return Expanded(
              child: Container(
                decoration: showDivider
                    ? const BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Color(0x1A000000),
                            width: 1,
                          ),
                        ),
                      )
                    : null,
                child: _TodayTile(stat: tiles[i]),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _TodayTile extends StatelessWidget {
  const _TodayTile({required this.stat});
  final StaffDashboardStatModel stat;

  @override
  Widget build(BuildContext context) {
    final isAlert = stat.borderColor != null;
    final valueColor = isAlert ? LuminaColors.error : LuminaColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LuminaSpacing.md, horizontal: LuminaSpacing.sm),
      child: Column(
        children: [
          Icon(stat.icon, size: 20, color: valueColor.withOpacity(0.70)),
          const SizedBox(height: 6),
          Text(
            stat.value,
            style: LuminaTextStyles.titleLg.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: LuminaTextStyles.labelMd.copyWith(
              color: LuminaColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Charts ────────────────────────────────────────────────────────────────────

class LibraryStaffBorrowingTrendChart extends StatelessWidget {
  const LibraryStaffBorrowingTrendChart({super.key, required this.points});
  final List<StaffTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final maxY = points.map((p) => p.count).fold(0, (a, b) => a > b ? a : b).toDouble();
    final barGroups = points.asMap().entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value.count.toDouble(),
            width: 18,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            gradient: const LinearGradient(
              colors: [LuminaColors.primaryContainer, LuminaColors.primary],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ],
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.marginMobile),
      child: Container(
        height: 200,
        padding: const EdgeInsets.fromLTRB(LuminaSpacing.md, LuminaSpacing.md, LuminaSpacing.md, LuminaSpacing.sm),
        decoration: BoxDecoration(
          color: LuminaColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: LuminaColors.outlineVariant.withOpacity(0.30)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.045), blurRadius: 18, offset: const Offset(0, 8)),
          ],
        ),
        child: BarChart(
          BarChartData(
            maxY: maxY == 0 ? 5 : maxY * 1.25,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(
                color: LuminaColors.outlineVariant.withOpacity(0.25),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => LuminaColors.primary,
                tooltipRoundedRadius: 8,
                getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                  '${rod.toY.toInt()}',
                  const TextStyle(color: LuminaColors.onPrimary, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, _) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= points.length) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        points[idx].label,
                        style: const TextStyle(
                          color: LuminaColors.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: barGroups,
          ),
        ),
      ),
    );
  }
}

class LibraryStaffMonthlyChart extends StatelessWidget {
  const LibraryStaffMonthlyChart({super.key, required this.points});
  final List<StaffTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final maxY = points.map((p) => p.count).fold(0, (a, b) => a > b ? a : b).toDouble();
    final spots = points.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.count.toDouble()))
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.marginMobile),
      child: Container(
        height: 200,
        padding: const EdgeInsets.fromLTRB(LuminaSpacing.md, LuminaSpacing.md, LuminaSpacing.md, LuminaSpacing.sm),
        decoration: BoxDecoration(
          color: LuminaColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: LuminaColors.outlineVariant.withOpacity(0.30)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.045), blurRadius: 18, offset: const Offset(0, 8)),
          ],
        ),
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY == 0 ? 5 : maxY * 1.25,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(
                color: LuminaColors.outlineVariant.withOpacity(0.25),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => LuminaColors.primary,
                tooltipRoundedRadius: 8,
                getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                  '${s.y.toInt()}',
                  const TextStyle(color: LuminaColors.onPrimary, fontWeight: FontWeight.w700, fontSize: 12),
                )).toList(),
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, _) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= points.length) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        points[idx].label,
                        style: const TextStyle(
                          color: LuminaColors.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.35,
                color: LuminaColors.secondary,
                barWidth: 2.5,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                    radius: 4,
                    color: LuminaColors.secondary,
                    strokeWidth: 2,
                    strokeColor: LuminaColors.surfaceContainerLowest,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      LuminaColors.secondary.withOpacity(0.18),
                      LuminaColors.secondary.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LibraryStaffTopCategoriesCard extends StatelessWidget {
  const LibraryStaffTopCategoriesCard({super.key, required this.categories});
  final List<StaffCategoryPoint> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final maxCount = categories.map((c) => c.count).fold(0, (a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.marginMobile),
      child: Container(
        padding: const EdgeInsets.all(LuminaSpacing.md),
        decoration: BoxDecoration(
          color: LuminaColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: LuminaColors.outlineVariant.withOpacity(0.30)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.045), blurRadius: 18, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          children: categories.asMap().entries.map((e) {
            final isLast = e.key == categories.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : LuminaSpacing.sm),
              child: _CategoryBar(point: e.value, maxCount: maxCount),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({required this.point, required this.maxCount});
  final StaffCategoryPoint point;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final ratio = maxCount == 0 ? 0.0 : point.count / maxCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                point.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LuminaTextStyles.bodyMd.copyWith(
                  color: LuminaColors.onBackground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: LuminaSpacing.sm),
            Text(
              '${point.count}',
              style: LuminaTextStyles.labelMd.copyWith(
                color: LuminaColors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: LuminaColors.surfaceContainer,
            valueColor: const AlwaysStoppedAnimation<Color>(LuminaColors.secondary),
          ),
        ),
      ],
    );
  }
}