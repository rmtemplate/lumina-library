/// A single application-level event received over the WebSocket, already
/// unwrapped from the Pusher protocol envelope (`event`/`channel`/`data`,
/// with `data` decoded from its inner JSON string into a map).
///
/// `name` matches each backend event's `broadcastAs()`, e.g. `qr.generated`,
/// `pickup.success`, `borrowing.expired` — see docs/websocket.md for the
/// full list and payload shapes.
class WebSocketEvent {
  const WebSocketEvent({
    required this.name,
    required this.channel,
    required this.data,
  });

  final String name;
  final String channel;
  final Map<String, dynamic> data;

  /// Convenience accessor matching the `borrowing_id` field every pickup/QR/
  /// borrowing event payload carries.
  String? get borrowingId => data['borrowing_id'] as String?;

  @override
  String toString() => 'WebSocketEvent(name: $name, channel: $channel, data: $data)';
}
