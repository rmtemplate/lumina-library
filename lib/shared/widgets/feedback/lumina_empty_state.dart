import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';

class LuminaEmptyState extends StatelessWidget {
  const LuminaEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.action,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LuminaSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: LuminaColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: LuminaColors.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: LuminaSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: LuminaTextStyles.titleLg.copyWith(
                color: LuminaColors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: LuminaSpacing.xs),
            Text(
              description,
              textAlign: TextAlign.center,
              style: LuminaTextStyles.bodyMd.copyWith(
                color: LuminaColors.onSurfaceVariant,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: LuminaSpacing.md),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
