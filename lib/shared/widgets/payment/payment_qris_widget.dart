import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';

/// Renders a QRIS payment as a scannable QR code, client-side, from the raw
/// `qr_string` Midtrans returns (NOT an image from the backend — QRIS is a
/// text payload any QR renderer can draw, unlike the pickup/return QRs
/// which are pre-rendered server-side images).
class PaymentQrisWidget extends StatelessWidget {
  const PaymentQrisWidget({super.key, required this.qrString});

  final String qrString;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(LuminaSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(LuminaRadius.xl),
            border: Border.all(color: LuminaColors.outlineVariant.withOpacity(0.3), width: 1.5),
          ),
          child: QrImageView(
            data: qrString,
            version: QrVersions.auto,
            size: 220,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: LuminaSpacing.sm),
        Text(
          'Scan dengan aplikasi e-wallet/mobile banking apa pun yang mendukung QRIS',
          textAlign: TextAlign.center,
          style: LuminaTextStyles.labelMd.copyWith(
            color: LuminaColors.onSurfaceVariant,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
