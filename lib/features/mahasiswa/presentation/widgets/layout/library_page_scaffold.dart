import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';

class LibraryPageScaffold extends StatelessWidget {
  const LibraryPageScaffold({
    super.key,
    required this.child,
    this.topBar,
    this.maxWidth = 1180,
  });

  final Widget child;
  final Widget? topBar;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: LuminaColors.background,
      child: Column(
        children: [
          ?topBar,
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    LuminaSpacing.marginMobile,
                    LuminaSpacing.lg,
                    LuminaSpacing.marginMobile,
                    LuminaSpacing.lg,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
