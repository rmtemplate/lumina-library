import 'package:flutter/material.dart';

class LuminaSpacing {
  const LuminaSpacing._();

  /// Base scale: 4pt / 8pt rhythm.
  static const double base = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  /// Mobile layout.
  static const double marginMobile = 20;
  static const double gutterMobile = 16;

  /// Common padding presets.
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: marginMobile,
    vertical: lg,
  );

  static const EdgeInsets cardPadding = EdgeInsets.all(lg);

  static const EdgeInsets compactCardPadding = EdgeInsets.all(md);

  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: sm,
  );

  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: sm,
    vertical: xs,
  );

  static const EdgeInsets sectionMargin = EdgeInsets.only(
    bottom: lg,
  );

  static const EdgeInsets cardMargin = EdgeInsets.only(
    bottom: md,
  );
}
