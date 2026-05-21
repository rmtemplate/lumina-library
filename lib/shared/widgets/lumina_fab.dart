import 'package:flutter/material.dart';

import '../../core/theme/lumina_colors.dart';
import '../../core/theme/lumina_radius.dart';
import '../../core/theme/lumina_shadows.dart';
import '../../core/theme/lumina_spacing.dart';
import '../../core/theme/lumina_text_styles.dart';

class LuminaFab extends StatelessWidget {
  const LuminaFab({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
  });

  final Widget icon;
  final VoidCallback onPressed;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final isExtended = label != null && label!.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(LuminaRadius.full),
        boxShadow: LuminaShadows.level2,
      ),
      child: isExtended
          ? FloatingActionButton.extended(
              heroTag: null,
              elevation: 0,
              backgroundColor: LuminaColors.secondary,
              foregroundColor: LuminaColors.onSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(LuminaRadius.full),
              ),
              onPressed: onPressed,
              icon: icon,
              label: Padding(
                padding: const EdgeInsets.only(right: LuminaSpacing.xs),
                child: Text(
                  label!,
                  style: LuminaTextStyles.bodyMd.copyWith(
                    color: LuminaColors.onSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          : FloatingActionButton(
              heroTag: null,
              elevation: 0,
              backgroundColor: LuminaColors.secondary,
              foregroundColor: LuminaColors.onSecondary,
              shape: const CircleBorder(),
              onPressed: onPressed,
              child: icon,
            ),
    );
  }
}
