import 'package:flutter/material.dart';

import '../../../../../core/theme/lumina_colors.dart';
import '../../../../../core/theme/lumina_radius.dart';
import '../../../../../core/theme/lumina_spacing.dart';
import '../../../../../core/theme/lumina_text_styles.dart';
import '../../models/staff_dashboard_model.dart';

class LibraryStaffDashboardHeader extends StatelessWidget {
  const LibraryStaffDashboardHeader({
    super.key,
    required this.dateText,
    required this.staffName,
    required this.avatarUrl,
    this.hasNotification = false,
    this.onAvatarTap,
  });

  final String dateText;
  final String staffName;
  final String avatarUrl;
  final bool hasNotification;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        LuminaSpacing.marginMobile,
        LuminaSpacing.md,
        LuminaSpacing.marginMobile,
        LuminaSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateText,
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: LuminaColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Halo, $staffName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LuminaTextStyles.displayLgMobile.copyWith(
                    color: LuminaColors.primary,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: LuminaSpacing.md),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onAvatarTap,
              customBorder: const CircleBorder(),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: LuminaColors.surfaceContainerLowest,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: LuminaColors.surfaceContainerLow,
                          child: const Icon(
                            Icons.person_rounded,
                            color: LuminaColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                  if (hasNotification)
                    Positioned(
                      top: 1,
                      right: 1,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: LuminaColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: LuminaColors.background,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LibraryStaffStatGrid extends StatelessWidget {
  const LibraryStaffStatGrid({
    super.key,
    required this.items,
  });

  final List<StaffDashboardStatModel> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.marginMobile,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = LuminaSpacing.gutterMobile;
          final itemWidth = (constraints.maxWidth - spacing) / 2;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: items.map((item) {
              return SizedBox(
                width: itemWidth,
                child: LibraryStaffStatCard(item: item),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class LibraryStaffStatCard extends StatelessWidget {
  const LibraryStaffStatCard({
    super.key,
    required this.item,
  });

  final StaffDashboardStatModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 110,
      ),
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: item.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: item.borderColor == null
            ? null
            : Border.all(
                color: item.borderColor!,
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: item.backgroundColor.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                item.icon,
                color: item.foregroundColor.withOpacity(0.78),
                size: 20,
              ),
              const SizedBox(width: LuminaSpacing.xs),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: item.foregroundColor.withOpacity(0.78),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          Text(
            item.value,
            style: LuminaTextStyles.displayLgMobile.copyWith(
              color: item.foregroundColor,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}

class LibraryStaffQuickActionGrid extends StatelessWidget {
  const LibraryStaffQuickActionGrid({
    super.key,
    required this.items,
    this.onItemTap,
  });

  final List<StaffDashboardActionModel> items;
  final ValueChanged<StaffDashboardActionModel>? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.marginMobile,
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == items.length - 1 ? 0 : LuminaSpacing.md,
              ),
              child: LibraryStaffQuickActionCard(
                item: item,
                onTap: () => onItemTap?.call(item),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class LibraryStaffQuickActionCard extends StatelessWidget {
  const LibraryStaffQuickActionCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final StaffDashboardActionModel item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LuminaColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 118,
          ),
          padding: const EdgeInsets.all(LuminaSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: LuminaColors.outlineVariant.withOpacity(0.30),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.045),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: LuminaColors.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  color: LuminaColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(height: LuminaSpacing.sm),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: LuminaTextStyles.labelMd.copyWith(
                  color: LuminaColors.onBackground,
                  fontWeight: FontWeight.w800,
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

class LibraryStaffSectionHeader extends StatelessWidget {
  const LibraryStaffSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.marginMobile,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: LuminaTextStyles.titleLg.copyWith(
                color: LuminaColors.onBackground,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onActionTap,
              style: TextButton.styleFrom(
                foregroundColor: LuminaColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: LuminaSpacing.xs,
                  vertical: LuminaSpacing.xs,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionLabel!,
                style: LuminaTextStyles.labelMd.copyWith(
                  color: LuminaColors.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class LibraryStaffRecentActivityCard extends StatelessWidget {
  const LibraryStaffRecentActivityCard({
    super.key,
    required this.items,
  });

  final List<StaffDashboardActivityModel> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.marginMobile,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: LuminaColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: LuminaColors.outlineVariant.withOpacity(0.30),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: List.generate(items.length, (index) {
            final item = items[index];

            return Container(
              decoration: BoxDecoration(
                border: index == 0
                    ? null
                    : Border(
                        top: BorderSide(
                          color: LuminaColors.outlineVariant.withOpacity(0.20),
                          width: 1,
                        ),
                      ),
              ),
              child: LibraryStaffActivityTile(item: item),
            );
          }),
        ),
      ),
    );
  }
}

class LibraryStaffActivityTile extends StatelessWidget {
  const LibraryStaffActivityTile({
    super.key,
    required this.item,
  });

  final StaffDashboardActivityModel item;

  @override
  Widget build(BuildContext context) {
    final isNewMember = item.id == 'activity-003';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(LuminaSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  color: item.iconColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: LuminaSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isNewMember)
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: '${item.titlePrefix} '),
                            TextSpan(
                              text: item.highlightText,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(text: ' ${item.titleSuffix}'),
                          ],
                        ),
                        style: LuminaTextStyles.bodyMd.copyWith(
                          color: LuminaColors.onBackground,
                          height: 1.45,
                        ),
                      )
                    else
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: item.titlePrefix,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(text: ' ${item.titleSuffix} '),
                            TextSpan(
                              text: item.highlightText,
                              style: TextStyle(
                                fontStyle: item.highlightItalic
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        style: LuminaTextStyles.bodyMd.copyWith(
                          color: LuminaColors.onBackground,
                          height: 1.45,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      item.timeText,
                      style: LuminaTextStyles.labelMd.copyWith(
                        color: LuminaColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}