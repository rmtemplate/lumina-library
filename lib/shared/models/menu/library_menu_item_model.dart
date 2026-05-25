import 'package:flutter/material.dart';

class LibraryMenuItemData {
  const LibraryMenuItemData({
    required this.icon,
    required this.title,
    this.isDestructive = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final bool isDestructive;
  final VoidCallback? onTap;
}
