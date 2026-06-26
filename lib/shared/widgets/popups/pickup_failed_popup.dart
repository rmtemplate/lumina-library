import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/shared/widgets/popups/realtime_popup_shell.dart';

/// Shown when a `pickup.failed` WebSocket event arrives for a borrowing the
/// current screen is displaying — e.g. staff scanned an expired/invalid QR
/// while the member is watching their own pickup screen.
class PickupFailedPopup {
  const PickupFailedPopup._();

  static Future<void> show(
    BuildContext context, {
    String? borrowingCode,
    required String reason,
  }) {
    return RealtimePopupShell.show(
      context,
      icon: Icons.error_rounded,
      iconColor: LuminaColors.error,
      iconBackgroundColor: LuminaColors.errorContainer.withOpacity(0.35),
      title: 'Pengambilan Gagal',
      message: reason,
      borrowingCode: borrowingCode,
      autoCloseAfter: const Duration(seconds: 6),
      buttonLabel: 'Mengerti',
    );
  }
}
