import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/staff/presentation/controllers/payment/staff_payments_controller.dart';
import 'package:lumina_library/shared/models/payment/borrowing_payment_model.dart';

/// Consolidated admin/staff view — Pending / Paid / Failed / Overdue /
/// Returned, all in one page (see docs/payment-flow.md for why this is one
/// page with tabs rather than five separate fully-built pages).
class StaffPaymentsPage extends StatelessWidget {
  const StaffPaymentsPage({super.key});

  StaffPaymentsController get controller => Get.isRegistered<StaffPaymentsController>()
      ? Get.find<StaffPaymentsController>()
      : Get.put(StaffPaymentsController(), permanent: true);

  static final _currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Scaffold(
      backgroundColor: LuminaColors.background,
      appBar: AppBar(
        backgroundColor: LuminaColors.surface,
        elevation: 0,
        foregroundColor: LuminaColors.primary,
        title: Text(
          'Pembayaran',
          style: LuminaTextStyles.titleLg.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w900),
        ),
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (c.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(c.errorMessage.value, style: LuminaTextStyles.bodyMd.copyWith(color: LuminaColors.error)),
                const SizedBox(height: LuminaSpacing.sm),
                OutlinedButton(onPressed: c.reload, child: const Text('Coba Lagi')),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: c.reload,
          child: Column(
            children: [
              _TabBar(controller: c),
              Expanded(
                child: c.filteredPayments.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 80),
                          Center(child: Text('Tidak ada data.')),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          LuminaSpacing.marginMobile,
                          LuminaSpacing.md,
                          LuminaSpacing.marginMobile,
                          LuminaSpacing.xl,
                        ),
                        itemCount: c.filteredPayments.length,
                        itemBuilder: (context, index) => _PaymentTile(
                          payment: c.filteredPayments[index],
                          currencyFormat: _currencyFormat,
                        ),
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.controller});

  final StaffPaymentsController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.marginMobile, vertical: LuminaSpacing.xs),
        itemCount: controller.tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: LuminaSpacing.xs),
        itemBuilder: (context, index) {
          final tab = controller.tabs[index];
          final isSelected = controller.selectedTabIndex.value == index;
          final count = controller.countFor(tab);

          return ChoiceChip(
            label: Text('$tab ($count)'),
            selected: isSelected,
            onSelected: (_) => controller.setTabIndex(index),
            selectedColor: LuminaColors.primary,
            labelStyle: LuminaTextStyles.labelMd.copyWith(
              color: isSelected ? Colors.white : LuminaColors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
            backgroundColor: LuminaColors.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LuminaRadius.full)),
            side: BorderSide.none,
          );
        },
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.payment, required this.currencyFormat});

  final BorrowingPaymentModel payment;
  final NumberFormat currencyFormat;

  Color get _statusColor => switch (payment.status) {
        'paid' => LuminaColors.secondary,
        'pending' => LuminaColors.primary,
        _ => LuminaColors.error,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: LuminaSpacing.sm),
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
        border: Border.all(color: LuminaColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  payment.memberName ?? 'Member',
                  style: LuminaTextStyles.bodyMd.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.sm, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(LuminaRadius.full),
                ),
                child: Text(
                  payment.status,
                  style: LuminaTextStyles.labelMd.copyWith(color: _statusColor, fontWeight: FontWeight.w900, letterSpacing: 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            payment.borrowingCode ?? payment.midtransOrderId,
            style: LuminaTextStyles.labelMd.copyWith(color: LuminaColors.outline, letterSpacing: 0),
          ),
          const SizedBox(height: LuminaSpacing.xs),
          Text(
            currencyFormat.format(payment.totalAmount),
            style: LuminaTextStyles.titleMd.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
