import 'package:flutter/material.dart';

import '../../core/theme/lumina_colors.dart';
import '../../core/theme/lumina_radius.dart';
import '../../core/theme/lumina_spacing.dart';
import '../../core/theme/lumina_text_styles.dart';

enum LuminaChipVariant {
  emerald,
  sky,
  navy,
  gray,
}

class LuminaChip extends StatelessWidget {
  const LuminaChip({
    super.key,
    required this.label,
    this.variant = LuminaChipVariant.emerald,
    this.onTap,
  });

  final String label;
  final LuminaChipVariant variant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();

    return InkWell(
      borderRadius: LuminaRadius.chip,
      onTap: onTap,
      child: Container(
        padding: LuminaSpacing.chipPadding,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: LuminaRadius.chip,
        ),
        child: Text(
          label,
          style: LuminaTextStyles.labelMd.copyWith(
            color: colors.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  _LuminaChipColors _getColors() {
    switch (variant) {
      case LuminaChipVariant.emerald:
        return _LuminaChipColors(
          background: LuminaColors.secondary.withOpacity(0.10),
          foreground: LuminaColors.secondary,
        );
      case LuminaChipVariant.sky:
        return _LuminaChipColors(
          background: LuminaColors.onTertiaryContainer.withOpacity(0.12),
          foreground: LuminaColors.onTertiaryContainer,
        );
      case LuminaChipVariant.navy:
        return _LuminaChipColors(
          background: LuminaColors.primary.withOpacity(0.08),
          foreground: LuminaColors.primary,
        );
      case LuminaChipVariant.gray:
        return const _LuminaChipColors(
          background: LuminaColors.surfaceContainerHigh,
          foreground: LuminaColors.onSurfaceVariant,
        );
    }
  }
}

class _LuminaChipColors {
  const _LuminaChipColors({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;
}
