import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/lumina_colors.dart';
import '../../../../core/theme/lumina_radius.dart';
import '../../../../core/theme/lumina_spacing.dart';
import '../../../../core/theme/lumina_text_styles.dart';
import '../controllers/library_cart_controller.dart';
import '../widgets/library_cart_book_tile.dart';
import '../widgets/library_transaction_top_bar.dart';

class LibraryCheckoutPage extends StatelessWidget {
  const LibraryCheckoutPage({
    super.key,
  });

  LibraryCartController get controller => Get.isRegistered<LibraryCartController>()
      ? Get.find<LibraryCartController>()
      : Get.put(LibraryCartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuminaColors.background,
      bottomNavigationBar: _CheckoutBottomAction(
        controller: controller,
      ),
      body: Column(
        children: [
          const LibraryTransactionTopBar(
            title: 'Checkout Peminjaman',
          ),
          Expanded(
            child: Obx(() {
              final books = controller.checkedItems;

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
                  _SectionTitle(
                    title: 'Buku yang Dipinjam',
                    subtitle: '${books.length} buku dipilih dari keranjang',
                  ),

                  const SizedBox(height: LuminaSpacing.sm),

                  ...List.generate(books.length, (index) {
                    final item = books[index];

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == books.length - 1
                            ? 0
                            : LuminaSpacing.xs,
                      ),
                      child: LibraryCartBookTile(
                        book: item,
                        coverWidth: 64,
                        coverHeight: 86,
                      ),
                    );
                  }),

                  const SizedBox(height: LuminaSpacing.xl),

                  const Divider(
                    color: LuminaColors.outlineVariant,
                    height: 1,
                  ),

                  const SizedBox(height: LuminaSpacing.xl),

                  const _SectionTitle(
                    title: 'Periode Peminjaman',
                    subtitle: 'Pilih tanggal pinjam dan tanggal pengembalian',
                  ),

                  const SizedBox(height: LuminaSpacing.md),

                  _BorrowDateRangeField(
                    borrowDate: controller.borrowDate.value,
                    returnDate: controller.returnDate.value,
                    onTap: () => controller.pickBorrowDateRange(context),
                  ),

                  const SizedBox(height: LuminaSpacing.md),

                  _ReturnDeadlineAlert(
                    borrowDate: controller.borrowDate.value,
                    returnDate: controller.returnDate.value,
                    latestReturnDate: controller.latestReturnDate,
                    durationDays: controller.borrowDurationDays,
                    isValid: controller.isBorrowRangeValid,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
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
            fontWeight: FontWeight.w800,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(
            subtitle!,
            style: LuminaTextStyles.bodyMd.copyWith(
              color: LuminaColors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _BorrowDateRangeField extends StatelessWidget {
  const _BorrowDateRangeField({
    required this.borrowDate,
    required this.returnDate,
    required this.onTap,
  });

  final DateTime borrowDate;
  final DateTime returnDate;
  final VoidCallback onTap;

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();

    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LuminaColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(LuminaRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(LuminaSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LuminaRadius.lg),
            border: Border.all(
              color: LuminaColors.outlineVariant,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: LuminaColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.date_range_rounded,
                  color: LuminaColors.primary,
                  size: 22,
                ),
              ),

              const SizedBox(width: LuminaSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rentang Tanggal Peminjaman',
                      style: LuminaTextStyles.labelMd.copyWith(
                        color: LuminaColors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${_formatDate(borrowDate)} - ${_formatDate(returnDate)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LuminaTextStyles.bodyLg.copyWith(
                        color: LuminaColors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: LuminaSpacing.sm),

              const Icon(
                Icons.expand_more_rounded,
                color: LuminaColors.onSurfaceVariant,
                size: 24,
              ),
            ],
          ),
        ),
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

    final backgroundColor = isValid
        ? isAtLimit
            ? LuminaColors.errorContainer.withOpacity(0.65)
            : LuminaColors.tertiaryContainer
        : LuminaColors.errorContainer;

    final iconColor = isValid
        ? isAtLimit
            ? LuminaColors.onErrorContainer
            : LuminaColors.inversePrimary
        : LuminaColors.onErrorContainer;

    final titleColor = isValid
        ? isAtLimit
            ? LuminaColors.onErrorContainer
            : LuminaColors.onTertiary
        : LuminaColors.onErrorContainer;

    final bodyColor = isValid
        ? isAtLimit
            ? LuminaColors.onErrorContainer
            : LuminaColors.inversePrimary
        : LuminaColors.onErrorContainer;

    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(
          color: isAtLimit || !isValid
              ? LuminaColors.error.withOpacity(0.20)
              : LuminaColors.inversePrimary.withOpacity(0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isAtLimit || !isValid
                    ? LuminaColors.error
                    : LuminaColors.tertiaryContainer)
                .withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isValid
                  ? Colors.white.withOpacity(isAtLimit ? 0.35 : 0.12)
                  : LuminaColors.onError.withOpacity(0.45),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isValid
                  ? Icons.event_available_rounded
                  : Icons.error_outline_rounded,
              color: iconColor,
              size: 23,
            ),
          ),

          const SizedBox(width: LuminaSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isValid
                      ? 'Batas Pengembalian Buku'
                      : 'Periode Peminjaman Tidak Valid',
                  style: LuminaTextStyles.bodyLg.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: isValid
                            ? 'Buku harus dikembalikan paling telat '
                            : 'Tanggal pengembalian harus setelah tanggal pinjam dan maksimal ',
                      ),
                      TextSpan(
                        text: isValid
                            ? _formatDateLong(returnDate)
                            : '${LibraryCartController.maxBorrowDays} hari',
                        style: LuminaTextStyles.bodyMd.copyWith(
                          color: bodyColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextSpan(
                        text: isValid
                            ? '. Durasi peminjaman Anda $durationDays hari.'
                            : ' dari tanggal pinjam.',
                      ),
                    ],
                  ),
                  style: LuminaTextStyles.bodyMd.copyWith(
                    color: bodyColor,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: LuminaSpacing.sm),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: LuminaSpacing.sm,
                    vertical: LuminaSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(isValid ? 0.12 : 0.45),
                    borderRadius: BorderRadius.circular(LuminaRadius.lg),
                  ),
                  child: Text(
                    'Maksimal tanggal kembali: ${_formatDateLong(latestReturnDate)}',
                    style: LuminaTextStyles.labelMd.copyWith(
                      color: bodyColor,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
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

class _CheckoutBottomAction extends StatelessWidget {
  const _CheckoutBottomAction({
    required this.controller,
  });

  final LibraryCartController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LuminaColors.surface.withOpacity(0.96),
        border: Border(
          top: BorderSide(
            color: LuminaColors.outlineVariant.withOpacity(0.30),
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
          padding: const EdgeInsets.all(LuminaSpacing.marginMobile),
          child: Obx(() {
            final canConfirm =
                controller.checkedCount > 0 && controller.isBorrowRangeValid;

            return SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: canConfirm ? controller.confirmBorrowing : null,
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
                      'Konfirmasi Peminjaman',
                      style: LuminaTextStyles.titleLg.copyWith(
                        color: canConfirm
                            ? LuminaColors.onPrimary
                            : LuminaColors.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: LuminaSpacing.sm),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 22,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
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
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: LuminaColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.checklist_rounded,
                color: LuminaColors.outline,
                size: 34,
              ),
            ),
            const SizedBox(height: LuminaSpacing.md),
            Text(
              'Belum ada buku dipilih',
              style: LuminaTextStyles.titleLg.copyWith(
                color: LuminaColors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: LuminaSpacing.xs),
            Text(
              'Kembali ke keranjang dan centang buku yang ingin dipinjam.',
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
