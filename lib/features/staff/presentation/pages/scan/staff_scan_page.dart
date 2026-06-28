import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/staff/presentation/controllers/cart/staff_borrow_cart_controller.dart';
import 'package:lumina_library/features/staff/presentation/controllers/scan/staff_scan_controller.dart';
import 'package:lumina_library/features/staff/presentation/pages/cart/staff_borrow_cart_page.dart';
import 'package:lumina_library/features/staff/presentation/pages/qr_scanner/staff_qr_scanner_page.dart';

/// Universal QR Scanner entry point — staff never picks a mode. Re-opens
/// StaffQrScannerPage in a loop (it pops itself with the scanned value on
/// every successful read) so book scans keep accumulating in the cart
/// without the staff needing to manually relaunch the camera each time.
class StaffScanPage extends StatefulWidget {
  const StaffScanPage({super.key});

  @override
  State<StaffScanPage> createState() => _StaffScanPageState();
}

class _StaffScanPageState extends State<StaffScanPage> {
  final StaffScanController _controller = Get.put(StaffScanController());

  StaffBorrowCartController get _cart {
    if (Get.isRegistered<StaffBorrowCartController>()) {
      return Get.find<StaffBorrowCartController>();
    }
    return Get.put(StaffBorrowCartController(), permanent: true);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loopScan());
  }

  Future<void> _loopScan() async {
    while (mounted) {
      final result = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const StaffQrScannerPage(
            title: 'Universal Scanner',
            description: 'Scan Borrowing QR, Return QR, atau Book QR — sistem akan mendeteksi otomatis.',
          ),
        ),
      );

      if (!mounted) return;
      if (result == null || result.trim().isEmpty) {
        Get.back();
        return;
      }

      await _controller.handleScan(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuminaColors.background,
      body: SafeArea(
        child: Center(
          child: Obx(() {
            if (_controller.isProcessing.value) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: LuminaSpacing.md),
                  Text('Memproses scan...'),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ),
      ),
      bottomNavigationBar: Obx(() {
        final count = _cart.count;
        if (count == 0) return const SizedBox.shrink();

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(LuminaSpacing.marginMobile),
            child: Material(
              color: LuminaColors.primary,
              borderRadius: BorderRadius.circular(LuminaRadius.full),
              child: InkWell(
                borderRadius: BorderRadius.circular(LuminaRadius.full),
                onTap: () => Get.to(() => const StaffBorrowCartPage()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.lg, vertical: LuminaSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_basket_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: LuminaSpacing.sm),
                      Text(
                        '$count book${count > 1 ? 's' : ''} in cart — Proceed Borrow',
                        style: LuminaTextStyles.titleSm.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
