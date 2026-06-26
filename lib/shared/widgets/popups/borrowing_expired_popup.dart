import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/shared/widgets/popups/realtime_popup_shell.dart';

/// Shown when a `borrowing.expired` WebSocket event arrives — the pickup
/// deadline passed (see docs/scheduler.md) while the member had the
/// borrowing/My Books screen open, so it never has to wait for a manual
/// pull-to-refresh to find out.
class BorrowingExpiredPopup {
  const BorrowingExpiredPopup._();

  static Future<void> show(
    BuildContext context, {
    String? bookCoverUrl,
    String? bookTitle,
    required String borrowingCode,
  }) {
    return RealtimePopupShell.show(
      context,
      icon: Icons.lock_clock_rounded,
      iconColor: LuminaColors.onSurfaceVariant,
      iconBackgroundColor: LuminaColors.surfaceContainerHigh,
      title: 'Reservasi Kedaluwarsa',
      message: 'Batas waktu pengambilan telah berakhir. Buku sudah dilepas kembali ke katalog.',
      bookCoverUrl: bookCoverUrl,
      bookTitle: bookTitle,
      borrowingCode: borrowingCode,
      autoCloseAfter: const Duration(seconds: 6),
      buttonLabel: 'Mengerti',
    );
  }
}
