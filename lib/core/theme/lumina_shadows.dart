import 'package:flutter/material.dart';

class LuminaShadows {
  const LuminaShadows._();

  /// Ambient shadow: blur 20px, opacity 4%, Y 8px.
  static List<BoxShadow> get level1 => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  /// Overlay shadow for modals, FAB, and dropdowns.
  static List<BoxShadow> get level2 => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
      ];

  /// Navigation shadow / subtle top elevation.
  static List<BoxShadow> get navigation => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 16,
          offset: const Offset(0, -4),
        ),
      ];
}
