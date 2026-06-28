import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/mahasiswa/data/services/payment_api_service.dart';
import 'package:lumina_library/shared/models/payment/borrowing_payment_model.dart';
import 'package:lumina_library/shared/widgets/feedback/lumina_toast.dart';
import 'package:lumina_library/shared/widgets/payment/payment_method_selector.dart';
import 'package:lumina_library/shared/widgets/payment/payment_status_badge.dart';

/// Step 1 of the payment flow — opened from Book Detail's "Proceed to
/// Payment" button. Shows the outstanding fine, the current payment status
/// (if a charge already exists for this borrowing), and the method list.
/// Only once the member taps "Continue" does a charge actually get created
/// and the dedicated Payment Detail page open — this sheet itself never
/// navigates anywhere on its own.
class PaymentMethodBottomSheet {
  const PaymentMethodBottomSheet._();

  static Future<BorrowingPaymentModel?> show(
    BuildContext context, {
    required String borrowingId,
    required String borrowingCode,
    required double outstandingFineAmount,
  }) {
    return showModalBottomSheet<BorrowingPaymentModel>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (_) => _PaymentMethodSheetBody(
        borrowingId: borrowingId,
        borrowingCode: borrowingCode,
        outstandingFineAmount: outstandingFineAmount,
      ),
    );
  }
}

class _PaymentMethodSheetBody extends StatefulWidget {
  const _PaymentMethodSheetBody({
    required this.borrowingId,
    required this.borrowingCode,
    required this.outstandingFineAmount,
  });

  final String borrowingId;
  final String borrowingCode;
  final double outstandingFineAmount;

  @override
  State<_PaymentMethodSheetBody> createState() => _PaymentMethodSheetBodyState();
}

class _PaymentMethodSheetBodyState extends State<_PaymentMethodSheetBody> {
  static final _currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  BorrowingPaymentModel? _existing;
  bool _isLoading = true;
  bool _isCreating = false;
  String? _selectedMethod;

  PaymentApiService get _service => Get.find<PaymentApiService>();

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    try {
      final payment = await _service.byBorrowing(widget.borrowingId);
      if (!mounted) return;
      setState(() {
        _existing = payment;
        _selectedMethod = (payment != null && payment.isPending && !payment.isExpired) ? payment.paymentMethod : null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _continue() async {
    final method = _selectedMethod;
    if (method == null || _isCreating) return;

    setState(() => _isCreating = true);
    try {
      final existing = _existing;
      final reusable = existing != null &&
          existing.paymentMethod == method &&
          existing.isPending &&
          !existing.isExpired;

      final payment = reusable ? existing : await _service.create(borrowingId: widget.borrowingId, paymentMethod: method);

      if (!mounted) return;
      Navigator.of(context).pop(payment);
    } on LuminaApiException catch (e) {
      if (!mounted) return;
      setState(() => _isCreating = false);
      LuminaToast.error(e.displayMessage);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isCreating = false);
      LuminaToast.error('Gagal membuat pembayaran. Silakan coba lagi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: LuminaColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(LuminaRadius.xl)),
          ),
          child: Column(
            children: [
              const SizedBox(height: LuminaSpacing.sm),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: LuminaColors.outlineVariant.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(LuminaRadius.full),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(
                          LuminaSpacing.marginMobile,
                          LuminaSpacing.md,
                          LuminaSpacing.marginMobile,
                          LuminaSpacing.lg,
                        ),
                        children: [
                          Text(
                            'Pembayaran Denda',
                            style: LuminaTextStyles.titleLg.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: LuminaSpacing.md),
                          _OutstandingFineRow(amount: widget.outstandingFineAmount, existing: _existing, currencyFormat: _currencyFormat),
                          const SizedBox(height: LuminaSpacing.lg),
                          Text(
                            'Pilih Metode Pembayaran',
                            style: LuminaTextStyles.titleMd.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: LuminaSpacing.xs),
                          PaymentMethodSelector(selected: _selectedMethod, onSelect: (m) => setState(() => _selectedMethod = m)),
                        ],
                      ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(
                  LuminaSpacing.marginMobile,
                  LuminaSpacing.sm,
                  LuminaSpacing.marginMobile,
                  LuminaSpacing.md,
                ),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: LuminaColors.outlineVariant.withOpacity(0.3))),
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (_selectedMethod == null || _isCreating) ? null : _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LuminaColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: LuminaColors.outlineVariant,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LuminaRadius.full)),
                      ),
                      child: _isCreating
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(
                              'Continue',
                              style: LuminaTextStyles.titleSm.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OutstandingFineRow extends StatelessWidget {
  const _OutstandingFineRow({required this.amount, required this.existing, required this.currencyFormat});

  final double amount;
  final BorrowingPaymentModel? existing;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [LuminaColors.primary, LuminaColors.primary.withOpacity(0.82)],
        ),
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Outstanding Fine',
                  style: LuminaTextStyles.labelMd.copyWith(color: Colors.white.withOpacity(0.75), letterSpacing: 0),
                ),
                const SizedBox(height: 2),
                Text(
                  currencyFormat.format(existing?.totalAmount ?? amount),
                  style: LuminaTextStyles.titleLg.copyWith(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24),
                ),
              ],
            ),
          ),
          if (existing != null) PaymentStatusBadge(status: existing!.status, compact: true),
        ],
      ),
    );
  }
}
