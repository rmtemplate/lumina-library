import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/core/services/websocket/websocket_event.dart';
import 'package:lumina_library/core/services/websocket/websocket_service.dart';
import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/mahasiswa/data/services/payment_api_service.dart';
import 'package:lumina_library/shared/models/payment/borrowing_payment_model.dart';
import 'package:lumina_library/shared/widgets/feedback/lumina_toast.dart';
import 'package:lumina_library/shared/widgets/payment/payment_countdown.dart';
import 'package:lumina_library/shared/widgets/payment/payment_logo.dart';
import 'package:lumina_library/shared/widgets/payment/payment_method_bottom_sheet.dart';
import 'package:lumina_library/shared/widgets/payment/payment_qris_widget.dart';
import 'package:lumina_library/shared/widgets/payment/payment_success_dialog.dart';
import 'package:lumina_library/shared/widgets/payment/payment_summary_card.dart';
import 'package:lumina_library/shared/widgets/payment/payment_va_widget.dart';

/// Dedicated Payment Detail page — one per transaction. Always opened with
/// an already-created [payment] (the method picker now lives in
/// [PaymentMethodBottomSheet], not here). Renders a method-specific layout
/// (QRIS / Virtual Account / E-Wallet) and reacts live to `payment.*`
/// WebSocket events instead of polling. On success, automatically pops
/// back to whatever pushed this page (the borrowing detail page), which
/// refreshes itself — see library_my_book_detail_page.dart.
class LibraryPaymentPage extends StatefulWidget {
  const LibraryPaymentPage({
    super.key,
    required this.borrowingId,
    required this.borrowingCode,
    required this.payment,
  });

  final String borrowingId;
  final String borrowingCode;
  final BorrowingPaymentModel payment;

  @override
  State<LibraryPaymentPage> createState() => _LibraryPaymentPageState();
}

class _LibraryPaymentPageState extends State<LibraryPaymentPage> {
  late BorrowingPaymentModel _payment;
  bool _isRefreshing = false;
  bool _isProcessingQr = false;
  bool _hasPoppedAfterSuccess = false;
  StreamSubscription<WebSocketEvent>? _wsSubscription;
  final GlobalKey _qrBoundaryKey = GlobalKey();

  PaymentApiService get _service => Get.find<PaymentApiService>();

  @override
  void initState() {
    super.initState();
    _payment = widget.payment;
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
            amount: (event.data['total_amount'] as num?)?.toDouble() ?? _payment.totalAmount,
            orderId: (event.data['order_id'] as String?) ?? _payment.midtransOrderId,
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
      final payment = await _service.show(_payment.id);
      if (mounted) setState(() => _payment = payment);
    } catch (_) {}
  }

  /// Shows the success dialog, then automatically navigates back to the
  /// caller (the borrowing detail page) — guarded so a second success
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

  Future<void> _refreshStatus() async {
    setState(() => _isRefreshing = true);
    try {
      final updated = await _service.refresh(_payment.id);
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

  Future<void> _changeMethod() async {
    final result = await PaymentMethodBottomSheet.show(
      context,
      borrowingId: widget.borrowingId,
      borrowingCode: widget.borrowingCode,
      outstandingFineAmount: _payment.totalAmount,
    );
    if (result != null && mounted) {
      setState(() => _payment = result);
    }
  }

  Future<Uint8List?> _captureQrImage() async {
    try {
      final boundary = _qrBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveQr() async {
    if (_isProcessingQr) return;
    setState(() => _isProcessingQr = true);
    try {
      final bytes = await _captureQrImage();
      if (bytes == null) {
        LuminaToast.error('Gagal menyimpan QR.');
        return;
      }
      final hasAccess = await Gal.hasAccess() || await Gal.requestAccess();
      if (!hasAccess) {
        LuminaToast.error('Izin akses galeri ditolak.');
        return;
      }
      await Gal.putImageBytes(bytes, name: 'qris_${_payment.midtransOrderId}');
      LuminaToast.success('QR berhasil disimpan ke galeri.');
    } catch (_) {
      LuminaToast.error('Gagal menyimpan QR.');
    } finally {
      if (mounted) setState(() => _isProcessingQr = false);
    }
  }

  Future<void> _shareQr() async {
    if (_isProcessingQr) return;
    setState(() => _isProcessingQr = true);
    try {
      final bytes = await _captureQrImage();
      if (bytes == null) {
        LuminaToast.error('Gagal membagikan QR.');
        return;
      }
      await SharePlus.instance.share(ShareParams(
        files: [XFile.fromData(bytes, mimeType: 'image/png', name: 'qris_${_payment.midtransOrderId}.png')],
        text: 'Pembayaran Lumina Library — No. Transaksi: ${_payment.midtransOrderId}',
      ));
    } catch (_) {
      LuminaToast.error('Gagal membagikan QR.');
    } finally {
      if (mounted) setState(() => _isProcessingQr = false);
    }
  }

  Future<void> _openDeeplink() async {
    final url = _payment.deeplinkUrl;
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      LuminaToast.error('Tidak dapat membuka aplikasi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final payment = _payment;
    final canChangeMethod = !payment.isPaid;
    final isTerminal = payment.isExpired || payment.status == 'failed' || payment.status == 'cancelled';

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
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: ListView(
            key: ValueKey(payment.id),
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
              const SizedBox(height: LuminaSpacing.lg),
              if (payment.isQris)
                _QrisSection(
                  payment: payment,
                  boundaryKey: _qrBoundaryKey,
                  isProcessing: _isProcessingQr,
                  onSave: _saveQr,
                  onShare: _shareQr,
                )
              else if (payment.isVirtualAccount || payment.isMandiriBill)
                _VirtualAccountSection(payment: payment)
              else if (payment.isEWallet)
                _EWalletSection(payment: payment, onOpenApp: _openDeeplink),
              const SizedBox(height: LuminaSpacing.lg),
              if (!payment.isPaid) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _isRefreshing ? null : _refreshStatus,
                    icon: _isRefreshing
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Refresh Status'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: LuminaColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                  ),
                ),
                if (canChangeMethod) ...[
                  const SizedBox(height: LuminaSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: isTerminal
                        ? ElevatedButton.icon(
                            onPressed: _changeMethod,
                            icon: const Icon(Icons.replay_rounded, size: 18),
                            label: const Text('Retry Payment'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LuminaColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                            ),
                          )
                        : OutlinedButton.icon(
                            onPressed: _changeMethod,
                            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                            label: const Text('Change Payment Method'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: LuminaColors.secondary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                            ),
                          ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QrisSection extends StatelessWidget {
  const _QrisSection({
    required this.payment,
    required this.boundaryKey,
    required this.isProcessing,
    required this.onSave,
    required this.onShare,
  });

  final BorrowingPaymentModel payment;
  final GlobalKey boundaryKey;
  final bool isProcessing;
  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(color: LuminaColors.outlineVariant),
      ),
      child: Column(
        children: [
          Text(
            payment.instructionsText,
            textAlign: TextAlign.center,
            style: LuminaTextStyles.labelMd.copyWith(color: LuminaColors.onSurfaceVariant, height: 1.5, letterSpacing: 0),
          ),
          const SizedBox(height: LuminaSpacing.md),
          if (payment.qrString != null)
            RepaintBoundary(
              key: boundaryKey,
              child: PaymentQrisWidget(qrString: payment.qrString!),
            )
          else
            const Icon(Icons.qr_code_2_rounded, size: 96, color: LuminaColors.outline),
          if (payment.isPending && payment.expiredAt != null) ...[
            const SizedBox(height: LuminaSpacing.md),
            PaymentCountdown(expiresAt: payment.expiredAt!, large: true),
          ],
          if (payment.qrString != null) ...[
            const SizedBox(height: LuminaSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isProcessing ? null : onSave,
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Save QR'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: LuminaColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LuminaRadius.full)),
                    ),
                  ),
                ),
                const SizedBox(width: LuminaSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isProcessing ? null : onShare,
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text('Share QR'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: LuminaColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LuminaRadius.full)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _VirtualAccountSection extends StatelessWidget {
  const _VirtualAccountSection({required this.payment});

  final BorrowingPaymentModel payment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(color: LuminaColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PaymentLogo(method: payment.paymentMethod ?? '', size: 36),
              const SizedBox(width: LuminaSpacing.sm),
              Expanded(
                child: Text(
                  payment.paymentChannel ?? payment.paymentMethod ?? '',
                  style: LuminaTextStyles.titleSm.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: LuminaSpacing.md),
          if (payment.vaNumber != null)
            PaymentVaWidget(
              channelLabel: payment.paymentChannel ?? payment.paymentMethod ?? '',
              vaNumber: payment.vaNumber!,
              numberLabel: payment.isMandiriBill ? 'Bill Key' : 'Nomor Virtual Account',
            ),
          const SizedBox(height: LuminaSpacing.md),
          Text(
            payment.instructionsText,
            style: LuminaTextStyles.labelMd.copyWith(color: LuminaColors.onSurfaceVariant, height: 1.5, letterSpacing: 0),
          ),
          if (payment.isPending && payment.expiredAt != null) ...[
            const SizedBox(height: LuminaSpacing.md),
            Center(child: PaymentCountdown(expiresAt: payment.expiredAt!, large: true)),
          ],
        ],
      ),
    );
  }
}

class _EWalletSection extends StatelessWidget {
  const _EWalletSection({required this.payment, required this.onOpenApp});

  final BorrowingPaymentModel payment;
  final VoidCallback onOpenApp;

  @override
  Widget build(BuildContext context) {
    final appLabel = payment.paymentMethod == 'gopay' ? 'Gojek' : 'Shopee';

    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(color: LuminaColors.outlineVariant),
      ),
      child: Column(
        children: [
          PaymentLogo(method: payment.paymentMethod ?? '', size: 56),
          const SizedBox(height: LuminaSpacing.sm),
          Text(
            payment.instructionsText,
            textAlign: TextAlign.center,
            style: LuminaTextStyles.labelMd.copyWith(color: LuminaColors.onSurfaceVariant, height: 1.5, letterSpacing: 0),
          ),
          if (payment.deeplinkUrl != null) ...[
            const SizedBox(height: LuminaSpacing.md),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: onOpenApp,
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: Text('Buka Aplikasi $appLabel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: LuminaColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
              ),
            ),
          ],
          if (payment.isPending && payment.expiredAt != null) ...[
            const SizedBox(height: LuminaSpacing.md),
            PaymentCountdown(expiresAt: payment.expiredAt!, large: true),
          ],
        ],
      ),
    );
  }
}
