import 'package:flutter/material.dart';

class OnboardingSlideModel {
  const OnboardingSlideModel({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.imageSemanticLabel,
    required this.accentColor,
  });

  final String title;
  final String description;
  final String imageUrl;
  final String imageSemanticLabel;
  final Color accentColor;
}
