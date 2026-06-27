import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/shared/widgets/payment/payment_status_badge.dart';

/// Outstanding fine amount + transaction number + status — the "what do I
/// owe and what's the state of it" summary at the top of the Payment
/// Detail page. Pure display — no actions here, those live in the page.
class PaymentSummaryCard extends StatelessWidget {
  const PaymentSummaryCard({
    super.key,
    required this.amount,
    required this.status,
    required this.orderId,
    required this.purpose,
  });

  final double amount;
  final String status;
  final String orderId;

  /// overdue_fine | return_condition | pickup_no_show
  final String purpose;

  static final _currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  String get _purposeLabel => switch (purpose) {
        'overdue_fine' => 'Denda Keterlambatan',
        'pickup_no_show' => 'Denda Tidak Mengambil Pesanan',
        _ => 'Denda Pengembalian',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [LuminaColors.primary, LuminaColors.primary.withOpacity(0.82)],
        ),
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        boxShadow: [
          BoxShadow(color: LuminaColors.primary.withOpacity(0.24), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _purposeLabel,
                  style: LuminaTextStyles.titleSm.copyWith(color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.w700),
                ),
              ),
              PaymentStatusBadge(status: status, compact: true),
            ],
          ),
          const SizedBox(height: LuminaSpacing.xs),
          Text(
            _currencyFormat.format(amount),
            style: LuminaTextStyles.titleLg.copyWith(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28),
          ),
          const SizedBox(height: LuminaSpacing.sm),
          Container(height: 1, color: Colors.white.withOpacity(0.18)),
          const SizedBox(height: LuminaSpacing.sm),
          Row(
            children: [
              Text(
                'No. Transaksi',
                style: LuminaTextStyles.labelMd.copyWith(color: Colors.white.withOpacity(0.7), letterSpacing: 0),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  orderId,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: LuminaTextStyles.labelMd.copyWith(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
