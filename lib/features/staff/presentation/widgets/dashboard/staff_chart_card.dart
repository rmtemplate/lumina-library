import 'package:flutter/material.dart';

import '../../../../../core/theme/lumina_colors.dart';
import '../../../../../core/theme/lumina_spacing.dart';
import '../../../../../core/theme/lumina_text_styles.dart';
import '../../../data/models/staff_dashboard_summary_model.dart';
import 'library_staff_dashboard_widgets.dart';

class StaffChartSection extends StatefulWidget {
  const StaffChartSection({super.key, required this.charts, this.onViewReport});

  final StaffDashboardChartsModel charts;
  final VoidCallback? onViewReport;

  @override
  State<StaffChartSection> createState() => _StaffChartSectionState();
}

class _StaffChartSectionState extends State<StaffChartSection> {
  int _selected = 0;

  static const _tabs = ['7 Hari', '6 Bulan', 'Kategori'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.marginMobile),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_tabs.length, (i) {
                      final selected = _selected == i;
                      return Padding(
                        padding: EdgeInsets.only(
                          right: i < _tabs.length - 1 ? LuminaSpacing.xs : 0,
                        ),
                        child: GestureDetector(
                          onTap: () => setState(() => _selected = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: LuminaSpacing.sm,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? LuminaColors.primary
                                  : LuminaColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? LuminaColors.primary
                                    : LuminaColors.outlineVariant.withOpacity(0.40),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _tabs[i],
                              style: LuminaTextStyles.labelMd.copyWith(
                                color: selected
                                    ? LuminaColors.onPrimary
                                    : LuminaColors.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              if (widget.onViewReport != null) ...[
                const SizedBox(width: LuminaSpacing.xs),
                TextButton(
                  onPressed: widget.onViewReport,
                  style: TextButton.styleFrom(
                    foregroundColor: LuminaColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: LuminaSpacing.xs,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Lihat Laporan',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: LuminaSpacing.sm),

        _chartContent(),
      ],
    );
  }

  Widget _chartContent() {
    switch (_selected) {
      case 0:
        return LibraryStaffBorrowingTrendChart(points: widget.charts.borrowingTrend);
      case 1:
        return LibraryStaffMonthlyChart(points: widget.charts.monthlyBorrowings);
      case 2:
      default:
        return widget.charts.topCategories.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.marginMobile),
                child: Container(
                  padding: const EdgeInsets.all(LuminaSpacing.lg),
                  decoration: BoxDecoration(
                    color: LuminaColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: LuminaColors.outlineVariant.withOpacity(0.30)),
                  ),
                  child: Center(
                    child: Text(
                      'Belum ada data kategori bulan ini.',
                      style: LuminaTextStyles.bodyMd.copyWith(
                        color: LuminaColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              )
            : LibraryStaffTopCategoriesCard(categories: widget.charts.topCategories);
    }
  }
}
