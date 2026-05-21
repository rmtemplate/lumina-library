import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart';

import '../../../../core/theme/lumina_colors.dart';
import '../../../../core/theme/lumina_radius.dart';
import '../../../../core/theme/lumina_spacing.dart';
import '../../../../core/theme/lumina_text_styles.dart';
import '../../../../shared/widgets/lumina_brand_mark.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({
    super.key,
    this.duration = const Duration(milliseconds: 2200),
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
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1).animate(
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

    Get.off(
      () => const OnboardingPage(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 420),
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
        const LuminaBrandLockup(),
        const SizedBox(height: LuminaSpacing.xl),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: LuminaSpacing.md,
            vertical: LuminaSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: LuminaColors.secondary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(LuminaRadius.full),
          ),
          child: Text(
            'MODERN ACADEMIC LIBRARY',
            style: LuminaTextStyles.labelMd.copyWith(
              color: LuminaColors.secondary,
              fontWeight: FontWeight.w700,
            ),
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
            strokeWidth: 2.4,
            color: LuminaColors.secondary,
            backgroundColor: LuminaColors.surfaceContainerHigh,
          ),
        ),
        const SizedBox(height: LuminaSpacing.md),
        Text(
          'Preparing your reading space...',
          textAlign: TextAlign.center,
          style: LuminaTextStyles.bodyMd.copyWith(
            color: LuminaColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
