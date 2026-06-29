import 'package:flutter/material.dart';

import '../../../../../core/theme/lumina_colors.dart';
import '../../../../../core/theme/lumina_spacing.dart';
import '../../../../../core/theme/lumina_text_styles.dart';
import '../../../data/models/staff_dashboard_summary_model.dart';

class StaffPopularBooksSection extends StatelessWidget {
  const StaffPopularBooksSection({super.key, required this.books});

  final List<StaffPopularBookModel> books;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.marginMobile),
        itemCount: books.length,
        separatorBuilder: (_, __) => const SizedBox(width: LuminaSpacing.gutterMobile),
        itemBuilder: (_, i) => StaffPopularBookCard(book: books[i]),
      ),
    );
  }
}

class StaffPopularBookCard extends StatelessWidget {
  const StaffPopularBookCard({super.key, required this.book});

  final StaffPopularBookModel book;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LuminaColors.outlineVariant.withOpacity(0.30)),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover — fills top portion
          Stack(
            children: [
              SizedBox(
                height: 110,
                width: double.infinity,
                child: book.coverUrl != null
                    ? Image.network(
                        book.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _coverPlaceholder(),
                      )
                    : _coverPlaceholder(),
              ),
              // Borrow count badge
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: LuminaColors.primary.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.trending_up_rounded, size: 10, color: LuminaColors.onPrimary),
                      const SizedBox(width: 3),
                      Text(
                        '${book.borrowCount}x',
                        style: const TextStyle(
                          color: LuminaColors.onPrimary,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(LuminaSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: LuminaTextStyles.bodySm.copyWith(
                      color: LuminaColors.onBackground,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LuminaTextStyles.labelMd.copyWith(
                      color: LuminaColors.onSurfaceVariant,
                      letterSpacing: 0,
                    ),
                  ),
                  const Spacer(),
                  // Availability chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: book.isAvailable
                          ? LuminaColors.secondaryContainer
                          : LuminaColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      book.isAvailable ? '${book.availableCount} tersedia' : 'Tidak tersedia',
                      style: TextStyle(
                        color: book.isAvailable
                            ? LuminaColors.onSecondaryContainer
                            : LuminaColors.onSurfaceVariant,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
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

  Widget _coverPlaceholder() {
    return Container(
      color: LuminaColors.surfaceContainerLow,
      child: const Center(
        child: Icon(Icons.menu_book_rounded, size: 36, color: LuminaColors.onSurfaceVariant),
      ),
    );
  }
}
