import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';

class StaffStatData {
  const StaffStatData({
    required this.icon,
    required this.label,
    required this.value,
    required this.variant,
  });

  final IconData icon;
  final String label;
  final String value;
  final StaffStatVariant variant;
}

enum StaffStatVariant {
  light,
  primary,
  error,
}

extension StaffStatVariantX on StaffStatVariant {
  StaffStatConfig get config {
    switch (this) {
      case StaffStatVariant.light:
        return const StaffStatConfig(
          backgroundColor: LuminaColors.surfaceContainerLowest,
          labelColor: LuminaColors.onSurfaceVariant,
          valueColor: LuminaColors.primary,
        );

      case StaffStatVariant.primary:
        return const StaffStatConfig(
          backgroundColor: LuminaColors.primaryContainer,
          labelColor: LuminaColors.primaryFixedDim,
          valueColor: LuminaColors.onPrimary,
        );

      case StaffStatVariant.error:
        return const StaffStatConfig(
          backgroundColor: LuminaColors.errorContainer,
          labelColor: LuminaColors.onErrorContainer,
          valueColor: LuminaColors.onErrorContainer,
        );
    }
  }
}

class StaffStatConfig {
  const StaffStatConfig({
    required this.backgroundColor,
    required this.labelColor,
    required this.valueColor,
  });

  final Color backgroundColor;
  final Color labelColor;
  final Color valueColor;
}

class StaffQuickActionData {
  const StaffQuickActionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBackgroundColor,
    required this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBackgroundColor;
  final Color iconColor;
  final VoidCallback? onTap;
}

class StaffActivityData {
  const StaffActivityData({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.titlePrefix,
    required this.actionText,
    required this.bookTitle,
    required this.timeText,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String titlePrefix;
  final String actionText;
  final String bookTitle;
  final String timeText;
}
