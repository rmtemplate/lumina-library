import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';

/// Reusable status pill covering every Midtrans-adjacent payment state.
/// Only pending|paid|expired|failed|cancelled are reachable from the
/// current backend (`BorrowingPayment.status` — see
/// app/Models/BorrowingPayment.php on the backend); settlement/refunded/
/// challenge are included for UI completeness/future-proofing — settlement
/// is a Midtrans `transaction_status` value that's already normalized to
/// `paid` server-side before it ever reaches the client, and
/// refunded/challenge aren't implemented backend states today.
class PaymentStatusBadge extends StatelessWidget {
  const PaymentStatusBadge({super.key, required this.status, this.compact = false});

  final String status;
  final bool compact;

  static const Map<String, _StatusStyle> _styles = {
    'pending': _StatusStyle(label: 'Menunggu Pembayaran', color: Color(0xFFB7791F), icon: Icons.hourglass_top_rounded),
    'paid': _StatusStyle(label: 'Lunas', color: Color(0xFF2E7D32), icon: Icons.check_circle_rounded),
    'settlement': _StatusStyle(label: 'Lunas', color: Color(0xFF2E7D32), icon: Icons.check_circle_rounded),
    'expired': _StatusStyle(label: 'Kedaluwarsa', color: Color(0xFF6B7280), icon: Icons.timer_off_rounded),
    'failed': _StatusStyle(label: 'Gagal', color: Color(0xFFC62828), icon: Icons.error_rounded),
    'cancelled': _StatusStyle(label: 'Dibatalkan', color: Color(0xFF6B7280), icon: Icons.cancel_rounded),
    'refunded': _StatusStyle(label: 'Dana Dikembalikan', color: Color(0xFF1565C0), icon: Icons.replay_circle_filled_rounded),
    'challenge': _StatusStyle(label: 'Perlu Verifikasi', color: Color(0xFFB7791F), icon: Icons.shield_rounded),
  };

  @override
  Widget build(BuildContext context) {
    final style = _styles[status] ?? _StatusStyle(label: status, color: LuminaColors.outline, icon: Icons.help_rounded);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      child: Container(
        key: ValueKey(status),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? LuminaSpacing.sm : LuminaSpacing.md,
          vertical: compact ? 2 : LuminaSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: style.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(LuminaRadius.full),
          border: Border.all(color: style.color.withOpacity(0.24)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(style.icon, size: compact ? 12 : 16, color: style.color),
            SizedBox(width: compact ? 4 : LuminaSpacing.xs),
            Text(
              style.label,
              style: LuminaTextStyles.labelMd.copyWith(
                color: style.color,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
                fontSize: compact ? 11 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusStyle {
  const _StatusStyle({required this.label, required this.color, required this.icon});

  final String label;
  final Color color;
  final IconData icon;
}
