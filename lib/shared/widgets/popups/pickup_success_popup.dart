import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/shared/widgets/popups/realtime_popup_shell.dart';

/// Shown when a `pickup.success` WebSocket event arrives — fired regardless
/// of whether the pickup came from a real QR scan or a staff/dev bypass
/// (see docs/development-bypass.md), matching the backend's intent that the
/// member-facing experience is identical either way.
class PickupSuccessPopup {
  const PickupSuccessPopup._();

  static Future<void> show(
    BuildContext context, {
    String? bookCoverUrl,
    String? bookTitle,
    required String borrowingCode,
    required DateTime pickedAt,
  }) {
    return RealtimePopupShell.show(
      context,
      icon: Icons.check_circle_rounded,
      iconColor: LuminaColors.secondary,
      iconBackgroundColor: LuminaColors.secondaryContainer.withOpacity(0.35),
      title: 'Pengambilan Berhasil!',
      message: 'Buku berhasil diambil. Selamat membaca!',
      bookCoverUrl: bookCoverUrl,
      bookTitle: bookTitle,
      borrowingCode: borrowingCode,
      timeLabel: 'Waktu Ambil',
      timeValue: DateFormat('HH:mm').format(pickedAt.toLocal()),
      buttonLabel: 'OK',
    );
  }
}
