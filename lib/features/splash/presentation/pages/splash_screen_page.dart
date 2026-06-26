import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/core/routing/lumina_role_router.dart';
import 'package:lumina_library/core/services/lumina_permission_service.dart';
import 'package:lumina_library/core/services/lumina_storage_service.dart';
import 'package:lumina_library/core/services/websocket/websocket_service.dart';
import 'package:lumina_library/features/auth/data/models/auth_models.dart';
import 'package:lumina_library/features/auth/data/services/auth_api_service.dart';
import 'package:lumina_library/features/onboarding/presentation/pages/onboarding_page.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({
    super.key,
    this.duration = const Duration(milliseconds: 2500), // Sedikit diperpanjang agar animasi logo lebih dinikmati
  });

  final Duration duration;

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Animasi sedikit lebih smooth
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();
    _timer = Timer(widget.duration, _goToHome);
  }

  void _goToHome() {
    if (!mounted) return;
    _resolveDestination();
  }

  Future<void> _resolveDestination() async {
    if (!mounted) return;

    // Jika ada token tersimpan, coba restore session.
    if (LuminaStorageService.hasSession) {
      await _tryRestoreSession();
      return;
    }

    // Tidak ada session — tampilkan onboarding atau login.
    _navigateToOnboardingOrLogin();
  }

  Future<void> _tryRestoreSession() async {
    try {
      final authService = Get.find<AuthApiService>();
      final user = await authService.me();

      LuminaStorageService.saveUser(user.toJson());
      unawaited(Get.find<WebSocketService>().connectForCurrentUser());

      if (!mounted) return;
      final role = user.isStaff ? 'STAFF' : 'MEMBER';
      await LuminaPermissionService.navigateWithCheck(
        () => LuminaRoleRouter.navigateAfterLogin(role),
      );
    } on LuminaApiException catch (e) {
      if (e.isUnauthorized) {
        LuminaStorageService.clearSession();
      }
      if (!mounted) return;
      await _navigateToOnboardingOrLogin();
    } catch (_) {
      // Gagal jaringan — coba gunakan data user yang tersimpan.
      final userJson = LuminaStorageService.getUser();
      if (!mounted) return;

      if (userJson != null) {
        final user = AuthUserModel.fromJson(userJson);
        final role = user.isStaff ? 'STAFF' : 'MEMBER';
        unawaited(Get.find<WebSocketService>().connectForCurrentUser());
        await LuminaPermissionService.navigateWithCheck(
          () => LuminaRoleRouter.navigateAfterLogin(role),
        );
      } else {
        await _navigateToOnboardingOrLogin();
      }
    }
  }

  Future<void> _navigateToOnboardingOrLogin() async {
    if (!mounted) return;

    if (LuminaStorageService.isOnboardingDone) {
      await LuminaPermissionService.navigateWithCheck(
        LuminaRoleRouter.goToLogin,
      );
      return;
    }

    // Onboarding belum selesai — permission gate ditampilkan setelah onboarding.
    Get.off(
      () => const OnboardingPage(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuminaColors.background,
      body: SafeArea(
        child: Padding(
          padding: LuminaSpacing.pagePadding,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: const _SplashContent(),
                    ),
                  ),
                ),
              ),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const _SplashFooter(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Menggunakan asset gambar logo
        Image.asset(
          'assets/images/logo/lumina-logo.png',
          width: 160, // Sesuaikan lebar ini agar proporsional dengan layout Anda
          fit: BoxFit.contain,
        ),
        const SizedBox(height: LuminaSpacing.xl),
        
        // Badge dengan sentuhan UI yang lebih rapi dan merepresentasikan perpustakaan
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: LuminaSpacing.lg,
            vertical: LuminaSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: LuminaColors.secondary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(LuminaRadius.full),
            border: Border.all(
              color: LuminaColors.secondary.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.menu_book_rounded, // Ikon buku untuk mempertegas identitas library
                size: 16,
                color: LuminaColors.secondary,
              ),
              const SizedBox(width: LuminaSpacing.sm),
              Text(
                'PERPUSTAKAAN AKADEMIK',
                style: LuminaTextStyles.labelMd.copyWith(
                  color: LuminaColors.secondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2, // Menambah kesan clean dan modern
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SplashFooter extends StatelessWidget {
  const _SplashFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: LuminaColors.secondary,
            backgroundColor: LuminaColors.surfaceContainerHigh,
          ),
        ),
        const SizedBox(height: LuminaSpacing.md),
        Text(
          'Menyusun rak digital Anda...', // Copywriting bernuansa perpustakaan
          textAlign: TextAlign.center,
          style: LuminaTextStyles.bodyMd.copyWith(
            color: LuminaColors.onSurfaceVariant,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: LuminaSpacing.lg), // Memberikan sedikit ruang bernapas di bagian bawah
      ],
    );
  }
}