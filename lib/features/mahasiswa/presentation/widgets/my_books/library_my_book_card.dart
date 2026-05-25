import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/shared/models/book/library_my_book_item_model.dart';

class LibraryMyBookCard extends StatelessWidget {
  const LibraryMyBookCard({
    super.key,
    required this.book,
    this.onTap,
    this.onDetailTap,
  });

  final LibraryMyBookItemModel book;
  final VoidCallback? onTap;
  final VoidCallback? onDetailTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(book.status);
    final statusBackgroundColor = _statusBackgroundColor(book.status);
    final progress = _loanProgress(book);
    final progressLabel = _progressLabel(book, progress);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        child: Container(
          padding: const EdgeInsets.all(LuminaSpacing.md),
          decoration: BoxDecoration(
            color: LuminaColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(LuminaRadius.xl),
            border: Border.all(
              color: book.isOverdue
                  ? LuminaColors.error.withOpacity(0.22)
                  : LuminaColors.outlineVariant.withOpacity(0.42),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BookCover(imageUrl: book.imageUrl),
                  const SizedBox(width: LuminaSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StatusBadge(
                          label: _statusLabel(book.status),
                          textColor: statusColor,
                          backgroundColor: statusBackgroundColor,
                        ),
                        const SizedBox(height: LuminaSpacing.sm),
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: LuminaTextStyles.titleMd.copyWith(
                            color: LuminaColors.onSurface,
                            fontWeight: FontWeight.w900,
                            height: 1.18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: LuminaTextStyles.bodyMd.copyWith(
                            color: LuminaColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: LuminaSpacing.sm),
                        _InfoLine(
                          icon: Icons.local_library_rounded,
                          text: book.libraryName,
                        ),
                        const SizedBox(height: 5),
                        _InfoLine(
                          icon: book.isOverdue
                              ? Icons.warning_amber_rounded
                              : Icons.event_available_rounded,
                          text: _dueText(book),
                          color: book.isOverdue
                              ? LuminaColors.error
                              : LuminaColors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: LuminaSpacing.md),
              _LoanProgressBar(
                value: progress,
                label: progressLabel,
                color: statusColor,
                isOverdue: book.isOverdue,
              ),
              if (book.hasFine) ...[
                const SizedBox(height: LuminaSpacing.md),
                _FineBox(book: book),
              ],
              const SizedBox(height: LuminaSpacing.md),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: onDetailTap ?? onTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: LuminaColors.primary,
                    side: BorderSide(
                      color: LuminaColors.primary.withOpacity(0.28),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(LuminaRadius.lg),
                    ),
                  ),
                  child: Text(
                    'Loan Details',
                    style: LuminaTextStyles.titleSm.copyWith(
                      color: LuminaColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(LibraryMyBookStatus status) {
    switch (status) {
      case LibraryMyBookStatus.active:
        return 'Active';
      case LibraryMyBookStatus.dueSoon:
        return 'Due Soon';
      case LibraryMyBookStatus.overdue:
        return 'Overdue';
      case LibraryMyBookStatus.finished:
        return 'Returned';
    }
  }

  String _dueText(LibraryMyBookItemModel book) {
    switch (book.status) {
      case LibraryMyBookStatus.active:
        return 'Due in ${book.remainingDays} days';
      case LibraryMyBookStatus.dueSoon:
        return 'Due in ${book.remainingDays} days';
      case LibraryMyBookStatus.overdue:
        return '${book.overdueDays} days overdue';
      case LibraryMyBookStatus.finished:
        final returnedDate = book.returnedDateText;

        if (returnedDate == null || returnedDate.trim().isEmpty) {
          return 'Returned';
        }

        return 'Returned on $returnedDate';
    }
  }

  double _loanProgress(LibraryMyBookItemModel book) {
    switch (book.status) {
      case LibraryMyBookStatus.active:
      case LibraryMyBookStatus.dueSoon:
        const maxLoanDays = 14;
        final remainingDays = book.remainingDays.clamp(0, maxLoanDays);
        final elapsedDays = maxLoanDays - remainingDays;
        final progress = elapsedDays / maxLoanDays;

        return progress.clamp(0.08, 0.92);
      case LibraryMyBookStatus.overdue:
      case LibraryMyBookStatus.finished:
        return 1;
    }
  }

  String _progressLabel(LibraryMyBookItemModel book, double progress) {
    switch (book.status) {
      case LibraryMyBookStatus.active:
        return '${(progress * 100).round()}% of loan period used';
      case LibraryMyBookStatus.dueSoon:
        return '${(progress * 100).round()}% used • return soon';
      case LibraryMyBookStatus.overdue:
        return 'Loan period exceeded';
      case LibraryMyBookStatus.finished:
        return 'Loan completed';
    }
  }

  Color _statusColor(LibraryMyBookStatus status) {
    switch (status) {
      case LibraryMyBookStatus.active:
        return LuminaColors.secondary;
      case LibraryMyBookStatus.dueSoon:
        return LuminaColors.primary;
      case LibraryMyBookStatus.overdue:
        return LuminaColors.error;
      case LibraryMyBookStatus.finished:
        return LuminaColors.onSurfaceVariant;
    }
  }

  Color _statusBackgroundColor(LibraryMyBookStatus status) {
    switch (status) {
      case LibraryMyBookStatus.active:
        return LuminaColors.secondary.withOpacity(0.12);
      case LibraryMyBookStatus.dueSoon:
        return LuminaColors.primary.withOpacity(0.10);
      case LibraryMyBookStatus.overdue:
        return LuminaColors.errorContainer.withOpacity(0.58);
      case LibraryMyBookStatus.finished:
        return LuminaColors.surfaceContainerHighest;
    }
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      height: 116,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainer,
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
      ),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const Icon(
            Icons.menu_book_rounded,
            color: LuminaColors.primary,
            size: 34,
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
  });

  final String label;
  final Color textColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.sm,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(LuminaRadius.full),
      ),
      child: Text(
        label,
        style: LuminaTextStyles.labelMd.copyWith(
          color: textColor,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
          height: 1,
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.text,
    this.color,
  });

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? LuminaColors.onSurfaceVariant;

    return Row(
      children: [
        Icon(
          icon,
          color: effectiveColor,
          size: 16,
        ),
        const SizedBox(width: LuminaSpacing.xs),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: LuminaTextStyles.labelMd.copyWith(
              color: effectiveColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoanProgressBar extends StatelessWidget {
  const _LoanProgressBar({
    required this.value,
    required this.label,
    required this.color,
    required this.isOverdue,
  });

  final double value;
  final String label;
  final Color color;
  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
    final progress = value.clamp(0, 1).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isOverdue
                  ? Icons.warning_amber_rounded
                  : Icons.timeline_rounded,
              color: color,
              size: 16,
            ),
            const SizedBox(width: LuminaSpacing.xs),
            Expanded(
              child: Text(
                'Loan Progress',
                style: LuminaTextStyles.labelMd.copyWith(
                  color: LuminaColors.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: LuminaTextStyles.labelMd.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: LuminaSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(LuminaRadius.full),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: LuminaColors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: LuminaTextStyles.labelMd.copyWith(
            color: isOverdue
                ? LuminaColors.error
                : LuminaColors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _FineBox extends StatelessWidget {
  const _FineBox({
    required this.book,
  });

  final LibraryMyBookItemModel book;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.sm),
      decoration: BoxDecoration(
        color: LuminaColors.errorContainer.withOpacity(0.48),
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
        border: Border.all(
          color: LuminaColors.error.withOpacity(0.14),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.payments_rounded,
            color: LuminaColors.error,
            size: 20,
          ),
          const SizedBox(width: LuminaSpacing.sm),
          Expanded(
            child: Text(
              'Outstanding fine: ${book.fineAmountText}',
              style: LuminaTextStyles.bodyMd.copyWith(
                color: LuminaColors.onErrorContainer,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}