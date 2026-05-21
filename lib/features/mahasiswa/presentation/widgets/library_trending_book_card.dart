import 'package:flutter/material.dart';

import '../../../../shared/widgets/book/lumina_book_card.dart';

class LibraryTrendingBookCard extends LuminaBookCard {
  const LibraryTrendingBookCard({
    super.key,
    required super.title,
    required super.author,
    required super.rating,
    required super.imageUrl,
    required super.isAvailable,
    super.width = 160,
    super.imageAspectRatio = 2 / 3,
    super.showRatingBadge = true,
    super.showInlineRating = false,
    super.showBorrowButton = true,
    super.showAvailabilityStatus = false,
    super.showFavoriteButton = false,
    super.isFavorite = false,
    super.dimUnavailableCover = false,
    super.availableButtonLabel = 'Pinjam',
    super.unavailableButtonLabel = 'Dipinjam',
    super.availableStatusLabel = 'Available',
    super.unavailableStatusLabel = 'Borrowed',
    super.onTap,
    super.onFavoriteTap,
    super.onBorrowTap,
  });
}
