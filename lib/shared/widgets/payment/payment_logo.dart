import 'package:flutter/material.dart';

/// Renders a payment method's brand mark. Prefers a real asset file from
/// `assets/payment/` if one exists (see assets/payment/README.md for the
/// expected filenames) and falls back to a clean, code-drawn branded badge
/// (correct brand color + initials/icon) otherwise — so dropping real
/// brand logo files in later is a zero-code-change swap.
class PaymentLogo extends StatelessWidget {
  const PaymentLogo({super.key, required this.method, this.size = 40});

  final String method;
  final double size;

  static const Map<String, _Brand> _brands = {
    'qris': _Brand(asset: 'qris.png', color: Color(0xFFE4002B), label: 'QR', icon: Icons.qr_code_2_rounded),
    'bca_va': _Brand(asset: 'bca.png', color: Color(0xFF0066AE), label: 'BCA'),
    'bni_va': _Brand(asset: 'bni.png', color: Color(0xFFF37021), label: 'BNI'),
    'bri_va': _Brand(asset: 'bri.png', color: Color(0xFF00529C), label: 'BRI'),
    'permata_va': _Brand(asset: 'permata.png', color: Color(0xFF00A65E), label: 'PMT'),
    'mandiri_bill': _Brand(asset: 'mandiri.png', color: Color(0xFF003D79), label: 'MDR'),
    'gopay': _Brand(asset: 'gopay.png', color: Color(0xFF00AED6), label: 'GP', icon: Icons.account_balance_wallet_rounded),
    'shopeepay': _Brand(asset: 'shopeepay.png', color: Color(0xFFEE4D2D), label: 'SP', icon: Icons.account_balance_wallet_rounded),
  };

  @override
  Widget build(BuildContext context) {
    final brand = _brands[method] ?? const _Brand(asset: '', color: Color(0xFF9E9E9E), label: '?');

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: Image.asset(
        'assets/payment/${brand.asset}',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _FallbackBadge(brand: brand, size: size),
      ),
    );
  }
}

class _Brand {
  const _Brand({required this.asset, required this.color, required this.label, this.icon});

  final String asset;
  final Color color;
  final String label;
  final IconData? icon;
}

class _FallbackBadge extends StatelessWidget {
  const _FallbackBadge({required this.brand, required this.size});

  final _Brand brand;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: brand.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: brand.color.withOpacity(0.25)),
      ),
      alignment: Alignment.center,
      child: brand.icon != null
          ? Icon(brand.icon, color: brand.color, size: size * 0.55)
          : Text(
              brand.label,
              style: TextStyle(
                color: brand.color,
                fontWeight: FontWeight.w900,
                fontSize: size * 0.26,
                letterSpacing: -0.2,
              ),
            ),
    );
  }
}
