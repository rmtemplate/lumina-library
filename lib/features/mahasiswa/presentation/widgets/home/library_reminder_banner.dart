import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';

class LibraryReminderBanner extends StatelessWidget {
  const LibraryReminderBanner({
    super.key,
    required this.title,
    required this.description,
    this.onExtend,
    this.onDismiss,
  });

  final String title;
  final String description;
  final VoidCallback? onExtend;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Padding dibuat lebih rapat (compact)
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.md,
        vertical: LuminaSpacing.sm, 
      ),
      decoration: BoxDecoration(
        color: LuminaColors.tertiaryContainer,
        borderRadius: BorderRadius.circular(LuminaRadius.lg), // Radius sedikit diperkecil
        boxShadow: [
          BoxShadow(
            color: LuminaColors.tertiaryContainer.withOpacity(0.15), // Shadow lebih soft
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Mengikuti ukuran konten
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: LuminaColors.error,
                        borderRadius: BorderRadius.circular(LuminaRadius.sm),
                      ),
                      child: Text(
                        'PENGINGAT',
                        style: LuminaTextStyles.labelMd.copyWith(
                          color: LuminaColors.onError,
                          fontSize: 8, // Ukuran badge lebih kecil
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: LuminaSpacing.xs),
                    Expanded(
                      child: Text(
                        title,
                        style: LuminaTextStyles.labelMd.copyWith( // Menggunakan labelMd menggantikan bodyMd
                          color: LuminaColors.onTertiary,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1, // Agar title tidak turun ke baris baru
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 2), // Jarak antar teks diperkecil

                Text(
                  description,
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: LuminaColors.inversePrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 11, // Sedikit lebih kecil agar compact
                  ),
                  maxLines: 2, // Maksimal 2 baris untuk deskripsi
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: LuminaSpacing.sm),

          // Tombol aksi diubah ke format Row (berjejer ke samping)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onExtend != null)
                TextButton(
                  onPressed: onExtend,
                  style: TextButton.styleFrom(
                    backgroundColor: LuminaColors.onTertiary,
                    foregroundColor: LuminaColors.tertiaryContainer,
                    minimumSize: const Size(0, 26), // Memaksa tinggi tombol lebih pendek
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Menghilangkan margin bawaan Material
                    padding: const EdgeInsets.symmetric(
                      horizontal: LuminaSpacing.sm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(LuminaRadius.full),
                    ),
                  ),
                  child: Text(
                    'Perpanjang',
                    style: LuminaTextStyles.labelMd.copyWith(
                      color: LuminaColors.tertiaryContainer,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  ),
                ),
                
              if (onDismiss != null) ...[
                const SizedBox(width: 4),
                InkWell(
                  onTap: onDismiss,
                  borderRadius: BorderRadius.circular(LuminaRadius.full),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      color: LuminaColors.onTertiary.withOpacity(0.70),
                      size: 18, // Ikon diperkecil sedikit
                    ),
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
