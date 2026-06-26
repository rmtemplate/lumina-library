/// Connection lifecycle states for [WebSocketService], in the order a
/// normal connect → disconnect → reconnect cycle moves through them.
enum WebSocketConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

extension WebSocketConnectionStateLabel on WebSocketConnectionState {
  String get label => switch (this) {
        WebSocketConnectionState.disconnected => 'Disconnected',
        WebSocketConnectionState.connecting => 'Connecting...',
        WebSocketConnectionState.connected => 'Connected',
        WebSocketConnectionState.reconnecting => 'Reconnecting...',
      };
}
