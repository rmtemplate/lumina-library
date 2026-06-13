import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/mahasiswa/presentation/pages/checkout/library_checkout_success_page.dart';
import 'package:lumina_library/shared/models/book/cart_book_model.dart';
import 'package:lumina_library/shared/widgets/date/lumina_date_range_bottom_sheet_field.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/cart/library_cart_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/cart/library_cart_book_tile.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/layout/library_transaction_top_bar.dart';

class LibraryCheckoutPage extends StatelessWidget {
  const LibraryCheckoutPage({
    super.key,
  });

  LibraryCartController get controller =>
      Get.isRegistered<LibraryCartController>()
          ? Get.find<LibraryCartController>()
          : Get.put(LibraryCartController());

  Future<void> _confirmBorrowing() async {
    final result = await controller.confirmBorrowing();
    if (result == null) return;

    // Ganti halaman checkout dengan halaman sukses (tidak ada back ke checkout)
    Get.off(
      () => LibraryCheckoutSuccessPage(result: result),
      transition: Transition.fadeIn,
    );
  }

  void _updateBorrowDateRange(DateTimeRange range) {
    controller.borrowDate.value = DateUtils.dateOnly(range.start);
    controller.returnDate.value = DateUtils.dateOnly(range.end);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuminaColors.background,
      bottomNavigationBar: _CheckoutBottomAction(
        controller: controller,
        onConfirmTap: _confirmBorrowing,
      ),
      body: Column(
        children: [
          const LibraryTransactionTopBar(
            title: 'Checkout Peminjaman',
          ),
          Expanded(
            child: Obx(() {
              final books = controller.checkedItems.map(LibraryCartBook.fromCartItem).toList();

              if (books.isEmpty) {
                return const _CheckoutEmptyState();
              }

              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  LuminaSpacing.marginMobile,
                  LuminaSpacing.md,
                  LuminaSpacing.marginMobile,
                  LuminaSpacing.xl,
                ),
                children: [
                  _CheckoutSummaryCard(
                    controller: controller,
                  ),

                  const SizedBox(height: LuminaSpacing.lg),

                  _SectionHeader(
                    title: 'Periode Peminjaman',
                    subtitle:
                        'Tanggal pinjam tidak boleh mundur dan maksimal ${LibraryCartController.maxBorrowDays} hari.',
                  ),

                  const SizedBox(height: LuminaSpacing.md),

                  LuminaDateRangeBottomSheetField(
                    value: DateTimeRange(
                      start: controller.borrowDate.value,
                      end: controller.returnDate.value,
                    ),
                    title: 'Periode Peminjaman',
                    subtitle: 'Pilih tanggal pinjam dan tanggal pengembalian',
                    startLabel: 'Tanggal Pinjam',
                    endLabel: 'Tanggal Kembali',
                    maxRangeDays: LibraryCartController.maxBorrowDays,
                    allowBackdate: false,
                    onChanged: _updateBorrowDateRange,
                  ),

                  const SizedBox(height: LuminaSpacing.md),

                  _ReturnDeadlineAlert(
                    borrowDate: controller.borrowDate.value,
                    returnDate: controller.returnDate.value,
                    latestReturnDate: controller.latestReturnDate,
                    durationDays: controller.borrowDurationDays,
                    isValid: controller.isBorrowRangeValid,
                  ),

                  const SizedBox(height: LuminaSpacing.xl),

                  _SectionHeader(
                    title: 'Buku yang Dipinjam',
                    subtitle: '${books.length} buku dipilih dari keranjang',
                  ),

                  const SizedBox(height: LuminaSpacing.md),

                  _CheckoutBookList(
                    books: books,
                  ),

                  const SizedBox(height: LuminaSpacing.xl),

                  const _BorrowingRulesCard(),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _CheckoutSummaryCard extends StatelessWidget {
  const _CheckoutSummaryCard({
    required this.controller,
  });

  final LibraryCartController controller;

  @override
  Widget build(BuildContext context) {
    final libraryName = controller.selectedBranchName ?? 'Perpustakaan';
    final count = controller.checkedCount;

    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.primary,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        boxShadow: [
          BoxShadow(
            color: LuminaColors.primary.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(LuminaRadius.lg),
            ),
            child: const Icon(
              Icons.fact_check_rounded,
              color: LuminaColors.onPrimary,
              size: 28,
            ),
          ),

          const SizedBox(width: LuminaSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  libraryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LuminaTextStyles.titleLg.copyWith(
                    color: LuminaColors.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count buku siap diajukan untuk peminjaman.',
                  style: LuminaTextStyles.bodyMd.copyWith(
                    color: LuminaColors.onPrimary.withOpacity(0.78),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutBookList extends StatelessWidget {
  const _CheckoutBookList({
    required this.books,
  });

  final List<LibraryCartBook> books;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(
          color: LuminaColors.outlineVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(books.length, (index) {
          final book = books[index];

          return Container(
            padding: const EdgeInsets.all(LuminaSpacing.md),
            decoration: BoxDecoration(
              border: index == 0
                  ? null
                  : const Border(
                      top: BorderSide(
                        color: LuminaColors.surfaceVariant,
                        width: 1,
                      ),
                    ),
            ),
            child: LibraryCartBookTile(
              book: book,
              coverWidth: 60,
              coverHeight: 82,
              showCheckbox: false,
              showDeleteButton: false,
            ),
          );
        }),
      ),
    );
  }
}

class _ReturnDeadlineAlert extends StatelessWidget {
  const _ReturnDeadlineAlert({
    required this.borrowDate,
    required this.returnDate,
    required this.latestReturnDate,
    required this.durationDays,
    required this.isValid,
  });

  final DateTime borrowDate;
  final DateTime returnDate;
  final DateTime latestReturnDate;
  final int durationDays;
  final bool isValid;

  String _formatDateLong(DateTime value) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final day = value.day.toString().padLeft(2, '0');
    final month = months[value.month - 1];
    final year = value.year.toString();

    return '$day $month $year';
  }

  @override
  Widget build(BuildContext context) {
    final isAtLimit = durationDays == LibraryCartController.maxBorrowDays;

    final backgroundColor = !isValid
        ? LuminaColors.errorContainer
        : isAtLimit
            ? LuminaColors.errorContainer.withOpacity(0.58)
            : LuminaColors.secondary.withOpacity(0.10);

    final accentColor = !isValid || isAtLimit
        ? LuminaColors.error
        : LuminaColors.secondary;

    final title = !isValid
        ? 'Periode peminjaman tidak valid'
        : isAtLimit
            ? 'Batas maksimal pengembalian'
            : 'Batas pengembalian aman';

    final description = !isValid
        ? 'Durasi peminjaman harus 1 sampai ${LibraryCartController.maxBorrowDays} hari.'
        : isAtLimit
            ? 'Buku wajib dikembalikan paling telat ${_formatDateLong(latestReturnDate)}.'
            : 'Buku perlu dikembalikan pada ${_formatDateLong(returnDate)}. Maksimal sampai ${_formatDateLong(latestReturnDate)}.';

    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(
          color: accentColor.withOpacity(0.18),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isValid
                  ? Icons.notifications_active_rounded
                  : Icons.warning_rounded,
              color: accentColor,
              size: 22,
            ),
          ),

          const SizedBox(width: LuminaSpacing.sm),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: LuminaTextStyles.bodyMd.copyWith(
                    color: LuminaColors.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: LuminaColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BorrowingRulesCard extends StatelessWidget {
  const _BorrowingRulesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(
          color: LuminaColors.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        children: const [
          _RuleItem(
            icon: Icons.event_available_rounded,
            title: 'Maksimal 14 hari',
            description:
                'Tanggal pengembalian otomatis dibatasi maksimal 14 hari dari tanggal pinjam.',
          ),
          SizedBox(height: LuminaSpacing.md),
          _RuleItem(
            icon: Icons.history_toggle_off_rounded,
            title: 'Tidak bisa backdate',
            description:
                'Tanggal pinjam tidak dapat dipilih sebelum hari ini.',
          ),
          SizedBox(height: LuminaSpacing.md),
          _RuleItem(
            icon: Icons.local_library_rounded,
            title: 'Satu perpustakaan',
            description:
                'Checkout hanya dapat dilakukan untuk buku dari satu perpustakaan.',
          ),
        ],
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  const _RuleItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: LuminaColors.primary.withOpacity(0.07),
            borderRadius: BorderRadius.circular(LuminaRadius.md),
          ),
          child: Icon(
            icon,
            color: LuminaColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: LuminaSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: LuminaTextStyles.bodyMd.copyWith(
                  color: LuminaColors.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: LuminaTextStyles.labelMd.copyWith(
                  color: LuminaColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CheckoutBottomAction extends StatelessWidget {
  const _CheckoutBottomAction({
    required this.controller,
    required this.onConfirmTap,
  });

  final LibraryCartController controller;
  final VoidCallback onConfirmTap;

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
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, -8),
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
            final isValid = controller.isBorrowRangeValid;
            final isCheckingOut = controller.isCheckoutLoading.value;
            final canSubmit = count > 0 && isValid && !isCheckingOut;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total Peminjaman',
                        style: LuminaTextStyles.bodyLg.copyWith(
                          color: LuminaColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '$count Buku',
                      style: LuminaTextStyles.headlineSm.copyWith(
                        color: LuminaColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: LuminaSpacing.md),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: canSubmit ? onConfirmTap : null,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: LuminaColors.primary,
                      disabledBackgroundColor:
                          LuminaColors.surfaceContainerHigh,
                      foregroundColor: LuminaColors.onPrimary,
                      disabledForegroundColor:
                          LuminaColors.onSurfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(LuminaRadius.lg),
                      ),
                    ),
                    child: isCheckingOut
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: LuminaColors.onPrimary,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Ajukan Peminjaman',
                                style: LuminaTextStyles.titleLg.copyWith(
                                  color: canSubmit
                                      ? LuminaColors.onPrimary
                                      : LuminaColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: LuminaSpacing.xs),
                              const Icon(
                                Icons.check_circle_rounded,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: LuminaTextStyles.titleLg.copyWith(
            color: LuminaColors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(
            subtitle!,
            style: LuminaTextStyles.bodyMd.copyWith(
              color: LuminaColors.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}

class _CheckoutEmptyState extends StatelessWidget {
  const _CheckoutEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LuminaSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: LuminaColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.remove_shopping_cart_outlined,
                color: LuminaColors.outline,
                size: 36,
              ),
            ),
            const SizedBox(height: LuminaSpacing.md),
            Text(
              'Belum Ada Buku Dipilih',
              style: LuminaTextStyles.titleLg.copyWith(
                color: LuminaColors.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: LuminaSpacing.xs),
            Text(
              'Pilih minimal satu buku dari keranjang untuk melanjutkan checkout.',
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