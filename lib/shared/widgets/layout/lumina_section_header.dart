import 'package:flutter/material.dart';

import '../../../core/theme/lumina_colors.dart';
import '../../../core/theme/lumina_text_styles.dart';

class LuminaSectionHeader extends StatelessWidget {
  const LuminaSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel = 'Lihat Semua',
    this.showAction = true,
    this.onActionTap,
  });

  final String title;
  final String? subtitle;
  final String actionLabel;
  final bool showAction;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          subtitle == null ? CrossAxisAlignment.center : CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: LuminaTextStyles.headlineSm.copyWith(
                  color: LuminaColors.onBackground,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: LuminaTextStyles.bodyMd.copyWith(
                    color: LuminaColors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        if (showAction)
          TextButton(
            onPressed: onActionTap,
            child: Text(
              actionLabel,
              style: LuminaTextStyles.labelMd.copyWith(
                color: LuminaColors.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
      ],
    );
  }
}
