import 'package:flutter/material.dart';

import '../../../../core/theme/lumina_colors.dart';
import '../../../../core/theme/lumina_radius.dart';
import '../../../../core/theme/lumina_spacing.dart';
import '../../../../core/theme/lumina_text_styles.dart';

class LibraryTransactionTopBar extends StatelessWidget {
  const LibraryTransactionTopBar({
    super.key,
    required this.title,
    this.onBackTap,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBackTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LuminaColors.surface,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: LuminaSpacing.marginMobile,
              vertical: LuminaSpacing.sm,
            ),
            child: Row(
              children: [
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onBackTap ?? () => Navigator.of(context).maybePop(),
                    customBorder: const CircleBorder(),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: LuminaColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LuminaTextStyles.headlineSm.copyWith(
                      color: LuminaColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: trailing,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
