import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/staff/data/models/staff_book_item_model.dart';
import 'package:lumina_library/features/staff/presentation/controllers/cart/staff_borrow_cart_controller.dart';
import 'package:lumina_library/features/staff/presentation/controllers/scan/staff_scan_controller.dart';
import 'package:lumina_library/features/staff/presentation/pages/member/staff_member_step_page.dart';
import 'package:lumina_library/features/staff/presentation/pages/qr_scanner/staff_qr_scanner_page.dart';

/// Universal QR Scanner entry point — staff never picks a mode. Hosts a single
/// long-lived [StaffQrScannerPage] (the camera never tears down between reads)
/// and routes every scan through [StaffScanController]: book scans accumulate
/// in the cart while the camera stays live; pickup/return hand off to their
/// own confirmation flow and close the scanner. The borrow cart floats over
/// the viewfinder as a bar + bottom sheet so staff can review/finish without
/// leaving the camera.
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

  Future<bool> _onCode(String code) => _controller.handleScan(context, code);

  void _openCartSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BorrowCartSheet(
        cart: _cart,
        onFinish: () {
          Navigator.of(context).pop();
          Get.to(() => const StaffMemberStepPage());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StaffQrScannerPage(
      title: 'Universal Scanner',
      description:
          'Scan Borrowing QR, Return QR, atau Book QR — sistem mendeteksi otomatis.',
      onCode: _onCode,
      bottomOverlay: Obx(() {
        final count = _cart.count;
        if (count == 0) return const SizedBox.shrink();
        return _CartBar(count: count, onTap: _openCartSheet);
      }),
    );
  }
}

/// Floating summary bar over the viewfinder — tapping it opens the cart sheet.
class _CartBar extends StatelessWidget {
  const _CartBar({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.marginMobile),
      child: Material(
        color: LuminaColors.primary,
        borderRadius: BorderRadius.circular(LuminaRadius.full),
        elevation: 8,
        child: InkWell(
          borderRadius: BorderRadius.circular(LuminaRadius.full),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: LuminaSpacing.lg, vertical: LuminaSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_basket_rounded, color: Colors.white, size: 20),
                const SizedBox(width: LuminaSpacing.sm),
                Text(
                  '$count buku di keranjang — Ketuk untuk review',
                  style: LuminaTextStyles.titleSm
                      .copyWith(color: Colors.white, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Cart review sheet shown over the live camera. Camera stays behind it, so
/// "Continue Scanning" just closes the sheet.
class _BorrowCartSheet extends StatelessWidget {
  const _BorrowCartSheet({required this.cart, required this.onFinish});

  final StaffBorrowCartController cart;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: LuminaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(LuminaRadius.xl)),
      ),
      padding: const EdgeInsets.fromLTRB(
        LuminaSpacing.marginMobile,
        LuminaSpacing.md,
        LuminaSpacing.marginMobile,
        LuminaSpacing.marginMobile,
      ),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final items = cart.items;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: LuminaColors.outlineVariant.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(LuminaRadius.full),
                  ),
                ),
              ),
              const SizedBox(height: LuminaSpacing.md),
              Row(
                children: [
                  Text(
                    'Buku Dipilih',
                    style: LuminaTextStyles.titleLg.copyWith(
                        color: LuminaColors.primary, fontWeight: FontWeight.w900),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: LuminaSpacing.sm, vertical: 4),
                    decoration: BoxDecoration(
                      color: LuminaColors.secondary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(LuminaRadius.full),
                    ),
                    child: Text(
                      'Total: ${items.length} buku',
                      style: LuminaTextStyles.labelMd.copyWith(
                        color: LuminaColors.secondary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: LuminaSpacing.sm),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: LuminaSpacing.lg),
                  child: Center(
                    child: Text(
                      'Belum ada buku. Scan buku untuk menambahkan.',
                      style: LuminaTextStyles.bodyMd
                          .copyWith(color: LuminaColors.onSurfaceVariant),
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 260),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: LuminaSpacing.xs),
                    itemBuilder: (context, index) {
                      // Most-recently-added first, matching the "Recent Books" cue.
                      final item = items[items.length - 1 - index];
                      return _CartRow(
                        item: item,
                        onRemove: () => cart.removeItem(item.id),
                      );
                    },
                  ),
                ),
              const SizedBox(height: LuminaSpacing.md),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: items.isEmpty ? null : onFinish,
                  icon: const Icon(Icons.check_circle_rounded, size: 20),
                  label: Text(
                    'Selesai Meminjam (${items.length})',
                    style: LuminaTextStyles.titleSm
                        .copyWith(color: Colors.white, fontWeight: FontWeight.w900),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: LuminaColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: LuminaColors.outlineVariant,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(LuminaRadius.full)),
                  ),
                ),
              ),
              const SizedBox(height: LuminaSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: items.isEmpty ? null : cart.clear,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: LuminaColors.error,
                        side: const BorderSide(color: LuminaColors.error),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(LuminaRadius.full)),
                      ),
                      child: const Text('Kosongkan'),
                    ),
                  ),
                  const SizedBox(width: LuminaSpacing.sm),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                      label: const Text('Lanjut Scan'),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: LuminaColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(LuminaRadius.full)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  const _CartRow({required this.item, required this.onRemove});

  final StaffBookItemModel item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.sm),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
        border: Border.all(color: LuminaColors.outlineVariant),
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_book_rounded, color: LuminaColors.primary, size: 22),
          const SizedBox(width: LuminaSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.bookTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LuminaTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w800, color: LuminaColors.onSurface)),
                Text(item.itemCode,
                    style: LuminaTextStyles.labelMd.copyWith(
                        color: LuminaColors.secondary,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline_rounded, color: LuminaColors.error),
          ),
        ],
      ),
    );
  }
}
