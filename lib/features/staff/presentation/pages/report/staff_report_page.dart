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
                  period: reportController.selectedPeriod.value,
                  onTap: () => _openPeriodSelector(context, reportController),
                ),
                const SizedBox(height: LuminaSpacing.lg),
                const _SummaryCardsGrid(),
                const SizedBox(height: LuminaSpacing.lg),
                _BorrowTrendChartCard(
                  trends: reportController.borrowTrends,
                  onMoreTap: () {},
                ),
                const SizedBox(height: LuminaSpacing.lg),
                _PopularCategoryCard(
                  categories: reportController.popularCategories,
                ),
                const SizedBox(height: LuminaSpacing.lg),
                _MostBorrowedBooksCard(
                  books: reportController.mostBorrowedBooks,
                  onViewAllTap: () {},
                ),
              ],
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

class _SummaryCardsGrid extends StatelessWidget {
  const _SummaryCardsGrid();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _TotalBorrowSummaryCard(),

        SizedBox(height: LuminaSpacing.sm),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _SmallSummaryCard(
                label: 'Aktif',
                value: '342',
                footerIcon: Icons.book_rounded,
                footerText: 'Buku',
              ),
            ),

            SizedBox(width: LuminaSpacing.sm),

            Expanded(
              child: _SmallSummaryCard(
                label: 'Total Denda',
                value: 'Rp 2.450k',
                footerIcon: Icons.payments_rounded,
                footerText: 'Terkumpul',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TotalBorrowSummaryCard extends StatelessWidget {
  const _TotalBorrowSummaryCard();

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
          _UppercaseLabel(
            text: 'Total Peminjaman',
          ),
          const SizedBox(height: LuminaSpacing.base),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  '1,284',
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
                      Icons.trending_up_rounded,
                      color: LuminaColors.onSecondaryContainer,
                      size: 14,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '+12%',
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
      height: 154,
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

class _BorrowTrendChartCard extends StatelessWidget {
  const _BorrowTrendChartCard({
    required this.trends,
    this.onMoreTap,
  });

  final List<BorrowTrendData> trends;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
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
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tren Peminjaman',
                  style: LuminaTextStyles.titleLg.copyWith(
                    color: LuminaColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onMoreTap,
                  customBorder: const CircleBorder(),
                  child: const SizedBox(
                    width: 34,
                    height: 34,
                    child: Icon(
                      Icons.more_horiz_rounded,
                      color: LuminaColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: LuminaSpacing.lg),
          SizedBox(
            height: 148,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: trends.map((item) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: LuminaSpacing.base,
                    ),
                    child: _AnimatedBarItem(data: item),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedBarItem extends StatelessWidget {
  const _AnimatedBarItem({
    required this.data,
  });

  final BorrowTrendData data;

  @override
  Widget build(BuildContext context) {
    final normalizedValue = data.value.clamp(0, 100) / 100;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0,
                end: normalizedValue,
              ),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return FractionallySizedBox(
                  heightFactor: value,
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: data.isHighlighted
                          ? LuminaColors.primary
                          : LuminaColors.surfaceContainerHighest,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(LuminaRadius.sm),
                        topRight: Radius.circular(LuminaRadius.sm),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: LuminaSpacing.xs),
        Text(
          data.day,
          style: LuminaTextStyles.labelMd.copyWith(
            color: data.isHighlighted
                ? LuminaColors.primary
                : LuminaColors.onSurfaceVariant,
            fontWeight: data.isHighlighted ? FontWeight.w900 : FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _PopularCategoryCard extends StatelessWidget {
  const _PopularCategoryCard({
    required this.categories,
  });

  final List<PopularCategoryData> categories;

  @override
  Widget build(BuildContext context) {
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
            'Kategori Paling Populer',
            style: LuminaTextStyles.titleLg.copyWith(
              color: LuminaColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: LuminaSpacing.md),
          ...List.generate(categories.length, (index) {
            final item = categories[index];

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == categories.length - 1 ? 0 : LuminaSpacing.md,
              ),
              child: _CategoryProgressItem(data: item),
            );
          }),
        ],
      ),
    );
  }
}

class _CategoryProgressItem extends StatelessWidget {
  const _CategoryProgressItem({
    required this.data,
  });

  final PopularCategoryData data;

  @override
  Widget build(BuildContext context) {
    final value = data.percentage.clamp(0, 100) / 100;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                data.name,
                style: LuminaTextStyles.bodyMd.copyWith(
                  color: LuminaColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${data.percentage}%',
              style: LuminaTextStyles.bodyMd.copyWith(
                color: LuminaColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: LuminaSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(LuminaRadius.full),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0,
              end: value,
            ),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return LinearProgressIndicator(
                value: animatedValue,
                minHeight: 8,
                backgroundColor: LuminaColors.surfaceContainer,
                valueColor: AlwaysStoppedAnimation<Color>(data.color),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MostBorrowedBooksCard extends StatelessWidget {
  const _MostBorrowedBooksCard({
    required this.books,
    this.onViewAllTap,
  });

  final List<MostBorrowedBookData> books;
  final VoidCallback? onViewAllTap;

  @override
  Widget build(BuildContext context) {
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
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Buku Paling Sering Dipinjam',
                  style: LuminaTextStyles.titleLg.copyWith(
                    color: LuminaColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: onViewAllTap,
                child: Text(
                  'Lihat Semua',
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: LuminaColors.primary,
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.underline,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: LuminaSpacing.sm),
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
    final trendConfig = data.trend.config;

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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            data.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.menu_book_rounded,
                color: LuminaColors.primary,
                size: 28,
              );
            },
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
        Icon(
          trendConfig.icon,
          color: trendConfig.color,
          size: 24,
        ),
      ],
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

  static const List<String> _periods = [
    'Januari 2023',
    'Februari 2023',
    'Maret 2023',
    'April 2023',
    'Mei 2023',
    'Juni 2023',
    'Juli 2023',
    'Agustus 2023',
    'September 2023',
    'Oktober 2023',
    'November 2023',
    'Desember 2023',
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
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _periods.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  color: LuminaColors.surfaceVariant,
                ),
                itemBuilder: (context, index) {
                  final period = _periods[index];
                  final isSelected = selectedPeriod == period;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      period,
                      style: LuminaTextStyles.bodyLg.copyWith(
                        color: isSelected
                            ? LuminaColors.primary
                            : LuminaColors.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w900 : FontWeight.w600,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: LuminaColors.secondary,
                          )
                        : null,
                    onTap: () {
                      Navigator.of(context).pop(period);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

