import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/shared/widgets/popups/realtime_popup_shell.dart';

/// Shown when a `payment.success` WebSocket event arrives — built on the
/// same RealtimePopupShell used by the pickup/borrowing-expired popups
/// (fade + scale + bounce, auto-close), not a separate dialog shell.
class PaymentSuccessDialog {
  const PaymentSuccessDialog._();

  static final _currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  static Future<void> show(
    BuildContext context, {
    required double amount,
    required String orderId,
    String? borrowingCode,
  }) {
    return RealtimePopupShell.show(
      context,
      icon: Icons.check_circle_rounded,
      iconColor: LuminaColors.secondary,
      iconBackgroundColor: LuminaColors.secondaryContainer.withOpacity(0.35),
      title: 'Pembayaran Berhasil!',
      message: 'Jumlah Dibayar: ${_currencyFormat.format(amount)}',
      borrowingCode: borrowingCode,
      timeLabel: 'No. Transaksi',
      timeValue: orderId,
      buttonLabel: 'OK',
    );
  }
}
