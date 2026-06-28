import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';

/// Reusable circular profile photo with an optional edit (camera) badge and
/// loading overlay — used by the profile header and the Edit Profile page.
/// Pure presentation: picking/cropping/uploading logic lives in
/// [LuminaProfileController], not here.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.avatarUrl,
    this.size = 104,
    this.isUploading = false,
    this.onEditTap,
  });

  final String? avatarUrl;
  final double size;
  final bool isUploading;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    final hasUrl = avatarUrl != null && avatarUrl!.trim().isNotEmpty;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: LuminaColors.surfaceContainerHigh,
              shape: BoxShape.circle,
              border: Border.all(color: LuminaColors.surfaceVariant, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: hasUrl
                ? Image.network(
                    avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.person_rounded,
                      color: LuminaColors.primary,
                      size: size * 0.44,
                    ),
                  )
                : Icon(
                    Icons.person_rounded,
                    color: LuminaColors.primary,
                    size: size * 0.44,
                  ),
          ),
          if (isUploading)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              ),
            ),
          if (onEditTap != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: Material(
                color: LuminaColors.primary,
                shape: const CircleBorder(),
                elevation: 3,
                child: InkWell(
                  onTap: isUploading ? null : onEditTap,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: size * 0.327,
                    height: size * 0.327,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: LuminaColors.surface, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: LuminaColors.onPrimary,
                      size: size * 0.173,
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
