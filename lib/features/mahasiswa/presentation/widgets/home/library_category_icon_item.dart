import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';

class LibraryCategoryIconItem extends StatelessWidget {
  const LibraryCategoryIconItem({
    super.key,
    required this.label,
    this.icon,
    this.imageUrl,
    this.onTap,
  }) : assert(
          icon != null || imageUrl != null,
          'Either icon or imageUrl must be provided',
        );

  final String label;
  final IconData? icon;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      // ❌ Hapus fixed height — biar Column yang tentukan tingginya sendiri
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: LuminaSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min, // ✅ tinggi ikut konten
            children: [
              _CategoryCircle(imageUrl: imageUrl, icon: icon),

              const SizedBox(height: LuminaSpacing.xs),

              Text(
                label,
                maxLines: 2,          // ✅ izinkan 2 baris
                overflow: TextOverflow.visible, // ✅ tidak terpotong
                textAlign: TextAlign.center,
                style: LuminaTextStyles.labelMd.copyWith(
                  color: LuminaColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCircle extends StatelessWidget {
  const _CategoryCircle({this.imageUrl, this.icon});
  final String? imageUrl;
  final IconData? icon;

  bool get _hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: LuminaColors.surfaceContainerLow,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: _hasImage
          ? _NetworkImage(url: imageUrl!)
          : _IconFallback(icon: icon!),
    );
  }
}

class _NetworkImage extends StatelessWidget {
  const _NetworkImage({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _IconFallback(
        icon: Icons.category_rounded,
      ),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(color: LuminaColors.surfaceContainerLow);
      },
    );
  }
}

class _IconFallback extends StatelessWidget {
  const _IconFallback({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: LuminaColors.primary, size: 26);
  }
}