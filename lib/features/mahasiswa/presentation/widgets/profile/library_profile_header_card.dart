import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';

class LibraryProfileHeaderCard extends StatelessWidget {
  const LibraryProfileHeaderCard({
    super.key,
    required this.name,
    required this.studentId,
    required this.faculty,
    required this.avatarUrl,
    this.onEditTap,
  });

  final String name;
  final String studentId;
  final String faculty;
  final String avatarUrl;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(LuminaSpacing.lg),
      decoration: BoxDecoration(
        color: LuminaColors.surface,
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
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: LuminaColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: LuminaColors.surface,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.person_rounded,
                      color: LuminaColors.primary,
                      size: 46,
                    );
                  },
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Material(
                  color: LuminaColors.secondary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onEditTap,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: LuminaColors.surface,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: LuminaColors.onSecondary,
                        size: 17,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: LuminaSpacing.md),
          Text(
            name,
            textAlign: TextAlign.center,
            style: LuminaTextStyles.headlineMd.copyWith(
              color: LuminaColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: LuminaSpacing.xs),
          Text(
            'NIM: $studentId',
            textAlign: TextAlign.center,
            style: LuminaTextStyles.bodyMd.copyWith(
              color: LuminaColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: LuminaSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: LuminaSpacing.sm,
              vertical: LuminaSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: LuminaColors.tertiaryFixed,
              borderRadius: BorderRadius.circular(LuminaRadius.full),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.school_rounded,
                  color: LuminaColors.onTertiaryFixedVariant,
                  size: 15,
                ),
                const SizedBox(width: LuminaSpacing.xs),
                Flexible(
                  child: Text(
                    faculty,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LuminaTextStyles.labelMd.copyWith(
                      color: LuminaColors.onTertiaryFixedVariant,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
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
