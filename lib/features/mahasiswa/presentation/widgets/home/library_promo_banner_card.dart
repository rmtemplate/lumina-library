import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';

enum LibraryPromoVariant {
  navy,
  green,
}

class LibraryPromoBannerCard extends StatelessWidget {
  const LibraryPromoBannerCard({
    super.key,
    required this.label,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.icon,
    required this.variant,
    this.onTap,
  });

  final String label;
  final String title;
  final String description;
  final String buttonLabel;
  final IconData icon;
  final LibraryPromoVariant variant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

    return Container(
      width: MediaQuery.sizeOf(context).width >= 768 ? 360 : 280,
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: config.gradientColors,
        ),
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        boxShadow: [
          BoxShadow(
            color: config.gradientColors.first.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -26,
            bottom: -30,
            child: Icon(
              icon,
              size: 88,
              color: Colors.white.withOpacity(0.18),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: config.badgeColor,
                  borderRadius: BorderRadius.circular(LuminaRadius.sm),
                ),
                child: Text(
                  label.toUpperCase(),
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: config.badgeTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: LuminaSpacing.xs),

              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: LuminaTextStyles.titleLg.copyWith(
                  color: config.titleColor,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: LuminaSpacing.xs),

              Expanded(
                child: Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: LuminaTextStyles.bodyMd.copyWith(
                    color: config.descriptionColor,
                    height: 1.45,
                  ),
                ),
              ),

              const SizedBox(height: LuminaSpacing.sm),

              Align(
                alignment: Alignment.bottomLeft,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(LuminaRadius.full),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: LuminaSpacing.md,
                      vertical: LuminaSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: config.buttonColor,
                      borderRadius: BorderRadius.circular(LuminaRadius.full),
                    ),
                    child: Text(
                      buttonLabel,
                      style: LuminaTextStyles.labelMd.copyWith(
                        color: config.buttonTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _PromoConfig _getConfig() {
    switch (variant) {
      case LibraryPromoVariant.navy:
        return const _PromoConfig(
          gradientColors: [
            LuminaColors.primary,
            LuminaColors.tertiaryContainer,
          ],
          badgeColor: LuminaColors.secondary,
          badgeTextColor: LuminaColors.onSecondary,
          titleColor: LuminaColors.onPrimary,
          descriptionColor: LuminaColors.inversePrimary,
          buttonColor: LuminaColors.secondaryContainer,
          buttonTextColor: LuminaColors.onSecondaryContainer,
        );

      case LibraryPromoVariant.green:
        return const _PromoConfig(
          gradientColors: [
            LuminaColors.secondary,
            LuminaColors.tertiary,
          ],
          badgeColor: LuminaColors.error,
          badgeTextColor: LuminaColors.onError,
          titleColor: LuminaColors.onSecondary,
          descriptionColor: LuminaColors.inverseOnSurface,
          buttonColor: LuminaColors.primaryContainer,
          buttonTextColor: LuminaColors.onPrimaryContainer,
        );
    }
  }
}

class _PromoConfig {
  const _PromoConfig({
    required this.gradientColors,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.titleColor,
    required this.descriptionColor,
    required this.buttonColor,
    required this.buttonTextColor,
  });

  final List<Color> gradientColors;
  final Color badgeColor;
  final Color badgeTextColor;
  final Color titleColor;
  final Color descriptionColor;
  final Color buttonColor;
  final Color buttonTextColor;
}
