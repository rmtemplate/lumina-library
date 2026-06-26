import 'dart:async';

import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';

/// Internal shell shared by every realtime popup (success/failed/expired).
/// Handles the fade + scale + bounce entrance, the auto-close timer, and the
/// card chrome — each popup widget only supplies its icon/color/content.
///
/// Not exported on its own; use [RealtimePopupShell.show].
class RealtimePopupShell extends StatefulWidget {
  const RealtimePopupShell({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    required this.message,
    this.bookCoverUrl,
    this.bookTitle,
    this.borrowingCode,
    this.timeLabel,
    this.timeValue,
    this.autoCloseAfter = const Duration(seconds: 5),
    this.buttonLabel = 'OK',
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String title;
  final String message;
  final String? bookCoverUrl;
  final String? bookTitle;
  final String? borrowingCode;
  final String? timeLabel;
  final String? timeValue;
  final Duration autoCloseAfter;
  final String buttonLabel;

  static Future<void> show(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBackgroundColor,
    required String title,
    required String message,
    String? bookCoverUrl,
    String? bookTitle,
    String? borrowingCode,
    String? timeLabel,
    String? timeValue,
    Duration autoCloseAfter = const Duration(seconds: 5),
    String buttonLabel = 'OK',
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: title,
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, _, _) => RealtimePopupShell(
        icon: icon,
        iconColor: iconColor,
        iconBackgroundColor: iconBackgroundColor,
        title: title,
        message: message,
        bookCoverUrl: bookCoverUrl,
        bookTitle: bookTitle,
        borrowingCode: borrowingCode,
        timeLabel: timeLabel,
        timeValue: timeValue,
        autoCloseAfter: autoCloseAfter,
        buttonLabel: buttonLabel,
      ),
      transitionBuilder: (context, animation, _, child) {
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        final scale = CurvedAnimation(parent: animation, curve: Curves.elasticOut);

        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(scale: scale, child: child),
        );
      },
    );
  }

  @override
  State<RealtimePopupShell> createState() => _RealtimePopupShellState();
}

class _RealtimePopupShellState extends State<RealtimePopupShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _iconBounceController;
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();

    _iconBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    // Slight delay so the icon bounces in just after the card has scaled in.
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _iconBounceController.forward();
    });

    if (widget.autoCloseAfter > Duration.zero) {
      _autoCloseTimer = Timer(widget.autoCloseAfter, () {
        if (mounted) Navigator.of(context).maybePop();
      });
    }
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    _iconBounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconBounce = CurvedAnimation(
      parent: _iconBounceController,
      curve: Curves.elasticOut,
    );

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: LuminaSpacing.xl),
          padding: const EdgeInsets.fromLTRB(
            LuminaSpacing.lg,
            LuminaSpacing.xl,
            LuminaSpacing.lg,
            LuminaSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: LuminaColors.surface,
            borderRadius: BorderRadius.circular(LuminaRadius.xl),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: iconBounce,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: widget.iconBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, color: widget.iconColor, size: 38),
                ),
              ),
              const SizedBox(height: LuminaSpacing.md),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: LuminaTextStyles.titleLg.copyWith(
                  color: LuminaColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: LuminaSpacing.xs),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: LuminaTextStyles.bodyMd.copyWith(
                  color: LuminaColors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              if (widget.bookTitle != null || widget.bookCoverUrl != null) ...[
                const SizedBox(height: LuminaSpacing.md),
                _BookSummaryRow(
                  coverUrl: widget.bookCoverUrl,
                  title: widget.bookTitle,
                ),
              ],
              if (widget.borrowingCode != null || widget.timeValue != null) ...[
                const SizedBox(height: LuminaSpacing.md),
                _MetaRow(
                  borrowingCode: widget.borrowingCode,
                  timeLabel: widget.timeLabel ?? 'Waktu',
                  timeValue: widget.timeValue,
                ),
              ],
              const SizedBox(height: LuminaSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: widget.iconColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(LuminaRadius.full),
                    ),
                  ),
                  child: Text(
                    widget.buttonLabel,
                    style: LuminaTextStyles.titleSm.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
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
}

class _BookSummaryRow extends StatelessWidget {
  const _BookSummaryRow({this.coverUrl, this.title});

  final String? coverUrl;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.sm),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
      ),
      child: Row(
        children: [
          if (coverUrl != null && coverUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(LuminaRadius.md),
              child: Image.network(
                coverUrl!,
                width: 44,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const _BookFallbackIcon(),
              ),
            )
          else
            const _BookFallbackIcon(),
          const SizedBox(width: LuminaSpacing.sm),
          Expanded(
            child: Text(
              title ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: LuminaTextStyles.bodyMd.copyWith(
                color: LuminaColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookFallbackIcon extends StatelessWidget {
  const _BookFallbackIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 60,
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(LuminaRadius.md),
      ),
      child: const Icon(Icons.menu_book_rounded, color: LuminaColors.primary, size: 22),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({this.borrowingCode, required this.timeLabel, this.timeValue});

  final String? borrowingCode;
  final String timeLabel;
  final String? timeValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (borrowingCode != null)
          Expanded(child: _MetaChip(label: 'Kode', value: borrowingCode!)),
        if (borrowingCode != null && timeValue != null) const SizedBox(width: LuminaSpacing.sm),
        if (timeValue != null) Expanded(child: _MetaChip(label: timeLabel, value: timeValue!)),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.sm, vertical: LuminaSpacing.xs),
      decoration: BoxDecoration(
        color: LuminaColors.secondaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(LuminaRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: LuminaTextStyles.labelMd.copyWith(
              color: LuminaColors.outline,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: LuminaTextStyles.labelMd.copyWith(
              color: LuminaColors.secondary,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
