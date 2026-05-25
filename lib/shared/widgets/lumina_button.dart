import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';

enum LuminaButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
}

class LuminaButton extends StatelessWidget {
  const LuminaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = LuminaButtonVariant.primary,
    this.isFullWidth = false,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final LuminaButtonVariant variant;
  final bool isFullWidth;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: colors.background,
          foregroundColor: colors.foreground,
          disabledBackgroundColor: LuminaColors.surfaceContainerHigh,
          disabledForegroundColor: LuminaColors.outline,
          padding: LuminaSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: LuminaRadius.button,
            side: BorderSide(
              color: colors.border,
              width: 1,
            ),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: isLoading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  key: const ValueKey('content'),
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      icon!,
                      const SizedBox(width: LuminaSpacing.xs),
                    ],
                    Text(
                      label,
                      style: LuminaTextStyles.bodyMd.copyWith(
                        color: colors.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  _LuminaButtonColors _getColors() {
    switch (variant) {
      case LuminaButtonVariant.primary:
        return const _LuminaButtonColors(
          background: LuminaColors.secondary,
          foreground: LuminaColors.onSecondary,
          border: LuminaColors.secondary,
        );
      case LuminaButtonVariant.secondary:
        return const _LuminaButtonColors(
          background: LuminaColors.primary,
          foreground: LuminaColors.onPrimary,
          border: LuminaColors.primary,
        );
      case LuminaButtonVariant.outline:
        return const _LuminaButtonColors(
          background: Colors.transparent,
          foreground: LuminaColors.primary,
          border: LuminaColors.outlineVariant,
        );
      case LuminaButtonVariant.ghost:
        return const _LuminaButtonColors(
          background: Colors.transparent,
          foreground: LuminaColors.primary,
          border: Colors.transparent,
        );
    }
  }
}

class _LuminaButtonColors {
  const _LuminaButtonColors({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}
