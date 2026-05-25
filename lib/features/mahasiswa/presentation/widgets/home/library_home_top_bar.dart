import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';

class LibraryHomeTopBar extends StatelessWidget {
  const LibraryHomeTopBar({
    super.key,
    this.userName = 'Ahmad',
    this.appName = 'Lumina Library',
    this.avatarUrl =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuB6M5wKgD9gfoPIAqHAU7Uyw_bSonoCVJOGlL4Gaw0QWc6MZZ0F1gVo8lo5Szngekb6zXikcQuYbv1awIJAttiSjCztuALyKssaXPeotpep7rDZrNvQJ5FcBqeUnAY6rQkES6JpxDuim7UUYRvUOfN6eWPuxNLOiWAvs5nhueAkgctiiHXl4CRKceDlIxGNr23rSh61GMH_z-vExOo42mk50FNfBuJAz0U7EF-14zhbaeSI30a6sZG34dRqHpNOTtaS6JU_RjaSmN05',
    this.onNotificationTap,
    this.onCartTap,
  });

  final String userName;
  final String appName;
  final String avatarUrl;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onCartTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LuminaColors.surface,
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.08),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LuminaSpacing.marginMobile,
            vertical: LuminaSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: LuminaColors.outlineVariant,
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
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
              ),

              const SizedBox(width: LuminaSpacing.sm),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, $userName!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LuminaTextStyles.headlineSm.copyWith(
                        color: LuminaColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      appName,
                      style: LuminaTextStyles.labelMd.copyWith(
                        color: LuminaColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Ikon Cart
              InkWell(
                onTap: onCartTap,
                borderRadius: BorderRadius.circular(LuminaRadius.full),
                child: Padding(
                  padding: const EdgeInsets.all(LuminaSpacing.xs),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    color: LuminaColors.primary,
                    size: 26,
                  ),
                ),
              ),

              const SizedBox(width: 4), // Jarak antara Cart dan Notification

              // Ikon Notification
              InkWell(
                onTap: onNotificationTap,
                borderRadius: BorderRadius.circular(LuminaRadius.full),
                child: Padding(
                  padding: const EdgeInsets.all(LuminaSpacing.xs),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        color: LuminaColors.primary,
                        size: 26,
                      ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}