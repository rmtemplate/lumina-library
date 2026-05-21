import 'package:flutter/material.dart';

import '../../core/theme/lumina_colors.dart';
import '../../core/theme/lumina_radius.dart';

class LuminaProgressBar extends StatelessWidget {
  const LuminaProgressBar({
    super.key,
    required this.value,
    this.height = 8,
  });

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final normalizedValue = value.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(LuminaRadius.full),
      child: LinearProgressIndicator(
        value: normalizedValue,
        minHeight: height,
        backgroundColor: LuminaColors.surfaceContainerHigh,
        valueColor: const AlwaysStoppedAnimation<Color>(
          LuminaColors.secondary,
        ),
      ),
    );
  }
}
