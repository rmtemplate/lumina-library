import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:lumina_library/core/config/network_config.dart';
import 'package:lumina_library/core/services/lumina_storage_service.dart';
import 'package:lumina_library/core/services/websocket/websocket_connection_state.dart';
import 'package:lumina_library/core/services/websocket/websocket_event.dart';

/// Reusable, UI-agnostic WebSocket client speaking the Pusher wire protocol
/// against the backend's Reverb server. Implemented by hand over
/// `web_socket_channel` (not a native Pusher SDK plugin) specifically so
/// reconnect/heartbeat behavior is fully visible and controllable here,
/// rather than buried inside an opaque native client.
///
/// Usage: register once (`Get.put(WebSocketService(), permanent: true)`),
/// then anywhere in the app:
/// ```dart
/// Get.find<WebSocketService>().subscribeToPrivateChannel('user.$userId');
/// Get.find<WebSocketService>().events
///     .where((e) => e.name == 'qr.generated')
///     .listen((e) => ...);
/// ```
///
/// No UI widget should hold a WebSocketChannel or know about the Pusher
/// protocol directly — only this service does.
class WebSocketService extends GetxService with WidgetsBindingObserver {
  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;

  final Rx<WebSocketConnectionState> connectionState =
      Rx<WebSocketConnectionState>(WebSocketConnectionState.disconnected);

  final _eventController = StreamController<WebSocketEvent>.broadcast();

  /// Firehose of every application event received, already unwrapped from
  /// the Pusher envelope. Controllers filter by `.name`/`.borrowingId`.
  Stream<WebSocketEvent> get events => _eventController.stream;

  String? _socketId;
  final Set<String> _subscribedChannels = {};
  final Set<String> _pendingChannels = {};

  Timer? _reconnectTimer;
  Timer? _idleWatchdogTimer;
  int _reconnectAttempts = 0;
  DateTime _lastMessageAt = DateTime.now();
  bool _manuallyDisconnected = false;

  static const int _maxBackoffSeconds = 30;
  static const Duration _idleCheckInterval = Duration(seconds: 10);
  static const Duration _idleTimeout = Duration(seconds: 45);

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    disconnect(permanent: true);
    _eventController.close();
    super.onClose();
  }

  // ── App lifecycle ───────────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _log('App resumed — checking connection');
      if (connectionState.value != WebSocketConnectionState.connected) {
        _reconnectAttempts = 0;
        _connectNow();
      }
    }
  }

  // ── Public API ───────────────────────────────────────────────────────────

  Future<void> connect() async {
    _manuallyDisconnected = false;
    await _connectNow();
  }

  /// Connects (if needed) and subscribes to the current logged-in user's
  /// private channel, using whatever user is currently in
  /// [LuminaStorageService]. Safe to call multiple times (e.g. once after
  /// login, once on splash-screen session restore) — subscribing to an
  /// already-subscribed channel is a no-op.
  Future<void> connectForCurrentUser() async {
    final user = LuminaStorageService.getUser();
    final userId = user?['id'] as String?;

    if (userId == null || userId.isEmpty) {
      _log('connectForCurrentUser() called with no stored user — skipping');
      return;
    }

    // subscribeToPrivateChannel() connects automatically if needed and
    // queues the subscription until the handshake completes.
    subscribeToPrivateChannel('user.$userId');
  }

  void disconnect({bool permanent = false}) {
    _manuallyDisconnected = permanent;
    _reconnectTimer?.cancel();
    _idleWatchdogTimer?.cancel();
    _channelSubscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    _socketId = null;
    _subscribedChannels.clear();
    connectionState.value = WebSocketConnectionState.disconnected;
    _log('Socket Disconnected${permanent ? ' (permanent)' : ''}');
  }

  /// Subscribes to a `private-{channelName}` channel. If the socket isn't
  /// connected yet, the subscription is queued and sent automatically once
  /// `pusher:connection_established` arrives (including after a reconnect).
  void subscribeToPrivateChannel(String channelName) {
    _pendingChannels.add(channelName);

    if (connectionState.value == WebSocketConnectionState.connected && _socketId != null) {
      unawaited(_authorizeAndSubscribe(channelName));
    } else {
      unawaited(connect());
    }
  }

  void unsubscribe(String channelName) {
    _pendingChannels.remove(channelName);
    if (_subscribedChannels.remove(channelName)) {
      _send({
        'event': 'pusher:unsubscribe',
        'data': {'channel': 'private-$channelName'},
      });
    }
  }

  // ── Connection lifecycle ─────────────────────────────────────────────────

  Future<void> _connectNow() async {
    if (connectionState.value == WebSocketConnectionState.connecting) return;

    connectionState.value = _reconnectAttempts > 0
        ? WebSocketConnectionState.reconnecting
        : WebSocketConnectionState.connecting;

    final uri = Uri.parse(NetworkConfig.websocketUrl);
    _log('Connecting to $uri');

    try {
      final channel = WebSocketChannel.connect(uri);
      await channel.ready;
      _channel = channel;
      _lastMessageAt = DateTime.now();

      _channelSubscription = channel.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      _startIdleWatchdog();
    } catch (e) {
      _log('Connect failed: $e');
      _onError(e);
    }
  }

  void _onMessage(dynamic raw) {
    _lastMessageAt = DateTime.now();

    Map<String, dynamic> frame;
    try {
      frame = jsonDecode(raw as String) as Map<String, dynamic>;
    } catch (e) {
      _log('Failed to decode frame: $e');
      return;
    }

    final eventName = frame['event'] as String?;
    if (eventName == null) return;

    switch (eventName) {
      case 'pusher:connection_established':
        final data = _decodeInner(frame['data']);
        _socketId = data['socket_id'] as String?;
        _reconnectAttempts = 0;
        connectionState.value = WebSocketConnectionState.connected;
        _log('Socket Connected (socket_id: $_socketId)');
        _resubscribeAll();
        break;

      case 'pusher:ping':
        _send({'event': 'pusher:pong', 'data': {}});
        break;

      case 'pusher:error':
        _log('Server error frame: ${frame['data']}');
        break;

      case 'pusher_internal:subscription_succeeded':
        _log('Subscription confirmed: ${frame['channel']}');
        break;

      default:
        _emitApplicationEvent(frame, eventName);
    }
  }

  void _emitApplicationEvent(Map<String, dynamic> frame, String eventName) {
    final channel = frame['channel'] as String? ?? '';
    final data = _decodeInner(frame['data']);

    _log('Broadcast Received: $eventName on $channel — $data');

    _eventController.add(WebSocketEvent(name: eventName, channel: channel, data: data));
  }

  Map<String, dynamic> _decodeInner(dynamic rawData) {
    if (rawData is Map<String, dynamic>) return rawData;
    if (rawData is String) {
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return <String, dynamic>{};
  }

  void _onError(Object error) {
    _log('Socket error: $error');
    _handleDisconnect();
  }

  void _onDone() {
    _log('Socket closed by server/network');
    _handleDisconnect();
  }

  void _handleDisconnect() {
    _idleWatchdogTimer?.cancel();
    _socketId = null;
    _subscribedChannels.clear();

    if (_manuallyDisconnected) {
      connectionState.value = WebSocketConnectionState.disconnected;
      return;
    }

    connectionState.value = WebSocketConnectionState.reconnecting;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();

    final delaySeconds = min(pow(2, _reconnectAttempts).toInt(), _maxBackoffSeconds);
    _reconnectAttempts++;

    _log('Reconnect Attempt #$_reconnectAttempts in ${delaySeconds}s');

    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (!_manuallyDisconnected) {
        unawaited(_connectNow());
      }
    });
  }

  // ── Heartbeat / idle watchdog ────────────────────────────────────────────
  //
  // Reverb/Pusher servers send `pusher:ping` periodically and expect `pong`
  // back (handled in _onMessage). This watchdog is the other half: if NO
  // frame at all (ping or otherwise) has arrived within `_idleTimeout`, the
  // connection is treated as dead even though the OS socket might not have
  // reported an error yet — a real risk on mobile networks that silently
  // drop idle connections. Forces a reconnect instead of waiting forever.

  void _startIdleWatchdog() {
    _idleWatchdogTimer?.cancel();
    _idleWatchdogTimer = Timer.periodic(_idleCheckInterval, (_) {
      final idleFor = DateTime.now().difference(_lastMessageAt);
      if (idleFor > _idleTimeout) {
        _log('No frames for ${idleFor.inSeconds}s — assuming dead connection, forcing reconnect');
        _channelSubscription?.cancel();
        _channel?.sink.close();
        _handleDisconnect();
      }
    });
  }

  // ── Channel auth (Sanctum-protected /broadcasting/auth) ─────────────────

  Future<void> _authorizeAndSubscribe(String channelName) async {
    final fullChannel = 'private-$channelName';

    if (_subscribedChannels.contains(fullChannel)) return;

    final token = LuminaStorageService.getToken();
    if (token == null || token.isEmpty) {
      _log('Cannot subscribe to $fullChannel — no auth token available');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(NetworkConfig.broadcastingAuthUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'socket_id': _socketId,
          'channel_name': fullChannel,
        }),
      ).timeout(NetworkConfig.requestTimeout);

      if (response.statusCode != 200) {
        _log('Channel auth failed (${response.statusCode}) for $fullChannel: ${response.body}');
        return;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final auth = body['auth'] as String?;
      if (auth == null) {
        _log('Channel auth response missing "auth" for $fullChannel');
        return;
      }

      _send({
        'event': 'pusher:subscribe',
        'data': {'channel': fullChannel, 'auth': auth},
      });

      _subscribedChannels.add(fullChannel);
      _log('Subscribed to $fullChannel');
    } catch (e) {
      _log('Channel auth request failed for $fullChannel: $e');
    }
  }

  void _resubscribeAll() {
    for (final channel in _pendingChannels) {
      unawaited(_authorizeAndSubscribe(channel));
    }
  }

  // ── Low-level send ──────────────────────────────────────────────────────

  void _send(Map<String, dynamic> frame) {
    final channel = _channel;
    if (channel == null) return;
    channel.sink.add(jsonEncode(frame));
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[WS] $message');
    }
  }
}
