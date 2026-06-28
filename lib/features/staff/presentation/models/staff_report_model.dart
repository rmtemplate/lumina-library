import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';

class MostBorrowedBookData {
  const MostBorrowedBookData({
    required this.title,
    required this.borrowCount,
    required this.imageUrl,
    required this.trend,
  });

  final String title;
  final int borrowCount;
  final String imageUrl;
  final BookTrend trend;
}

enum BookTrend {
  up,
  stable,
  down,
}

extension BookTrendX on BookTrend {
  BookTrendConfig get config {
    switch (this) {
      case BookTrend.up:
        return const BookTrendConfig(
          icon: Icons.arrow_upward_rounded,
          color: LuminaColors.secondary,
        );
      case BookTrend.stable:
        return const BookTrendConfig(
          icon: Icons.remove_rounded,
          color: LuminaColors.outline,
        );
      case BookTrend.down:
        return const BookTrendConfig(
          icon: Icons.arrow_downward_rounded,
          color: LuminaColors.error,
        );
    }
  }
}

class BookTrendConfig {
  const BookTrendConfig({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;
}
