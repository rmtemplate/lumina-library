import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';

class LuminaStatCard extends StatelessWidget {
  const LuminaStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.iconBackgroundColor = LuminaColors.primaryFixed,
    this.iconColor = LuminaColors.onPrimaryFixed,
    this.valueColor = LuminaColors.primary,
    this.backgroundColor = LuminaColors.surfaceContainerLowest,
    this.labelColor = LuminaColors.onSurfaceVariant,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color iconBackgroundColor;
  final Color iconColor;
  final Color valueColor;
  final Color backgroundColor;
  final Color labelColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(
          color: LuminaColors.surfaceVariant.withOpacity(0.50),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 23,
            ),
          ),
          const SizedBox(height: LuminaSpacing.xs),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: LuminaTextStyles.displayLgMobile.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: LuminaSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: LuminaTextStyles.labelMd.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        child: card,
      ),
    );
  }
}
