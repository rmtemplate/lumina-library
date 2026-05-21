import 'package:flutter/material.dart';

import '../../../core/theme/lumina_colors.dart';
import '../../../core/theme/lumina_radius.dart';
import '../../../core/theme/lumina_spacing.dart';
import '../../../core/theme/lumina_text_styles.dart';

class LuminaAppTopBar extends StatelessWidget {
  const LuminaAppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.avatarUrl,
    this.leadingIcon,
    this.leading,
    this.actions = const [],
    this.showNotificationDot = false,
    this.onLeadingTap,
    this.onNotificationTap,
  });

  final String title;
  final String? subtitle;
  final String? avatarUrl;
  final IconData? leadingIcon;
  final Widget? leading;
  final List<Widget> actions;
  final bool showNotificationDot;
  final VoidCallback? onLeadingTap;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LuminaColors.surface,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: LuminaSpacing.marginMobile,
            ),
            child: Row(
              children: [
                leading ?? _DefaultLeading(
                  avatarUrl: avatarUrl,
                  icon: leadingIcon,
                  onTap: onLeadingTap,
                ),
                const SizedBox(width: LuminaSpacing.sm),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LuminaTextStyles.headlineSm.copyWith(
                          color: LuminaColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: LuminaTextStyles.labelMd.copyWith(
                            color: LuminaColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                        ),
                    ],
                  ),
                ),
                ...actions,
                if (onNotificationTap != null)
                  _TopBarIconButton(
                    icon: Icons.notifications_none_rounded,
                    showDot: showNotificationDot,
                    onTap: onNotificationTap,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DefaultLeading extends StatelessWidget {
  const _DefaultLeading({
    this.avatarUrl,
    this.icon,
    this.onTap,
  });

  final String? avatarUrl;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl != null && avatarUrl!.trim().isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(LuminaRadius.full),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: LuminaColors.outlineVariant,
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasAvatar
            ? Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.person_rounded,
                    color: LuminaColors.primary,
                  );
                },
              )
            : Icon(
                icon ?? Icons.person_rounded,
                color: LuminaColors.primary,
              ),
      ),
    );
  }
}

class LuminaTopBarIconButton extends StatelessWidget {
  const LuminaTopBarIconButton({
    super.key,
    required this.icon,
    this.showDot = false,
    this.onTap,
  });

  final IconData icon;
  final bool showDot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _TopBarIconButton(
      icon: icon,
      showDot: showDot,
      onTap: onTap,
    );
  }
}

class _TopBarIconButton extends StatelessWidget {
  const _TopBarIconButton({
    required this.icon,
    required this.showDot,
    this.onTap,
  });

  final IconData icon;
  final bool showDot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(LuminaRadius.full),
      child: Padding(
        padding: const EdgeInsets.all(LuminaSpacing.xs),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              color: LuminaColors.primary,
              size: 26,
            ),
            if (showDot)
              Positioned(
                top: 1,
                right: 1,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: LuminaColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: LuminaColors.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
