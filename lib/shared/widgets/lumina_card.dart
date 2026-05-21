import 'package:flutter/material.dart';

import '../../core/theme/lumina_colors.dart';
import '../../core/theme/lumina_radius.dart';
import '../../core/theme/lumina_shadows.dart';
import '../../core/theme/lumina_spacing.dart';

class LuminaCard extends StatelessWidget {
  const LuminaCard({
    super.key,
    required this.child,
    this.padding = LuminaSpacing.cardPadding,
    this.margin = LuminaSpacing.cardMargin,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: LuminaRadius.card,
        border: Border.all(
          color: LuminaColors.outlineVariant,
          width: 1,
        ),
        boxShadow: LuminaShadows.level1,
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: LuminaRadius.card,
        onTap: onTap,
        child: content,
      ),
    );
  }
}
