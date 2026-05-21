import 'package:flutter/material.dart';

import '../../../../core/theme/lumina_colors.dart';
import '../../../../core/theme/lumina_radius.dart';
import '../../../../core/theme/lumina_spacing.dart';
import '../../../../core/theme/lumina_text_styles.dart';

class LibraryMyBookCard extends StatelessWidget {
  const LibraryMyBookCard({
    super.key,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.dueDate,
    required this.progress,
    this.status = LibraryMyBookStatus.active,
    this.onTap,
    this.onReadTap,
    this.onRenewTap,
  });

  final String title;
  final String author;
  final String imageUrl;
  final String dueDate;
  final double progress;
  final LibraryMyBookStatus status;
  final VoidCallback? onTap;
  final VoidCallback? onReadTap;
  final VoidCallback? onRenewTap;

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        child: Container(
          padding: const EdgeInsets.all(LuminaSpacing.sm),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BookCover(
                imageUrl: imageUrl,
                statusColor: config.color,
              ),
              const SizedBox(width: LuminaSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatusBadge(
                      label: config.label,
                      color: config.color,
                      backgroundColor: config.backgroundColor,
                    ),
                    const SizedBox(height: LuminaSpacing.xs),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: LuminaTextStyles.titleLg.copyWith(
                        color: LuminaColors.onSurface,
                        fontSize: 16,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LuminaTextStyles.bodyMd.copyWith(
                        color: LuminaColors.onSurfaceVariant,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: LuminaSpacing.sm),
                    _ProgressInfo(
                      dueDate: dueDate,
                      progress: progress,
                      color: config.color,
                    ),
                    const SizedBox(height: LuminaSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _CardActionButton(
                            label: 'Baca',
                            backgroundColor: LuminaColors.primary,
                            foregroundColor: LuminaColors.onPrimary,
                            onTap: onReadTap,
                          ),
                        ),
                        const SizedBox(width: LuminaSpacing.xs),
                        Expanded(
                          child: _CardActionButton(
                            label: 'Perpanjang',
                            backgroundColor: LuminaColors.surfaceContainerLow,
                            foregroundColor: LuminaColors.primary,
                            onTap: onRenewTap,
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
    );
  }

  _StatusConfig _getStatusConfig() {
    switch (status) {
      case LibraryMyBookStatus.active:
        return _StatusConfig(
          label: 'Aktif',
          color: LuminaColors.secondary,
          backgroundColor: LuminaColors.secondary.withOpacity(0.10),
        );
      case LibraryMyBookStatus.dueSoon:
        return _StatusConfig(
          label: 'Segera Kembali',
          color: LuminaColors.tertiaryContainer,
          backgroundColor: LuminaColors.tertiaryFixed.withOpacity(0.70),
        );
      case LibraryMyBookStatus.overdue:
        return _StatusConfig(
          label: 'Terlambat',
          color: LuminaColors.error,
          backgroundColor: LuminaColors.errorContainer,
        );
      case LibraryMyBookStatus.finished:
        return _StatusConfig(
          label: 'Selesai',
          color: LuminaColors.outline,
          backgroundColor: LuminaColors.surfaceContainerHigh,
        );
    }
  }
}

class _BookCover extends StatelessWidget {
  const _BookCover({
    required this.imageUrl,
    required this.statusColor,
  });

  final String imageUrl;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      height: 122,
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainer,
        borderRadius: BorderRadius.circular(LuminaRadius.md),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.menu_book_rounded,
                  color: LuminaColors.primary,
                  size: 36,
                );
              },
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.xs,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(LuminaRadius.full),
      ),
      child: Text(
        label,
        style: LuminaTextStyles.labelMd.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 0,
          height: 1,
        ),
      ),
    );
  }
}

class _ProgressInfo extends StatelessWidget {
  const _ProgressInfo({
    required this.dueDate,
    required this.progress,
    required this.color,
  });

  final String dueDate;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dueDate,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: LuminaTextStyles.labelMd.copyWith(
            color: LuminaColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(LuminaRadius.full),
          child: LinearProgressIndicator(
            value: normalizedProgress,
            minHeight: 6,
            backgroundColor: LuminaColors.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: EdgeInsets.zero,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: LuminaColors.surfaceContainerHigh,
          disabledForegroundColor: LuminaColors.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LuminaRadius.md),
          ),
        ),
        child: Text(
          label,
          style: LuminaTextStyles.labelMd.copyWith(
            color: foregroundColor,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _StatusConfig {
  const _StatusConfig({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;
}

enum LibraryMyBookStatus {
  active,
  dueSoon,
  overdue,
  finished,
}
