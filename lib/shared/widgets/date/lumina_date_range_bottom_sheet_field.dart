import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';

class LuminaDateRangeBottomSheetField extends StatelessWidget {
  const LuminaDateRangeBottomSheetField({
    super.key,
    required this.value,
    required this.onChanged,
    this.title = 'Periode Tanggal',
    this.subtitle = 'Pilih tanggal mulai dan tanggal selesai',
    this.startLabel = 'Tanggal Mulai',
    this.endLabel = 'Tanggal Selesai',
    this.maxRangeDays = 14,
    this.allowBackdate = false,
    this.minDate,
    this.maxDate,
    this.enabled = true,
  });

  final DateTimeRange value;
  final ValueChanged<DateTimeRange> onChanged;

  final String title;
  final String subtitle;
  final String startLabel;
  final String endLabel;

  final int maxRangeDays;
  final bool allowBackdate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final bool enabled;

  Future<void> _openPicker(BuildContext context) async {
    if (!enabled) return;

    final result = await showModalBottomSheet<DateTimeRange>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return LuminaDateRangeBottomSheet(
          initialRange: value,
          maxRangeDays: maxRangeDays,
          allowBackdate: allowBackdate,
          minDate: minDate,
          maxDate: maxDate,
          title: title,
          startLabel: startLabel,
          endLabel: endLabel,
        );
      },
    );

    if (result == null) return;

    onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final start = _dateOnly(value.start);
    final end = _dateOnly(value.end);
    final durationDays = end.difference(start).inDays;
    final latestReturnDate = start.add(Duration(days: maxRangeDays));

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        child: InkWell(
          onTap: () => _openPicker(context),
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
                        child: _LuminaDateRangeFieldInfo(
                          label: startLabel,
                          value: _formatShortDate(start),
                          icon: Icons.login_rounded,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 42,
                        color: LuminaColors.outlineVariant,
                      ),
                      Expanded(
                        child: _LuminaDateRangeFieldInfo(
                          label: endLabel,
                          value: _formatShortDate(end),
                          icon: Icons.assignment_return_rounded,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: LuminaSpacing.md),

                Row(
                  children: [
                    _LuminaDateRangePill(
                      icon: Icons.timer_rounded,
                      label: '$durationDays hari',
                    ),
                    const SizedBox(width: LuminaSpacing.xs),
                    Expanded(
                      child: _LuminaDateRangePill(
                        icon: Icons.event_busy_rounded,
                        label: 'Maks. ${_formatLongDate(latestReturnDate)}',
                        expanded: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LuminaDateRangeBottomSheet extends StatefulWidget {
  const LuminaDateRangeBottomSheet({
    super.key,
    required this.initialRange,
    required this.maxRangeDays,
    required this.allowBackdate,
    this.minDate,
    this.maxDate,
    this.title = 'Pilih Periode',
    this.startLabel = 'Tanggal Mulai',
    this.endLabel = 'Tanggal Selesai',
  });

  final DateTimeRange initialRange;
  final int maxRangeDays;
  final bool allowBackdate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final String title;
  final String startLabel;
  final String endLabel;

  @override
  State<LuminaDateRangeBottomSheet> createState() =>
      _LuminaDateRangeBottomSheetState();
}

class _LuminaDateRangeBottomSheetState
    extends State<LuminaDateRangeBottomSheet> {
  late DateTime _visibleMonth;
  late DateTime? _startDate;
  late DateTime? _endDate;

  String? _message;

  DateTime get _today => _dateOnly(DateTime.now());

  DateTime get _effectiveMinDate {
    final min = widget.minDate == null ? null : _dateOnly(widget.minDate!);

    if (widget.allowBackdate) {
      return min ?? _today.subtract(const Duration(days: 365));
    }

    if (min == null) return _today;

    return min.isAfter(_today) ? min : _today;
  }

  DateTime get _effectiveMaxDate {
    return widget.maxDate == null
        ? _today.add(const Duration(days: 365))
        : _dateOnly(widget.maxDate!);
  }

  bool get _canSubmit {
    final start = _startDate;
    final end = _endDate;

    if (start == null || end == null) return false;

    final duration = end.difference(start).inDays;

    return duration > 0 && duration <= widget.maxRangeDays;
  }

  int get _selectedDurationDays {
    final start = _startDate;
    final end = _endDate;

    if (start == null || end == null) return 0;

    return end.difference(start).inDays;
  }

  @override
  void initState() {
    super.initState();

    final initialStart = _dateOnly(widget.initialRange.start);
    var initialEnd = _dateOnly(widget.initialRange.end);

    if (!initialEnd.isAfter(initialStart)) {
      initialEnd = initialStart.add(const Duration(days: 1));
    }

    final maxEnd = initialStart.add(Duration(days: widget.maxRangeDays));

    if (initialEnd.isAfter(maxEnd)) {
      initialEnd = maxEnd;
    }

    _startDate = initialStart.isBefore(_effectiveMinDate)
        ? _effectiveMinDate
        : initialStart;

    _endDate = initialEnd.isBefore(_effectiveMinDate) ? null : initialEnd;

    if (_startDate != null && _endDate != null) {
      if (_endDate!.difference(_startDate!).inDays > widget.maxRangeDays) {
        _endDate = _startDate!.add(Duration(days: widget.maxRangeDays));
      }
    }

    _visibleMonth = DateTime(_startDate!.year, _startDate!.month);
  }

  void _goToPreviousMonth() {
    final previous = DateTime(_visibleMonth.year, _visibleMonth.month - 1);

    if (DateTime(previous.year, previous.month)
        .isBefore(DateTime(_effectiveMinDate.year, _effectiveMinDate.month))) {
      return;
    }

    setState(() {
      _visibleMonth = previous;
    });
  }

  void _goToNextMonth() {
    final next = DateTime(_visibleMonth.year, _visibleMonth.month + 1);

    if (DateTime(next.year, next.month)
        .isAfter(DateTime(_effectiveMaxDate.year, _effectiveMaxDate.month))) {
      return;
    }

    setState(() {
      _visibleMonth = next;
    });
  }

  bool _isDateDisabled(DateTime date) {
    final cleanDate = _dateOnly(date);

    if (cleanDate.isBefore(_effectiveMinDate)) return true;
    if (cleanDate.isAfter(_effectiveMaxDate)) return true;

    final start = _startDate;
    final end = _endDate;

    if (start != null && end == null && cleanDate.isAfter(start)) {
      final maxSelectableEnd = start.add(Duration(days: widget.maxRangeDays));

      if (cleanDate.isAfter(maxSelectableEnd)) return true;
    }

    return false;
  }

  bool _isDateInRange(DateTime date) {
    final start = _startDate;
    final end = _endDate;

    if (start == null || end == null) return false;

    return date.isAfter(start) && date.isBefore(end);
  }

  bool _isStartDate(DateTime date) {
    final start = _startDate;

    return start != null && _isSameDate(start, date);
  }

  bool _isEndDate(DateTime date) {
    final end = _endDate;

    return end != null && _isSameDate(end, date);
  }

  void _onDateTap(DateTime date) {
    final selected = _dateOnly(date);

    if (_isDateDisabled(selected)) {
      setState(() {
        _message =
            'Tanggal tidak dapat dipilih. Maksimal rentang ${widget.maxRangeDays} hari dan tidak boleh backdate.';
      });
      return;
    }

    final currentStart = _startDate;
    final currentEnd = _endDate;

    setState(() {
      _message = null;

      if (currentStart == null || currentEnd != null) {
        _startDate = selected;
        _endDate = null;
        return;
      }

      if (selected.isAtSameMomentAs(currentStart) ||
          selected.isBefore(currentStart)) {
        _startDate = selected;
        _endDate = null;
        return;
      }

      final duration = selected.difference(currentStart).inDays;

      if (duration > widget.maxRangeDays) {
        _endDate = currentStart.add(Duration(days: widget.maxRangeDays));
        _message =
            'Maksimal rentang ${widget.maxRangeDays} hari. Tanggal selesai otomatis dibatasi.';
        return;
      }

      _endDate = selected;
    });
  }

  void _resetSelection() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _message = null;
    });
  }

  void _submit() {
    final start = _startDate;
    final end = _endDate;

    if (start == null || end == null) return;

    Navigator.of(context).pop(
      DateTimeRange(
        start: start,
        end: end,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.92,
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
            const SizedBox(height: LuminaSpacing.sm),

            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: LuminaColors.outlineVariant,
                borderRadius: BorderRadius.circular(LuminaRadius.full),
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  LuminaSpacing.marginMobile,
                  LuminaSpacing.lg,
                  LuminaSpacing.marginMobile,
                  LuminaSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LuminaDatePickerHeader(
                      title: widget.title,
                      subtitle:
                          'Maksimal ${widget.maxRangeDays} hari${widget.allowBackdate ? '' : ', tidak bisa backdate'}.',
                    ),

                    const SizedBox(height: LuminaSpacing.lg),

                    _SelectedDateRangePreview(
                      startDate: _startDate,
                      endDate: _endDate,
                      startLabel: widget.startLabel,
                      endLabel: widget.endLabel,
                      durationDays: _selectedDurationDays,
                    ),

                    const SizedBox(height: LuminaSpacing.lg),

                    _MonthNavigator(
                      visibleMonth: _visibleMonth,
                      minDate: _effectiveMinDate,
                      maxDate: _effectiveMaxDate,
                      onPreviousTap: _goToPreviousMonth,
                      onNextTap: _goToNextMonth,
                    ),

                    const SizedBox(height: LuminaSpacing.md),

                    const _WeekdayHeader(),

                    const SizedBox(height: LuminaSpacing.xs),

                    _CalendarMonthGrid(
                      visibleMonth: _visibleMonth,
                      isDateDisabled: _isDateDisabled,
                      isDateInRange: _isDateInRange,
                      isStartDate: _isStartDate,
                      isEndDate: _isEndDate,
                      onDateTap: _onDateTap,
                    ),

                    const SizedBox(height: LuminaSpacing.md),

                    const _DatePickerLegend(),

                    if (_message != null) ...[
                      const SizedBox(height: LuminaSpacing.md),
                      _PickerMessage(message: _message!),
                    ],
                  ],
                ),
              ),
            ),

            _DatePickerBottomAction(
              canSubmit: _canSubmit,
              onResetTap: _resetSelection,
              onSubmitTap: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _LuminaDateRangeFieldInfo extends StatelessWidget {
  const _LuminaDateRangeFieldInfo({
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
      padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.xs),
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

class _LuminaDateRangePill extends StatelessWidget {
  const _LuminaDateRangePill({
    required this.icon,
    required this.label,
    this.expanded = false,
  });

  final IconData icon;
  final String label;
  final bool expanded;

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
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
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

class _LuminaDatePickerHeader extends StatelessWidget {
  const _LuminaDatePickerHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
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
                style: LuminaTextStyles.headlineSm.copyWith(
                  color: LuminaColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: LuminaTextStyles.bodyMd.copyWith(
                  color: LuminaColors.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectedDateRangePreview extends StatelessWidget {
  const _SelectedDateRangePreview({
    required this.startDate,
    required this.endDate,
    required this.startLabel,
    required this.endLabel,
    required this.durationDays,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final String startLabel;
  final String endLabel;
  final int durationDays;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.sm),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _PreviewDateItem(
                  label: startLabel,
                  value:
                      startDate == null ? 'Pilih tanggal' : _formatShortDate(startDate!),
                ),
              ),
              Container(
                width: 1,
                height: 42,
                color: LuminaColors.outlineVariant,
              ),
              Expanded(
                child: _PreviewDateItem(
                  label: endLabel,
                  value: endDate == null ? 'Pilih tanggal' : _formatShortDate(endDate!),
                ),
              ),
            ],
          ),
          if (startDate != null && endDate != null) ...[
            const SizedBox(height: LuminaSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: LuminaSpacing.sm,
                vertical: LuminaSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: LuminaColors.secondary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(LuminaRadius.full),
              ),
              child: Text(
                'Durasi terpilih: $durationDays hari',
                textAlign: TextAlign.center,
                style: LuminaTextStyles.labelMd.copyWith(
                  color: LuminaColors.secondary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PreviewDateItem extends StatelessWidget {
  const _PreviewDateItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
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
    );
  }
}

class _MonthNavigator extends StatelessWidget {
  const _MonthNavigator({
    required this.visibleMonth,
    required this.minDate,
    required this.maxDate,
    required this.onPreviousTap,
    required this.onNextTap,
  });

  final DateTime visibleMonth;
  final DateTime minDate;
  final DateTime maxDate;
  final VoidCallback onPreviousTap;
  final VoidCallback onNextTap;

  bool get _canGoPrevious {
    return DateTime(visibleMonth.year, visibleMonth.month)
        .isAfter(DateTime(minDate.year, minDate.month));
  }

  bool get _canGoNext {
    return DateTime(visibleMonth.year, visibleMonth.month)
        .isBefore(DateTime(maxDate.year, maxDate.month));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MonthButton(
          icon: Icons.chevron_left_rounded,
          enabled: _canGoPrevious,
          onTap: onPreviousTap,
        ),
        Expanded(
          child: Text(
            _formatMonthYear(visibleMonth),
            textAlign: TextAlign.center,
            style: LuminaTextStyles.titleLg.copyWith(
              color: LuminaColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        _MonthButton(
          icon: Icons.chevron_right_rounded,
          enabled: _canGoNext,
          onTap: onNextTap,
        ),
      ],
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LuminaColors.surfaceContainerLow,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            color: enabled ? LuminaColors.primary : LuminaColors.outline,
          ),
        ),
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  static const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: days.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: LuminaTextStyles.labelMd.copyWith(
                color: LuminaColors.onSurfaceVariant,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CalendarMonthGrid extends StatelessWidget {
  const _CalendarMonthGrid({
    required this.visibleMonth,
    required this.isDateDisabled,
    required this.isDateInRange,
    required this.isStartDate,
    required this.isEndDate,
    required this.onDateTap,
  });

  final DateTime visibleMonth;
  final bool Function(DateTime date) isDateDisabled;
  final bool Function(DateTime date) isDateInRange;
  final bool Function(DateTime date) isStartDate;
  final bool Function(DateTime date) isEndDate;
  final ValueChanged<DateTime> onDateTap;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final totalDays = DateUtils.getDaysInMonth(
      visibleMonth.year,
      visibleMonth.month,
    );

    final leadingEmptyCells = firstDay.weekday - 1;
    final totalCells = ((leadingEmptyCells + totalDays) / 7).ceil() * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemBuilder: (context, index) {
        final dayNumber = index - leadingEmptyCells + 1;

        if (dayNumber < 1 || dayNumber > totalDays) {
          return const SizedBox.shrink();
        }

        final date = DateTime(
          visibleMonth.year,
          visibleMonth.month,
          dayNumber,
        );

        return _CalendarDateCell(
          date: date,
          disabled: isDateDisabled(date),
          inRange: isDateInRange(date),
          isStart: isStartDate(date),
          isEnd: isEndDate(date),
          onTap: () => onDateTap(date),
        );
      },
    );
  }
}

class _CalendarDateCell extends StatelessWidget {
  const _CalendarDateCell({
    required this.date,
    required this.disabled,
    required this.inRange,
    required this.isStart,
    required this.isEnd,
    required this.onTap,
  });

  final DateTime date;
  final bool disabled;
  final bool inRange;
  final bool isStart;
  final bool isEnd;
  final VoidCallback onTap;

  bool get selected => isStart || isEnd;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = selected
        ? LuminaColors.primary
        : inRange
            ? LuminaColors.primary.withOpacity(0.09)
            : Colors.transparent;

    final textColor = selected
        ? LuminaColors.onPrimary
        : disabled
            ? LuminaColors.outline.withOpacity(0.55)
            : inRange
                ? LuminaColors.primary
                : LuminaColors.onSurface;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(LuminaRadius.full),
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(LuminaRadius.full),
        child: Center(
          child: Text(
            '${date.day}',
            style: LuminaTextStyles.bodyMd.copyWith(
              color: textColor,
              fontWeight: selected || inRange ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _DatePickerLegend extends StatelessWidget {
  const _DatePickerLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _LegendDot(
          color: LuminaColors.primary,
          label: 'Dipilih',
        ),
        SizedBox(width: LuminaSpacing.md),
        _LegendDot(
          color: LuminaColors.outline,
          label: 'Tidak tersedia',
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: LuminaTextStyles.labelMd.copyWith(
            color: LuminaColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _PickerMessage extends StatelessWidget {
  const _PickerMessage({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(LuminaSpacing.sm),
      decoration: BoxDecoration(
        color: LuminaColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
        border: Border.all(
          color: LuminaColors.error.withOpacity(0.14),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: LuminaColors.error,
            size: 18,
          ),
          const SizedBox(width: LuminaSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: LuminaTextStyles.labelMd.copyWith(
                color: LuminaColors.error,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePickerBottomAction extends StatelessWidget {
  const _DatePickerBottomAction({
    required this.canSubmit,
    required this.onResetTap,
    required this.onSubmitTap,
  });

  final bool canSubmit;
  final VoidCallback onResetTap;
  final VoidCallback onSubmitTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        LuminaSpacing.marginMobile,
        LuminaSpacing.md,
        LuminaSpacing.marginMobile,
        LuminaSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(
            color: LuminaColors.surfaceVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: onResetTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: LuminaColors.primary,
                  side: const BorderSide(
                    color: LuminaColors.outlineVariant,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(LuminaRadius.lg),
                  ),
                ),
                child: Text(
                  'Reset',
                  style: LuminaTextStyles.titleLg.copyWith(
                    color: LuminaColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: LuminaSpacing.sm),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: canSubmit ? onSubmitTap : null,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: LuminaColors.primary,
                  disabledBackgroundColor: LuminaColors.surfaceContainerHigh,
                  foregroundColor: LuminaColors.onPrimary,
                  disabledForegroundColor: LuminaColors.onSurfaceVariant,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(LuminaRadius.lg),
                  ),
                ),
                child: Text(
                  'Gunakan',
                  style: LuminaTextStyles.titleLg.copyWith(
                    color: canSubmit
                        ? LuminaColors.onPrimary
                        : LuminaColors.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

DateTime _dateOnly(DateTime value) {
  return DateUtils.dateOnly(value);
}

bool _isSameDate(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
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

String _formatMonthYear(DateTime value) {
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  return '${months[value.month - 1]} ${value.year}';
}