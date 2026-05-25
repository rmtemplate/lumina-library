import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/shared/models/navigation/bottom_nav_item_model.dart';

class LuminaRoleBottomNavBar extends StatelessWidget {
  const LuminaRoleBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onChanged,
    this.centerActionIndex,
    this.height = 64,
    this.centerButtonIcon,
  });

  final List<LuminaBottomNavItemModel> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final int? centerActionIndex;
  final double height;
  final IconData? centerButtonIcon;

  @override
  Widget build(BuildContext context) {
    if (centerActionIndex == null) {
      return _StandardBottomNavBar(
        items: items,
        currentIndex: currentIndex,
        onChanged: onChanged,
        height: height,
      );
    }

    return _CenterActionBottomNavBar(
      items: items,
      currentIndex: currentIndex,
      onChanged: onChanged,
      centerActionIndex: centerActionIndex!,
      centerButtonIcon: centerButtonIcon ?? items[centerActionIndex!].icon,
    );
  }
}

class _StandardBottomNavBar extends StatelessWidget {
  const _StandardBottomNavBar({
    required this.items,
    required this.currentIndex,
    required this.onChanged,
    required this.height,
  });

  final List<LuminaBottomNavItemModel> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: LuminaColors.surface,
        border: Border(
          top: BorderSide(
            color: LuminaColors.surfaceVariant,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 4),
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: LuminaSpacing.xs,
            ),
            child: Row(
              children: List.generate(items.length, (index) {
                final item = items[index];

                return Expanded(
                  child: _BottomItemButton(
                    icon: item.icon,
                    label: item.label,
                    isActive: currentIndex == index,
                    onTap: () => onChanged(index),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterActionBottomNavBar extends StatelessWidget {
  const _CenterActionBottomNavBar({
    required this.items,
    required this.currentIndex,
    required this.onChanged,
    required this.centerActionIndex,
    required this.centerButtonIcon,
  });

  final List<LuminaBottomNavItemModel> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final int centerActionIndex;
  final IconData centerButtonIcon;

  @override
  Widget build(BuildContext context) {
    final sideItems = <int>[
      for (var i = 0; i < items.length; i++)
        if (i != centerActionIndex) i,
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: LuminaColors.surface,
        border: const Border(
          top: BorderSide(
            color: LuminaColors.surfaceVariant,
            width: 1,
          ),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(LuminaRadius.xl),
          topRight: Radius.circular(LuminaRadius.xl),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: LuminaSpacing.md,
                    vertical: LuminaSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _BottomItemButton(
                          icon: items[sideItems[0]].icon,
                          label: items[sideItems[0]].label,
                          isActive: currentIndex == sideItems[0],
                          onTap: () => onChanged(sideItems[0]),
                        ),
                      ),
                      const SizedBox(width: 84),
                      Expanded(
                        child: _BottomItemButton(
                          icon: items[sideItems[1]].icon,
                          label: items[sideItems[1]].label,
                          isActive: currentIndex == sideItems[1],
                          onTap: () => onChanged(sideItems[1]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: -22,
                child: Material(
                  color: LuminaColors.secondary,
                  shape: const CircleBorder(),
                  elevation: 8,
                  shadowColor: LuminaColors.secondary,
                  child: InkWell(
                    onTap: () => onChanged(centerActionIndex),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: currentIndex == centerActionIndex
                              ? LuminaColors.secondaryFixed.withOpacity(0.60)
                              : LuminaColors.surface.withOpacity(0.75),
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        centerButtonIcon,
                        color: LuminaColors.onSecondary,
                        size: 29,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomItemButton extends StatelessWidget {
  const _BottomItemButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = LuminaColors.secondary;
    final inactiveColor = LuminaColors.onSurfaceVariant;

    return Material(
      color: isActive
          ? LuminaColors.secondaryContainer.withOpacity(0.16)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(LuminaRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        child: SizedBox(
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 23,
                color: isActive ? activeColor : inactiveColor,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LuminaTextStyles.labelMd.copyWith(
                  fontSize: 11,
                  height: 1.1,
                  color: isActive ? activeColor : inactiveColor,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
