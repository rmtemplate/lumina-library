import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/core/routing/lumina_role_router.dart';

import 'package:lumina_library/features/onboarding/presentation/models/onboarding_slide_model.dart';
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    super.key,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;

  int _currentIndex = 0;

  static const List<OnboardingSlideModel> _slides = [
    OnboardingSlideModel(
      title: 'Akses Tanpa Batas',
      description:
          'Temukan ribuan koleksi buku digital dan jurnal akademik dari genggaman Anda.',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD6jwDqk0lJZMT0Oum1auw5RF507lUzTeLGYFG4m7YZ2Up3v0pr0r2aFh69q-4Qzo9eYhTCON_seGcQ_lyhCg-EkHX3UKhnfXk6GC4yc1zrC7q00K9bYvh2BxtQ5EukHmh8O-c6t3BmlrW089OGxAmWnH_d2o1yDC5F7thKGrrxfOXXCsmTLY6BoWUHAu95Ho6T7Lmp2Ja72NqNkoaMUUQU0QTb2v2LmH8RY8sTzcDxlHxnhrTZpaBoUONNsYnIzx9bBlkCOysrb4QI',
      imageSemanticLabel: 'Student reading digital books',
      accentColor: LuminaColors.primary,
    ),
    OnboardingSlideModel(
      title: 'Pinjam dengan Mudah',
      description:
          'Gunakan fitur scan QR untuk proses peminjaman yang cepat dan tanpa kontak fisik.',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDto1qMFSYfyJXuunKcVtG_CVk31lGdsCjmFzplTDvelXJpqrpMLwjXwjZqyKVdLxjxtGRBZelEotLt6u0xpJsVODtXRMLD95ohia1Qnf6dbjTt2eaolpe6ZGcI6WoCPub0g2xeuUYGV3uZStKHfguAYKGr7WDvvsdXIzbfJzM5_r7zSrA244aFdBSiIKOdaoA82sYjDUMKcR4zgSBQ-20oVsDjpc9djrzHtnTcmRCzojR7jmibpZOu0vK1KF5hfG5WeQY-ZG7Sgwnz',
      imageSemanticLabel: 'QR Code Scanning',
      accentColor: LuminaColors.secondary,
    ),
    OnboardingSlideModel(
      title: 'Kelola Perpustakaan',
      description:
          'Pantau riwayat bacaan dan kelola koleksi pribadi Anda dengan sistem yang terorganisir.',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDFJGxxWRfEsqGvwyUcMh0-WRP9V6RoWqfto1UU4YO4UBaKac2urEupZ3_f7Yh4U5xV-5oKpAgHyzRDUtp3AMK3-8PRGaUDmWuBbLy_Jvn85e45LXqDh5fASmKcAI3loS4TYX_Y0MtL71lO2mHS9nlAAgX0IDgfF-hYNxJaMhjo_Jd0LHNCrYAgjnPXnja1WZZc51RtOyg34TutO5--kTQvxP5yY4GoWpU0VAolexKzs19zH5t3YGQRfK_cBDCdR8MiT5FBUEoA7jTm',
      imageSemanticLabel: 'Admin Dashboard Preview',
      accentColor: LuminaColors.tertiaryContainer,
    ),
  ];

  bool get _isLastSlide => _currentIndex == _slides.length - 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _goToNextSlide() {
    if (_isLastSlide) {
      _goToHome();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void _skipToLastSlide() {
    _pageController.animateToPage(
      _slides.length - 1,
      duration: const Duration(milliseconds: 460),
      curve: Curves.easeOutCubic,
    );
  }

  void _goToHome() {
    LuminaRoleRouter.goToMahasiswaHome();
    // LuminaRoleRouter.goToStaffHome();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuminaColors.surface,
      body: Stack(
        children: [
          const Positioned.fill(
            child: _OnboardingBackground(),
          ),

          SafeArea(
            child: Column(
              children: [
                _OnboardingHeader(
                  isLastSlide: _isLastSlide,
                  onSkip: _skipToLastSlide,
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _slides.length,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return _OnboardingSlide(
                        data: _slides[index],
                      );
                    },
                  ),
                ),

                _OnboardingFooter(
                  currentIndex: _currentIndex,
                  totalSlides: _slides.length,
                  isLastSlide: _isLastSlide,
                  onNext: _goToNextSlide,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingBackground extends StatelessWidget {
  const _OnboardingBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: LuminaColors.surface,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -110,
            child: _SoftGlow(
              size: 280,
              color: LuminaColors.inversePrimary,
              opacity: 0.24,
            ),
          ),
          Positioned(
            left: -130,
            bottom: 70,
            child: _SoftGlow(
              size: 300,
              color: LuminaColors.secondaryContainer,
              opacity: 0.20,
            ),
          ),
          Positioned(
            top: 230,
            left: -90,
            child: _SoftGlow(
              size: 180,
              color: LuminaColors.primaryContainer,
              opacity: 0.08,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftGlow extends StatelessWidget {
  const _SoftGlow({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(opacity),
              color.withOpacity(0),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader({
    required this.isLastSlide,
    required this.onSkip,
  });

  final bool isLastSlide;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        LuminaSpacing.marginMobile,
        LuminaSpacing.md,
        LuminaSpacing.marginMobile,
        LuminaSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedOpacity(
            opacity: isLastSlide ? 0 : 1,
            duration: const Duration(milliseconds: 220),
            child: IgnorePointer(
              ignoring: isLastSlide,
              child: TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: LuminaColors.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(
                    horizontal: LuminaSpacing.sm,
                    vertical: LuminaSpacing.xs,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(LuminaRadius.full),
                  ),
                ),
                child: Text(
                  'Skip',
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: LuminaColors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
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

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({
    required this.data,
  });

  final OnboardingSlideModel data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageSize = constraints.maxWidth;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            LuminaSpacing.marginMobile,
            LuminaSpacing.md,
            LuminaSpacing.marginMobile,
            LuminaSpacing.lg,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - LuminaSpacing.lg,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _OnboardingImageCard(
                  imageUrl: data.imageUrl,
                  semanticLabel: data.imageSemanticLabel,
                  accentColor: data.accentColor,
                  size: imageSize,
                ),

                const SizedBox(height: LuminaSpacing.xl),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: Text(
                    data.title,
                    key: ValueKey(data.title),
                    textAlign: TextAlign.center,
                    style: LuminaTextStyles.headlineMd.copyWith(
                      color: LuminaColors.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.24,
                    ),
                  ),
                ),

                const SizedBox(height: LuminaSpacing.sm),

                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Text(
                    data.description,
                    textAlign: TextAlign.center,
                    style: LuminaTextStyles.bodyMd.copyWith(
                      color: LuminaColors.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingImageCard extends StatelessWidget {
  const _OnboardingImageCard({
    required this.imageUrl,
    required this.semanticLabel,
    required this.accentColor,
    required this.size,
  });

  final String imageUrl;
  final String semanticLabel;
  final Color accentColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      constraints: const BoxConstraints(
        maxWidth: 360,
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          padding: const EdgeInsets.all(LuminaSpacing.xs),
          decoration: BoxDecoration(
            color: LuminaColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(LuminaRadius.xl),
            border: Border.all(
              color: LuminaColors.surfaceVariant,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: accentColor.withOpacity(0.06),
                blurRadius: 36,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(LuminaRadius.lg),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageUrl,
                  semanticLabel: semanticLabel,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    return _ImageLoadingPlaceholder(
                      accentColor: accentColor,
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return _ImageErrorPlaceholder(
                      accentColor: accentColor,
                    );
                  },
                ),

                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          LuminaColors.primary.withOpacity(0.08),
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: LuminaSpacing.md,
                  right: LuminaSpacing.md,
                  bottom: LuminaSpacing.md,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(LuminaRadius.full),
                      gradient: LinearGradient(
                        colors: [
                          accentColor.withOpacity(0.85),
                          accentColor.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageLoadingPlaceholder extends StatelessWidget {
  const _ImageLoadingPlaceholder({
    required this.accentColor,
  });

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLow,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withOpacity(0.08),
            LuminaColors.surfaceContainerLow,
            LuminaColors.surfaceContainerLowest,
          ],
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: accentColor,
            backgroundColor: LuminaColors.surfaceContainerHigh,
          ),
        ),
      ),
    );
  }
}

class _ImageErrorPlaceholder extends StatelessWidget {
  const _ImageErrorPlaceholder({
    required this.accentColor,
  });

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLow,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withOpacity(0.10),
            LuminaColors.surfaceContainerLow,
            LuminaColors.surfaceContainerLowest,
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: LuminaColors.surfaceContainerLowest,
            shape: BoxShape.circle,
            border: Border.all(
              color: LuminaColors.outlineVariant,
              width: 1,
            ),
          ),
          child: Icon(
            Icons.image_not_supported_rounded,
            color: accentColor,
            size: 34,
          ),
        ),
      ),
    );
  }
}

class _OnboardingFooter extends StatelessWidget {
  const _OnboardingFooter({
    required this.currentIndex,
    required this.totalSlides,
    required this.isLastSlide,
    required this.onNext,
  });

  final int currentIndex;
  final int totalSlides;
  final bool isLastSlide;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        LuminaSpacing.marginMobile,
        LuminaSpacing.sm,
        LuminaSpacing.marginMobile,
        LuminaSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest.withOpacity(0.97),
        border: const Border(
          top: BorderSide(
            color: LuminaColors.surfaceContainerHigh,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _OnboardingDots(
            currentIndex: currentIndex,
            totalSlides: totalSlides,
          ),

          const SizedBox(height: LuminaSpacing.lg),

          _OnboardingPrimaryButton(
            label: isLastSlide ? 'Mulai Sekarang' : 'Selanjutnya',
            showIcon: !isLastSlide,
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _OnboardingDots extends StatelessWidget {
  const _OnboardingDots({
    required this.currentIndex,
    required this.totalSlides,
  });

  final int currentIndex;
  final int totalSlides;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSlides, (index) {
        final isActive = currentIndex == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          width: isActive ? 24 : 7,
          height: 7,
          margin: EdgeInsets.only(
            right: index == totalSlides - 1 ? 0 : 8,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? LuminaColors.primary
                : LuminaColors.surfaceVariant,
            borderRadius: BorderRadius.circular(LuminaRadius.full),
          ),
        );
      }),
    );
  }
}

class _OnboardingPrimaryButton extends StatelessWidget {
  const _OnboardingPrimaryButton({
    required this.label,
    required this.showIcon,
    required this.onPressed,
  });

  final String label;
  final bool showIcon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: LuminaColors.primary,
          foregroundColor: LuminaColors.onPrimary,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LuminaRadius.xl),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.96,
                  end: 1,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Row(
            key: ValueKey('$label-$showIcon'),
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: LuminaTextStyles.titleLg.copyWith(
                  color: LuminaColors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (showIcon) ...[
                const SizedBox(width: LuminaSpacing.sm),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 22,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

