import 'package:flutter/material.dart';

class LibraryActivityModel {
  const LibraryActivityModel({
    required this.icon,
    required this.title,
    required this.timeLabel,
    this.subtitle,
    this.iconColor,
    this.iconBackgroundColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String timeLabel;
  final String? subtitle;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final VoidCallback? onTap;
}
