import 'package:flutter/material.dart';

class StatisticCardModel {
  const StatisticCardModel({
    required this.icon,
    required this.label,
    required this.value,
    this.description,
    this.backgroundColor,
    this.iconColor,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? description;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? valueColor;
}
