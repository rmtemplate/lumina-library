import 'package:flutter/material.dart';

import '../../../../core/theme/lumina_colors.dart';
import '../../../../core/theme/lumina_radius.dart';
import '../../../../core/theme/lumina_spacing.dart';
import '../../../../core/theme/lumina_text_styles.dart';

class LibraryMenuCard extends StatelessWidget {
  const LibraryMenuCard({
    super.key,
    required this.items,
  });

  final List<LibraryMenuItemData> items;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;

          return _LibraryMenuTile(
            item: item,
            showDivider: !isLast,
          );
        }),
      ),
    );
  }
}

class _LibraryMenuTile extends StatelessWidget {
  const _LibraryMenuTile({
    required this.item,
    required this.showDivider,
  });

  final LibraryMenuItemData item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final contentColor = item.isDestructive ? LuminaColors.error : LuminaColors.onSurface;
    final iconColor = item.isDestructive ? LuminaColors.error : LuminaColors.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        child: Container(
          decoration: BoxDecoration(
            border: showDivider
                ? Border(
                    bottom: BorderSide(
                      color: LuminaColors.surfaceVariant.withOpacity(0.35),
                      width: 1,
                    ),
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(LuminaSpacing.md),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: iconColor,
                  size: 23,
                ),
                const SizedBox(width: LuminaSpacing.sm),
                Expanded(
                  child: Text(
                    item.title,
                    style: LuminaTextStyles.bodyLg.copyWith(
                      color: contentColor,
                      fontWeight: item.isDestructive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (!item.isDestructive)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: LuminaColors.outlineVariant,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LibraryMenuItemData {
  const LibraryMenuItemData({
    required this.icon,
    required this.title,
    this.isDestructive = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final bool isDestructive;
  final VoidCallback? onTap;
}
