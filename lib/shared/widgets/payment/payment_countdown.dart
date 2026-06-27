import 'dart:async';

import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';

/// Countdown pill for a payment's `expired_at` — follows the exact
/// wall-clock-anchored pattern established for the QR countdown in
/// library_my_book_detail_page.dart (recomputes from the absolute DateTime
/// every tick, so it self-corrects after the app is backgrounded, instead
/// of decrementing a local counter that goes stale).
class PaymentCountdown extends StatefulWidget {
  const PaymentCountdown({
    super.key,
    required this.expiresAt,
    this.onExpired,
    this.large = false,
  });

  final DateTime expiresAt;
  final VoidCallback? onExpired;

  /// When true, renders a bigger, more prominent display (for the Payment
  /// Detail page's hero area) instead of the small inline pill.
  final bool large;

  @override
  State<PaymentCountdown> createState() => _PaymentCountdownState();
}

class _PaymentCountdownState extends State<PaymentCountdown> {
  Timer? _timer;
  int _secondsLeft = 0;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(PaymentCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expiresAt != widget.expiresAt) {
      _start();
    }
  }

  void _start() {
    _timer?.cancel();

    void tick() {
      if (!mounted) return;
      final remaining = widget.expiresAt.difference(DateTime.now()).inSeconds;
      setState(() {
        if (remaining > 0) {
          _secondsLeft = remaining;
          _isExpired = false;
        } else {
          _secondsLeft = 0;
          if (!_isExpired) {
            _isExpired = true;
            widget.onExpired?.call();
          }
        }
      });
    }

    tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _label {
    final hours = _secondsLeft ~/ 3600;
    final minutes = (_secondsLeft % 3600) ~/ 60;
    final seconds = _secondsLeft % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final urgent = !_isExpired && _secondsLeft <= 60;
    final color = _isExpired || urgent ? LuminaColors.error : LuminaColors.secondary;

    if (widget.large) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isExpired ? 'Waktu pembayaran habis' : 'Selesaikan pembayaran dalam',
            style: LuminaTextStyles.labelMd.copyWith(color: LuminaColors.onSurfaceVariant, letterSpacing: 0),
          ),
          const SizedBox(height: 4),
          Text(
            _isExpired ? 'KEDALUWARSA' : _label,
            style: LuminaTextStyles.titleLg.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.md, vertical: LuminaSpacing.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(LuminaRadius.full),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_isExpired ? Icons.timer_off_rounded : Icons.timer_rounded, size: 16, color: color),
          const SizedBox(width: LuminaSpacing.xs),
          Text(
            _isExpired ? 'Kedaluwarsa' : 'Bayar dalam $_label',
            style: LuminaTextStyles.labelMd.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
