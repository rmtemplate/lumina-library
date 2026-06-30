import 'package:flutter/material.dart';

import '../../../../../core/theme/lumina_colors.dart';
import '../../../../../core/theme/lumina_spacing.dart';
import '../../../../../core/theme/lumina_text_styles.dart';
import '../../../data/models/staff_dashboard_summary_model.dart';

class StaffBookDetailSheet extends StatelessWidget {
  const StaffBookDetailSheet({super.key, required this.book});

  final StaffPopularBookModel book;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: LuminaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: LuminaSpacing.xs),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: LuminaColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: LuminaSpacing.md),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              LuminaSpacing.marginMobile,
              0,
              LuminaSpacing.marginMobile,
              LuminaSpacing.lg,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 72,
                    height: 100,
                    child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                        ? Image.network(
                            book.coverUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder(),
                          )
                        : _placeholder(),
                  ),
                ),
                const SizedBox(width: LuminaSpacing.md),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: LuminaTextStyles.titleMd.copyWith(
                          color: LuminaColors.onBackground,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.author,
                        style: LuminaTextStyles.bodyMd.copyWith(
                          color: LuminaColors.onSurfaceVariant,
                        ),
                      ),
                      if (book.category != null && book.category!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: LuminaColors.tertiaryContainer.withOpacity(0.50),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            book.category!,
                            style: TextStyle(
                              color: LuminaColors.onTertiaryContainer,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _statChip(
                            icon: Icons.trending_up_rounded,
                            label: '${book.borrowCount}x dipinjam',
                            color: LuminaColors.primary,
                          ),
                          const SizedBox(width: 8),
                          _statChip(
                            icon: book.isAvailable
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            label: book.isAvailable
                                ? '${book.availableCount} tersedia'
                                : 'Tidak tersedia',
                            color: book.isAvailable
                                ? LuminaColors.secondary
                                : LuminaColors.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: LuminaColors.surfaceContainerLow,
      child: const Center(
        child: Icon(Icons.menu_book_rounded, size: 28, color: LuminaColors.onSurfaceVariant),
      ),
    );
  }

  Widget _statChip({required IconData icon, required String label, required Color color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class StaffActivityDetailSheet extends StatelessWidget {
  const StaffActivityDetailSheet({super.key, required this.activity});

  final StaffRecentActivityModel activity;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = _statusStyle(activity.status);

    return Container(
      decoration: const BoxDecoration(
        color: LuminaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: LuminaSpacing.xs),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: LuminaColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              LuminaSpacing.marginMobile,
              LuminaSpacing.md,
              LuminaSpacing.marginMobile,
              LuminaSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        activity.memberName,
                        style: LuminaTextStyles.titleMd.copyWith(
                          color: LuminaColors.onBackground,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: fg,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: LuminaSpacing.sm),
                _row(Icons.qr_code_rounded, activity.borrowingCode),
                const SizedBox(height: 6),
                _row(Icons.menu_book_rounded, '${activity.itemsCount} buku'),
                if (activity.bookTitle != null && activity.bookTitle!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _row(Icons.auto_stories_rounded, activity.bookTitle!, italic: true),
                ],
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text, {bool italic = false}) {
    return Row(
      children: [
        Icon(icon, size: 15, color: LuminaColors.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: LuminaTextStyles.bodyMd.copyWith(
              color: LuminaColors.onSurfaceVariant,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }

  (String, Color, Color) _statusStyle(String status) => switch (status) {
        'awaiting_pickup' => ('Menunggu', const Color(0xFFE8F0FE), const Color(0xFF1A73E8)),
        'active' => ('Dipinjam', LuminaColors.primaryContainer, LuminaColors.onPrimaryContainer),
        'overdue' => ('Terlambat', LuminaColors.errorContainer, LuminaColors.onErrorContainer),
        'waiting_payment' => ('Bayar', LuminaColors.errorContainer, LuminaColors.onErrorContainer),
        'returned' || 'returned_with_fine' => (
            'Kembali',
            LuminaColors.secondaryContainer,
            LuminaColors.onSecondaryContainer,
          ),
        _ => (status, LuminaColors.surfaceContainer, LuminaColors.onSurfaceVariant),
      };
}
