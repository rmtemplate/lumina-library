import 'package:flutter/material.dart';

import '../../../../../core/theme/lumina_colors.dart';
import '../../../../../core/theme/lumina_spacing.dart';
import '../../../../../core/theme/lumina_text_styles.dart';
import '../../../data/models/staff_dashboard_summary_model.dart';

class StaffPopularBooksSection extends StatelessWidget {
  const StaffPopularBooksSection({super.key, required this.books, this.onTap});

  final List<StaffPopularBookModel> books;
  final void Function(StaffPopularBookModel book)? onTap;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.marginMobile),
        itemCount: books.length,
        separatorBuilder: (_, __) => const SizedBox(width: LuminaSpacing.gutterMobile),
        itemBuilder: (_, i) => StaffPopularBookCard(
          book: books[i],
          onTap: onTap != null ? () => onTap!(books[i]) : null,
        ),
      ),
    );
  }
}

class StaffPopularBookCard extends StatelessWidget {
  const StaffPopularBookCard({super.key, required this.book, this.onTap});

  final StaffPopularBookModel book;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LuminaColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 140,
          decoration: BoxDecoration(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover — fills top portion
              Stack(
                children: [
                  SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                        ? Image.network(
                            book.coverUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) => progress == null
                                ? child
                                : _coverPlaceholder(),
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
                      if (book.category != null && book.category!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: LuminaColors.tertiaryContainer.withOpacity(0.40),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            book.category!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: LuminaColors.onTertiaryContainer,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
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
        ),
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
