import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';

import 'package:lumina_library/shared/models/banner/library_banner_model.dart';

/// Widget carousel/banner untuk data promosi Lumina.
class LibraryFeaturedBanner extends StatefulWidget {
  const LibraryFeaturedBanner({
    super.key,
    required this.banners,
  });

  /// Data banner yang di-assign dari luar komponen
  final List<LibraryBannerData> banners;

  @override
  State<LibraryFeaturedBanner> createState() => _LibraryFeaturedBannerState();
}

class _LibraryFeaturedBannerState extends State<LibraryFeaturedBanner> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Jika list kosong, tidak perlu merender apapun
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return AspectRatio(
      aspectRatio: 2 / 1,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return _BannerItem(
                title: banner.title,
                subtitle: banner.subtitle,
                // Gunakan icon dari data, atau default ke Icons.image_rounded
                icon: banner.icon ?? Icons.image_rounded, 
              );
            },
          ),
          
          // Sembunyikan indikator jika banner hanya ada 1
          if (widget.banners.length > 1)
            Positioned(
              bottom: LuminaSpacing.sm,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.banners.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    width: _currentIndex == index ? 20 : 6,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? LuminaColors.primary
                          : LuminaColors.outlineVariant,
                      borderRadius: BorderRadius.circular(LuminaRadius.full),
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

class _BannerItem extends StatelessWidget {
  const _BannerItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(LuminaSpacing.lg),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(
          color: LuminaColors.outlineVariant,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            bottom: -32,
            child: Icon(
              Icons.local_library_rounded,
              size: 132,
              color: LuminaColors.primary.withOpacity(0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                icon,
                color: LuminaColors.onSurfaceVariant.withOpacity(0.60),
                size: 38,
              ),
              const SizedBox(height: LuminaSpacing.sm),
              Text(
                title,
                style: LuminaTextStyles.titleLg.copyWith(
                  color: LuminaColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                subtitle,
                style: LuminaTextStyles.bodyMd.copyWith(
                  color: LuminaColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: LuminaSpacing.sm),
            ],
          ),
        ],
      ),
    );
  }
}
