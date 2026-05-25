import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/shared/widgets/lumina_card.dart';
import 'package:lumina_library/shared/widgets/lumina_chip.dart';
import 'package:lumina_library/shared/widgets/lumina_progress_bar.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.title,
    required this.author,
    required this.category,
    required this.progress,
    required this.onTap,
  });

  final String title;
  final String author;
  final String category;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LuminaCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 104,
            decoration: BoxDecoration(
              color: LuminaColors.primaryContainer,
              borderRadius: LuminaRadius.bookCover,
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: LuminaColors.inversePrimary,
              size: 32,
            ),
          ),
          const SizedBox(width: LuminaSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LuminaChip(
                  label: category.toUpperCase(),
                  variant: LuminaChipVariant.sky,
                ),
                const SizedBox(height: LuminaSpacing.sm),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: LuminaTextStyles.titleLg.copyWith(
                    color: LuminaColors.onSurface,
                  ),
                ),
                const SizedBox(height: LuminaSpacing.xs),
                Text(
                  author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LuminaTextStyles.bodyMd.copyWith(
                    color: LuminaColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: LuminaSpacing.md),
                LuminaProgressBar(value: progress),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
