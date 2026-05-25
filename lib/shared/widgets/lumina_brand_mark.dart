import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_shadows.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';

class LuminaBrandMark extends StatelessWidget {
  const LuminaBrandMark({
    super.key,
    this.size = 88,
    this.showShadow = true,
  });

  final double size;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: LuminaColors.primary,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        boxShadow: showShadow ? LuminaShadows.level2 : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.48,
            height: size * 0.58,
            decoration: BoxDecoration(
              color: LuminaColors.onPrimary,
              borderRadius: BorderRadius.circular(LuminaRadius.sm),
            ),
          ),
          Positioned(
            top: size * 0.25,
            child: Container(
              width: size * 0.30,
              height: size * 0.04,
              decoration: BoxDecoration(
                color: LuminaColors.primary,
                borderRadius: BorderRadius.circular(LuminaRadius.full),
              ),
            ),
          ),
          Positioned(
            top: size * 0.36,
            child: Container(
              width: size * 0.30,
              height: size * 0.04,
              decoration: BoxDecoration(
                color: LuminaColors.primary,
                borderRadius: BorderRadius.circular(LuminaRadius.full),
              ),
            ),
          ),
          Positioned(
            bottom: size * 0.23,
            child: Container(
              width: size * 0.18,
              height: size * 0.04,
              decoration: BoxDecoration(
                color: LuminaColors.secondary,
                borderRadius: BorderRadius.circular(LuminaRadius.full),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LuminaBrandLockup extends StatelessWidget {
  const LuminaBrandLockup({
    super.key,
    this.alignment = CrossAxisAlignment.center,
  });

  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: [
        const LuminaBrandMark(),
        const SizedBox(height: LuminaSpacing.lg),
        Text(
          'Lumina',
          textAlign: TextAlign.center,
          style: LuminaTextStyles.displayLgMobile.copyWith(
            color: LuminaColors.primary,
          ),
        ),
        const SizedBox(height: LuminaSpacing.xs),
        Text(
          'Digital Library',
          textAlign: TextAlign.center,
          style: LuminaTextStyles.bodyMd.copyWith(
            color: LuminaColors.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
