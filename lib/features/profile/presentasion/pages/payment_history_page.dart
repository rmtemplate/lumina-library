import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/mahasiswa/data/services/payment_api_service.dart';
import 'package:lumina_library/shared/models/payment/borrowing_payment_model.dart';
import 'package:lumina_library/shared/widgets/payment/payment_logo.dart';
import 'package:lumina_library/shared/widgets/payment/payment_status_badge.dart';

/// Member's own payment history — reuses PaymentApiService.history() (the
/// same endpoint already built for the staff side's data shape) and the
/// existing PaymentLogo/PaymentStatusBadge widgets rather than introducing
/// new ones for what is fundamentally the same "payment row" concept.
class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  static final _currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
  static final _dateFormat = DateFormat('d MMM yyyy, HH:mm', 'id_ID');

  final List<BorrowingPaymentModel> _items = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await Get.find<PaymentApiService>().history(page: 1);
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(result.items);
        _hasMore = result.hasMore;
        _page = 1;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Gagal memuat riwayat pembayaran.';
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final result = await Get.find<PaymentApiService>().history(page: _page + 1);
      if (!mounted) return;
      setState(() {
        _items.addAll(result.items);
        _hasMore = result.hasMore;
        _page += 1;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
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
          'Payment History',
          style: LuminaTextStyles.titleLg.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const _HistorySkeleton()
            : _error != null
                ? _ErrorState(message: _error!, onRetry: _load)
                : _items.isEmpty
                    ? const _EmptyState()
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200) {
                              _loadMore();
                            }
                            return false;
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                              LuminaSpacing.marginMobile,
                              LuminaSpacing.lg,
                              LuminaSpacing.marginMobile,
                              LuminaSpacing.xl,
                            ),
                            itemCount: _items.length + (_hasMore ? 1 : 0),
                            separatorBuilder: (_, _) => const SizedBox(height: LuminaSpacing.sm),
                            itemBuilder: (context, index) {
                              if (index >= _items.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: LuminaSpacing.md),
                                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                );
                              }
                              final payment = _items[index];
                              return _PaymentHistoryTile(
                                payment: payment,
                                currencyFormat: _currencyFormat,
                                dateFormat: _dateFormat,
                              );
                            },
                          ),
                        ),
                      ),
      ),
    );
  }
}

class _PaymentHistoryTile extends StatelessWidget {
  const _PaymentHistoryTile({required this.payment, required this.currencyFormat, required this.dateFormat});

  final BorrowingPaymentModel payment;
  final NumberFormat currencyFormat;
  final DateFormat dateFormat;

  String get _purposeLabel => switch (payment.purpose) {
        'overdue_fine' => 'Denda Keterlambatan',
        'pickup_no_show' => 'Denda Tidak Mengambil Pesanan',
        _ => 'Denda Pengembalian',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(color: LuminaColors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PaymentLogo(method: payment.paymentMethod ?? '', size: 40),
          const SizedBox(width: LuminaSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _purposeLabel,
                        style: LuminaTextStyles.bodyMd.copyWith(color: LuminaColors.onSurface, fontWeight: FontWeight.w800),
                      ),
                    ),
                    PaymentStatusBadge(status: payment.status, compact: true),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  payment.midtransOrderId,
                  style: LuminaTextStyles.labelMd.copyWith(color: LuminaColors.outline, letterSpacing: 0),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      currencyFormat.format(payment.totalAmount),
                      style: LuminaTextStyles.bodyMd.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w900),
                    ),
                    const Spacer(),
                    if (payment.createdAt != null)
                      Text(
                        dateFormat.format(payment.createdAt!),
                        style: LuminaTextStyles.labelMd.copyWith(color: LuminaColors.outline, letterSpacing: 0),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorySkeleton extends StatelessWidget {
  const _HistorySkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        LuminaSpacing.marginMobile,
        LuminaSpacing.lg,
        LuminaSpacing.marginMobile,
        LuminaSpacing.xl,
      ),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: LuminaSpacing.sm),
      itemBuilder: (_, _) => Container(
        height: 84,
        decoration: BoxDecoration(
          color: LuminaColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(LuminaRadius.xl),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LuminaSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_rounded, size: 56, color: LuminaColors.outline),
            const SizedBox(height: LuminaSpacing.sm),
            Text(
              'Belum ada riwayat pembayaran.',
              textAlign: TextAlign.center,
              style: LuminaTextStyles.bodyMd.copyWith(color: LuminaColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LuminaSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 56, color: LuminaColors.outline),
            const SizedBox(height: LuminaSpacing.sm),
            Text(message, textAlign: TextAlign.center, style: LuminaTextStyles.bodyMd.copyWith(color: LuminaColors.onSurfaceVariant)),
            const SizedBox(height: LuminaSpacing.md),
            OutlinedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}
