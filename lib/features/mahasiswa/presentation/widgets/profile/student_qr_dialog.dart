import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screen_brightness/screen_brightness.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';

/// Full-screen student QR shown from the profile page. The QR encodes the
/// student's member code — staff scan it on the borrow flow (StaffApiService
/// .lookupMember → backend resolves member_code/id). Screen brightness is
/// boosted to max while visible (reliable scanning) and the background is a
/// dark overlay, restoring brightness on close.
class StudentQrDialog extends StatefulWidget {
  const StudentQrDialog({
    super.key,
    required this.code,
    required this.name,
    this.subtitle,
  });

  final String code;
  final String name;
  final String? subtitle;

  static Future<void> show(
    BuildContext context, {
    required String code,
    required String name,
    String? subtitle,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'QR',
      barrierColor: Colors.black.withOpacity(0.88),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (_, _, _) =>
          StudentQrDialog(code: code, name: name, subtitle: subtitle),
      transitionBuilder: (context, anim, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: child,
        ),
      ),
    );
  }

  @override
  State<StudentQrDialog> createState() => _StudentQrDialogState();
}

class _StudentQrDialogState extends State<StudentQrDialog> {
  final ScreenBrightness _brightness = ScreenBrightness();

  @override
  void initState() {
    super.initState();
    _boostBrightness();
  }

  Future<void> _boostBrightness() async {
    try {
      await _brightness.setApplicationScreenBrightness(1.0);
    } catch (_) {}
  }

  @override
  void dispose() {
    try {
      _brightness.resetApplicationScreenBrightness();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: LuminaSpacing.xl),
          padding: const EdgeInsets.all(LuminaSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(LuminaRadius.xl),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'QR Peminjaman',
                style: LuminaTextStyles.titleLg.copyWith(
                  color: LuminaColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: LuminaSpacing.xs),
              Text(
                'Tunjukkan ke petugas untuk memulai peminjaman',
                textAlign: TextAlign.center,
                style: LuminaTextStyles.labelMd.copyWith(
                  color: LuminaColors.onSurfaceVariant,
                  letterSpacing: 0,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: LuminaSpacing.lg),
              // Black-on-white for maximum scan reliability.
              Container(
                padding: const EdgeInsets.all(LuminaSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(LuminaRadius.lg),
                  border: Border.all(color: LuminaColors.outlineVariant),
                ),
                child: QrImageView(
                  data: widget.code,
                  version: QrVersions.auto,
                  size: 240,
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: LuminaSpacing.lg),
              Text(
                widget.name,
                textAlign: TextAlign.center,
                style: LuminaTextStyles.titleMd.copyWith(
                  color: LuminaColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (widget.subtitle != null && widget.subtitle!.trim().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  widget.subtitle!,
                  textAlign: TextAlign.center,
                  style: LuminaTextStyles.bodyMd.copyWith(
                    color: LuminaColors.secondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
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
                    backgroundColor: LuminaColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(LuminaRadius.full),
                    ),
                  ),
                  child: Text(
                    'Tutup',
                    style: LuminaTextStyles.titleSm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
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
