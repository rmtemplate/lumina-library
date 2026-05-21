import 'package:flutter/material.dart';

import '../../../../core/theme/lumina_colors.dart';
import '../../../../core/theme/lumina_radius.dart';
import '../../../../core/theme/lumina_spacing.dart';
import '../../../../core/theme/lumina_text_styles.dart';
import '../../../../shared/models/book/cart_book_model.dart';

class LibraryCartBookTile extends StatelessWidget {
  const LibraryCartBookTile({
    super.key,
    required this.book,
    this.isChecked = false,
    this.showCheckbox = false,
    this.showDeleteButton = false,
    this.coverWidth = 72,
    this.coverHeight = 104,
    this.onTap,
    this.onCheckedChanged,
    this.onDeleteTap,
  });

  final LibraryCartBook book;
  final bool isChecked;
  final bool showCheckbox;
  final bool showDeleteButton;
  final double coverWidth;
  final double coverHeight;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onCheckedChanged;
  final VoidCallback? onDeleteTap;

  @override
  Widget build(BuildContext context) {
    final disabled = !book.isAvailable;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
        child: Opacity(
          opacity: disabled ? 0.62 : 1,
          child: Container(
            padding: const EdgeInsets.all(LuminaSpacing.sm),
            decoration: BoxDecoration(
              color: LuminaColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(LuminaRadius.lg),
              border: Border.all(
                color: isChecked
                    ? LuminaColors.secondary.withOpacity(0.55)
                    : LuminaColors.outlineVariant.withOpacity(0.55),
                width: isChecked ? 1.4 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showCheckbox) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 34),
                    child: Checkbox(
                      value: isChecked,
                      activeColor: LuminaColors.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(LuminaRadius.sm),
                      ),
                      onChanged: disabled
                          ? null
                          : (value) {
                              onCheckedChanged?.call(value ?? false);
                            },
                    ),
                  ),
                  const SizedBox(width: LuminaSpacing.xs),
                ],
                _BookCover(
                  imageUrl: book.imageUrl,
                  width: coverWidth,
                  height: coverHeight,
                ),
                const SizedBox(width: LuminaSpacing.sm),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: LuminaSpacing.xs,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: LuminaTextStyles.titleLg.copyWith(
                            color: LuminaColors.onSurface,
                            fontWeight: FontWeight.w800,
                            height: 1.22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: LuminaTextStyles.bodyMd.copyWith(
                            color: LuminaColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: LuminaSpacing.xs),
                        _StatusBadge(
                          isAvailable: book.isAvailable,
                          label: book.statusLabel,
                        ),
                      ],
                    ),
                  ),
                ),
                if (showDeleteButton)
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: onDeleteTap,
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        width: 36,
                        height: 36,
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: LuminaColors.outline,
                          size: 22,
                        ),
                      ),
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
    required this.width,
    required this.height,
  });

  final String imageUrl;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainer,
        borderRadius: BorderRadius.circular(LuminaRadius.sm),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
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
    required this.isAvailable,
    required this.label,
  });

  final bool isAvailable;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = isAvailable ? LuminaColors.secondary : LuminaColors.outline;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.xs,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(LuminaRadius.sm),
      ),
      child: Text(
        isAvailable ? label : 'Tidak Tersedia',
        style: LuminaTextStyles.labelMd.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 0,
          height: 1,
        ),
      ),
    );
  }
}
