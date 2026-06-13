import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screen_protector/screen_protector.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/mahasiswa/data/services/home_api_service.dart';
import 'package:lumina_library/features/mahasiswa/presentation/pages/library_location/library_route_map_page.dart';
import 'package:lumina_library/shared/models/book/library_my_book_item_model.dart';
import 'package:lumina_library/shared/models/borrowing/checkout_result_model.dart';
import 'package:lumina_library/shared/widgets/feedback/lumina_toast.dart';

class LibraryMyBookDetailPage extends StatelessWidget {
  const LibraryMyBookDetailPage({
    super.key,
    required this.book,
  });

  final LibraryMyBookItemModel book;

  void _openRoutePage() {
    Get.to(
      () => LibraryRouteMapPage(
        destinationName: book.effectiveReturnLocationName,
        destinationAddress: book.effectiveReturnLocationDetail,
        destinationLatitude: book.destinationLatitude,
        destinationLongitude: book.destinationLongitude,
      ),
      transition: Transition.cupertino,
    );
  }

  void _showReturnQrBottomSheet() {
    Get.bottomSheet<void>(
      _BorrowingQrBottomSheet(
        borrowingId: book.loanId,
        borrowingCode: book.bookCode,
        isPickup: false,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.42),
      isDismissible: true,
      enableDrag: true,
    );
  }

  void _showPickupQrBottomSheet() {
    Get.bottomSheet<void>(
      _BorrowingQrBottomSheet(
        borrowingId: book.loanId,
        borrowingCode: book.bookCode,
        isPickup: true,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.42),
      isDismissible: true,
      enableDrag: true,
    );
  }

  void _handlePayFine() {
    LuminaToast.warning('Fitur pembayaran denda belum tersedia. Total: ${book.fineAmountText}.');
  }

  @override
  Widget build(BuildContext context) {
    final showReturnQr = book.canReturn;
    final showPickupQr = book.canPickup || book.isAwaitingPickup;
    final showQrButton = showReturnQr || showPickupQr;

    return Scaffold(
      backgroundColor: LuminaColors.background,
      bottomNavigationBar: showQrButton || book.mustPayFine
          ? _LoanBottomActionBar(
              showPickupQr: showPickupQr,
              showPayFineButton: book.mustPayFine,
              onShowQrTap: showPickupQr ? _showPickupQrBottomSheet : _showReturnQrBottomSheet,
              onPayFineTap: _handlePayFine,
            )
          : null,
      body: Column(
        children: [
          const _LoanDetailTopBar(),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                LuminaSpacing.marginMobile,
                LuminaSpacing.lg,
                LuminaSpacing.marginMobile,
                120,
              ),
              children: [
                _LoanStatusBanner(book: book),
                const SizedBox(height: LuminaSpacing.lg),
                _LoanBookInfoCard(book: book),
                const SizedBox(height: LuminaSpacing.lg),
                _LoanTimelineCard(book: book),
                const SizedBox(height: LuminaSpacing.lg),
                _ReturnLocationCard(
                  book: book,
                  onRouteTap: _openRoutePage,
                ),
                if (book.mustPayFine) ...[
                  const SizedBox(height: LuminaSpacing.lg),
                  _FineSummaryCard(book: book),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoanDetailTopBar extends StatelessWidget {
  const _LoanDetailTopBar();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LuminaColors.surface,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(
            horizontal: LuminaSpacing.marginMobile,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: LuminaColors.outlineVariant.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: Get.back,
                  customBorder: const CircleBorder(),
                  child: const SizedBox(
                    width: 42,
                    height: 42,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: LuminaColors.primary,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: LuminaSpacing.sm),
              Expanded(
                child: Text(
                  'Loan Details',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LuminaTextStyles.titleLg.copyWith(
                    color: LuminaColors.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoanStatusBanner extends StatelessWidget {
  const _LoanStatusBanner({
    required this.book,
  });

  final LibraryMyBookItemModel book;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(book.status);
    final backgroundColor = _statusBackgroundColor(book.status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.md,
        vertical: LuminaSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _statusIcon(book.status),
            color: statusColor,
            size: 22,
          ),
          const SizedBox(width: LuminaSpacing.xs),
          Expanded(
            child: Text(
              book.statusLabel,
              style: LuminaTextStyles.labelMd.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
          Text(
            book.dueStatusText,
            style: LuminaTextStyles.labelMd.copyWith(
              color: book.isOverdue
                  ? LuminaColors.error
                  : LuminaColors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(LibraryMyBookStatus status) {
    switch (status) {
      case LibraryMyBookStatus.pending:
        return Icons.hourglass_top_rounded;
      case LibraryMyBookStatus.awaitingPickup:
        return Icons.store_rounded;
      case LibraryMyBookStatus.active:
        return Icons.check_circle_rounded;
      case LibraryMyBookStatus.dueSoon:
        return Icons.schedule_rounded;
      case LibraryMyBookStatus.overdue:
        return Icons.warning_amber_rounded;
      case LibraryMyBookStatus.finished:
        return Icons.assignment_turned_in_rounded;
      case LibraryMyBookStatus.waitingPayment:
        return Icons.payments_rounded;
      case LibraryMyBookStatus.expired:
        return Icons.event_busy_rounded;
      case LibraryMyBookStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  Color _statusColor(LibraryMyBookStatus status) {
    switch (status) {
      case LibraryMyBookStatus.pending:
        return const Color(0xFF6B5B00);
      case LibraryMyBookStatus.awaitingPickup:
        return LuminaColors.secondary;
      case LibraryMyBookStatus.active:
        return LuminaColors.secondary;
      case LibraryMyBookStatus.dueSoon:
        return LuminaColors.primary;
      case LibraryMyBookStatus.overdue:
        return LuminaColors.error;
      case LibraryMyBookStatus.finished:
        return LuminaColors.onSurfaceVariant;
      case LibraryMyBookStatus.waitingPayment:
        return LuminaColors.error;
      case LibraryMyBookStatus.expired:
      case LibraryMyBookStatus.cancelled:
        return LuminaColors.onSurfaceVariant;
    }
  }

  Color _statusBackgroundColor(LibraryMyBookStatus status) {
    switch (status) {
      case LibraryMyBookStatus.pending:
        return const Color(0xFFFFF8E1);
      case LibraryMyBookStatus.awaitingPickup:
        return LuminaColors.secondaryContainer.withOpacity(0.20);
      case LibraryMyBookStatus.active:
        return LuminaColors.secondaryContainer.withOpacity(0.20);
      case LibraryMyBookStatus.dueSoon:
        return LuminaColors.primaryFixed.withOpacity(0.38);
      case LibraryMyBookStatus.overdue:
        return LuminaColors.errorContainer.withOpacity(0.62);
      case LibraryMyBookStatus.finished:
        return LuminaColors.surfaceContainerLow;
      case LibraryMyBookStatus.waitingPayment:
        return LuminaColors.errorContainer.withOpacity(0.40);
      case LibraryMyBookStatus.expired:
      case LibraryMyBookStatus.cancelled:
        return LuminaColors.surfaceContainerLow;
    }
  }
}

class _LoanBookInfoCard extends StatelessWidget {
  const _LoanBookInfoCard({
    required this.book,
  });

  final LibraryMyBookItemModel book;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 96,
            height: 144,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: LuminaColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(LuminaRadius.lg),
            ),
            child: Image.network(
              book.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.menu_book_rounded,
                  color: LuminaColors.primary,
                  size: 40,
                );
              },
            ),
          ),
          const SizedBox(width: LuminaSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: LuminaTextStyles.titleLg.copyWith(
                    color: LuminaColors.primary,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: LuminaSpacing.base),
                Text(
                  book.author,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: LuminaTextStyles.bodyMd.copyWith(
                    color: LuminaColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: LuminaSpacing.sm),
                Wrap(
                  spacing: LuminaSpacing.xs,
                  runSpacing: LuminaSpacing.xs,
                  children: [
                    if (book.isbn != null && book.isbn!.trim().isNotEmpty)
                      _InfoChip(label: 'ISBN: ${book.isbn}'),
                    if (book.category != null &&
                        book.category!.trim().isNotEmpty)
                      _InfoChip(
                        label: book.category!,
                        color: LuminaColors.secondary,
                        backgroundColor:
                            LuminaColors.secondary.withOpacity(0.1),
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

class _LoanTimelineCard extends StatelessWidget {
  const _LoanTimelineCard({
    required this.book,
  });

  final LibraryMyBookItemModel book;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.schedule_rounded,
            title: 'Timeline',
          ),
          const SizedBox(height: LuminaSpacing.md),
          Container(
            margin: const EdgeInsets.only(left: 7),
            padding: const EdgeInsets.only(left: LuminaSpacing.md),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: LuminaColors.surfaceContainerHigh,
                  width: 2,
                ),
              ),
            ),
            child: Column(
              children: [
                _TimelineItem(
                  title: 'Borrowed',
                  value: book.timelineBorrowedText,
                  dotColor: LuminaColors.surfaceContainerHigh,
                ),
                const SizedBox(height: LuminaSpacing.lg),
                _TimelineItem(
                  title: 'Due Date',
                  value: book.timelineDueText,
                  dotColor: book.isOverdue
                      ? LuminaColors.error
                      : LuminaColors.secondary,
                  valueColor: book.isOverdue
                      ? LuminaColors.error
                      : LuminaColors.secondary,
                ),
                if (book.timelineReturnedText != null) ...[
                  const SizedBox(height: LuminaSpacing.lg),
                  _TimelineItem(
                    title: 'Returned',
                    value: book.timelineReturnedText!,
                    dotColor: LuminaColors.primary,
                    valueColor: LuminaColors.primary,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.title,
    required this.value,
    required this.dotColor,
    this.valueColor,
  });

  final String title;
  final String value;
  final Color dotColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -25,
          top: 3,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: LuminaColors.surface,
                width: 2,
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: LuminaTextStyles.labelMd.copyWith(
                color: LuminaColors.outline,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: LuminaSpacing.base),
            Text(
              value,
              style: LuminaTextStyles.bodyMd.copyWith(
                color: valueColor ?? LuminaColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReturnLocationCard extends StatelessWidget {
  const _ReturnLocationCard({
    required this.book,
    required this.onRouteTap,
  });

  final LibraryMyBookItemModel book;
  final VoidCallback onRouteTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: LuminaColors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: LuminaColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: LuminaSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Return Location',
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: LuminaColors.outline,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: LuminaSpacing.base),
                Text(
                  book.effectiveReturnLocationName,
                  style: LuminaTextStyles.bodyMd.copyWith(
                    color: LuminaColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: LuminaSpacing.base),
                Text(
                  book.effectiveReturnLocationDetail,
                  style: LuminaTextStyles.bodyMd.copyWith(
                    color: LuminaColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: LuminaSpacing.md),
                SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: onRouteTap,
                    icon: const Icon(Icons.route_rounded, size: 18),
                    label: Text(
                      'View Route',
                      style: LuminaTextStyles.labelMd.copyWith(
                        color: LuminaColors.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: LuminaColors.primary,
                      side: BorderSide(
                        color: LuminaColors.primary.withOpacity(0.24),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(LuminaRadius.full),
                      ),
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

class _FineSummaryCard extends StatelessWidget {
  const _FineSummaryCard({
    required this.book,
  });

  final LibraryMyBookItemModel book;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.errorContainer.withOpacity(0.72),
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(
          color: LuminaColors.error.withOpacity(0.18),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: LuminaColors.error.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.payments_rounded,
              color: LuminaColors.error,
              size: 24,
            ),
          ),
          const SizedBox(width: LuminaSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fine Payment Required',
                  style: LuminaTextStyles.bodyMd.copyWith(
                    color: LuminaColors.onErrorContainer,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${book.overdueDays} days x ${book.finePerDayText} = ${book.fineAmountText}',
                  style: LuminaTextStyles.bodyMd.copyWith(
                    color: LuminaColors.onErrorContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Please show the QR code and complete the fine payment at the return desk.',
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: LuminaColors.onErrorContainer.withOpacity(0.78),
                    fontWeight: FontWeight.w600,
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

class _LoanBottomActionBar extends StatelessWidget {
  const _LoanBottomActionBar({
    required this.showPickupQr,
    required this.showPayFineButton,
    required this.onShowQrTap,
    required this.onPayFineTap,
  });

  final bool showPickupQr;
  final bool showPayFineButton;
  final VoidCallback onShowQrTap;
  final VoidCallback onPayFineTap;

  @override
  Widget build(BuildContext context) {
    final qrLabel = showPickupQr ? 'QR Pengambilan' : 'QR Pengembalian';

    return Material(
      color: LuminaColors.surface.withOpacity(0.98),
      elevation: 18,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            LuminaSpacing.marginMobile,
            LuminaSpacing.md,
            LuminaSpacing.marginMobile,
            LuminaSpacing.md,
          ),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: LuminaColors.outlineVariant.withOpacity(0.28),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: onShowQrTap,
                    icon: const Icon(Icons.qr_code_2_rounded, size: 20),
                    label: Text(
                      qrLabel,
                      style: LuminaTextStyles.titleSm.copyWith(
                        color: LuminaColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: LuminaColors.primary,
                      side: BorderSide(
                        color: LuminaColors.primary.withOpacity(0.28),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(LuminaRadius.full),
                      ),
                    ),
                  ),
                ),
              ),
              if (showPayFineButton) ...[
                const SizedBox(width: LuminaSpacing.sm),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: onPayFineTap,
                      icon: const Icon(Icons.payment_rounded, size: 20),
                      label: Text(
                        'Bayar Denda',
                        style: LuminaTextStyles.titleSm.copyWith(
                          color: LuminaColors.onError,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: LuminaColors.error,
                        foregroundColor: LuminaColors.onError,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            LuminaRadius.full,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Backend-integrated QR Bottom Sheet (pickup & return) ────────────────────

class _BorrowingQrBottomSheet extends StatefulWidget {
  const _BorrowingQrBottomSheet({
    required this.borrowingId,
    required this.borrowingCode,
    required this.isPickup,
  });

  final String borrowingId;
  final String borrowingCode;
  /// true → QR Pengambilan (/borrowings/{id}/qr/refresh)
  /// false → QR Pengembalian (/my-books/{id}/return-qr/refresh)
  final bool isPickup;

  @override
  State<_BorrowingQrBottomSheet> createState() => _BorrowingQrBottomSheetState();
}

class _BorrowingQrBottomSheetState extends State<_BorrowingQrBottomSheet> {
  static final Map<String, CheckoutQrModel> _qrCache = {};
  static final Map<String, DateTime> _qrExpiryCache = {};

  Timer? _countdownTimer;
  CheckoutQrModel? _qr;
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isExpired = false;
  int _secondsLeft = 0;

  String get _cacheKey =>
      '${widget.borrowingId}_${widget.isPickup ? "pickup" : "return"}';

  @override
  void initState() {
    super.initState();
    _fetchQr();
    unawaited(_enableScreenProtection());
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    unawaited(_disableScreenProtection());
    super.dispose();
  }

  Future<void> _fetchQr() async {
    final cacheKey = _cacheKey;
    final cached = _qrCache[cacheKey];
    final cachedExpiry = _qrExpiryCache[cacheKey];

    if (cached != null && cachedExpiry != null) {
      debugPrint('[QR] Existing QR found');
      debugPrint('[QR] Expired At: $cachedExpiry');
      debugPrint('[QR] Current Time: ${DateTime.now()}');
      if (DateTime.now().isBefore(cachedExpiry)) {
        debugPrint('[QR] QR still valid');
        debugPrint('[QR] Using cached QR');
        debugPrint('[QR] Skip refresh request');
        final remaining =
            cachedExpiry.difference(DateTime.now()).inSeconds.clamp(0, 86400);
        if (mounted) {
          setState(() {
            _qr = cached;
            _isLoading = false;
          });
          _startCountdown(remaining);
        }
        return;
      }
      debugPrint('[QR] QR expired');
    }

    debugPrint('[QR] Requesting new QR');
    debugPrint(
      '[QR] Refresh endpoint: ${widget.isPickup ? "/borrowings/${widget.borrowingId}/qr/refresh" : "/my-books/${widget.borrowingId}/return-qr/refresh"}',
    );
    setState(() { _isLoading = true; });
    try {
      final service = Get.find<HomeApiService>();
      final qr = widget.isPickup
          ? await service.refreshPickupQr(widget.borrowingId)
          : await service.refreshReturnQr(widget.borrowingId);
      if (!mounted) return;
      final expiry = _parseQrExpiry(qr);
      _qrCache[cacheKey] = qr;
      _qrExpiryCache[cacheKey] = expiry;
      debugPrint('[QR] New QR received');
      debugPrint('[QR] QR cache updated — expires at $expiry');
      setState(() {
        _qr = qr;
        _isLoading = false;
      });
      _startCountdown(qr.ttlSeconds);
    } on LuminaApiException catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; });
      LuminaToast.error(e.displayMessage);
    } catch (_) {
      if (!mounted) return;
      setState(() { _isLoading = false; });
      LuminaToast.error('Gagal memuat QR. Silakan coba lagi.');
    }
  }

  Future<void> _refreshQr() async {
    if (_isRefreshing) return;
    // Clear cache so the upcoming API call is not short-circuited by _fetchQr
    _qrCache.remove(_cacheKey);
    _qrExpiryCache.remove(_cacheKey);
    setState(() { _isRefreshing = true; _isExpired = false; });
    _countdownTimer?.cancel();
    debugPrint('[QR] Requesting new QR');
    debugPrint(
      '[QR] Refresh endpoint: ${widget.isPickup ? "/borrowings/${widget.borrowingId}/qr/refresh" : "/my-books/${widget.borrowingId}/return-qr/refresh"}',
    );
    try {
      final service = Get.find<HomeApiService>();
      final qr = widget.isPickup
          ? await service.refreshPickupQr(widget.borrowingId)
          : await service.refreshReturnQr(widget.borrowingId);
      if (!mounted) return;
      final expiry = _parseQrExpiry(qr);
      _qrCache[_cacheKey] = qr;
      _qrExpiryCache[_cacheKey] = expiry;
      debugPrint('[QR] New QR received');
      debugPrint('[QR] QR cache updated — expires at $expiry');
      setState(() {
        _qr = qr;
        _isRefreshing = false;
      });
      _startCountdown(qr.ttlSeconds);
    } on LuminaApiException catch (e) {
      if (!mounted) return;
      setState(() { _isRefreshing = false; });
      LuminaToast.error(e.displayMessage);
    } catch (_) {
      if (!mounted) return;
      setState(() { _isRefreshing = false; });
      LuminaToast.error('Gagal memperbarui QR. Silakan coba lagi.');
    }
  }

  DateTime _parseQrExpiry(CheckoutQrModel qr) {
    final expiresAt = qr.expiresAt;
    if (expiresAt != null && expiresAt.isNotEmpty) {
      try {
        return DateTime.parse(expiresAt).toLocal();
      } catch (_) {}
    }
    return DateTime.now().add(Duration(seconds: qr.ttlSeconds));
  }

  void _startCountdown(int ttlSeconds) {
    _countdownTimer?.cancel();
    _secondsLeft = ttlSeconds;
    _isExpired = false;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _isExpired = true;
          _countdownTimer?.cancel();
        }
      });
    });
  }

  String get _remainingTimeText {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _enableScreenProtection() async {
    if (kIsWeb) return;
    try {
      await ScreenProtector.preventScreenshotOn();
      await ScreenProtector.protectDataLeakageOn();
    } catch (_) {}
  }

  Future<void> _disableScreenProtection() async {
    if (kIsWeb) return;
    try {
      await ScreenProtector.preventScreenshotOff();
      await ScreenProtector.protectDataLeakageOff();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isPickup ? 'QR Pengambilan' : 'QR Pengembalian';
    final description = widget.isPickup
        ? 'Tunjukkan QR ini ke petugas perpustakaan untuk mengambil buku yang sudah dipesan.'
        : 'Tunjukkan QR ini ke petugas perpustakaan untuk menyelesaikan proses pengembalian.';

    return SafeArea(
      top: false,
      child: Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
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

            const SizedBox(height: LuminaSpacing.lg),

            Text(
              title,
              textAlign: TextAlign.center,
              style: LuminaTextStyles.titleLg.copyWith(
                color: LuminaColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: LuminaSpacing.xs),

            Text(
              description,
              textAlign: TextAlign.center,
              style: LuminaTextStyles.bodyMd.copyWith(
                color: LuminaColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),

            const SizedBox(height: LuminaSpacing.md),

            // Loading state
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: LuminaSpacing.xl),
                child: CircularProgressIndicator(),
              )
            else if (_qr == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: LuminaSpacing.xl),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: LuminaColors.error, size: 48),
                    const SizedBox(height: LuminaSpacing.sm),
                    Text(
                      'Gagal memuat QR',
                      style: LuminaTextStyles.bodyMd.copyWith(color: LuminaColors.error),
                    ),
                    const SizedBox(height: LuminaSpacing.md),
                    OutlinedButton(
                      onPressed: _fetchQr,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
            else ...[
              // Countdown pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.md, vertical: LuminaSpacing.xs),
                decoration: BoxDecoration(
                  color: _isExpired
                      ? LuminaColors.error.withOpacity(0.10)
                      : (_secondsLeft <= 15
                          ? LuminaColors.error.withOpacity(0.10)
                          : LuminaColors.secondary.withOpacity(0.10)),
                  borderRadius: BorderRadius.circular(LuminaRadius.full),
                  border: Border.all(
                    color: _isExpired || _secondsLeft <= 15
                        ? LuminaColors.error.withOpacity(0.28)
                        : LuminaColors.secondary.withOpacity(0.28),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isExpired ? Icons.timer_off_rounded : Icons.timer_rounded,
                      size: 16,
                      color: _isExpired || _secondsLeft <= 15
                          ? LuminaColors.error
                          : LuminaColors.secondary,
                    ),
                    const SizedBox(width: LuminaSpacing.xs),
                    Text(
                      _isExpired ? 'QR Kadaluwarsa' : _remainingTimeText,
                      style: LuminaTextStyles.labelMd.copyWith(
                        color: _isExpired || _secondsLeft <= 15
                            ? LuminaColors.error
                            : LuminaColors.secondary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: LuminaSpacing.md),

              // QR image
              Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: _isExpired ? 0.22 : 1.0,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(LuminaRadius.xl),
                        border: Border.all(
                          color: _isExpired
                              ? LuminaColors.error.withOpacity(0.3)
                              : LuminaColors.outlineVariant.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(LuminaSpacing.sm),
                      child: _qr!.imageBytes != null
                          ? Image.memory(_qr!.imageBytes!, fit: BoxFit.contain)
                          : const Icon(Icons.qr_code_2_rounded, size: 80, color: LuminaColors.primary),
                    ),
                  ),
                  if (_isExpired)
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(LuminaRadius.xl),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_clock_rounded, color: Colors.white, size: 36),
                          const SizedBox(height: LuminaSpacing.xs),
                          Text(
                            'QR Kadaluwarsa',
                            style: LuminaTextStyles.titleMd.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: LuminaSpacing.md),

              // Perbarui QR button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _isRefreshing ? null : _refreshQr,
                  icon: _isRefreshing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(
                    _isRefreshing ? 'Memperbarui...' : 'Perbarui QR',
                    style: LuminaTextStyles.titleSm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: LuminaColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(LuminaRadius.full),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: LuminaSpacing.sm),

            // Tutup button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: Get.back,
                style: OutlinedButton.styleFrom(
                  foregroundColor: LuminaColors.primary,
                  side: BorderSide(color: LuminaColors.primary.withOpacity(0.24), width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LuminaRadius.full)),
                ),
                child: Text(
                  'Tutup',
                  style: LuminaTextStyles.titleSm.copyWith(
                    color: LuminaColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

// Placeholder to preserve compile from old dead code references
class _SecureQrContent_PLACEHOLDER extends StatelessWidget {
  const _SecureQrContent_PLACEHOLDER({
    required this.book,
    required this.qrToken,
    required this.expired,
    required this.remainingTimeText,
    required this.generatedAt,
    required this.expiredAt,
    required this.onRegenerateTap,
  });

  final LibraryMyBookItemModel book;
  final String qrToken;
  final bool expired;
  final String remainingTimeText;
  final DateTime generatedAt;
  final DateTime expiredAt;
  final VoidCallback onRegenerateTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Return QR Code',
          textAlign: TextAlign.center,
          style: LuminaTextStyles.titleLg.copyWith(
            color: LuminaColors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: LuminaSpacing.sm),
        Text(
          book.mustPayFine
              ? 'Show this QR code to the librarian. Since this loan is overdue, the fine must also be paid.'
              : 'Show this QR code to the librarian to complete your book return.',
          textAlign: TextAlign.center,
          style: LuminaTextStyles.bodyMd.copyWith(
            color: LuminaColors.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: LuminaSpacing.md),
        _QrExpiryBadge(
          expired: expired,
          remainingTimeText: remainingTimeText,
        ),
        const SizedBox(height: LuminaSpacing.lg),
        Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: expired ? 0.22 : 1,
              child: Container(
                padding: const EdgeInsets.all(LuminaSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(LuminaRadius.xl),
                  border: Border.all(
                    color: expired
                        ? LuminaColors.error.withOpacity(0.28)
                        : LuminaColors.surfaceContainerHigh,
                    width: 1,
                  ),
                ),
                child: SizedBox(
                  width: 190,
                  height: 190,
                  child: CustomPaint(
                    painter: _PseudoQrPainter(seed: qrToken),
                  ),
                ),
              ),
            ),
            if (expired)
              Container(
                width: 190,
                padding: const EdgeInsets.all(LuminaSpacing.md),
                decoration: BoxDecoration(
                  color: LuminaColors.surface.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(LuminaRadius.xl),
                  border: Border.all(
                    color: LuminaColors.error.withOpacity(0.18),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_clock_rounded,
                      color: LuminaColors.error,
                      size: 34,
                    ),
                    const SizedBox(height: LuminaSpacing.sm),
                    Text(
                      'QR Expired',
                      textAlign: TextAlign.center,
                      style: LuminaTextStyles.titleMd.copyWith(
                        color: LuminaColors.error,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Generate a new QR code to continue.',
                      textAlign: TextAlign.center,
                      style: LuminaTextStyles.labelMd.copyWith(
                        color: LuminaColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: LuminaSpacing.md),
                    SizedBox(
                      height: 38,
                      child: ElevatedButton.icon(
                        onPressed: onRegenerateTap,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(
                          'Generate New QR',
                          style: LuminaTextStyles.labelMd.copyWith(
                            color: LuminaColors.onPrimary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: LuminaColors.primary,
                          foregroundColor: LuminaColors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(LuminaRadius.full),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: LuminaSpacing.md),
        Text(
          'Loan ID: ${book.loanId}',
          style: LuminaTextStyles.labelMd.copyWith(
            color: LuminaColors.outline,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Generated: ${_formatTime(generatedAt)} • Expires: ${_formatTime(expiredAt)}',
          textAlign: TextAlign.center,
          style: LuminaTextStyles.labelMd.copyWith(
            color: LuminaColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: LuminaSpacing.sm),
        _ScreenshotProtectionNotice(),
      ],
    );
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final second = value.second.toString().padLeft(2, '0');

    return '$hour:$minute:$second';
  }
}

class _QrExpiryBadge extends StatelessWidget {
  const _QrExpiryBadge({
    required this.expired,
    required this.remainingTimeText,
  });

  final bool expired;
  final String remainingTimeText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.md,
        vertical: LuminaSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: expired
            ? LuminaColors.errorContainer.withOpacity(0.72)
            : LuminaColors.secondaryContainer.withOpacity(0.42),
        borderRadius: BorderRadius.circular(LuminaRadius.full),
        border: Border.all(
          color: expired
              ? LuminaColors.error.withOpacity(0.18)
              : LuminaColors.secondary.withOpacity(0.16),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            expired ? Icons.lock_clock_rounded : Icons.timer_rounded,
            color: expired ? LuminaColors.error : LuminaColors.secondary,
            size: 18,
          ),
          const SizedBox(width: LuminaSpacing.xs),
          Text(
            expired ? 'Expired' : 'Expires in $remainingTimeText',
            style: LuminaTextStyles.labelMd.copyWith(
              color: expired ? LuminaColors.error : LuminaColors.secondary,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScreenshotProtectionNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.sm,
        vertical: LuminaSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(LuminaRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.security_rounded,
            color: LuminaColors.onSurfaceVariant,
            size: 16,
          ),
          const SizedBox(width: LuminaSpacing.xs),
          Text(
            'Screenshot protection is enabled',
            style: LuminaTextStyles.labelMd.copyWith(
              color: LuminaColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _PseudoQrPainter extends CustomPainter {
  const _PseudoQrPainter({
    required this.seed,
  });

  final String seed;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = Colors.white;
    final blockPaint = Paint()..color = LuminaColors.primary;
    final lightPaint = Paint()..color = LuminaColors.surfaceContainerHigh;

    canvas.drawRect(Offset.zero & size, backgroundPaint);

    const count = 21;
    final cell = size.width / count;

    void drawFinder(int startX, int startY) {
      final outer = Rect.fromLTWH(
        startX * cell,
        startY * cell,
        cell * 7,
        cell * 7,
      );
      final innerWhite = Rect.fromLTWH(
        (startX + 1) * cell,
        (startY + 1) * cell,
        cell * 5,
        cell * 5,
      );
      final innerBlack = Rect.fromLTWH(
        (startX + 2) * cell,
        (startY + 2) * cell,
        cell * 3,
        cell * 3,
      );

      canvas.drawRect(outer, blockPaint);
      canvas.drawRect(innerWhite, backgroundPaint);
      canvas.drawRect(innerBlack, blockPaint);
    }

    drawFinder(0, 0);
    drawFinder(14, 0);
    drawFinder(0, 14);

    var hash = 0;
    for (final codeUnit in seed.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }

    for (var y = 0; y < count; y++) {
      for (var x = 0; x < count; x++) {
        final inTopLeft = x < 7 && y < 7;
        final inTopRight = x >= 14 && y < 7;
        final inBottomLeft = x < 7 && y >= 14;

        if (inTopLeft || inTopRight || inBottomLeft) continue;

        final value = (x * 17 + y * 31 + hash) % 7;
        if (value == 0 || value == 2 || value == 5) {
          final rect = Rect.fromLTWH(
            x * cell + 1,
            y * cell + 1,
            cell - 2,
            cell - 2,
          );
          canvas.drawRect(rect, value == 5 ? lightPaint : blockPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PseudoQrPainter oldDelegate) {
    return oldDelegate.seed != seed;
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    this.color = LuminaColors.primaryContainer,
    this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.xs,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(LuminaRadius.sm),
      ),
      child: Text(
        label,
        style: LuminaTextStyles.labelMd.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: LuminaColors.outline,
          size: 22,
        ),
        const SizedBox(width: LuminaSpacing.xs),
        Text(
          title,
          style: LuminaTextStyles.titleLg.copyWith(
            color: LuminaColors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: LuminaColors.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(LuminaRadius.xl),
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
  );
}