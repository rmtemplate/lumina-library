import 'package:flutter/material.dart';

import '../../core/theme/lumina_colors.dart';
import '../../core/theme/lumina_shadows.dart';
import '../../core/theme/lumina_spacing.dart';
import '../../core/theme/lumina_text_styles.dart';

class LuminaBottomNavItem {
  const LuminaBottomNavItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

class LuminaBottomNav extends StatelessWidget {
  const LuminaBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onChanged,
  });

  final List<LuminaBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest.withOpacity(0.96),
        border: const Border(
          top: BorderSide(
            color: LuminaColors.surfaceContainerHigh,
            width: 1,
          ),
        ),
        boxShadow: LuminaShadows.navigation,
      ),
      padding: const EdgeInsets.only(
        top: LuminaSpacing.xs,
        bottom: LuminaSpacing.xs,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isActive = currentIndex == index;

            return Expanded(
              child: InkWell(
                onTap: () => onChanged(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 24,
                        color: isActive
                            ? LuminaColors.primary
                            : LuminaColors.outline,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LuminaTextStyles.labelMd.copyWith(
                          color: isActive
                              ? LuminaColors.primary
                              : LuminaColors.outline,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isActive
                              ? LuminaColors.primary
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
