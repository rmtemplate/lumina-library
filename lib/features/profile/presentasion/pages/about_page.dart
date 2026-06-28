import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';

/// "About" — app identity, version, short description. Static content,
/// no API calls, kept production-quality (not a stub) per the brief.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const String _version = '1.0.0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuminaColors.background,
      appBar: AppBar(
        backgroundColor: LuminaColors.surface,
        elevation: 0,
        foregroundColor: LuminaColors.primary,
        title: Text(
          'About',
          style: LuminaTextStyles.titleLg.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            LuminaSpacing.marginMobile,
            LuminaSpacing.xl,
            LuminaSpacing.marginMobile,
            LuminaSpacing.xl,
          ),
          children: [
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: LuminaColors.primary,
                  borderRadius: BorderRadius.circular(LuminaRadius.xl),
                ),
                child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 44),
              ),
            ),
            const SizedBox(height: LuminaSpacing.md),
            Text(
              'Lumina Library',
              textAlign: TextAlign.center,
              style: LuminaTextStyles.headlineSm.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              'Version $_version',
              textAlign: TextAlign.center,
              style: LuminaTextStyles.bodyMd.copyWith(color: LuminaColors.outline, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: LuminaSpacing.lg),
            Container(
              padding: const EdgeInsets.all(LuminaSpacing.md),
              decoration: BoxDecoration(
                color: LuminaColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(LuminaRadius.xl),
                border: Border.all(color: LuminaColors.outlineVariant),
              ),
              child: Text(
                'Lumina Library adalah aplikasi perpustakaan digital yang membantu mahasiswa dan staf mengelola peminjaman, '
                'pengembalian, dan pembayaran denda buku secara real-time — dari pemesanan hingga pengembalian.',
                style: LuminaTextStyles.bodyMd.copyWith(color: LuminaColors.onSurfaceVariant, height: 1.5),
              ),
            ),
            const SizedBox(height: LuminaSpacing.lg),
            Text(
              '© ${DateTime.now().year} Lumina Library. All rights reserved.',
              textAlign: TextAlign.center,
              style: LuminaTextStyles.labelMd.copyWith(color: LuminaColors.outline, letterSpacing: 0),
            ),
          ],
        ),
      ),
    );
  }
}
