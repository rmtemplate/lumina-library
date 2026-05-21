import 'package:flutter/material.dart';

import '../../../../core/theme/lumina_colors.dart';
import '../../../../core/theme/lumina_radius.dart';
import '../../../../core/theme/lumina_spacing.dart';
import '../../../../core/theme/lumina_text_styles.dart';

class LibraryCategoryFilterBar extends StatelessWidget {
  const LibraryCategoryFilterBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: LuminaSpacing.sm),
        itemBuilder: (context, index) {
          final isActive = selectedIndex == index;

          return InkWell(
            onTap: () => onChanged(index),
            borderRadius: BorderRadius.circular(LuminaRadius.full),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: LuminaSpacing.md,
                vertical: LuminaSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? LuminaColors.primary
                    : LuminaColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(LuminaRadius.full),
                border: Border.all(
                  color: isActive
                      ? LuminaColors.primary
                      : LuminaColors.outlineVariant,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  items[index],
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: isActive
                        ? LuminaColors.onPrimary
                        : LuminaColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
