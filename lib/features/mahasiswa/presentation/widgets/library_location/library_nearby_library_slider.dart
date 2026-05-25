import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';

import 'package:lumina_library/shared/models/library/library_branch_model.dart';

class LibraryNearbyLibrarySlider extends StatelessWidget {
  const LibraryNearbyLibrarySlider({
    super.key,
    required this.items,
    this.onTap,
    this.onDirectionTap,
  });

  final List<LibraryNearbyLibraryData> items;
  final ValueChanged<LibraryNearbyLibraryData>? onTap;
  final ValueChanged<LibraryNearbyLibraryData>? onDirectionTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: LuminaSpacing.marginMobile),
          ...List.generate(items.length, (index) {
            final item = items[index];

            return Padding(
              padding: EdgeInsets.only(
                right: index == items.length - 1
                    ? LuminaSpacing.marginMobile
                    : LuminaSpacing.md,
              ),
              child: _NearbyLibraryCard(
                item: item,
                onTap: () => onTap?.call(item),
                onDirectionTap: () => onDirectionTap?.call(item),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _NearbyLibraryCard extends StatelessWidget {
  const _NearbyLibraryCard({
    required this.item,
    this.onTap,
    this.onDirectionTap,
  });

  final LibraryNearbyLibraryData item;
  final VoidCallback? onTap;
  final VoidCallback? onDirectionTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 304,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(LuminaRadius.xl),
          child: Container(
            decoration: BoxDecoration(
              color: LuminaColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(LuminaRadius.xl),
              border: Border.all(
                color: LuminaColors.surfaceVariant,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LibraryPhotoHeader(
                  imageUrl: item.imageUrl,
                  isOpen: item.isOpen,
                  openStatusText: item.openStatusText,
                  distanceText: item.distanceText,
                ),

                Padding(
                  padding: const EdgeInsets.all(LuminaSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: LuminaTextStyles.titleLg.copyWith(
                          color: LuminaColors.primary,
                          fontWeight: FontWeight.w900,
                          height: 1.18,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: LuminaColors.onSurfaceVariant,
                            size: 17,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              item.address,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: LuminaTextStyles.bodyMd.copyWith(
                                color: LuminaColors.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: LuminaSpacing.md),

                      Row(
                        children: [
                          _InfoPill(
                            icon: Icons.directions_walk_rounded,
                            label: item.durationText,
                            color: LuminaColors.secondary,
                            backgroundColor:
                                LuminaColors.secondary.withOpacity(0.10),
                          ),

                          const SizedBox(width: LuminaSpacing.xs),

                          _InfoPill(
                            icon: Icons.schedule_rounded,
                            label: item.scheduleText,
                            color: LuminaColors.primary,
                            backgroundColor:
                                LuminaColors.primary.withOpacity(0.08),
                          ),
                        ],
                      ),

                      const SizedBox(height: LuminaSpacing.md),

                      Row(
                        children: [
                          _OpenStatusBadge(
                            isOpen: item.isOpen,
                            label: item.openStatusText,
                          ),

                          const Spacer(),

                          Material(
                            color: LuminaColors.primary,
                            borderRadius:
                                BorderRadius.circular(LuminaRadius.full),
                            child: InkWell(
                              onTap: onDirectionTap,
                              borderRadius:
                                  BorderRadius.circular(LuminaRadius.full),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: LuminaSpacing.sm,
                                  vertical: LuminaSpacing.xs,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.route_rounded,
                                      color: LuminaColors.onPrimary,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Rute',
                                      style:
                                          LuminaTextStyles.labelMd.copyWith(
                                        color: LuminaColors.onPrimary,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LibraryPhotoHeader extends StatelessWidget {
  const _LibraryPhotoHeader({
    required this.imageUrl,
    required this.isOpen,
    required this.openStatusText,
    required this.distanceText,
  });

  final String imageUrl;
  final bool isOpen;
  final String openStatusText;
  final String distanceText;

  @override
  Widget build(BuildContext context) {
    final statusColor = isOpen ? LuminaColors.secondary : LuminaColors.error;

    return SizedBox(
      height: 138,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;

                return Container(
                  color: LuminaColors.surfaceContainerLow,
                  child: const Center(
                    child: SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: LuminaColors.secondary,
                      ),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: LuminaColors.surfaceContainerLow,
                  child: const Center(
                    child: Icon(
                      Icons.local_library_rounded,
                      color: LuminaColors.primary,
                      size: 42,
                    ),
                  ),
                );
              },
            ),
          ),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.06),
                    Colors.black.withOpacity(0.55),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: LuminaSpacing.sm,
            left: LuminaSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: LuminaSpacing.xs,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: LuminaColors.surfaceContainerLowest.withOpacity(0.92),
                borderRadius: BorderRadius.circular(LuminaRadius.full),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.near_me_rounded,
                    color: LuminaColors.primary,
                    size: 15,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    distanceText,
                    style: LuminaTextStyles.labelMd.copyWith(
                      color: LuminaColors.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            right: LuminaSpacing.sm,
            bottom: LuminaSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: LuminaSpacing.xs,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.94),
                borderRadius: BorderRadius.circular(LuminaRadius.full),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.circle,
                    color: LuminaColors.onSecondary,
                    size: 7,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    openStatusText,
                    style: LuminaTextStyles.labelMd.copyWith(
                      color: LuminaColors.onSecondary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
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

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: LuminaSpacing.xs,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(LuminaRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 15,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LuminaTextStyles.labelMd.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenStatusBadge extends StatelessWidget {
  const _OpenStatusBadge({
    required this.isOpen,
    required this.label,
  });

  final bool isOpen;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? LuminaColors.secondary : LuminaColors.error;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: LuminaSpacing.xs),
        Text(
          label,
          style: LuminaTextStyles.labelMd.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

