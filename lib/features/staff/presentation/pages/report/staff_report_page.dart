import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/staff/presentation/controllers/report/staff_report_controller.dart';
import 'package:lumina_library/features/staff/presentation/models/staff_report_model.dart';

class StaffReportPage extends StatelessWidget {
  const StaffReportPage({super.key});

  StaffReportController get controller => Get.isRegistered<StaffReportController>()
      ? Get.find<StaffReportController>()
      : Get.put(StaffReportController(), permanent: true);

  Future<void> _openPeriodSelector(
    BuildContext context,
    StaffReportController reportController,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _PeriodSelectorSheet(
          selectedPeriod: reportController.selectedPeriod.value,
        );
      },
    );

    if (selected == null || selected.isEmpty) return;
    reportController.setSelectedPeriod(selected);
  }

  @override
  Widget build(BuildContext context) {
    final reportController = controller;

    return Obx(
      () => SizedBox.expand(
        child: ColoredBox(
          color: LuminaColors.background,
          child: SafeArea(
            top: false,
            bottom: false,
            child: RefreshIndicator(
              onRefresh: reportController.reload,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  LuminaSpacing.marginMobile,
                  LuminaSpacing.lg,
                  LuminaSpacing.marginMobile,
                  LuminaSpacing.xl,
                ),
                children: [
                  const _ReportHeader(
                    title: 'Laporan Statistik',
                    subtitle: 'Ringkasan performa perpustakaan',
                  ),
                  const SizedBox(height: LuminaSpacing.lg),
                  _PeriodSelectorCard(
                    period: reportController.periodLabel,
                    onTap: () => _openPeriodSelector(context, reportController),
                  ),
                  const SizedBox(height: LuminaSpacing.lg),
                  if (reportController.isLoading.value)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: LuminaSpacing.xl),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else ...[
                    _SummaryCardsGrid(controller: reportController),
                    const SizedBox(height: LuminaSpacing.lg),
                    _PaymentMemberSummaryGrid(controller: reportController),
                    const SizedBox(height: LuminaSpacing.lg),
                    _BookStatusChart(controller: reportController),
                    const SizedBox(height: LuminaSpacing.lg),
                    _TopBooksProgressCard(controller: reportController),
                    const SizedBox(height: LuminaSpacing.lg),
                    _MostBorrowedBooksCard(
                      controller: reportController,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportHeader extends StatelessWidget {
  const _ReportHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: LuminaTextStyles.headlineMd.copyWith(
            color: LuminaColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: LuminaSpacing.base),
        Text(
          subtitle,
          style: LuminaTextStyles.bodyMd.copyWith(
            color: LuminaColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PeriodSelectorCard extends StatelessWidget {
  const _PeriodSelectorCard({
    required this.period,
    required this.onTap,
  });

  final String period;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LuminaColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(LuminaRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        child: Container(
          padding: const EdgeInsets.all(LuminaSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LuminaRadius.xl),
            border: Border.all(
              color: LuminaColors.outlineVariant,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: LuminaColors.onSurfaceVariant,
                size: 22,
              ),
              const SizedBox(width: LuminaSpacing.sm),
              Expanded(
                child: Text(
                  period,
                  style: LuminaTextStyles.bodyMd.copyWith(
                    color: LuminaColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.expand_more_rounded,
                color: LuminaColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Borrow / Return / Overdue Report — driven by the backend's `loans` +
/// `returns` sections.
class _SummaryCardsGrid extends StatelessWidget {
  const _SummaryCardsGrid({required this.controller});

  final StaffReportController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TotalBorrowSummaryCard(controller: controller),
        const SizedBox(height: LuminaSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _SmallSummaryCard(
                label: 'Overdue',
                value: '${controller.overdueLoans}',
                footerIcon: Icons.warning_rounded,
                footerText: 'Borrowing',
              ),
            ),
            const SizedBox(width: LuminaSpacing.sm),
            Expanded(
              child: _SmallSummaryCard(
                label: 'On-Time Return',
                value: '${controller.onTimeReturnPct.toStringAsFixed(0)}%',
                footerIcon: Icons.assignment_turned_in_rounded,
                footerText: '${controller.totalReturns} returns',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Payment Report + Member Report — driven by `payments` + `members`.
class _PaymentMemberSummaryGrid extends StatelessWidget {
  const _PaymentMemberSummaryGrid({required this.controller});

  final StaffReportController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _SmallSummaryCard(
            label: 'Unpaid Fines',
            value: controller.totalUnpaidFinesText,
            footerIcon: Icons.payments_rounded,
            footerText: '${controller.pendingPaymentsCount} pending',
          ),
        ),
        const SizedBox(width: LuminaSpacing.sm),
        Expanded(
          child: _SmallSummaryCard(
            label: 'New Members',
            value: '${controller.newMembersInPeriod}',
            footerIcon: Icons.group_rounded,
            footerText: '${controller.totalMembers} total',
          ),
        ),
      ],
    );
  }
}

class _TotalBorrowSummaryCard extends StatelessWidget {
  const _TotalBorrowSummaryCard({required this.controller});

  final StaffReportController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(
          color: LuminaColors.outlineVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _UppercaseLabel(text: 'Total Peminjaman'),
          const SizedBox(height: LuminaSpacing.base),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  '${controller.totalLoans}',
                  style: LuminaTextStyles.displayLgMobile.copyWith(
                    color: LuminaColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: LuminaSpacing.xs,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: LuminaColors.secondaryContainer.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(LuminaRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      color: LuminaColors.onSecondaryContainer,
                      size: 14,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${controller.activeLoans} aktif',
                      style: LuminaTextStyles.labelMd.copyWith(
                        color: LuminaColors.onSecondaryContainer,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallSummaryCard extends StatelessWidget {
  const _SmallSummaryCard({
    required this.label,
    required this.value,
    required this.footerIcon,
    required this.footerText,
  });

  final String label;
  final String value;
  final IconData footerIcon;
  final String footerText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 134,
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(
          color: LuminaColors.outlineVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UppercaseLabel(text: label),
          const SizedBox(height: LuminaSpacing.xs),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: LuminaTextStyles.headlineMd.copyWith(
              color: LuminaColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                footerIcon,
                color: LuminaColors.onSurfaceVariant,
                size: 15,
              ),
              const SizedBox(width: LuminaSpacing.xs),
              Expanded(
                child: Text(
                  footerText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: LuminaColors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Book Report — most-borrowed list, with client-side search by title.
class _MostBorrowedBooksCard extends StatefulWidget {
  const _MostBorrowedBooksCard({required this.controller});

  final StaffReportController controller;

  @override
  State<_MostBorrowedBooksCard> createState() => _MostBorrowedBooksCardState();
}

class _MostBorrowedBooksCardState extends State<_MostBorrowedBooksCard> {
  @override
  Widget build(BuildContext context) {
    final books = widget.controller.mostBorrowedBooks;

    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.lg),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(
          color: LuminaColors.outlineVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Buku Paling Sering Dipinjam',
            style: LuminaTextStyles.titleLg.copyWith(
              color: LuminaColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: LuminaSpacing.sm),
          TextField(
            onChanged: (value) => setState(() => widget.controller.setSearchQuery(value)),
            decoration: InputDecoration(
              hintText: 'Cari judul buku...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              isDense: true,
              filled: true,
              fillColor: LuminaColors.surfaceContainerLow,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(LuminaRadius.md), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: LuminaSpacing.md),
          if (books.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: LuminaSpacing.md),
              child: Text(
                'Tidak ada data untuk periode ini.',
                style: LuminaTextStyles.bodyMd.copyWith(color: LuminaColors.onSurfaceVariant),
              ),
            )
          else
            ...List.generate(books.length, (index) {
              final book = books[index];

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == books.length - 1 ? 0 : LuminaSpacing.md,
                ),
                child: _MostBorrowedBookTile(data: book),
              );
            }),
        ],
      ),
    );
  }
}

class _MostBorrowedBookTile extends StatelessWidget {
  const _MostBorrowedBookTile({
    required this.data,
  });

  final MostBorrowedBookData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 64,
          decoration: BoxDecoration(
            color: LuminaColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(LuminaRadius.sm),
            border: Border.all(
              color: LuminaColors.outlineVariant,
              width: 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: const Icon(
            Icons.menu_book_rounded,
            color: LuminaColors.primary,
            size: 28,
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
                style: LuminaTextStyles.bodyLg.copyWith(
                  color: LuminaColors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${data.borrowCount} Peminjaman',
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
    );
  }
}

// ── Charts ────────────────────────────────────────────────────────────────────

class _BookStatusChart extends StatelessWidget {
  const _BookStatusChart({required this.controller});
  final StaffReportController controller;

  static const _statusColors = {
    'available': LuminaColors.secondary,
    'borrowed': LuminaColors.primary,
    'overdue': LuminaColors.error,
    'reserved': LuminaColors.onTertiaryContainer,
    'maintenance': LuminaColors.onSurfaceVariant,
  };

  static const _statusLabels = {
    'available': 'Tersedia',
    'borrowed': 'Dipinjam',
    'overdue': 'Terlambat',
    'reserved': 'Dipesan',
    'maintenance': 'Perawatan',
  };

  @override
  Widget build(BuildContext context) {
    final breakdown = controller.bookItemStatusBreakdown;
    if (breakdown.isEmpty) return const SizedBox.shrink();

    final entries = breakdown.entries.toList();
    final maxY = entries.map((e) => e.value).fold(0, (a, b) => a > b ? a : b).toDouble();

    final groups = entries.asMap().entries.map((e) {
      final color = _statusColors[e.value.key] ?? LuminaColors.onSurfaceVariant;
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value.value.toDouble(),
            width: 24,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            color: color,
          ),
        ],
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.lg),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(color: LuminaColors.outlineVariant),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Buku',
            style: LuminaTextStyles.titleLg.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: LuminaSpacing.md),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxY == 0 ? 5 : maxY * 1.3,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: LuminaColors.outlineVariant.withOpacity(0.25), strokeWidth: 1),
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
                      reservedSize: 32,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= entries.length) return const SizedBox.shrink();
                        final key = entries[idx].key;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _statusLabels[key] ?? key,
                            style: const TextStyle(
                              color: LuminaColors.onSurfaceVariant,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: groups,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBooksProgressCard extends StatelessWidget {
  const _TopBooksProgressCard({required this.controller});
  final StaffReportController controller;

  @override
  Widget build(BuildContext context) {
    final books = controller.mostBorrowedBooks.take(5).toList();
    if (books.isEmpty) return const SizedBox.shrink();

    final maxCount = books.map((b) => b.borrowCount).fold(0, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.lg),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(color: LuminaColors.outlineVariant),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top 5 Buku Terpopuler',
            style: LuminaTextStyles.titleLg.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: LuminaSpacing.md),
          ...books.asMap().entries.map((e) {
            final book = e.value;
            final ratio = maxCount == 0 ? 0.0 : book.borrowCount / maxCount;
            final isLast = e.key == books.length - 1;

            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : LuminaSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          book.title,
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
                        '${book.borrowCount}×',
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
                      valueColor: const AlwaysStoppedAnimation<Color>(LuminaColors.primary),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _UppercaseLabel extends StatelessWidget {
  const _UppercaseLabel({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: LuminaTextStyles.labelMd.copyWith(
        color: LuminaColors.onSurfaceVariant,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _PeriodSelectorSheet extends StatelessWidget {
  const _PeriodSelectorSheet({
    required this.selectedPeriod,
  });

  final String selectedPeriod;

  static const List<({String value, String label})> _periods = [
    (value: 'week', label: 'This Week'),
    (value: 'month', label: 'This Month'),
    (value: 'year', label: 'This Year'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        LuminaSpacing.marginMobile,
        LuminaSpacing.lg,
        LuminaSpacing.marginMobile,
        LuminaSpacing.marginMobile,
      ),
      decoration: const BoxDecoration(
        color: LuminaColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(LuminaRadius.xl),
          topRight: Radius.circular(LuminaRadius.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: LuminaColors.outlineVariant,
                borderRadius: BorderRadius.circular(LuminaRadius.full),
              ),
            ),
            const SizedBox(height: LuminaSpacing.lg),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pilih Periode',
                style: LuminaTextStyles.headlineSm.copyWith(
                  color: LuminaColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: LuminaSpacing.md),
            ..._periods.map((period) {
              final isSelected = selectedPeriod == period.value;

              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  period.label,
                  style: LuminaTextStyles.bodyLg.copyWith(
                    color: isSelected ? LuminaColors.primary : LuminaColors.onSurface,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  ),
                ),
                trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: LuminaColors.secondary) : null,
                onTap: () => Navigator.of(context).pop(period.value),
              );
            }),
          ],
        ),
      ),
    );
  }
}
