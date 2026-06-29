import 'package:flutter/material.dart';

import '../../../../../core/theme/lumina_colors.dart';
import '../../../../../core/theme/lumina_spacing.dart';
import '../../../../../core/theme/lumina_text_styles.dart';

class StaffDashboardHeader extends StatelessWidget {
  const StaffDashboardHeader({
    super.key,
    required this.staffName,
    required this.branchName,
    required this.dateText,
    required this.avatarUrl,
    this.hasNotification = false,
    this.onAvatarTap,
    this.onNotificationTap,
    this.onSearchTap,
  });

  final String staffName;
  final String branchName;
  final String dateText;
  final String avatarUrl;
  final bool hasNotification;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(
        LuminaSpacing.marginMobile,
        topPad + LuminaSpacing.md,
        LuminaSpacing.marginMobile,
        LuminaSpacing.md,
      ),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.055),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: greeting + name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat datang,',
                      style: LuminaTextStyles.bodyMd.copyWith(
                        color: LuminaColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      staffName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LuminaTextStyles.headlineSm.copyWith(
                        color: LuminaColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: LuminaColors.secondary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            branchName.isEmpty ? '-' : branchName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: LuminaTextStyles.labelMd.copyWith(
                              color: LuminaColors.secondary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: LuminaSpacing.md),

              // Right: actions + avatar
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      _IconAction(
                        icon: Icons.search_rounded,
                        onTap: onSearchTap,
                      ),
                      const SizedBox(width: 4),
                      _IconAction(
                        icon: Icons.notifications_none_rounded,
                        onTap: onNotificationTap,
                        badge: hasNotification,
                      ),
                    ],
                  ),
                  const SizedBox(height: LuminaSpacing.sm),
                  GestureDetector(
                    onTap: onAvatarTap,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: LuminaColors.outlineVariant.withOpacity(0.50),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: LuminaColors.surfaceContainerLow,
                          child: const Icon(
                            Icons.person_rounded,
                            color: LuminaColors.primary,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: LuminaSpacing.sm),

          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: LuminaColors.onSurfaceVariant,
              ),
              const SizedBox(width: 5),
              Text(
                dateText,
                style: LuminaTextStyles.labelMd.copyWith(
                  color: LuminaColors.onSurfaceVariant,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    this.onTap,
    this.badge = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(icon, size: 22, color: LuminaColors.onSurfaceVariant),
          onPressed: onTap,
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(),
        ),
        if (badge)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: LuminaColors.error,
                shape: BoxShape.circle,
                border: Border.all(color: LuminaColors.surfaceContainerLowest, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}
