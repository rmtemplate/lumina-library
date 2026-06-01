import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/theme/lumina_text_styles.dart';

// ─────────────────────────────────────────────
// Enum & Config
// ─────────────────────────────────────────────

enum LuminaToastType { success, error, warning, info }

class LuminaToastConfig {
  const LuminaToastConfig({
    this.bottomOffset = 16.0,
    this.horizontalPadding = 16.0,
    this.defaultInfoDuration = const Duration(seconds: 3),
    this.defaultSuccessDuration = const Duration(seconds: 3),
    this.defaultWarningDuration = const Duration(seconds: 3),
    this.defaultErrorDuration = const Duration(seconds: 4),
  });

  final double bottomOffset;
  final double horizontalPadding;
  final Duration defaultInfoDuration;
  final Duration defaultSuccessDuration;
  final Duration defaultWarningDuration;
  final Duration defaultErrorDuration;

  static const LuminaToastConfig defaults = LuminaToastConfig();
}

// ─────────────────────────────────────────────
// Main Toast API
// ─────────────────────────────────────────────

class LuminaToast {
  const LuminaToast._();

  static OverlayEntry? _currentEntry;
  static LuminaToastConfig _config = LuminaToastConfig.defaults;

  /// Optional: configure global defaults once (e.g. in main()).
  static void configure(LuminaToastConfig config) => _config = config;

  static void show(
    String message, {
    LuminaToastType type = LuminaToastType.info,
    Duration? duration,
  }) {
    final overlayState = _resolveOverlayState();

    if (overlayState == null) {
      debugPrint('[LuminaToast] No overlay found. Message: $message');
      return;
    }

    _dismissCurrentEntry();

    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _KeyboardAwareToastWrapper(
        config: _config,
        child: _ToastOverlay(
          message: message,
          type: type,
          duration: duration ?? _defaultDurationFor(type),
          onDismiss: () {
            if (entry.mounted) entry.remove();
            if (_currentEntry == entry) _currentEntry = null;
          },
        ),
      ),
    );

    _currentEntry = entry;
    overlayState.insert(entry);
  }

  static void success(String message, {Duration? duration}) =>
      show(message, type: LuminaToastType.success, duration: duration);

  static void error(String message, {Duration? duration}) =>
      show(message, type: LuminaToastType.error, duration: duration);

  static void warning(String message, {Duration? duration}) =>
      show(message, type: LuminaToastType.warning, duration: duration);

  static void info(String message, {Duration? duration}) =>
      show(message, type: LuminaToastType.info, duration: duration);

  static void dismiss() => _dismissCurrentEntry();

  // ── Private helpers ──────────────────────────

  static Duration _defaultDurationFor(LuminaToastType type) {
    return switch (type) {
      LuminaToastType.success => _config.defaultSuccessDuration,
      LuminaToastType.error => _config.defaultErrorDuration,
      LuminaToastType.warning => _config.defaultWarningDuration,
      LuminaToastType.info => _config.defaultInfoDuration,
    };
  }

  static OverlayState? _resolveOverlayState() {
    // 1. GetX overlay context (preferred).
    final overlayCtx = Get.overlayContext;
    if (overlayCtx != null) {
      final overlay = Overlay.maybeOf(overlayCtx, rootOverlay: true);
      if (overlay != null) return overlay;
    }

    // 2. GetX regular context fallback.
    final ctx = Get.context;
    if (ctx != null) {
      final navOverlay =
          Navigator.maybeOf(ctx, rootNavigator: true)?.overlay;
      if (navOverlay != null) return navOverlay;

      final overlay = Overlay.maybeOf(ctx, rootOverlay: true);
      if (overlay != null) return overlay;
    }

    // 3. Navigator key fallback.
    return Get.key.currentState?.overlay;
  }

  static void _dismissCurrentEntry() {
    final entry = _currentEntry;
    if (entry != null && entry.mounted) entry.remove();
    _currentEntry = null;
  }
}

// ─────────────────────────────────────────────
// Keyboard-Aware Wrapper
// Reads keyboard height every frame via MediaQuery.viewInsetsOf,
// so the toast animates smoothly as the keyboard appears/disappears.
// ─────────────────────────────────────────────

class _KeyboardAwareToastWrapper extends StatelessWidget {
  const _KeyboardAwareToastWrapper({
    required this.config,
    required this.child,
  });

  final LuminaToastConfig config;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // viewInsetsOf gives the keyboard height (updates reactively).
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

    // systemGestureInsets / padding.bottom handles home-bar on iPhone, etc.
    final bottomSafeArea = MediaQuery.paddingOf(context).bottom;

    // If keyboard is open, sit just above it. Otherwise, sit above the
    // nav bar / home indicator with a small breathing gap.
    final bottomOffset = keyboardHeight > 0
        ? keyboardHeight + config.bottomOffset
        : bottomSafeArea + config.bottomOffset;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      left: config.horizontalPadding,
      right: config.horizontalPadding,
      bottom: bottomOffset,
      child: child,
    );
  }
}

// ─────────────────────────────────────────────
// Toast Overlay (animation controller)
// ─────────────────────────────────────────────

class _ToastOverlay extends StatefulWidget {
  const _ToastOverlay({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  final String message;
  final LuminaToastType type;
  final Duration duration;
  final VoidCallback onDismiss;

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  bool _dismissed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    Future<void>.delayed(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (_dismissed || !mounted) return;
    _dismissed = true;
    await _controller.reverse();
    if (mounted) widget.onDismiss();
  }

  @override
  void dispose() {
    _dismissed = true;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        // Swipe down to dismiss early.
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 100) {
            _dismiss();
          }
        },
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: _ToastBody(
              message: widget.message,
              type: widget.type,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Toast Body (visual)
// ─────────────────────────────────────────────

class _ToastBody extends StatelessWidget {
  const _ToastBody({required this.message, required this.type});

  final String message;
  final LuminaToastType type;

  _ToastStyle get _style => switch (type) {
        LuminaToastType.success => const _ToastStyle(
            backgroundColor: Color(0xFF1B3D2C),
            borderColor: Color(0xFF2E6647),
            iconColor: Color(0xFF4EDEA3),
            icon: Icons.check_circle_rounded,
          ),
        LuminaToastType.error => const _ToastStyle(
            backgroundColor: Color(0xFF3B1212),
            borderColor: Color(0xFF6B2020),
            iconColor: Color(0xFFFF8080),
            icon: Icons.error_rounded,
          ),
        LuminaToastType.warning => const _ToastStyle(
            backgroundColor: Color(0xFF3B2A00),
            borderColor: Color(0xFF6B4D00),
            iconColor: Color(0xFFFFCC00),
            icon: Icons.warning_rounded,
          ),
        LuminaToastType.info => const _ToastStyle(
            backgroundColor: Color(0xFF0D1B2E),
            borderColor: Color(0xFF1A3352),
            iconColor: Color(0xFF8CCDFF),
            icon: Icons.info_rounded,
          ),
      };

  @override
  Widget build(BuildContext context) {
    final style = _style;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: style.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: style.iconColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(style.icon, color: style.iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: LuminaTextStyles.bodyMd.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Style data class
// ─────────────────────────────────────────────

class _ToastStyle {
  const _ToastStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.icon,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final IconData icon;
}