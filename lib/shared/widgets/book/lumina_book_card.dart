import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';

class LuminaBookCard extends StatelessWidget {
  const LuminaBookCard({
    super.key,
    required this.title,
    required this.author,
    required this.rating,
    required this.imageUrl,
    required this.isAvailable,
    this.libraryLocation,
    this.width = 160,
    this.imageAspectRatio = 2 / 3,
    this.showRatingBadge = true,
    this.showInlineRating = false,
    this.showBorrowButton = true,
    this.showAvailabilityStatus = false,
    this.showFavoriteButton = false,
    this.isFavorite = false,
    this.dimUnavailableCover = false,
    this.availableButtonLabel = 'Pinjam',
    this.unavailableButtonLabel = 'Dipinjam',
    this.availableStatusLabel = 'Available',
    this.unavailableStatusLabel = 'Borrowed',
    this.onTap,
    this.onFavoriteTap,
    this.onBorrowTap,
  });

  final String title;
  final String author;
  final String rating;
  final String imageUrl;
  final bool isAvailable;
  final String? libraryLocation;

  final double width;
  final double imageAspectRatio;

  final bool showRatingBadge;
  final bool showInlineRating;
  final bool showBorrowButton;
  final bool showAvailabilityStatus;
  final bool showFavoriteButton;
  final bool isFavorite;
  final bool dimUnavailableCover;

  final String availableButtonLabel;
  final String unavailableButtonLabel;
  final String availableStatusLabel;
  final String unavailableStatusLabel;

  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onBorrowTap;

  bool get _hasLibraryLocation {
    final value = libraryLocation;
    return value != null && value.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(LuminaRadius.xl),
          child: Container(
            clipBehavior: Clip.antiAlias,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: imageAspectRatio,
                  child: _BookCover(
                    imageUrl: imageUrl,
                    rating: rating,
                    isAvailable: isAvailable,
                    isFavorite: isFavorite,
                    showRatingBadge: showRatingBadge,
                    showFavoriteButton: showFavoriteButton,
                    dimUnavailableCover: dimUnavailableCover,
                    onFavoriteTap: onFavoriteTap,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(LuminaSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LuminaTextStyles.bodyMd.copyWith(
                          color: LuminaColors.onSurface,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LuminaTextStyles.labelMd.copyWith(
                          color: LuminaColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          height: 1.15,
                          letterSpacing: 0,
                        ),
                      ),
                      if (_hasLibraryLocation) ...[
                        const SizedBox(height: LuminaSpacing.xs),
                        _LibraryLocationText(
                          location: libraryLocation!.trim(),
                        ),
                      ],
                      if (showInlineRating) ...[
                        const SizedBox(height: LuminaSpacing.xs),
                        _InlineRating(rating: rating),
                      ],
                      if (showAvailabilityStatus) ...[
                        const SizedBox(height: LuminaSpacing.sm),
                        _AvailabilityStatus(
                          isAvailable: isAvailable,
                          availableLabel: availableStatusLabel,
                          unavailableLabel: unavailableStatusLabel,
                        ),
                      ],
                      if (showBorrowButton) ...[
                        const SizedBox(height: LuminaSpacing.sm),
                        _BorrowButton(
                          isAvailable: isAvailable,
                          availableLabel: availableButtonLabel,
                          unavailableLabel: unavailableButtonLabel,
                          onPressed: isAvailable ? onBorrowTap : null,
                        ),
                      ],
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

class _BookCover extends StatelessWidget {
  const _BookCover({
    required this.imageUrl,
    required this.rating,
    required this.isAvailable,
    required this.isFavorite,
    required this.showRatingBadge,
    required this.showFavoriteButton,
    required this.dimUnavailableCover,
    this.onFavoriteTap,
  });

  final String imageUrl;
  final String rating;
  final bool isAvailable;
  final bool isFavorite;
  final bool showRatingBadge;
  final bool showFavoriteButton;
  final bool dimUnavailableCover;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    Widget image = Image.network(
      imageUrl,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return const _BookImagePlaceholder(
          showLoading: true,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const _BookImagePlaceholder();
      },
    );

    if (!isAvailable && dimUnavailableCover) {
      image = Opacity(
        opacity: 0.72,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix(<double>[
            0.30,
            0.59,
            0.11,
            0,
            0,
            0.30,
            0.59,
            0.11,
            0,
            0,
            0.30,
            0.59,
            0.11,
            0,
            0,
            0,
            0,
            0,
            1,
            0,
          ]),
          child: image,
        ),
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: image,
        ),
        if (showRatingBadge)
          Positioned(
            top: 8,
            right: 8,
            child: _RatingBadge(rating: rating),
          ),
        if (showFavoriteButton)
          Positioned(
            top: 8,
            right: 8,
            child: _FavoriteButton(
              isFavorite: isFavorite,
              onTap: onFavoriteTap,
            ),
          ),
      ],
    );
  }
}

class _LibraryLocationText extends StatelessWidget {
  const _LibraryLocationText({
    required this.location,
  });

  final String location;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.location_on_rounded,
          size: 14,
          color: LuminaColors.secondary,
        ),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            location,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: LuminaTextStyles.labelMd.copyWith(
              color: LuminaColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              height: 1.15,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({
    required this.rating,
  });

  final String rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest.withOpacity(0.92),
        borderRadius: BorderRadius.circular(LuminaRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            size: 14,
            color: LuminaColors.secondary,
          ),
          const SizedBox(width: 2),
          Text(
            rating,
            style: LuminaTextStyles.labelMd.copyWith(
              color: LuminaColors.onSurface,
              fontSize: 11,
              height: 1,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({
    required this.isFavorite,
    this.onTap,
  });

  final bool isFavorite;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LuminaColors.surfaceContainerLowest.withOpacity(0.86),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFavorite ? LuminaColors.error : LuminaColors.outline,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _InlineRating extends StatelessWidget {
  const _InlineRating({
    required this.rating,
  });

  final String rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.star_rounded,
          color: Color(0xFFF59E0B),
          size: 16,
        ),
        const SizedBox(width: LuminaSpacing.base),
        Text(
          rating,
          style: LuminaTextStyles.labelMd.copyWith(
            color: LuminaColors.onSurface,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _AvailabilityStatus extends StatelessWidget {
  const _AvailabilityStatus({
    required this.isAvailable,
    required this.availableLabel,
    required this.unavailableLabel,
  });

  final bool isAvailable;
  final String availableLabel;
  final String unavailableLabel;

  @override
  Widget build(BuildContext context) {
    final color = isAvailable ? LuminaColors.secondary : LuminaColors.outline;
    final label = isAvailable ? availableLabel : unavailableLabel;

    return Row(
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
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _BorrowButton extends StatelessWidget {
  const _BorrowButton({
    required this.isAvailable,
    required this.availableLabel,
    required this.unavailableLabel,
    this.onPressed,
  });

  final bool isAvailable;
  final String availableLabel;
  final String unavailableLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 34,
      child: ElevatedButton(
        onPressed: isAvailable ? onPressed : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isAvailable
              ? LuminaColors.secondary
              : LuminaColors.surfaceContainerHighest,
          disabledBackgroundColor: LuminaColors.surfaceContainerHighest,
          foregroundColor: isAvailable
              ? LuminaColors.onSecondary
              : LuminaColors.onSurfaceVariant,
          disabledForegroundColor: LuminaColors.onSurfaceVariant,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LuminaRadius.md),
          ),
        ),
        child: Text(
          isAvailable ? availableLabel : unavailableLabel,
          style: LuminaTextStyles.labelMd.copyWith(
            color: isAvailable
                ? LuminaColors.onSecondary
                : LuminaColors.onSurfaceVariant,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _BookImagePlaceholder extends StatelessWidget {
  const _BookImagePlaceholder({
    this.showLoading = false,
  });

  final bool showLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LuminaColors.surfaceContainer,
      child: Center(
        child: showLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: LuminaColors.secondary,
                ),
              )
            : const Icon(
                Icons.menu_book_rounded,
                color: LuminaColors.primary,
                size: 40,
              ),
      ),
    );
  }
}