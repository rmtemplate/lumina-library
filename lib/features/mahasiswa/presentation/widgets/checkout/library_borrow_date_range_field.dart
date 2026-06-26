import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/shared/widgets/feedback/lumina_toast.dart';

class LibraryBorrowDateRangeField extends StatelessWidget {
  const LibraryBorrowDateRangeField({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onChanged,
    this.maxRangeDays = 14,
    this.allowBackdate = false,
    this.title = 'Periode Peminjaman',
    this.subtitle = 'Pilih tanggal pinjam dan tanggal pengembalian',
    this.enabled = true,
  });

  final DateTime startDate;
  final DateTime endDate;
  final ValueChanged<DateTimeRange> onChanged;

  final int maxRangeDays;
  final bool allowBackdate;
  final String title;
  final String subtitle;
  final bool enabled;

  DateTime _dateOnly(DateTime value) {
    return DateUtils.dateOnly(value);
  }

  String _formatShortDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();

    return '$day/$month/$year';
  }

  String _formatLongDate(DateTime value) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    final day = value.day.toString().padLeft(2, '0');
    final month = months[value.month - 1];
    final year = value.year.toString();

    return '$day $month $year';
  }

  int _durationDays(DateTime start, DateTime end) {
    return _dateOnly(end).difference(_dateOnly(start)).inDays;
  }

  Future<void> _openDateRangePicker(BuildContext context) async {
    if (!enabled) return;

    final today = _dateOnly(DateTime.now());
    final minimumDate = allowBackdate ? today.subtract(const Duration(days: 365)) : today;
    final maximumDate = today.add(const Duration(days: 365));

    final safeStart = _dateOnly(startDate).isBefore(minimumDate)
        ? minimumDate
        : _dateOnly(startDate);

    var safeEnd = _dateOnly(endDate);

    if (!safeEnd.isAfter(safeStart)) {
      safeEnd = safeStart.add(const Duration(days: 1));
    }

    final maxAllowedEndDate = safeStart.add(Duration(days: maxRangeDays));

    if (safeEnd.isAfter(maxAllowedEndDate)) {
      safeEnd = maxAllowedEndDate;
    }

    final selectedRange = await showDateRangePicker(
      context: context,
      firstDate: minimumDate,
      lastDate: maximumDate,
      initialDateRange: DateTimeRange(
        start: safeStart,
        end: safeEnd,
      ),
      helpText: 'Pilih Periode Peminjaman',
      saveText: 'Pilih',
      cancelText: 'Batal',
      fieldStartLabelText: 'Tanggal Pinjam',
      fieldEndLabelText: 'Tanggal Kembali',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: LuminaColors.primary,
                  secondary: LuminaColors.secondary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (selectedRange == null) return;

    final selectedStart = _dateOnly(selectedRange.start);
    var selectedEnd = _dateOnly(selectedRange.end);

    if (!allowBackdate && selectedStart.isBefore(today)) {
      LuminaToast.warning('Tanggal pinjam tidak boleh sebelum hari ini.');
      return;
    }

    final duration = _durationDays(selectedStart, selectedEnd);

    if (duration <= 0) {
      selectedEnd = selectedStart.add(const Duration(days: 1));
      LuminaToast.warning('Tanggal kembali harus setelah tanggal pinjam.');
    }

    final fixedDuration = _durationDays(selectedStart, selectedEnd);

    if (fixedDuration > maxRangeDays) {
      selectedEnd = selectedStart.add(Duration(days: maxRangeDays));
      LuminaToast.warning(
        'Maksimal peminjaman adalah $maxRangeDays hari. Tanggal kembali otomatis disesuaikan.',
        duration: const Duration(seconds: 3),
      );
    }

    onChanged(
      DateTimeRange(
        start: selectedStart,
        end: selectedEnd,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cleanStart = _dateOnly(startDate);
    final cleanEnd = _dateOnly(endDate);
    final duration = _durationDays(cleanStart, cleanEnd);
    final latestReturnDate = cleanStart.add(Duration(days: maxRangeDays));

    return Material(
      color: LuminaColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(LuminaRadius.xl),
      child: InkWell(
        onTap: () => _openDateRangePicker(context),
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(LuminaSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LuminaRadius.xl),
            border: Border.all(
              color: LuminaColors.outlineVariant,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: LuminaColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(LuminaRadius.lg),
                    ),
                    child: const Icon(
                      Icons.date_range_rounded,
                      color: LuminaColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: LuminaSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: LuminaTextStyles.bodyLg.copyWith(
                            color: LuminaColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
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
                  const SizedBox(width: LuminaSpacing.sm),
                  const Icon(
                    Icons.expand_more_rounded,
                    color: LuminaColors.onSurfaceVariant,
                    size: 24,
                  ),
                ],
              ),

              const SizedBox(height: LuminaSpacing.md),

              Container(
                padding: const EdgeInsets.all(LuminaSpacing.sm),
                decoration: BoxDecoration(
                  color: LuminaColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(LuminaRadius.lg),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _DateInfoItem(
                        label: 'Tanggal Pinjam',
                        value: _formatShortDate(cleanStart),
                        icon: Icons.login_rounded,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 42,
                      color: LuminaColors.outlineVariant,
                    ),
                    Expanded(
                      child: _DateInfoItem(
                        label: 'Tanggal Kembali',
                        value: _formatShortDate(cleanEnd),
                        icon: Icons.assignment_return_rounded,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: LuminaSpacing.md),

              Row(
                children: [
                  _DateRangePill(
                    icon: Icons.timer_rounded,
                    label: '$duration hari',
                  ),
                  const SizedBox(width: LuminaSpacing.xs),
                  Expanded(
                    child: _DateRangePill(
                      icon: Icons.event_busy_rounded,
                      label: 'Maks. ${_formatLongDate(latestReturnDate)}',
                      isExpanded: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateInfoItem extends StatelessWidget {
  const _DateInfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.xs,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: LuminaColors.primary,
            size: 18,
          ),
          const SizedBox(width: LuminaSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: LuminaColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LuminaTextStyles.bodyMd.copyWith(
                    color: LuminaColors.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateRangePill extends StatelessWidget {
  const _DateRangePill({
    required this.icon,
    required this.label,
    this.isExpanded = false,
  });

  final IconData icon;
  final String label;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.sm,
        vertical: LuminaSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: LuminaColors.secondary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(LuminaRadius.full),
      ),
      child: Row(
        mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: LuminaColors.secondary,
            size: 15,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LuminaTextStyles.labelMd.copyWith(
                color: LuminaColors.secondary,
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