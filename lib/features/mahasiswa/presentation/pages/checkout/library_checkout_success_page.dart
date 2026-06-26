import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/mahasiswa/data/services/home_api_service.dart';
import 'package:lumina_library/shared/models/borrowing/checkout_result_model.dart';
import 'package:lumina_library/shared/widgets/feedback/lumina_toast.dart';

class LibraryCheckoutSuccessPage extends StatefulWidget {
  const LibraryCheckoutSuccessPage({super.key, required this.result});

  final CheckoutResultModel result;

  @override
  State<LibraryCheckoutSuccessPage> createState() =>
      _LibraryCheckoutSuccessPageState();
}

class _LibraryCheckoutSuccessPageState
    extends State<LibraryCheckoutSuccessPage> {
  late CheckoutQrModel _qr;
  Timer? _countdownTimer;
  int _secondsLeft = 0;
  bool _isRefreshing = false;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _qr = widget.result.qr;
    _secondsLeft = _qr.ttlSeconds;
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _isExpired = true;
          t.cancel();
        }
      });
    });
  }

  Future<void> _refreshQr() async {
    if (_isRefreshing) return;
    setState(() {
      _isRefreshing = true;
      _isExpired = false;
    });

    try {
      final service = Get.find<HomeApiService>();
      final newQr = await service.refreshPickupQr(
        widget.result.borrowing.id,
      );
      if (!mounted) return;
      setState(() {
        _qr = newQr;
        _secondsLeft = newQr.ttlSeconds;
      });
      _startCountdown();
    } on LuminaApiException catch (e) {
      LuminaToast.error(e.displayMessage);
    } catch (_) {
      LuminaToast.error('Gagal memperbarui QR. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final borrowing = widget.result.borrowing;

    return Scaffold(
      backgroundColor: LuminaColors.background,
      body: Column(
        children: [
          // ── Top bar ────────────────────────────────────────────────────────
          _SuccessTopBar(
            onClose: () => Get.until((route) => route.isFirst),
          ),

          // ── Content ────────────────────────────────────────────────────────
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                LuminaSpacing.marginMobile,
                LuminaSpacing.lg,
                LuminaSpacing.marginMobile,
                LuminaSpacing.xl,
              ),
              children: [
                // Success banner
                const _SuccessBanner(),

                const SizedBox(height: LuminaSpacing.lg),

                // Borrowing info card
                _BorrowingInfoCard(borrowing: borrowing),

                const SizedBox(height: LuminaSpacing.lg),

                // QR code card
                _QrCodeCard(
                  qr: _qr,
                  secondsLeft: _secondsLeft,
                  isExpired: _isExpired,
                  isRefreshing: _isRefreshing,
                  onRefresh: _refreshQr,
                ),

                const SizedBox(height: LuminaSpacing.lg),

                // Books list
                if (borrowing.items.isNotEmpty) ...[
                  _BorrowedBooksCard(items: borrowing.items),
                  const SizedBox(height: LuminaSpacing.lg),
                ],

                // Instructions
                const _InstructionCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Top bar ──────────────────────────────────────────────────────────────────

class _SuccessTopBar extends StatelessWidget {
  const _SuccessTopBar({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.marginMobile),
        decoration: const BoxDecoration(
          color: LuminaColors.surface,
          border: Border(
            bottom: BorderSide(color: LuminaColors.surfaceVariant, width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Checkout Berhasil',
                style: LuminaTextStyles.titleLg.copyWith(
                  color: LuminaColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            GestureDetector(
              onTap: onClose,
              child: Container(
                padding: const EdgeInsets.all(LuminaSpacing.xs),
                decoration: BoxDecoration(
                  color: LuminaColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(LuminaRadius.lg),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: LuminaColors.onSurfaceVariant,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Success banner ───────────────────────────────────────────────────────────

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(
          color: LuminaColors.secondary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: LuminaColors.secondary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: LuminaColors.secondary.withValues(alpha: 0.30),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: LuminaColors.onSecondary,
              size: 28,
            ),
          ),
          const SizedBox(width: LuminaSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Peminjaman Berhasil Diajukan!',
                  style: LuminaTextStyles.titleLg.copyWith(
                    color: LuminaColors.secondary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Tunjukkan QR di bawah kepada petugas perpustakaan untuk mengambil buku.',
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: LuminaColors.onSurfaceVariant,
                    letterSpacing: 0,
                    height: 1.4,
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

// ─── Borrowing info ───────────────────────────────────────────────────────────

class _BorrowingInfoCard extends StatelessWidget {
  const _BorrowingInfoCard({required this.borrowing});

  final CheckoutBorrowingModel borrowing;

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
          _InfoRow(
            icon: Icons.confirmation_number_rounded,
            label: 'Kode Transaksi',
            value: borrowing.code,
            valueStyle: LuminaTextStyles.bodyMd.copyWith(
              color: LuminaColors.primary,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
            ),
          ),
          const _Divider(),
          _InfoRow(
            icon: Icons.local_library_rounded,
            label: 'Perpustakaan',
            value: borrowing.branchName,
          ),
          const _Divider(),
          _InfoRow(
            icon: Icons.login_rounded,
            label: 'Tanggal Pinjam',
            value: borrowing.startDate,
          ),
          const _Divider(),
          _InfoRow(
            icon: Icons.assignment_return_rounded,
            label: 'Tanggal Kembali',
            value: borrowing.endDate,
          ),
          const _Divider(),
          _InfoRow(
            icon: Icons.timer_rounded,
            label: 'Durasi',
            value: '${borrowing.totalDays} hari',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LuminaSpacing.sm),
      child: Row(
        children: [
          Icon(icon, color: LuminaColors.secondary, size: 20),
          const SizedBox(width: LuminaSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: LuminaTextStyles.bodyMd.copyWith(
                color: LuminaColors.onSurfaceVariant,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: valueStyle ??
                  LuminaTextStyles.bodyMd.copyWith(
                    color: LuminaColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: LuminaColors.surfaceVariant);
  }
}

// ─── QR Code card ─────────────────────────────────────────────────────────────

class _QrCodeCard extends StatelessWidget {
  const _QrCodeCard({
    required this.qr,
    required this.secondsLeft,
    required this.isExpired,
    required this.isRefreshing,
    required this.onRefresh,
  });

  final CheckoutQrModel qr;
  final int secondsLeft;
  final bool isExpired;
  final bool isRefreshing;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final bytes = qr.imageBytes;

    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.lg),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(
          color: isExpired
              ? LuminaColors.error.withValues(alpha: 0.30)
              : LuminaColors.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_2_rounded,
                color: LuminaColors.primary,
                size: 22,
              ),
              const SizedBox(width: LuminaSpacing.xs),
              Text(
                'QR Pengambilan Buku',
                style: LuminaTextStyles.titleLg.copyWith(
                  color: LuminaColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: LuminaSpacing.md),

          // QR image
          Stack(
            alignment: Alignment.center,
            children: [
              // QR image or placeholder
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: LuminaColors.surface,
                  borderRadius: BorderRadius.circular(LuminaRadius.lg),
                  border: Border.all(color: LuminaColors.surfaceVariant),
                ),
                clipBehavior: Clip.antiAlias,
                child: bytes != null
                    ? Image.memory(
                        bytes,
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                      )
                    : Center(
                        child: Icon(
                          Icons.qr_code_rounded,
                          size: 80,
                          color: LuminaColors.outline,
                        ),
                      ),
              ),

              // Expired overlay
              if (isExpired)
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: LuminaColors.surface.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(LuminaRadius.lg),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        color: LuminaColors.primary,
                        size: 36,
                      ),
                      const SizedBox(height: LuminaSpacing.sm),
                      Text(
                        'QR Kedaluwarsa',
                        style: LuminaTextStyles.bodyMd.copyWith(
                          color: LuminaColors.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Tap "Perbarui QR" untuk mendapatkan kode baru.',
                        textAlign: TextAlign.center,
                        style: LuminaTextStyles.labelMd.copyWith(
                          color: LuminaColors.onSurfaceVariant,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: LuminaSpacing.md),

          // Countdown
          if (!isExpired)
            _CountdownPill(secondsLeft: secondsLeft)
          else
            _ExpiredPill(),

          const SizedBox(height: LuminaSpacing.md),

          // Refresh button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: isRefreshing ? null : onRefresh,
              icon: isRefreshing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: LuminaColors.primary,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                isRefreshing ? 'Memperbarui...' : 'Perbarui QR',
                style: LuminaTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: LuminaColors.primary,
                side: BorderSide(
                  color: isRefreshing
                      ? LuminaColors.outline
                      : LuminaColors.primary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(LuminaRadius.lg),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownPill extends StatelessWidget {
  const _CountdownPill({required this.secondsLeft});

  final int secondsLeft;

  @override
  Widget build(BuildContext context) {
    final isWarning = secondsLeft <= 15;
    final color = isWarning ? LuminaColors.error : LuminaColors.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.md,
        vertical: LuminaSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(LuminaRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_rounded, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            'QR berlaku ${secondsLeft}s',
            style: LuminaTextStyles.labelMd.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpiredPill extends StatelessWidget {
  const _ExpiredPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.md,
        vertical: LuminaSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: LuminaColors.errorContainer,
        borderRadius: BorderRadius.circular(LuminaRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_rounded, color: LuminaColors.error, size: 16),
          const SizedBox(width: 6),
          Text(
            'QR sudah kedaluwarsa',
            style: LuminaTextStyles.labelMd.copyWith(
              color: LuminaColors.error,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Borrowed books ───────────────────────────────────────────────────────────

class _BorrowedBooksCard extends StatelessWidget {
  const _BorrowedBooksCard({required this.items});

  final List<CheckoutItemModel> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(color: LuminaColors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              LuminaSpacing.md,
              LuminaSpacing.md,
              LuminaSpacing.md,
              LuminaSpacing.sm,
            ),
            child: Text(
              'Buku yang Dipinjam (${items.length})',
              style: LuminaTextStyles.bodyMd.copyWith(
                color: LuminaColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const Divider(height: 1, color: LuminaColors.surfaceVariant),
          ...items.asMap().entries.map((e) {
            final item = e.value;
            final isLast = e.key == items.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(LuminaSpacing.md),
                  child: Row(
                    children: [
                      // Cover
                      ClipRRect(
                        borderRadius: BorderRadius.circular(LuminaRadius.md),
                        child: item.coverUrl != null && item.coverUrl!.isNotEmpty
                            ? Image.network(
                                item.coverUrl!,
                                width: 44,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => _CoverPlaceholder(),
                              )
                            : _CoverPlaceholder(),
                      ),
                      const SizedBox(width: LuminaSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: LuminaTextStyles.bodyMd.copyWith(
                                color: LuminaColors.onSurface,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.author,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: LuminaTextStyles.labelMd.copyWith(
                                color: LuminaColors.onSurfaceVariant,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(
                    height: 1,
                    color: LuminaColors.surfaceVariant,
                    indent: LuminaSpacing.md,
                    endIndent: LuminaSpacing.md,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 60,
      color: LuminaColors.surfaceContainer,
      child: const Icon(
        Icons.menu_book_rounded,
        color: LuminaColors.outline,
        size: 20,
      ),
    );
  }
}

// ─── Instructions ─────────────────────────────────────────────────────────────

class _InstructionCard extends StatelessWidget {
  const _InstructionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(
          color: LuminaColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: LuminaColors.primary,
                size: 20,
              ),
              const SizedBox(width: LuminaSpacing.xs),
              Text(
                'Cara Pengambilan Buku',
                style: LuminaTextStyles.bodyMd.copyWith(
                  color: LuminaColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: LuminaSpacing.sm),
          _InstructionStep(
            number: '1',
            text: 'Datang ke perpustakaan sesuai jadwal yang dipilih.',
          ),
          const SizedBox(height: LuminaSpacing.xs),
          _InstructionStep(
            number: '2',
            text: 'Tunjukkan QR code di atas kepada petugas.',
          ),
          const SizedBox(height: LuminaSpacing.xs),
          _InstructionStep(
            number: '3',
            text:
                'Petugas akan memindai QR dan menyerahkan buku. Reservasi berlaku 24 jam.',
          ),
        ],
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  const _InstructionStep({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: LuminaColors.primary.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: LuminaTextStyles.labelMd.copyWith(
                color: LuminaColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
        const SizedBox(width: LuminaSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: LuminaTextStyles.labelMd.copyWith(
              color: LuminaColors.onSurfaceVariant,
              letterSpacing: 0,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
