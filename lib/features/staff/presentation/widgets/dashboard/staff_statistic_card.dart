import 'package:flutter/material.dart';

import '../../../../../core/theme/lumina_colors.dart';
import '../../../../../core/theme/lumina_spacing.dart';
import '../../../../../core/theme/lumina_text_styles.dart';
import '../../models/staff_dashboard_model.dart';

class StaffStatisticRow extends StatelessWidget {
  const StaffStatisticRow({super.key, required this.items});

  final List<StaffDashboardStatModel> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.marginMobile),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: LuminaSpacing.gutterMobile),
        itemBuilder: (_, i) => StaffStatisticCard(item: items[i]),
      ),
    );
  }
}

class StaffStatisticCard extends StatelessWidget {
  const StaffStatisticCard({super.key, required this.item, this.onTap});

  final StaffDashboardStatModel item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isAlert = item.borderColor != null;
    final accentColor = isAlert ? LuminaColors.error : item.foregroundColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(LuminaSpacing.md),
        decoration: BoxDecoration(
          color: item.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: item.borderColor != null
              ? Border.all(color: item.borderColor!, width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: item.backgroundColor.withOpacity(0.22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, size: 18, color: item.foregroundColor.withOpacity(0.85)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AnimatedCounter(
                  value: int.tryParse(item.value) ?? 0,
                  style: LuminaTextStyles.titleLg.copyWith(
                    color: item.foregroundColor,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: item.foregroundColor.withOpacity(0.72),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedCounter extends StatelessWidget {
  const _AnimatedCounter({required this.value, required this.style});

  final int value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (_, v, __) => Text('${v.toInt()}', style: style),
    );
  }
}
