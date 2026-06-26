import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';

class LibrarySideNav extends StatelessWidget {
  const LibrarySideNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  static const _items = [
    _LibrarySideNavItem(
      icon: Icons.home_rounded,
      label: 'Home',
    ),
    _LibrarySideNavItem(
      icon: Icons.import_contacts_rounded,
      label: 'Catalog',
    ),
    _LibrarySideNavItem(
      icon: Icons.book_rounded,
      label: 'My Books',
    ),
    _LibrarySideNavItem(
      icon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      decoration: const BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        border: Border(
          right: BorderSide(
            color: LuminaColors.surfaceVariant,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LuminaSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(LuminaSpacing.md),
                child: Text(
                  'Lumina Library',
                  style: LuminaTextStyles.headlineSm.copyWith(
                    color: LuminaColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: LuminaSpacing.lg),

              Expanded(
                child: ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: LuminaSpacing.sm),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final isActive = currentIndex == index;

                    return InkWell(
                      onTap: () => onChanged(index),
                      borderRadius: BorderRadius.circular(LuminaRadius.lg),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: LuminaSpacing.md,
                          vertical: LuminaSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? LuminaColors.secondary.withOpacity(0.10)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(LuminaRadius.lg),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              color: isActive
                                  ? LuminaColors.secondary
                                  : LuminaColors.onSurfaceVariant,
                              size: 24,
                            ),

                            const SizedBox(width: LuminaSpacing.md),

                            Text(
                              item.label,
                              style: LuminaTextStyles.titleLg.copyWith(
                                color: isActive
                                    ? LuminaColors.secondary
                                    : LuminaColors.onSurfaceVariant,
                                fontWeight: isActive
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibrarySideNavItem {
  const _LibrarySideNavItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}
