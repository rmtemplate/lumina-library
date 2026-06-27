import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/shared/widgets/feedback/lumina_toast.dart';

/// Virtual Account / Mandiri Bill Payment details — bank/biller name, the
/// VA or bill key number, and a one-tap copy button. Covers both
/// `bank_transfer` (BCA/BNI/BRI/Permata, `vaNumber` = the VA number) and
/// `echannel` (Mandiri Bill, `vaNumber` = the bill key per
/// BorrowingPaymentService::resolveVaNumber()).
class PaymentVaWidget extends StatelessWidget {
  const PaymentVaWidget({
    super.key,
    required this.channelLabel,
    required this.vaNumber,
    this.numberLabel = 'Nomor Virtual Account',
  });

  final String channelLabel;
  final String vaNumber;
  final String numberLabel;

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: vaNumber));
    LuminaToast.success('Nomor disalin ke clipboard.');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_rounded, color: LuminaColors.primary, size: 20),
              const SizedBox(width: LuminaSpacing.xs),
              Text(
                channelLabel,
                style: LuminaTextStyles.bodyMd.copyWith(
                  color: LuminaColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: LuminaSpacing.sm),
          Text(
            numberLabel,
            style: LuminaTextStyles.labelMd.copyWith(
              color: LuminaColors.outline,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  vaNumber,
                  style: LuminaTextStyles.titleLg.copyWith(
                    color: LuminaColors.secondary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _copy(context),
                icon: const Icon(Icons.copy_rounded, color: LuminaColors.primary, size: 20),
                tooltip: 'Salin nomor',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
