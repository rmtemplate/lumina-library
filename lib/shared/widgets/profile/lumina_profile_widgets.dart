import 'package:flutter/material.dart';

import '../../../core/theme/lumina_colors.dart';
import '../../../core/theme/lumina_radius.dart';
import '../../../core/theme/lumina_spacing.dart';
import '../../../core/theme/lumina_text_styles.dart';
import '../../models/profile/lumina_profile_models.dart';
import 'profile_avatar.dart';

class LuminaProfileTopBar extends StatelessWidget {
  const LuminaProfileTopBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.showSettingsButton = true,
    this.onBackTap,
    this.onSettingsTap,
  });

  final String title;
  final bool showBackButton;
  final bool showSettingsButton;
  final VoidCallback? onBackTap;
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LuminaColors.surface.withOpacity(0.94),
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(
            horizontal: LuminaSpacing.marginMobile,
          ),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: LuminaColors.surfaceVariant,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              if (showBackButton)
                _ProfileCircleButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: onBackTap,
                )
              else
                const SizedBox(width: 40),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LuminaTextStyles.titleLg.copyWith(
                    color: LuminaColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (showSettingsButton)
                _ProfileCircleButton(
                  icon: Icons.settings_outlined,
                  onTap: onSettingsTap,
                )
              else
                const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCircleButton extends StatelessWidget {
  const _ProfileCircleButton({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            color: LuminaColors.onSurfaceVariant,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class LuminaProfileHeaderCard extends StatelessWidget {
  const LuminaProfileHeaderCard({
    super.key,
    required this.profile,
    required this.subtitle,
    this.onEditPhotoTap,
    this.isUploadingPhoto = false,
  });

  final LuminaProfileDataModel profile;
  final String subtitle;
  final VoidCallback? onEditPhotoTap;
  final bool isUploadingPhoto;

  @override
  Widget build(BuildContext context) {
    final memberCode = profile.memberCode?.trim() ?? '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ProfileAvatar(
          avatarUrl: profile.avatarUrl,
          isUploading: isUploadingPhoto,
          onEditTap: onEditPhotoTap,
        ),
        const SizedBox(height: LuminaSpacing.md),
        Text(
          profile.fullname,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: LuminaTextStyles.headlineSm.copyWith(
            color: LuminaColors.onSurface,
            fontWeight: FontWeight.w900,
            decoration: TextDecoration.none,
            decorationColor: Colors.transparent,
          ),
        ),
        if (subtitle.trim().isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: LuminaTextStyles.bodyMd.copyWith(
              color: LuminaColors.secondary,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.none,
              decorationColor: Colors.transparent,
            ),
          ),
        ],
        if (memberCode.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            memberCode,
            textAlign: TextAlign.center,
            style: LuminaTextStyles.bodyMd.copyWith(
              color: LuminaColors.outline,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
              decorationColor: Colors.transparent,
            ),
          ),
        ],
        const SizedBox(height: LuminaSpacing.xs),
        _MembershipStatusChip(status: profile.membershipStatus),
      ],
    );
  }
}

class _MembershipStatusChip extends StatelessWidget {
  const _MembershipStatusChip({required this.status});

  final String status;

  ({String label, Color color, IconData icon}) get _style => switch (status) {
        'inactive' => (label: 'Inactive', color: LuminaColors.outline, icon: Icons.pause_circle_rounded),
        'restricted' => (label: 'Restricted', color: LuminaColors.error, icon: Icons.block_rounded),
        _ => (label: 'Active Member', color: LuminaColors.secondary, icon: Icons.verified_rounded),
      };

  @override
  Widget build(BuildContext context) {
    final style = _style;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: style.color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(LuminaRadius.full),
        border: Border.all(color: style.color.withOpacity(0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 13, color: style.color),
          const SizedBox(width: 4),
          Text(
            style.label,
            style: LuminaTextStyles.labelMd.copyWith(
              color: style.color,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class LuminaStaffLibraryLocationCard extends StatelessWidget {
  const LuminaStaffLibraryLocationCard({
    super.key,
    required this.profile,
    this.onOpenLocationTap,
  });

  final LuminaProfileDataModel profile;
  final VoidCallback? onOpenLocationTap;

  @override
  Widget build(BuildContext context) {
    if (!profile.hasStaffLibrary) return const SizedBox.shrink();

    return Material(
      color: LuminaColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(LuminaRadius.xl),
      child: InkWell(
        onTap: onOpenLocationTap,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        child: Container(
          padding: const EdgeInsets.all(LuminaSpacing.md),
          decoration: BoxDecoration(
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
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: LuminaColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: LuminaColors.onSecondaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: LuminaSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Library Location',
                      style: LuminaTextStyles.labelMd.copyWith(
                        color: LuminaColors.outline,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.staffLibraryName ?? '-',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: LuminaTextStyles.bodyMd.copyWith(
                        color: LuminaColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (onOpenLocationTap != null)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: LuminaColors.outline,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class LuminaProfileInfoCard extends StatelessWidget {
  const LuminaProfileInfoCard({
    super.key,
    required this.items,
  });

  final List<LuminaProfileInfoRowModel> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return LuminaProfileMenuCard(
      sectionTitle: 'Personal Information',
      items: items.map((item) {
        return LuminaProfileMenuItemModel(
          id: item.label,
          icon: item.icon,
          label: item.label,
          trailingText: item.value,
        );
      }).toList(growable: false),
    );
  }
}

class LuminaProfileStatsGrid extends StatelessWidget {
  const LuminaProfileStatsGrid({
    super.key,
    required this.items,
  });

  final List<LuminaProfileStatModel> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = LuminaSpacing.md;
        final isWide = constraints.maxWidth >= 640;
        final crossAxisCount = isWide ? 3 : 2;
        final itemWidth =
            (constraints.maxWidth - ((crossAxisCount - 1) * spacing)) /
                crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final shouldSpanFullMobile = !isWide && index == 2;

            return SizedBox(
              width: shouldSpanFullMobile ? constraints.maxWidth : itemWidth,
              child: _ProfileStatCard(item: item),
            );
          }),
        );
      },
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  const _ProfileStatCard({
    required this.item,
  });

  final LuminaProfileStatModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(
          color: LuminaColors.surfaceVariant,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: item.backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              color: item.iconColor,
              size: 22,
            ),
          ),
          const SizedBox(height: LuminaSpacing.xs),
          Text(
            item.value,
            textAlign: TextAlign.center,
            style: LuminaTextStyles.displayLgMobile.copyWith(
              color: item.valueColor ?? LuminaColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: LuminaSpacing.xs),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: LuminaTextStyles.labelMd.copyWith(
              color: LuminaColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class LuminaProfileMenuCard extends StatelessWidget {
  const LuminaProfileMenuCard({
    super.key,
    required this.items,
    this.sectionTitle,
    this.onItemTap,
  });

  final List<LuminaProfileMenuItemModel> items;
  final String? sectionTitle;
  final ValueChanged<LuminaProfileMenuItemModel>? onItemTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sectionTitle != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: LuminaSpacing.sm,
              vertical: LuminaSpacing.xs,
            ),
            child: Text(
              sectionTitle!.toUpperCase(),
              style: LuminaTextStyles.labelMd.copyWith(
                color: LuminaColors.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                decoration: TextDecoration.none,
                decorationColor: Colors.transparent,
              ),
            ),
          ),
          const SizedBox(height: LuminaSpacing.xs),
        ],
        Container(
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
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];

              return _ProfileMenuTile(
                item: item,
                showDivider: index != items.length - 1,
                onTap: () => onItemTap?.call(item),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.item,
    required this.showDivider,
    this.onTap,
  });

  final LuminaProfileMenuItemModel item;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final titleColor =
        item.isDestructive ? LuminaColors.error : LuminaColors.onSurface;
    final iconColor =
        item.isDestructive ? LuminaColors.error : LuminaColors.outline;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: showDivider
                ? const Border(
                    bottom: BorderSide(
                      color: LuminaColors.surfaceVariant,
                      width: 1,
                    ),
                  )
                : null,
          ),
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
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LuminaTextStyles.bodyMd.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                    decorationColor: Colors.transparent,
                  ),
                ),
              ),
              if (item.trailingText != null &&
                  item.trailingText!.trim().isNotEmpty) ...[
                const SizedBox(width: LuminaSpacing.sm),
                Flexible(
                  child: Text(
                    item.trailingText!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: LuminaTextStyles.labelMd.copyWith(
                      color: LuminaColors.outline,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                      decoration: TextDecoration.none,
                      decorationColor: Colors.transparent,
                    ),
                  ),
                ),
              ],
              if (!item.isDestructive) ...[
                const SizedBox(width: LuminaSpacing.xs),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: LuminaColors.outline,
                  size: 24,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class LuminaProfileLogoutButton extends StatelessWidget {
  const LuminaProfileLogoutButton({
    super.key,
    required this.onTap,
    this.label = 'Logout',
  });

  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: LuminaSpacing.sm,
        bottom: LuminaSpacing.xl,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: const Icon(
            Icons.logout_rounded,
            size: 22,
          ),
          label: Text(
            label,
            style: LuminaTextStyles.titleLg.copyWith(
              color: LuminaColors.onErrorContainer,
              fontWeight: FontWeight.w900,
            ),
          ),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: LuminaColors.errorContainer,
            foregroundColor: LuminaColors.onErrorContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(LuminaRadius.xl),
            ),
          ),
        ),
      ),
    );
  }
}