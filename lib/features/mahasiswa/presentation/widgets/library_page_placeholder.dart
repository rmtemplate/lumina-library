import 'package:flutter/material.dart';

import '../../../../core/theme/lumina_colors.dart';
import '../../../../core/theme/lumina_radius.dart';
import '../../../../core/theme/lumina_spacing.dart';
import '../../../../core/theme/lumina_text_styles.dart';

class LibraryPagePlaceholder extends StatelessWidget {
  const LibraryPagePlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 460),
        padding: const EdgeInsets.all(LuminaSpacing.xl),
        decoration: BoxDecoration(
          color: LuminaColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(LuminaRadius.xl),
          border: Border.all(
            color: LuminaColors.surfaceVariant,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: LuminaColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: LuminaColors.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: LuminaSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: LuminaTextStyles.headlineSm.copyWith(
                color: LuminaColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: LuminaSpacing.xs),
            Text(
              description,
              textAlign: TextAlign.center,
              style: LuminaTextStyles.bodyMd.copyWith(
                color: LuminaColors.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
