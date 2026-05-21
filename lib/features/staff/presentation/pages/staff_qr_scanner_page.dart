import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/lumina_colors.dart';
import '../../../../core/theme/lumina_radius.dart';
import '../../../../core/theme/lumina_spacing.dart';
import '../../../../core/theme/lumina_text_styles.dart';

class StaffQrScannerPage extends StatefulWidget {
  const StaffQrScannerPage({
    super.key,
    this.title = 'Scan QR Peminjaman',
    this.description =
        'Arahkan kamera ke QR Code di layar HP mahasiswa atau barcode di buku',
    this.onScanned,
  });

  final String title;
  final String description;
  final ValueChanged<String>? onScanned;

  @override
  State<StaffQrScannerPage> createState() => _StaffQrScannerPageState();
}

class _StaffQrScannerPageState extends State<StaffQrScannerPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final MobileScannerController _scannerController;
  late final AnimationController _scanAnimationController;
  late final Animation<double> _scanLineAnimation;

  bool _isProcessingScan = false;
  bool _isTorchOn = false;
  String? _lastScannedCode;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      detectionTimeoutMs: 900,
    );

    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _scanLineAnimation = CurvedAnimation(
      parent: _scanAnimationController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_scannerController.value.hasCameraPermission) return;

    switch (state) {
      case AppLifecycleState.resumed:
        if (!_isProcessingScan) {
          unawaited(_scannerController.start());
        }
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        unawaited(_scannerController.stop());
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanAnimationController.dispose();
    unawaited(_scannerController.dispose());
    super.dispose();
  }

  Future<void> _handleDetect(BarcodeCapture capture) async {
    if (_isProcessingScan) return;

    final barcode = capture.barcodes.firstOrNull;
    final value = barcode?.rawValue?.trim();

    if (value == null || value.isEmpty) return;

    await _processScannedCode(value);
  }

  Future<void> _processScannedCode(String code) async {
    if (_isProcessingScan) return;

    setState(() {
      _isProcessingScan = true;
      _lastScannedCode = code;
    });

    await _scannerController.stop();

    if (!mounted) return;

    final shouldClosePage = await _showScanResultBottomSheet(code);

    if (!mounted) return;

    if (shouldClosePage == true) {
      widget.onScanned?.call(code);
      Navigator.of(context).pop(code);
      return;
    }

    await _restartScanner();
  }

  Future<void> _restartScanner() async {
    if (!mounted) return;

    setState(() {
      _isProcessingScan = false;
      _lastScannedCode = null;
    });

    await _scannerController.start();
  }

  Future<void> _toggleTorch() async {
    try {
      await _scannerController.toggleTorch();

      if (!mounted) return;

      setState(() {
        _isTorchOn = !_isTorchOn;
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Flashlight tidak tersedia di device atau browser ini.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openManualInputSheet() async {
    await _scannerController.stop();

    if (!mounted) return;

    final value = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const _ManualInputSheet();
      },
    );

    if (!mounted) return;

    final cleanValue = value?.trim();

    if (cleanValue != null && cleanValue.isNotEmpty) {
      await _processScannedCode(cleanValue);
      return;
    }

    if (!_isProcessingScan) {
      await _scannerController.start();
    }
  }

  Future<bool?> _showScanResultBottomSheet(String code) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) {
        return _ScanResultSheet(
          code: code,
          onProcessTap: () {
            Navigator.of(context).pop(true);
          },
          onScanAgainTap: () {
            Navigator.of(context).pop(false);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuminaColors.primary,
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: _scannerController,
              fit: BoxFit.cover,
              onDetect: _handleDetect,
            ),
          ),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: LuminaColors.primary.withOpacity(0.68),
              ),
            ),
          ),

          const Positioned.fill(
            child: _CameraVignetteOverlay(),
          ),

          SafeArea(
            child: Column(
              children: [
                _ScannerTopBar(
                  title: widget.title,
                  onBackTap: () {
                    Navigator.of(context).maybePop();
                  },
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      LuminaSpacing.marginMobile,
                      LuminaSpacing.lg,
                      LuminaSpacing.marginMobile,
                      128,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ScannerFrame(
                          animation: _scanLineAnimation,
                          isPaused: _isProcessingScan,
                        ),

                        const SizedBox(height: LuminaSpacing.xl),

                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: Text(
                            _lastScannedCode == null
                                ? widget.description
                                : 'QR berhasil terbaca. Mohon tunggu sebentar...',
                            textAlign: TextAlign.center,
                            style: LuminaTextStyles.bodyMd.copyWith(
                              color: LuminaColors.onPrimary.withOpacity(0.90),
                              height: 1.55,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.45),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 34,
            child: SafeArea(
              top: false,
              child: _ScannerActions(
                isTorchOn: _isTorchOn,
                onTorchTap: _toggleTorch,
                onManualInputTap: _openManualInputSheet,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerTopBar extends StatelessWidget {
  const _ScannerTopBar({
    required this.title,
    required this.onBackTap,
  });

  final String title;
  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.marginMobile,
      ),
      decoration: BoxDecoration(
        color: LuminaColors.primary.withOpacity(0.30),
        border: Border(
          bottom: BorderSide(
            color: LuminaColors.surfaceTint.withOpacity(0.20),
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
              onTap: onBackTap,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 42,
                height: 42,
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: LuminaColors.onPrimary.withOpacity(0.94),
                  size: 25,
                ),
              ),
            ),
          ),
          const SizedBox(width: LuminaSpacing.sm),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LuminaTextStyles.headlineSm.copyWith(
                color: LuminaColors.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame({
    required this.animation,
    required this.isPaused,
  });

  final Animation<double> animation;
  final bool isPaused;

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final frameSize = shortestSide >= 420 ? 320.0 : 280.0;

    return SizedBox(
      width: frameSize,
      height: frameSize,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(LuminaRadius.xl),
                border: Border.all(
                  color: LuminaColors.surfaceTint.withOpacity(0.32),
                  width: 1.5,
                ),
              ),
            ),
          ),

          if (!isPaused)
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final top = 18 + ((frameSize - 36) * animation.value);

                return Positioned(
                  left: 18,
                  right: 18,
                  top: top,
                  child: child!,
                );
              },
              child: Container(
                height: 2.4,
                decoration: BoxDecoration(
                  color: LuminaColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(LuminaRadius.full),
                  boxShadow: [
                    BoxShadow(
                      color: LuminaColors.secondaryContainer.withOpacity(0.85),
                      blurRadius: 14,
                      spreadRadius: 1.4,
                    ),
                  ],
                ),
              ),
            ),

          const _ScannerCorner(
            alignment: Alignment.topLeft,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(LuminaRadius.xl),
            ),
          ),
          const _ScannerCorner(
            alignment: Alignment.topRight,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(LuminaRadius.xl),
            ),
          ),
          const _ScannerCorner(
            alignment: Alignment.bottomLeft,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(LuminaRadius.xl),
            ),
          ),
          const _ScannerCorner(
            alignment: Alignment.bottomRight,
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(LuminaRadius.xl),
            ),
          ),

          if (isPaused)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: LuminaColors.primary.withOpacity(0.28),
                  borderRadius: BorderRadius.circular(LuminaRadius.xl),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 34,
                    height: 34,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      color: LuminaColors.secondaryContainer,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScannerCorner extends StatelessWidget {
  const _ScannerCorner({
    required this.alignment,
    required this.borderRadius,
  });

  final Alignment alignment;
  final BorderRadius borderRadius;

  bool get _isTop => alignment.y < 0;
  bool get _isLeft => alignment.x < 0;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.70, end: 1),
        duration: const Duration(milliseconds: 950),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                border: Border(
                  top: _isTop
                      ? const BorderSide(
                          color: LuminaColors.secondaryContainer,
                          width: 4,
                        )
                      : BorderSide.none,
                  bottom: !_isTop
                      ? const BorderSide(
                          color: LuminaColors.secondaryContainer,
                          width: 4,
                        )
                      : BorderSide.none,
                  left: _isLeft
                      ? const BorderSide(
                          color: LuminaColors.secondaryContainer,
                          width: 4,
                        )
                      : BorderSide.none,
                  right: !_isLeft
                      ? const BorderSide(
                          color: LuminaColors.secondaryContainer,
                          width: 4,
                        )
                      : BorderSide.none,
                ),
                boxShadow: [
                  BoxShadow(
                    color: LuminaColors.secondaryContainer.withOpacity(0.45),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ScannerActions extends StatelessWidget {
  const _ScannerActions({
    required this.isTorchOn,
    required this.onTorchTap,
    required this.onManualInputTap,
  });

  final bool isTorchOn;
  final VoidCallback onTorchTap;
  final VoidCallback onManualInputTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.marginMobile,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ScannerActionButton(
            icon: isTorchOn
                ? Icons.flashlight_on_rounded
                : Icons.flashlight_off_rounded,
            label: 'Flashlight',
            isActive: isTorchOn,
            onTap: onTorchTap,
          ),
          const SizedBox(width: 40),
          _ScannerActionButton(
            icon: Icons.keyboard_rounded,
            label: 'Input Manual',
            onTap: onManualInputTap,
          ),
        ],
      ),
    );
  }
}

class _ScannerActionButton extends StatelessWidget {
  const _ScannerActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isActive
        ? LuminaColors.secondaryContainer
        : LuminaColors.onPrimary.withOpacity(0.92);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: LuminaColors.surfaceContainerLowest.withOpacity(0.10),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive
                      ? LuminaColors.secondaryContainer.withOpacity(0.65)
                      : LuminaColors.surfaceTint.withOpacity(0.35),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: foregroundColor,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: LuminaSpacing.xs),
        Text(
          label,
          style: LuminaTextStyles.labelMd.copyWith(
            color: LuminaColors.onPrimary.withOpacity(0.82),
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ManualInputSheet extends StatefulWidget {
  const _ManualInputSheet();

  @override
  State<_ManualInputSheet> createState() => _ManualInputSheetState();
}

class _ManualInputSheetState extends State<_ManualInputSheet> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  bool get _canSubmit => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
    _focusNode = FocusNode();

    _controller.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();

    if (value.isEmpty) return;

    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          LuminaSpacing.marginMobile,
          LuminaSpacing.lg,
          LuminaSpacing.marginMobile,
          LuminaSpacing.marginMobile,
        ),
        decoration: const BoxDecoration(
          color: LuminaColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(LuminaRadius.xl),
            topRight: Radius.circular(LuminaRadius.xl),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: LuminaColors.outlineVariant,
                  borderRadius: BorderRadius.circular(LuminaRadius.full),
                ),
              ),
              const SizedBox(height: LuminaSpacing.lg),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Input Manual',
                  style: LuminaTextStyles.headlineSm.copyWith(
                    color: LuminaColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: LuminaSpacing.xs),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Masukkan kode transaksi, nomor peminjaman, atau kode buku secara manual.',
                  style: LuminaTextStyles.bodyMd.copyWith(
                    color: LuminaColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: LuminaSpacing.md),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                style: LuminaTextStyles.bodyLg.copyWith(
                  color: LuminaColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Contoh: BRW-2026-0001',
                  hintStyle: LuminaTextStyles.bodyMd.copyWith(
                    color: LuminaColors.outline,
                  ),
                  prefixIcon: const Icon(
                    Icons.qr_code_2_rounded,
                    color: LuminaColors.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: LuminaColors.surfaceContainerLowest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: LuminaSpacing.md,
                    vertical: LuminaSpacing.md,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(LuminaRadius.lg),
                    borderSide: const BorderSide(
                      color: LuminaColors.outlineVariant,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(LuminaRadius.lg),
                    borderSide: const BorderSide(
                      color: LuminaColors.outlineVariant,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(LuminaRadius.lg),
                    borderSide: const BorderSide(
                      color: LuminaColors.secondary,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: LuminaSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _canSubmit ? _submit : null,
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
                  child: Text(
                    'Gunakan Kode',
                    style: LuminaTextStyles.titleLg.copyWith(
                      color: _canSubmit
                          ? LuminaColors.onPrimary
                          : LuminaColors.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
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

class _ScanResultSheet extends StatelessWidget {
  const _ScanResultSheet({
    required this.code,
    required this.onProcessTap,
    required this.onScanAgainTap,
  });

  final String code;
  final VoidCallback onProcessTap;
  final VoidCallback onScanAgainTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        LuminaSpacing.marginMobile,
        LuminaSpacing.lg,
        LuminaSpacing.marginMobile,
        LuminaSpacing.marginMobile,
      ),
      decoration: const BoxDecoration(
        color: LuminaColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(LuminaRadius.xl),
          topRight: Radius.circular(LuminaRadius.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: LuminaColors.outlineVariant,
                borderRadius: BorderRadius.circular(LuminaRadius.full),
              ),
            ),
            const SizedBox(height: LuminaSpacing.lg),
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: LuminaColors.secondary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: LuminaColors.secondary,
                size: 38,
              ),
            ),
            const SizedBox(height: LuminaSpacing.md),
            Text(
              'QR Berhasil Dibaca',
              textAlign: TextAlign.center,
              style: LuminaTextStyles.headlineSm.copyWith(
                color: LuminaColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: LuminaSpacing.xs),
            Text(
              'Kode berikut siap diproses untuk validasi peminjaman.',
              textAlign: TextAlign.center,
              style: LuminaTextStyles.bodyMd.copyWith(
                color: LuminaColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: LuminaSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(LuminaSpacing.md),
              decoration: BoxDecoration(
                color: LuminaColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(LuminaRadius.lg),
                border: Border.all(
                  color: LuminaColors.outlineVariant,
                  width: 1,
                ),
              ),
              child: Text(
                code,
                textAlign: TextAlign.center,
                style: LuminaTextStyles.bodyLg.copyWith(
                  color: LuminaColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: LuminaSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onProcessTap,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: LuminaColors.primary,
                  foregroundColor: LuminaColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(LuminaRadius.lg),
                  ),
                ),
                child: Text(
                  'Proses Peminjaman',
                  style: LuminaTextStyles.titleLg.copyWith(
                    color: LuminaColors.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: LuminaSpacing.sm),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: TextButton(
                onPressed: onScanAgainTap,
                style: TextButton.styleFrom(
                  foregroundColor: LuminaColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(LuminaRadius.lg),
                  ),
                ),
                child: Text(
                  'Scan Ulang',
                  style: LuminaTextStyles.titleLg.copyWith(
                    color: LuminaColors.primary,
                    fontWeight: FontWeight.w800,
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

class _CameraVignetteOverlay extends StatelessWidget {
  const _CameraVignetteOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            radius: 0.92,
            colors: [
              Colors.transparent,
              LuminaColors.primary.withOpacity(0.10),
              LuminaColors.primary.withOpacity(0.48),
            ],
            stops: const [0, 0.55, 1],
          ),
        ),
      ),
    );
  }
}