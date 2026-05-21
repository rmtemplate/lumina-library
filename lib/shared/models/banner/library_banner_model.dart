import 'package:flutter/material.dart';

class LibraryBannerData {
  const LibraryBannerData({
    required this.title,
    required this.subtitle,
    this.icon,
    this.imageUrl,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData? icon;
  final String? imageUrl;
  final VoidCallback? onTap;
}
