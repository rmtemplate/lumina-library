import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screen_protector/screen_protector.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/core/services/websocket/websocket_event.dart';
import 'package:lumina_library/core/services/websocket/websocket_service.dart';
import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/mahasiswa/data/services/home_api_service.dart';
import 'package:lumina_library/features/mahasiswa/data/services/payment_api_service.dart';
import 'package:lumina_library/features/mahasiswa/presentation/pages/library_location/library_route_map_page.dart';
import 'package:lumina_library/shared/models/payment/borrowing_payment_model.dart';
import 'package:lumina_library/features/mahasiswa/presentation/pages/payment/library_payment_page.dart';
import 'package:lumina_library/shared/models/book/library_my_book_item_model.dart';
import 'package:lumina_library/shared/models/borrowing/checkout_result_model.dart';
import 'package:lumina_library/shared/widgets/feedback/lumina_toast.dart';
import 'package:lumina_library/shared/widgets/payment/payment_method_bottom_sheet.dart';

class LibraryMyBookDetailPage extends StatefulWidget {
  const LibraryMyBookDetailPage({
    super.key,
    required this.book,
  });

  final LibraryMyBookItemModel book;

  @override
  State<LibraryMyBookDetailPage> createState() => _LibraryMyBookDetailPageState();
}

class _LibraryMyBookDetailPageState extends State<LibraryMyBookDetailPage> {
  late LibraryMyBookItemModel _book;
  bool _isRefreshing = true;
  String? _loadError;
  StreamSubscription<WebSocketEvent>? _wsSubscription;
  BorrowingPaymentModel? _existingPayment;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
    unawaited(_enableScreenProtection());
    _refetchBook(silent: false);
    _listenToRealtimeEvents();
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    unawaited(_disableScreenProtection());
    super.dispose();
  }

  /// Re-fetches this borrowing's detail so the page reflects the freshest
  /// server state — called on first open, after returning from the payment
  /// page, and whenever a relevant realtime event arrives. [silent] skips
  /// the loading-skeleton flash for background refreshes (WS-driven), so
  /// the page updates in place instead of flickering back to a skeleton.
  Future<void> _refetchBook({bool silent = true}) async {
    if (!silent && mounted) setState(() => _isRefreshing = true);

    try {
      final service = Get.find<HomeApiService>();
      final fresh = await service.getMyBookDetail(widget.book.loanId);
      if (!mounted) return;
      setState(() {
        _book = fresh;
        _isRefreshing = false;
        _loadError = null;
      });
      // When waiting_payment, surface the existing pending payment so the
      // button says "Continue Payment" and we can skip the method sheet.
      if (fresh.isWaitingPayment) {
        unawaited(_fetchExistingPayment());
      } else if (_existingPayment != null) {
        setState(() => _existingPayment = null);
      }
    } on LuminaApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isRefreshing = false;
        // Only surface a blocking error state if we never had any data at
        // all — otherwise just keep showing the last good snapshot.
        _loadError = null;
      });
      debugPrint('[MYBOOK_DETAIL] Refetch failed: ${e.displayMessage}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRefreshing = false);
      debugPrint('[MYBOOK_DETAIL] Refetch failed: $e');
    }
  }

  Future<void> _fetchExistingPayment() async {
    try {
      final p = await Get.find<PaymentApiService>().byBorrowing(_book.loanId);
      if (!mounted) return;
      setState(() {
        _existingPayment = (p != null && p.isPending && !p.isExpired) ? p : null;
      });
    } catch (_) {}
  }

  /// Live updates while this page is open — a payment completed (possibly
  /// from another device), a return processed, or an overdue auto-flag
  /// firing all refresh this page in place. No polling, no manual refresh.
  void _listenToRealtimeEvents() {
    if (!Get.isRegistered<WebSocketService>()) return;

    _wsSubscription = Get.find<WebSocketService>().events.listen((event) {
      if (event.borrowingId != widget.book.loanId) return;

      switch (event.name) {
        case 'payment.success':
        case 'payment.pending':
        case 'payment.expired':
        case 'payment.cancelled':
        case 'borrowing.overdue':
        case 'return.success':
        // Staff scanned the Return QR → loan is now
        // return_pending_verification; refetch flips the page to the
        // "waiting for staff verification" state and hides the QR button.
        case 'return.pending_verification':
        // Staff finished verifying → charges finalized. Refetch surfaces the
        // waiting_payment state (fine card + "Proceed to Payment") or closes
        // the loan when nothing is owed. No manual refresh needed.
        case 'return.verified':
        case 'qr.expired':
          unawaited(_refetchBook());
        // ── Two-stage return flow — the single unified event ───────────────
        case 'borrowing.updated':
          _handleBorrowingUpdated(event);
      }
    });
  }

  /// Drives the entire two-stage return flow in realtime from ONE event. Each
  /// [action] refreshes Borrow Detail; payment_created auto-opens the payment
  /// sheet; completion shows an animation and returns to My Books.
  Future<void> _handleBorrowingUpdated(WebSocketEvent event) async {
    final action = (event.data['action'] as String?) ?? '';
    await _refetchBook();
    if (!mounted) return;

    switch (action) {
      case 'return_received':
        LuminaToast.success('Buku pengembalian Anda telah diterima petugas.');
      case 'overdue_payment_created':
      case 'damage_payment_created':
        // Refresh already surfaced waiting_payment — auto-open the sheet so the
        // student pays without tapping another button.
        LuminaToast.info(
          action == 'overdue_payment_created'
              ? 'Ada denda keterlambatan yang harus dibayar.'
              : 'Ada biaya kerusakan yang harus dibayar.',
        );
        unawaited(_handleProceedToPayment());
      case 'overdue_payment_paid':
        LuminaToast.success('Denda keterlambatan lunas. Menunggu inspeksi buku.');
      case 'damage_payment_paid':
        LuminaToast.success('Biaya kerusakan lunas.');
      case 'borrowing_completed':
        await _showCompletionThenLeave();
    }
  }

  /// Completion animation → after ~2s pop back to My Books.
  Future<void> _showCompletionThenLeave() async {
    if (!mounted) return;
    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _BorrowingCompletedDialog(),
    ));
    await Future.delayed(const Duration(seconds: 2));
    if (Get.isDialogOpen ?? false) Get.back();
    if (mounted) Get.back();
  }

  void _openRoutePage() {
    Get.to(
      () => LibraryRouteMapPage(
        destinationName: _book.effectiveReturnLocationName,
        destinationAddress: _book.effectiveReturnLocationDetail,
        destinationLatitude: _book.destinationLatitude,
        destinationLongitude: _book.destinationLongitude,
      ),
      transition: Transition.cupertino,
    );
  }

  void _showReturnQrBottomSheet() {
    Get.bottomSheet<void>(
      _BorrowingQrBottomSheet(
        borrowingId: _book.loanId,
        borrowingCode: _book.bookCode,
        isPickup: false,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.42),
      isDismissible: true,
      enableDrag: true,
    ).then((_) => _refetchBook());
  }

  void _showPickupQrBottomSheet() {
    Get.bottomSheet<void>(
      _BorrowingQrBottomSheet(
        borrowingId: _book.loanId,
        borrowingCode: _book.bookCode,
        isPickup: true,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.42),
      isDismissible: true,
      enableDrag: true,
    ).then((_) => _refetchBook());
  }

  /// "Proceed to Payment" / "Continue Payment" — if a pending, non-expired
  /// payment already exists for this borrowing (detected during the last
  /// refetch), skip the method-selection bottom sheet and open the payment
  /// page directly. Otherwise, show the method sheet first so the member
  /// can choose how to pay. Refetches on return either way.
  Future<void> _handleProceedToPayment() async {
    final existing = _existingPayment;
    if (existing != null) {
      await Get.to(
        () => LibraryPaymentPage(
          borrowingId: _book.loanId,
          borrowingCode: _book.bookCode,
          payment: existing,
        ),
        transition: Transition.cupertino,
      );
      unawaited(_refetchBook());
      return;
    }

    final payment = await PaymentMethodBottomSheet.show(
      context,
      borrowingId: _book.loanId,
      borrowingCode: _book.bookCode,
      outstandingFineAmount: _book.fineAmount.toDouble(),
    );

    if (payment == null) return;

    await Get.to(
      () => LibraryPaymentPage(
        borrowingId: _book.loanId,
        borrowingCode: _book.bookCode,
        payment: payment,
      ),
      transition: Transition.cupertino,
    );
    unawaited(_refetchBook());
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
    final book = _book;
    // Buttons are rendered STRICTLY from backend action flags — never from
    // status / overdue_days / total_fine. The backend is the single source of
    // truth (see MyBookResource `actions` + `workflow`).
    final showReturnQr = book.canGenerateReturnQr;
    final showPickupQr = book.canPickup;
    final showQrButton = showReturnQr || showPickupQr;
    // Payment button shows ONLY when the backend says a stage is payable
    // (waiting_overdue_payment or waiting_damage_payment) — so it never appears
    // for a plain-overdue loan that hasn't been scanned yet.
    final canPay = book.canPay;

    return Scaffold(
      backgroundColor: LuminaColors.background,
      bottomNavigationBar: (showQrButton || canPay)
          ? _LoanBottomActionBar(
              mustPayFine: canPay,
              payLabel: book.canPayDamage
                  ? 'Bayar Biaya Kerusakan'
                  : 'Bayar Denda Keterlambatan',
              hasPendingPayment: _existingPayment != null,
              showPickupQr: showPickupQr,
              showReturnQr: showReturnQr,
              onShowQrTap: showPickupQr ? _showPickupQrBottomSheet : _showReturnQrBottomSheet,
              onPayFineTap: _handleProceedToPayment,
            )
          : null,
      body: Column(
        children: [
          _LoanDetailGradientHeader(book: book),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _isRefreshing && _loadError == null
                  ? const _LoanDetailSkeleton(key: ValueKey('skeleton'))
                  : _loadError != null
                      ? _LoanDetailErrorState(key: const ValueKey('error'), onRetry: () => _refetchBook(silent: false))
                      : _LoanDetailBody(key: const ValueKey('body'), book: book, mustPayFine: canPay, onRouteTap: _openRoutePage),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoanDetailBody extends StatelessWidget {
  const _LoanDetailBody({
    super.key,
    required this.book,
    required this.mustPayFine,
    required this.onRouteTap,
  });

  final LibraryMyBookItemModel book;
  final bool mustPayFine;
  final VoidCallback onRouteTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(offset: Offset(0, (1 - value) * 12), child: child),
      ),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          LuminaSpacing.marginMobile,
          LuminaSpacing.lg,
          LuminaSpacing.marginMobile,
          120,
        ),
        children: [
          _LoanStatusChip(book: book),
          const SizedBox(height: LuminaSpacing.lg),
          _LoanBookInfoCard(book: book),
          const SizedBox(height: LuminaSpacing.lg),
          _LoanTimelineCard(book: book),
          if (book.isFinished) ...[
            const SizedBox(height: LuminaSpacing.lg),
            _CompletedSummaryCard(book: book),
          ] else if (!mustPayFine) ...[
            const SizedBox(height: LuminaSpacing.lg),
            _ReturnLocationCard(book: book, onRouteTap: onRouteTap),
          ],
          if (book.hasFine) ...[
            const SizedBox(height: LuminaSpacing.lg),
            _FineSummaryCard(book: book),
          ],
        ],
      ),
    );
  }
}

class _LoanDetailGradientHeader extends StatelessWidget {
  const _LoanDetailGradientHeader({required this.book});

  final LibraryMyBookItemModel book;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [LuminaColors.primary, LuminaColors.primary.withOpacity(0.85)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.marginMobile),
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
                    child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
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
                    color: Colors.white,
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

class _LoanDetailSkeleton extends StatelessWidget {
  const _LoanDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        LuminaSpacing.marginMobile,
        LuminaSpacing.lg,
        LuminaSpacing.marginMobile,
        120,
      ),
      children: const [
        _SkeletonBlock(height: 40, borderRadius: LuminaRadius.lg),
        SizedBox(height: LuminaSpacing.lg),
        _SkeletonBlock(height: 144, borderRadius: LuminaRadius.xl),
        SizedBox(height: LuminaSpacing.lg),
        _SkeletonBlock(height: 140, borderRadius: LuminaRadius.xl),
        SizedBox(height: LuminaSpacing.lg),
        _SkeletonBlock(height: 100, borderRadius: LuminaRadius.xl),
      ],
    );
  }
}

class _SkeletonBlock extends StatefulWidget {
  const _SkeletonBlock({required this.height, required this.borderRadius});

  final double height;
  final double borderRadius;

  @override
  State<_SkeletonBlock> createState() => _SkeletonBlockState();
}

class _SkeletonBlockState extends State<_SkeletonBlock> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(LuminaColors.surfaceContainerLow, LuminaColors.surfaceContainerHigh, t),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

class _LoanDetailErrorState extends StatelessWidget {
  const _LoanDetailErrorState({super.key, required this.onRetry});

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
            Text(
              'Gagal memuat detail peminjaman.',
              textAlign: TextAlign.center,
              style: LuminaTextStyles.bodyMd.copyWith(color: LuminaColors.onSurfaceVariant),
            ),
            const SizedBox(height: LuminaSpacing.md),
            OutlinedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}

class _LoanStatusChip extends StatelessWidget {
  const _LoanStatusChip({
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
        borderRadius: BorderRadius.circular(LuminaRadius.full),
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
              book.statusLabelId,
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
      case LibraryMyBookStatus.readyForReturn:
        return Icons.assignment_return_rounded;
      case LibraryMyBookStatus.returnPendingVerification:
        return Icons.hourglass_bottom_rounded;
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
      case LibraryMyBookStatus.readyForReturn:
        return LuminaColors.secondary;
      case LibraryMyBookStatus.returnPendingVerification:
        return LuminaColors.primary;
      case LibraryMyBookStatus.finished:
        return LuminaColors.secondary;
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
      case LibraryMyBookStatus.readyForReturn:
        return LuminaColors.secondary.withOpacity(0.12);
      case LibraryMyBookStatus.returnPendingVerification:
        return LuminaColors.primaryFixed.withOpacity(0.38);
      case LibraryMyBookStatus.finished:
        return LuminaColors.secondary.withOpacity(0.12);
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
              errorBuilder: (_, _, _) {
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

/// Displays the fine breakdown exactly as returned by the backend
/// (overdue_days / fine_per_day / total_fine — see FineCalculator on the
/// backend) — no value here is computed in Flutter, every number is a
/// direct passthrough of [book]'s fields.
class _FineSummaryCard extends StatelessWidget {
  const _FineSummaryCard({
    required this.book,
  });

  final LibraryMyBookItemModel book;

  @override
  Widget build(BuildContext context) {
    // Damage stage is a DIFFERENT charge — never show the overdue-days /
    // fine-per-day breakdown there (that made the damage total read like the
    // old overdue price). Title + breakdown follow the backend workflow.
    final isDamage = book.canPayDamage;
    final title = isDamage
        ? 'Biaya Kerusakan'
        : book.canPayOverdue
            ? 'Denda Keterlambatan'
            : (book.mustPayFine ? 'Payment Required' : 'Outstanding Fine');

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: LuminaColors.error.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: LuminaColors.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: LuminaSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: LuminaTextStyles.bodyMd.copyWith(
                    color: LuminaColors.onErrorContainer,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: LuminaSpacing.md),
          if (isDamage)
            // Damage: no overdue breakdown — just the amount to pay.
            _FineBreakdownItem(
              label: 'Total Biaya',
              value: book.fineAmountText,
              emphasize: true,
            )
          else
            Row(
              children: [
                Expanded(
                  child: _FineBreakdownItem(
                    label: 'Overdue Days',
                    value: '${book.overdueDays} Days',
                  ),
                ),
                Expanded(
                  child: _FineBreakdownItem(
                    label: 'Fine Per Day',
                    value: book.finePerDayText,
                  ),
                ),
                Expanded(
                  child: _FineBreakdownItem(
                    label: 'Total Fine',
                    value: book.fineAmountText,
                    emphasize: true,
                  ),
                ),
              ],
            ),
          if (book.mustPayFine) ...[
            const SizedBox(height: LuminaSpacing.sm),
            Text(
              book.workflowStepDescription.isNotEmpty
                  ? book.workflowStepDescription
                  : 'Selesaikan pembayaran di bawah untuk melanjutkan.',
              style: LuminaTextStyles.labelMd.copyWith(
                color: LuminaColors.onErrorContainer.withOpacity(0.78),
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FineBreakdownItem extends StatelessWidget {
  const _FineBreakdownItem({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: LuminaTextStyles.labelMd.copyWith(
            color: LuminaColors.onErrorContainer.withOpacity(0.75),
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: LuminaTextStyles.bodyMd.copyWith(
            color: LuminaColors.onErrorContainer,
            fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _LoanBottomActionBar extends StatelessWidget {
  const _LoanBottomActionBar({
    required this.mustPayFine,
    required this.payLabel,
    required this.hasPendingPayment,
    required this.showPickupQr,
    required this.showReturnQr,
    required this.onShowQrTap,
    required this.onPayFineTap,
  });

  final bool mustPayFine;
  final String payLabel;
  final bool hasPendingPayment;
  final bool showPickupQr;
  final bool showReturnQr;
  final VoidCallback onShowQrTap;
  final VoidCallback onPayFineTap;

  @override
  Widget build(BuildContext context) {
    // Overdue / payment-required: ONE primary button, nothing else — the
    // member cannot generate a Return QR until payment succeeds (the
    // backend enforces this too — see MyBookService::refreshReturnQr on
    // the backend — this is UI-side reinforcement, not the only guard).
    if (mustPayFine) {
      return _AnimatedBottomBar(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: onPayFineTap,
            icon: const Icon(Icons.payment_rounded, size: 20),
            label: Text(
              hasPendingPayment ? 'Lanjutkan Pembayaran' : payLabel,
              style: LuminaTextStyles.titleSm.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: LuminaColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LuminaRadius.full)),
            ),
          ),
        ),
      );
    }

    final qrLabel = showPickupQr ? 'QR Pengambilan' : 'Generate Return QR';

    return _AnimatedBottomBar(
      child: SizedBox(
        width: double.infinity,
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
    );
  }
}

/// Thin chrome + entrance animation shared by both action-bar states above.
class _AnimatedBottomBar extends StatelessWidget {
  const _AnimatedBottomBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
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
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.92, end: 1),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            builder: (context, scale, c) => Transform.scale(scale: scale, child: c),
            child: child,
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

  StreamSubscription<WebSocketEvent>? _wsSubscription;
  CheckoutQrModel? _qr;
  // Decoded once when a QR is applied and reused for the widget's whole life —
  // the countdown lives in its own widget now, so the QR image never rebuilds
  // on tick, but keeping a stable byte reference (+ gaplessPlayback) is the
  // belt-and-suspenders against any flicker on the rare full-sheet rebuild.
  Uint8List? _qrBytes;
  DateTime? _expiry;
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isExpired = false;
  String? _invalidReason;

  String get _cacheKey =>
      '${widget.borrowingId}_${widget.isPickup ? "pickup" : "return"}';

  @override
  void initState() {
    super.initState();
    _initQr();
    unawaited(_enableScreenProtection());
    _listenToRealtimeEvents();
  }

  /// Resolves the QR for the FIRST frame synchronously when a valid cached one
  /// exists, so the sheet opens straight onto the QR — no loading spinner and
  /// no "failed to load" flash before an async fetch resolves (the old jump).
  void _initQr() {
    final cached = _qrCache[_cacheKey];
    final cachedExpiry = _qrExpiryCache[_cacheKey];

    if (cached != null &&
        cachedExpiry != null &&
        DateTime.now().isBefore(cachedExpiry) &&
        _validateQrImage(cached, source: 'cache')) {
      _qr = cached;
      _qrBytes = cached.imageBytes;
      _expiry = cachedExpiry;
      _isLoading = false;
      return;
    }

    _isLoading = true;
    unawaited(_fetchQr());
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    unawaited(_disableScreenProtection());
    super.dispose();
  }

  /// Live updates while this sheet is open. Websocket events must NEVER
  /// regenerate the QR — that was the root of the "QR keeps refreshing / staff
  /// scans a stale code" bug. We only react to EXPIRY here (dim the code so a
  /// dead QR is never shown as scannable); the QR image itself changes solely
  /// via the member's explicit "Perbarui QR" tap. Scoped to THIS borrowing.
  void _listenToRealtimeEvents() {
    if (!Get.isRegistered<WebSocketService>()) return;

    _wsSubscription = Get.find<WebSocketService>().events.listen((event) {
      if (event.borrowingId != widget.borrowingId) return;

      switch (event.name) {
        case 'qr.generated':
        case 'qr.refreshed':
          // Intentionally ignored: the backend now returns ONE stable active
          // QR per borrowing+type, so these are informational only. Refetching
          // here is exactly what caused the regenerate-on-rebuild loop.
          debugPrint('[QR][WS] ${event.name} ignored — QR is stable until Refresh/expiry');
        case 'qr.expired':
          final qrIds = (event.data['qr_ids'] as List?)?.cast<dynamic>() ?? const [];
          if (qrIds.contains(_qr?.id) || _qr == null) {
            debugPrint('[QR][WS] qr.expired received for this sheet');
            if (mounted) setState(() => _isExpired = true);
          }
        case 'borrowing.expired':
          debugPrint('[QR][WS] borrowing.expired received for this sheet');
          if (mounted) setState(() => _isExpired = true);
        case 'borrowing.updated':
          // Staff scanned this Return QR (books received) → the code is now
          // consumed; auto-close the QR sheet so the member sees the updated
          // borrow detail instead of a stale QR.
          if (event.data['action'] == 'return_received' && mounted) {
            debugPrint('[QR][WS] return_received — closing QR sheet');
            Navigator.of(context).maybePop();
          }
      }
    });
  }

  String get _refreshEndpoint => widget.isPickup
      ? '/borrowings/${widget.borrowingId}/qr/refresh'
      : '/my-books/${widget.borrowingId}/return-qr/refresh';

  /// Validates that [qr.imageBytes] decodes to a renderable raster image.
  /// Logs the exact failure reason ([source] = cache | fresh-fetch |
  /// manual-refresh) so we can pinpoint whether corruption happened during
  /// base64 decode or because the backend emitted a non-raster format (SVG).
  bool _validateQrImage(CheckoutQrModel qr, {required String source}) {
    final bytes = qr.imageBytes;
    if (bytes == null) {
      debugPrint('[QR][VALIDATE][$source] FAILED — could not decode any bytes from imageDataUri');
      return false;
    }
    debugPrint('[QR][VALIDATE][$source] Decoded ${bytes.length} bytes');
    if (qr.isSvgContent) {
      debugPrint('[QR][VALIDATE][$source] FAILED — payload is SVG markup; Image.memory cannot render SVG. Backend must emit PNG/JPEG.');
      return false;
    }
    if (!qr.isRenderableRasterImage) {
      final headLen = bytes.length < 8 ? bytes.length : 8;
      final headHex = bytes.sublist(0, headLen).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
      debugPrint('[QR][VALIDATE][$source] FAILED — unrecognized image signature. First bytes: $headHex');
      return false;
    }
    debugPrint('[QR][VALIDATE][$source] OK — recognized raster image signature');
    return true;
  }

  String _describeInvalidReason(CheckoutQrModel qr) {
    if (qr.imageBytes == null) {
      return 'Data QR dari server tidak dapat dibaca (base64 tidak valid atau terpotong).';
    }
    if (qr.isSvgContent) {
      return 'Server mengirim QR dalam format SVG, namun aplikasi memerlukan format PNG/JPEG.';
    }
    return 'Format gambar QR dari server tidak dikenali atau rusak.';
  }

  /// Fetches the QR. Cache hits are resolved up-front in [_initQr] (so the
  /// first frame never flashes a spinner); this only runs when there's no
  /// valid local cache or on a "Coba Lagi" retry. [forceRefresh] maps to the
  /// backend `force` flag — false (the default here) makes the backend REUSE
  /// the existing active QR instead of generating a new one, so simply opening
  /// the sheet never regenerates. It's only true when the current cached image
  /// is corrupt and the retry genuinely needs a fresh code.
  Future<void> _fetchQr({bool forceRefresh = false}) async {
    debugPrint('[QR] Requesting QR (force=$forceRefresh) — endpoint: $_refreshEndpoint');
    setState(() { _isLoading = true; });
    try {
      final service = Get.find<HomeApiService>();
      final qr = widget.isPickup
          ? await service.refreshPickupQr(widget.borrowingId, force: forceRefresh)
          : await service.refreshReturnQr(widget.borrowingId, force: forceRefresh);
      if (!mounted) return;
      _applyFetchedQr(qr, source: forceRefresh ? 'forced-fetch' : 'reuse-fetch');
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
    // Clear cache so the upcoming API call is not short-circuited.
    _qrCache.remove(_cacheKey);
    _qrExpiryCache.remove(_cacheKey);
    setState(() { _isRefreshing = true; _isExpired = false; _invalidReason = null; });
    debugPrint('[QR] Manual refresh (force=true) — endpoint: $_refreshEndpoint');
    try {
      final service = Get.find<HomeApiService>();
      // The ONLY place that forces regeneration: invalidate the old QR and
      // mint a new one server-side.
      final qr = widget.isPickup
          ? await service.refreshPickupQr(widget.borrowingId, force: true)
          : await service.refreshReturnQr(widget.borrowingId, force: true);
      if (!mounted) return;
      _applyFetchedQr(qr, source: 'manual-refresh');
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

  /// Single place a freshly fetched QR is committed to state + cache. Decodes
  /// the bytes ONCE ([_qrBytes]) so the displayed image has a stable reference.
  void _applyFetchedQr(CheckoutQrModel qr, {required String source}) {
    final isValid = _validateQrImage(qr, source: source);
    final expiry = _parseQrExpiry(qr);
    _qrCache[_cacheKey] = qr;
    _qrExpiryCache[_cacheKey] = expiry;
    debugPrint('[QR] New QR received — expires at $expiry');
    setState(() {
      _qr = qr;
      _qrBytes = isValid ? qr.imageBytes : null;
      _expiry = expiry;
      _isLoading = false;
      _isRefreshing = false;
      _isExpired = false;
      _invalidReason = isValid ? null : _describeInvalidReason(qr);
    });
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

            const SizedBox(height: LuminaSpacing.sm),

            // Borrowing code
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: LuminaSpacing.md, vertical: 6),
              decoration: BoxDecoration(
                color: LuminaColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(LuminaRadius.full),
                border: Border.all(color: LuminaColors.primary.withOpacity(0.18)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.confirmation_number_outlined,
                      size: 15, color: LuminaColors.primary),
                  const SizedBox(width: LuminaSpacing.xs),
                  Text(
                    widget.borrowingCode,
                    style: LuminaTextStyles.labelMd.copyWith(
                      color: LuminaColors.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
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
            else if (_invalidReason != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: LuminaSpacing.xl),
                child: Column(
                  children: [
                    const Icon(Icons.broken_image_rounded, color: LuminaColors.error, size: 48),
                    const SizedBox(height: LuminaSpacing.sm),
                    Text(
                      'QR tidak valid',
                      style: LuminaTextStyles.bodyMd.copyWith(
                        color: LuminaColors.error,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _invalidReason!,
                      textAlign: TextAlign.center,
                      style: LuminaTextStyles.labelMd.copyWith(
                        color: LuminaColors.onSurfaceVariant,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: LuminaSpacing.md),
                    OutlinedButton(
                      onPressed: () => _fetchQr(forceRefresh: true),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
            else ...[
              // Countdown pill
              // Countdown lives in its own widget: it ticks once a second
              // WITHOUT rebuilding the sheet (or the QR image), which is what
              // used to cause the per-second flicker. Keyed by expiry so a
              // refreshed QR restarts it. Reports expiry back so the QR dim
              // overlay engages.
              _QrCountdownPill(
                key: ValueKey(_expiry),
                expiry: _expiry!,
                forceExpired: _isExpired,
                onExpired: () {
                  if (mounted && !_isExpired) setState(() => _isExpired = true);
                },
              ),

              const SizedBox(height: LuminaSpacing.md),

              // QR image
              Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: (_isExpired || _isRefreshing) ? 0.22 : 1.0,
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
                      child: _qrBytes != null
                          ? Image.memory(
                              _qrBytes!,
                              fit: BoxFit.contain,
                              // Hold the last frame while any (identical) bytes
                              // resolve — no white flash between rebuilds.
                              gaplessPlayback: true,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint('[QR][RENDER] Image.memory failed to decode at render time: $error');
                                return const Icon(Icons.error_outline_rounded, size: 64, color: LuminaColors.error);
                              },
                            )
                          : const Icon(Icons.qr_code_2_rounded, size: 80, color: LuminaColors.primary),
                    ),
                  ),
                  // Dim + overlay the QR while a refresh is in flight so a
                  // soon-to-be-invalidated code is never presented as if it
                  // were still scannable.
                  if (_isRefreshing && !_isExpired)
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(LuminaRadius.xl),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: LuminaSpacing.xs),
                          Text(
                            'Memperbarui...',
                            style: LuminaTextStyles.titleMd.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
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

            // View Detail + Close. The sheet is opened from the borrowing's
            // detail page, so "Lihat Detail" dismisses the sheet to reveal
            // that page (the QR Detail view) underneath — it is never removed.
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: TextButton.icon(
                      onPressed: Get.back,
                      icon: const Icon(Icons.receipt_long_rounded, size: 18),
                      style: TextButton.styleFrom(
                        foregroundColor: LuminaColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(LuminaRadius.full)),
                      ),
                      label: Text(
                        'Lihat Detail',
                        style: LuminaTextStyles.titleSm.copyWith(
                          color: LuminaColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: LuminaSpacing.sm),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: Get.back,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: LuminaColors.primary,
                        side: BorderSide(color: LuminaColors.primary.withOpacity(0.24), width: 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(LuminaRadius.full)),
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Self-contained 1-second countdown. Owns its own [Timer] so ticking never
/// rebuilds the parent QR sheet (the old per-second flicker). Anchors to the
/// absolute [expiry] instant so it self-corrects after the app is backgrounded
/// (Timer.periodic doesn't fire while suspended). Calls [onExpired] once when
/// it hits zero; [forceExpired] lets the parent (WS push) mark it expired.
class _QrCountdownPill extends StatefulWidget {
  const _QrCountdownPill({
    super.key,
    required this.expiry,
    required this.onExpired,
    this.forceExpired = false,
  });

  final DateTime expiry;
  final VoidCallback onExpired;
  final bool forceExpired;

  @override
  State<_QrCountdownPill> createState() => _QrCountdownPillState();
}

class _QrCountdownPillState extends State<_QrCountdownPill> {
  Timer? _timer;
  int _secondsLeft = 0;
  bool _notified = false;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    if (!mounted) return;
    final remaining = widget.expiry.difference(DateTime.now()).inSeconds;
    setState(() => _secondsLeft = remaining > 0 ? remaining : 0);
    if (remaining <= 0) {
      _timer?.cancel();
      if (!_notified) {
        _notified = true;
        widget.onExpired();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final expired = widget.forceExpired || _secondsLeft <= 0;
    final danger = expired || _secondsLeft <= 15;
    final color = danger ? LuminaColors.error : LuminaColors.secondary;

    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: LuminaSpacing.md, vertical: LuminaSpacing.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(LuminaRadius.full),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(expired ? Icons.timer_off_rounded : Icons.timer_rounded,
              size: 16, color: color),
          const SizedBox(width: LuminaSpacing.xs),
          Text(
            expired ? 'QR Kadaluwarsa' : '$m:$s',
            style: LuminaTextStyles.labelMd.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
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

class _CompletedSummaryCard extends StatelessWidget {
  const _CompletedSummaryCard({required this.book});

  final LibraryMyBookItemModel book;

  @override
  Widget build(BuildContext context) {
    final wasFinedAndPaid = book.rawStatus == 'returned_with_fine';

    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(
          color: LuminaColors.secondary.withOpacity(0.22),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: LuminaColors.secondary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: LuminaColors.secondary, size: 20),
              ),
              const SizedBox(width: LuminaSpacing.sm),
              Text(
                'Borrowing Completed',
                style: LuminaTextStyles.bodyMd.copyWith(
                  color: LuminaColors.secondary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: LuminaSpacing.md),
          if (book.returnedDateText != null) _CompletedRow(
            icon: Icons.event_available_rounded,
            label: 'Return Date',
            value: book.returnedDateText!,
          ),
          _CompletedRow(
            icon: Icons.local_library_rounded,
            label: 'Branch',
            value: book.libraryName,
          ),
          if (wasFinedAndPaid) ...[
            const SizedBox(height: LuminaSpacing.sm),
            Row(
              children: [
                const Icon(Icons.receipt_long_rounded, color: LuminaColors.secondary, size: 16),
                const SizedBox(width: LuminaSpacing.xs),
                Text(
                  'Fine Paid',
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: LuminaColors.secondary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
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

class _CompletedRow extends StatelessWidget {
  const _CompletedRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: LuminaSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 15, color: LuminaColors.outline),
          const SizedBox(width: LuminaSpacing.xs),
          Text(
            '$label: ',
            style: LuminaTextStyles.labelMd.copyWith(
              color: LuminaColors.outline,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LuminaTextStyles.labelMd.copyWith(
                color: LuminaColors.onSurface,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
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

/// Success animation shown when the two-stage return flow completes, just
/// before the page auto-navigates back to My Books.
class _BorrowingCompletedDialog extends StatelessWidget {
  const _BorrowingCompletedDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: LuminaColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(LuminaSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (context, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: LuminaColors.secondary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: LuminaColors.secondary, size: 44),
              ),
            ),
            const SizedBox(height: LuminaSpacing.md),
            Text(
              'Peminjaman Selesai',
              style: LuminaTextStyles.titleLg.copyWith(
                color: LuminaColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: LuminaSpacing.xs),
            Text(
              'Terima kasih! Semua kewajiban telah diselesaikan.',
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
