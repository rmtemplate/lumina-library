import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/shared/models/payment/borrowing_payment_model.dart';
import 'package:lumina_library/shared/widgets/payment/payment_qris_widget.dart';
import 'package:lumina_library/shared/widgets/payment/payment_va_widget.dart';

/// Method-specific payment instructions + the actual QR/VA/e-wallet content
/// + a Share button (Copy is already built into [PaymentVaWidget] for the
/// VA number itself; this widget adds Share on top, which works for every
/// method since it just shares a text summary).
class PaymentInstructionCard extends StatelessWidget {
  const PaymentInstructionCard({super.key, required this.payment});

  final BorrowingPaymentModel payment;

  String get _instructions => switch (payment.paymentMethod) {
        'qris' => 'Buka aplikasi e-wallet atau m-banking apa pun yang mendukung QRIS, lalu pindai (scan) kode di bawah ini.',
        'gopay' => 'Buka aplikasi Gojek, pilih GoPay, lalu pindai kode QR atau ketuk tombol di bawah untuk membuka otomatis.',
        'shopeepay' => 'Buka aplikasi Shopee, pilih ShopeePay, lalu pindai kode QR atau ketuk tombol di bawah untuk membuka otomatis.',
        'mandiri_bill' => 'Buka ATM atau aplikasi Livin\' by Mandiri, pilih Bayar/Bill Payment, masukkan kode biller dan Bill Key di bawah.',
        _ => 'Buka ATM, m-banking, atau internet banking, pilih Transfer ke Virtual Account, lalu masukkan nomor di bawah.',
      };

  String get _shareText {
    final method = PaymentMethodOption.all
        .firstWhere((o) => o.value == payment.paymentMethod, orElse: () => const PaymentMethodOption(value: '', label: '', group: '', description: ''))
        .label;

    return 'Pembayaran Lumina Library\n'
        'Metode: $method\n'
        'No. Transaksi: ${payment.midtransOrderId}\n'
        '${payment.vaNumber != null ? 'Nomor VA: ${payment.vaNumber}\n' : ''}'
        '${payment.qrString != null ? 'Kode QRIS tersedia di aplikasi.\n' : ''}'
        'Jumlah: Rp ${payment.totalAmount.toStringAsFixed(0)}';
  }

  Future<void> _share() async {
    await SharePlus.instance.share(ShareParams(text: _shareText));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(color: LuminaColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 18, color: LuminaColors.primary),
              const SizedBox(width: LuminaSpacing.xs),
              Text(
                'Cara Bayar',
                style: LuminaTextStyles.bodyMd.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: LuminaSpacing.xs),
          Text(
            _instructions,
            style: LuminaTextStyles.labelMd.copyWith(color: LuminaColors.onSurfaceVariant, height: 1.5, letterSpacing: 0),
          ),
          const SizedBox(height: LuminaSpacing.md),
          if (payment.isQris && payment.qrString != null)
            Center(child: PaymentQrisWidget(qrString: payment.qrString!))
          else if ((payment.isVirtualAccount || payment.isMandiriBill) && payment.vaNumber != null)
            PaymentVaWidget(
              channelLabel: payment.paymentChannel ?? payment.paymentMethod ?? '',
              vaNumber: payment.vaNumber!,
              numberLabel: payment.isMandiriBill ? 'Bill Key' : 'Nomor Virtual Account',
            )
          else if (payment.isEWallet)
            Container(
              padding: const EdgeInsets.all(LuminaSpacing.md),
              decoration: BoxDecoration(
                color: LuminaColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(LuminaRadius.lg),
              ),
              child: Row(
                children: [
                  const Icon(Icons.smartphone_rounded, color: LuminaColors.primary),
                  const SizedBox(width: LuminaSpacing.sm),
                  Expanded(
                    child: Text(
                      'Buka aplikasi wallet Anda untuk menyelesaikan pembayaran.',
                      style: LuminaTextStyles.labelMd.copyWith(color: LuminaColors.onSurfaceVariant, letterSpacing: 0),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: LuminaSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _share,
              icon: const Icon(Icons.share_rounded, size: 18),
              label: const Text('Bagikan Detail Pembayaran'),
              style: OutlinedButton.styleFrom(
                foregroundColor: LuminaColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LuminaRadius.full)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
