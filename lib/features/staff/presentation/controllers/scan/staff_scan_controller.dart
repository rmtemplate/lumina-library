import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/features/staff/data/models/staff_book_item_model.dart';
import 'package:lumina_library/features/staff/data/services/staff_api_service.dart';
import 'package:lumina_library/features/staff/presentation/controllers/cart/staff_borrow_cart_controller.dart';
import 'package:lumina_library/features/staff/presentation/pages/book/staff_book_registration_page.dart';
import 'package:lumina_library/features/staff/presentation/pages/borrow/staff_return_confirm_page.dart';
import 'package:lumina_library/shared/widgets/feedback/lumina_toast.dart';
import 'package:lumina_library/shared/widgets/popups/realtime_popup_shell.dart';

/// Drives the Universal QR Scanner — staff never picks a mode; this calls
/// the one `/staff/qr/scan` endpoint and branches purely on the `type` the
/// backend returns. Owns no scanning mechanics itself (StaffQrScannerPage
/// already does that) — just the "what happens after a code is read" logic.
class StaffScanController extends GetxController {
  final RxBool isProcessing = false.obs;

  StaffApiService get _service => Get.find<StaffApiService>();

  StaffBorrowCartController get _cart {
    if (Get.isRegistered<StaffBorrowCartController>()) {
      return Get.find<StaffBorrowCartController>();
    }
    return Get.put(StaffBorrowCartController(), permanent: true);
  }

  int get cartCount => _cart.count;

  Future<void> handleScan(BuildContext context, String raw) async {
    if (isProcessing.value) return;
    isProcessing.value = true;

    try {
      final result = await _service.universalScan(raw);
      final type = result['type']?.toString() ?? '';
      final data = result['data'] as Map<String, dynamic>? ?? {};

      if (!context.mounted) return;

      switch (type) {
        case 'book_intake':
          _cart.addItem(StaffBookItemModel.fromScanJson(data));
        case 'book_not_found':
          await _showBookNotFoundDialog(context, (data['raw'] as String?) ?? raw);
        case 'borrowing_pickup':
          await _showPickupSuccess(context, data);
        case 'borrowing_return':
          await Get.to(() => StaffReturnConfirmPage(preview: data));
        default:
          LuminaToast.error('Tipe QR tidak dikenali.');
      }
    } on LuminaApiException catch (e) {
      LuminaToast.error(e.displayMessage);
    } catch (_) {
      LuminaToast.error('Gagal memproses scan. Silakan coba lagi.');
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> _showPickupSuccess(BuildContext context, Map<String, dynamic> data) async {
    final borrowing = data['borrowing'] as Map<String, dynamic>? ?? {};

    if (!context.mounted) return;
    await RealtimePopupShell.show(
      context,
      icon: Icons.check_circle_rounded,
      iconColor: LuminaColors.secondary,
      iconBackgroundColor: LuminaColors.secondaryContainer.withOpacity(0.35),
      title: 'Pengambilan Berhasil!',
      message: 'Buku telah diserahkan kepada member.',
      borrowingCode: borrowing['code']?.toString(),
      timeLabel: 'Status',
      timeValue: 'Aktif',
      buttonLabel: 'OK',
    );
  }

  Future<void> _showBookNotFoundDialog(BuildContext context, String raw) async {
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: LuminaColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.menu_book_rounded, color: LuminaColors.error, size: 36),
        title: const Text(
          'Book Not Registered',
          textAlign: TextAlign.center,
          style: TextStyle(color: LuminaColors.primary, fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'QR/barcode ini belum terdaftar pada sistem Lumina Library.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Get.to(() => StaffBookRegistrationPage(scannedCode: raw));
            },
            style: ElevatedButton.styleFrom(backgroundColor: LuminaColors.primary, foregroundColor: Colors.white),
            child: const Text('Register Book'),
          ),
        ],
      ),
    );
  }
}
