import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/services/websocket/websocket_connection_state.dart';
import 'package:lumina_library/core/services/websocket/websocket_service.dart';

/// Small floating pill showing the live WebSocket connection state —
/// Connected / Connecting... / Disconnected / Reconnecting....
///
/// Debug-mode only by design (`kDebugMode` guard below) — this is a
/// developer/QA aid for verifying realtime connectivity while testing on a
/// physical device, not something an end user should ever see.
///
/// Mounted once at the app root (see lib/app.dart's `builder`), not on
/// individual pages — it reads [WebSocketService] directly via GetX.
class ConnectionStatusIndicator extends StatelessWidget {
  const ConnectionStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    // WebSocketService may not be registered yet on the very first frame.
    if (!Get.isRegistered<WebSocketService>()) return const SizedBox.shrink();

    final service = Get.find<WebSocketService>();

    return Positioned(
      top: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 6, right: 8),
          child: Obx(() => _Pill(state: service.connectionState.value)),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.state});

  final WebSocketConnectionState state;

  Color get _color => switch (state) {
        WebSocketConnectionState.connected => const Color(0xFF2E7D32),
        WebSocketConnectionState.connecting => const Color(0xFFF9A825),
        WebSocketConnectionState.reconnecting => const Color(0xFFF9A825),
        WebSocketConnectionState.disconnected => const Color(0xFFC62828),
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.72),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            'WS: ${state.label}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
