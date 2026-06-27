import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/core/services/websocket/websocket_event.dart';
import 'package:lumina_library/core/services/websocket/websocket_service.dart';
import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/mahasiswa/data/services/payment_api_service.dart';
import 'package:lumina_library/shared/models/payment/borrowing_payment_model.dart';
import 'package:lumina_library/shared/widgets/feedback/lumina_toast.dart';
import 'package:lumina_library/shared/widgets/payment/payment_countdown.dart';
import 'package:lumina_library/shared/widgets/payment/payment_instruction_card.dart';
import 'package:lumina_library/shared/widgets/payment/payment_method_selector.dart';
import 'package:lumina_library/shared/widgets/payment/payment_success_dialog.dart';
import 'package:lumina_library/shared/widgets/payment/payment_summary_card.dart';

/// Dedicated Payment Detail page (never a BottomSheet) — opened from the
/// borrowing detail page's "Proceed to Payment" button. Shows outstanding
/// amount, lets the member pick a Midtrans Core API method, displays the
/// resulting VA/QRIS/e-wallet details, and reacts live to `payment.*`
/// WebSocket events instead of polling. On success, automatically pops
/// back to whatever pushed this page (the borrowing detail page), which
/// refreshes itself — see library_my_book_detail_page.dart.
class LibraryPaymentPage extends StatefulWidget {
  const LibraryPaymentPage({
    super.key,
    required this.borrowingId,
    required this.borrowingCode,
  });

  final String borrowingId;
  final String borrowingCode;

  @override
  State<LibraryPaymentPage> createState() => _LibraryPaymentPageState();
}

class _LibraryPaymentPageState extends State<LibraryPaymentPage> {
  BorrowingPaymentModel? _payment;
  bool _isLoading = true;
  bool _isCreating = false;
  bool _isRefreshing = false;
  bool _showMethodPicker = false;
  bool _hasPoppedAfterSuccess = false;
  String? _selectedMethod;
  StreamSubscription<WebSocketEvent>? _wsSubscription;

  PaymentApiService get _service => Get.find<PaymentApiService>();

  @override
  void initState() {
    super.initState();
    _loadExisting();
    _listenToRealtimeEvents();
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    super.dispose();
  }

  void _listenToRealtimeEvents() {
    if (!Get.isRegistered<WebSocketService>()) return;

    _wsSubscription = Get.find<WebSocketService>().events.listen((event) {
      if (event.borrowingId != widget.borrowingId) return;

      switch (event.name) {
        case 'payment.success':
          unawaited(_refetchSilently());
          if (!mounted) return;
          unawaited(_celebrateAndReturn(
            amount: (event.data['total_amount'] as num?)?.toDouble() ?? _payment?.totalAmount ?? 0,
            orderId: (event.data['order_id'] as String?) ?? _payment?.midtransOrderId ?? '',
          ));
        case 'payment.pending':
        case 'payment.expired':
        case 'payment.cancelled':
          unawaited(_refetchSilently());
      }
    });
  }

  Future<void> _refetchSilently() async {
    try {
      final payment = await _service.byBorrowing(widget.borrowingId);
      if (mounted) setState(() => _payment = payment);
    } catch (_) {}
  }

  /// Shows the success dialog, then automatically navigates back to the
  /// caller (the borrowing detail page) — "automatically navigate back to
  /// the same Book Detail page" per spec. Guarded so a second success
  /// signal (e.g. WS event arriving right after a manual refresh already
  /// confirmed it) doesn't pop twice.
  Future<void> _celebrateAndReturn({required double amount, required String orderId}) async {
    if (_hasPoppedAfterSuccess) return;
    _hasPoppedAfterSuccess = true;

    await PaymentSuccessDialog.show(
      context,
      amount: amount,
      orderId: orderId,
      borrowingCode: widget.borrowingCode,
    );

    if (mounted) Get.back();
  }

  Future<void> _loadExisting() async {
    setState(() => _isLoading = true);
    try {
      final payment = await _service.byBorrowing(widget.borrowingId);
      if (!mounted) return;
      setState(() {
        _payment = payment;
        _showMethodPicker = payment == null;
        _isLoading = false;
      });
    } on LuminaApiException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      LuminaToast.error(e.displayMessage);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      LuminaToast.error('Gagal memuat data pembayaran.');
    }
  }

  Future<void> _createPayment(String method) async {
    setState(() => _isCreating = true);
    try {
      final payment = await _service.create(borrowingId: widget.borrowingId, paymentMethod: method);
      if (!mounted) return;
      setState(() {
        _payment = payment;
        _showMethodPicker = false;
        _isCreating = false;
        _selectedMethod = null;
      });
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

  Future<void> _refreshStatus() async {
    final payment = _payment;
    if (payment == null) return;

    setState(() => _isRefreshing = true);
    try {
      final updated = await _service.refresh(payment.id);
      if (!mounted) return;
      setState(() {
        _payment = updated;
        _isRefreshing = false;
      });
      if (updated.isPaid) {
        unawaited(_celebrateAndReturn(amount: updated.totalAmount, orderId: updated.midtransOrderId));
      } else {
        LuminaToast.success('Status pembayaran diperbarui.');
      }
    } on LuminaApiException catch (e) {
      if (!mounted) return;
      setState(() => _isRefreshing = false);
      LuminaToast.error(e.displayMessage);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isRefreshing = false);
      LuminaToast.error('Gagal memeriksa status pembayaran.');
    }
  }

  void _openMethodPicker() {
    setState(() {
      _showMethodPicker = true;
      _selectedMethod = _payment?.paymentMethod;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuminaColors.background,
      appBar: AppBar(
        backgroundColor: LuminaColors.surface,
        elevation: 0,
        foregroundColor: LuminaColors.primary,
        title: Text(
          'Payment Detail',
          style: LuminaTextStyles.titleLg.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w900),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _payment != null && !_showMethodPicker
                    ? _PaymentDetailView(
                        key: const ValueKey('detail'),
                        payment: _payment!,
                        isRefreshing: _isRefreshing,
                        onRefresh: _refreshStatus,
                        onChangeMethod: _openMethodPicker,
                        onRetry: _openMethodPicker,
                      )
                    : _MethodPickerView(
                        key: const ValueKey('picker'),
                        selected: _selectedMethod,
                        isCreating: _isCreating,
                        onSelect: (method) => setState(() => _selectedMethod = method),
                        onConfirm: _selectedMethod == null ? null : () => _createPayment(_selectedMethod!),
                      ),
              ),
            ),
    );
  }
}

class _PaymentDetailView extends StatelessWidget {
  const _PaymentDetailView({
    super.key,
    required this.payment,
    required this.isRefreshing,
    required this.onRefresh,
    required this.onChangeMethod,
    required this.onRetry,
  });

  final BorrowingPaymentModel payment;
  final bool isRefreshing;
  final VoidCallback onRefresh;
  final VoidCallback onChangeMethod;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final canRetry = payment.isExpired || payment.status == 'failed' || payment.status == 'cancelled';

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        LuminaSpacing.marginMobile,
        LuminaSpacing.lg,
        LuminaSpacing.marginMobile,
        LuminaSpacing.xl,
      ),
      children: [
        PaymentSummaryCard(
          amount: payment.totalAmount,
          status: payment.status,
          orderId: payment.midtransOrderId,
          purpose: payment.purpose,
        ),
        if (payment.isPending && payment.expiredAt != null) ...[
          const SizedBox(height: LuminaSpacing.lg),
          Center(child: PaymentCountdown(expiresAt: payment.expiredAt!, large: true)),
        ],
        if (payment.isPending) ...[
          const SizedBox(height: LuminaSpacing.lg),
          PaymentInstructionCard(payment: payment),
        ],
        const SizedBox(height: LuminaSpacing.lg),
        if (!payment.isPaid) ...[
          if (canRetry)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.replay_rounded, size: 18),
                label: const Text('Retry Payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: LuminaColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isRefreshing ? null : onRefresh,
                    icon: isRefreshing
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Refresh Status'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: LuminaColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                  ),
                ),
                const SizedBox(width: LuminaSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onChangeMethod,
                    icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                    label: const Text('Change Method'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: LuminaColors.secondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ],
    );
  }
}

class _MethodPickerView extends StatelessWidget {
  const _MethodPickerView({
    super.key,
    required this.selected,
    required this.isCreating,
    required this.onSelect,
    required this.onConfirm,
  });

  final String? selected;
  final bool isCreating;
  final ValueChanged<String> onSelect;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        LuminaSpacing.marginMobile,
        LuminaSpacing.lg,
        LuminaSpacing.marginMobile,
        LuminaSpacing.xl,
      ),
      children: [
        Text(
          'Pilih Metode Pembayaran',
          style: LuminaTextStyles.titleMd.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: LuminaSpacing.sm),
        PaymentMethodSelector(selected: selected, onSelect: onSelect),
        const SizedBox(height: LuminaSpacing.md),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: isCreating ? null : onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: LuminaColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: isCreating
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(
                    'Continue Payment',
                    style: LuminaTextStyles.titleSm.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
                  ),
          ),
        ),
      ],
    );
  }
}
