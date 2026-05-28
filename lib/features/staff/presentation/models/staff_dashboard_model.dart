import 'package:flutter/material.dart';

class StaffDashboardStatModel {
  const StaffDashboardStatModel({
    required this.id,
    required this.icon,
    required this.label,
    required this.value,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
  });

  final String id;
  final IconData icon;
  final String label;
  final String value;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
}

class StaffDashboardActionModel {
  const StaffDashboardActionModel({
    required this.id,
    required this.icon,
    required this.label,
  });

  final String id;
  final IconData icon;
  final String label;
}

class StaffDashboardActivityModel {
  const StaffDashboardActivityModel({
    required this.id,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.titlePrefix,
    required this.highlightText,
    required this.titleSuffix,
    required this.timeText,
    this.highlightItalic = false,
  });

  final String id;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String titlePrefix;
  final String highlightText;
  final String titleSuffix;
  final String timeText;
  final bool highlightItalic;
}