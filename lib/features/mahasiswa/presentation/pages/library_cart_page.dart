import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/lumina_colors.dart';
import '../../../../core/theme/lumina_radius.dart';
import '../../../../core/theme/lumina_spacing.dart';
import '../../../../core/theme/lumina_text_styles.dart';
import '../controllers/library_cart_controller.dart';
import '../widgets/library_cart_book_tile.dart';
import '../widgets/library_transaction_top_bar.dart';
import 'library_checkout_page.dart';

class LibraryCartPage extends StatelessWidget {
  LibraryCartPage({
    super.key,
  });

  final LibraryCartController controller = Get.isRegistered<LibraryCartController>()
      ? Get.find<LibraryCartController>()
      : Get.put(LibraryCartController());

  void _goToCheckout() {
    if (!controller.hasCheckedItems) {
      controller.showNoCheckedWarning();
      return;
    }

    Get.to(() => const LibraryCheckoutPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuminaColors.surface,
      bottomNavigationBar: _CartBottomAction(
        controller: controller,
        onCheckoutTap: _goToCheckout,
      ),
      body: Column(
        children: [
          const LibraryTransactionTopBar(
            title: 'Keranjang Pinjaman',
          ),
          Expanded(
            child: Obx(() {
              if (!controller.hasItems) {
                return const _CartEmptyState();
              }

              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  LuminaSpacing.marginMobile,
                  LuminaSpacing.md,
                  LuminaSpacing.marginMobile,
                  LuminaSpacing.lg,
                ),
                children: [
                  _CartSelectAllHeader(
                    controller: controller,
                  ),
                  const SizedBox(height: LuminaSpacing.md),
                  ...List.generate(controller.cartItems.length, (index) {
                    final item = controller.cartItems[index];
                    final isChecked = controller.checkedBookIds.contains(item.id);

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == controller.cartItems.length - 1
                            ? 0
                            : LuminaSpacing.md,
                      ),
                      child: LibraryCartBookTile(
                        book: item,
                        isChecked: isChecked,
                        showCheckbox: true,
                        showDeleteButton: true,
                        onTap: () => controller.toggleBookChecked(item.id),
                        onCheckedChanged: (_) {
                          controller.toggleBookChecked(item.id);
                        },
                        onDeleteTap: () => controller.removeBook(item.id),
                      ),
                    );
                  }),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _CartSelectAllHeader extends StatelessWidget {
  const _CartSelectAllHeader({
    required this.controller,
  });

  final LibraryCartController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: LuminaSpacing.sm,
          vertical: LuminaSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: LuminaColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(LuminaRadius.lg),
        ),
        child: Row(
          children: [
            Checkbox(
              value: controller.isAllAvailableChecked,
              activeColor: LuminaColors.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(LuminaRadius.sm),
              ),
              onChanged: (_) => controller.toggleSelectAllAvailable(),
            ),
            Expanded(
              child: Text(
                'Pilih semua buku tersedia',
                style: LuminaTextStyles.bodyMd.copyWith(
                  color: LuminaColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${controller.checkedCount}/${controller.availableCount}',
              style: LuminaTextStyles.labelMd.copyWith(
                color: LuminaColors.onSurfaceVariant,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _CartBottomAction extends StatelessWidget {
  const _CartBottomAction({
    required this.controller,
    required this.onCheckoutTap,
  });

  final LibraryCartController controller;
  final VoidCallback onCheckoutTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        border: const Border(
          top: BorderSide(
            color: LuminaColors.surfaceVariant,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            LuminaSpacing.marginMobile,
            LuminaSpacing.md,
            LuminaSpacing.marginMobile,
            LuminaSpacing.md,
          ),
          child: Obx(() {
            final count = controller.checkedCount;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Total Dipilih',
                      style: LuminaTextStyles.bodyLg.copyWith(
                        color: LuminaColors.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$count Buku',
                      style: LuminaTextStyles.headlineSm.copyWith(
                        color: LuminaColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: LuminaSpacing.md),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: count == 0 ? null : onCheckoutTap,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: LuminaColors.primary,
                      disabledBackgroundColor: LuminaColors.surfaceContainerHigh,
                      foregroundColor: LuminaColors.onPrimary,
                      disabledForegroundColor: LuminaColors.onSurfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(LuminaRadius.lg),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Lanjutkan ke Checkout',
                          style: LuminaTextStyles.titleLg.copyWith(
                            color: count == 0
                                ? LuminaColors.onSurfaceVariant
                                : LuminaColors.onPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: LuminaSpacing.xs),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 21,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _CartEmptyState extends StatelessWidget {
  const _CartEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LuminaSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: LuminaColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: LuminaColors.outline,
                size: 34,
              ),
            ),
            const SizedBox(height: LuminaSpacing.md),
            Text(
              'Keranjang Kosong',
              style: LuminaTextStyles.titleLg.copyWith(
                color: LuminaColors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: LuminaSpacing.xs),
            Text(
              'Anda belum menambahkan buku untuk dipinjam.',
              textAlign: TextAlign.center,
              style: LuminaTextStyles.bodyMd.copyWith(
                color: LuminaColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
