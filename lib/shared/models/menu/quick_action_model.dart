import 'package:flutter/material.dart';

class QuickActionModel {
  const QuickActionModel({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconBackgroundColor,
    this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconBackgroundColor;
  final Color? iconColor;
  final VoidCallback? onTap;
}
