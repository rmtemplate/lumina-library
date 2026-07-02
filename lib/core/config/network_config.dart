/// Single source of truth for every network endpoint the app talks to —
/// REST API base URL and WebSocket (Reverb) host/port/scheme.
///
/// No page, controller, or service should hardcode a URL, IP, or port.
/// Everything reads from here so switching networks (e.g. a different WiFi
/// hotspot IP) or environments (local → staging → production) is a one-line
/// change in [NetworkConfig.environment] / [NetworkConfig._localHost].
library;

enum AppEnvironment { local, staging, production }

class NetworkConfig {
  const NetworkConfig._();

  // ───────────────────────────────────────────────────────────────────────
  // CHANGE THIS when your network changes (e.g. switching WiFi/hotspot).
  // Find your machine's LAN IP with `ipconfig` (Windows) / `ifconfig` (Mac/
  // Linux) and make sure the Android device is on the SAME network.
  // ───────────────────────────────────────────────────────────────────────
  static const AppEnvironment environment = AppEnvironment.production;

  static const String _localHost = '172.20.10.3';
  static const int _localApiPort = 8000;
  // static const String _localHost = 'lumina-library.test';
  // static const int _localApiPort = 82;
  static const int _localWsPort = 8080;

  // Reverb app key — must match REVERB_APP_KEY in the backend's .env.
  // Not a secret (it's sent to every connecting client by design, same as
  // any Pusher-protocol app key), so it's safe to keep here in source.
  static const String _reverbAppKeyLocal = 'e93b9cdcb15b2128fbe3fc4db50042aa';

  // ── Placeholders for non-local environments — fill in when deploying. ──
  static const String _stagingApiHost = 'https://staging.lumina-library.example.com';
  static const String _stagingWsHost = 'staging-ws.lumina-library.example.com';
  static const String _stagingReverbAppKey = '';

  static const String _productionApiHost = 'https://lumina.rmtemplate.com';
  static const String _productionWsHost = 'lumina.rmtemplate.com';
  static const String _productionReverbAppKey = '889364ca26aa9fe6504927eba25d2c2c';

  /// True only for [AppEnvironment.local] — gates debug-only UI like the
  /// connection status indicator (see lib/shared/widgets/connection/).
  static bool get isLocal => environment == AppEnvironment.local;

  // ── REST API ────────────────────────────────────────────────────────────

  static String get apiBaseUrl => switch (environment) {
        AppEnvironment.local => 'http://$_localHost:$_localApiPort',
        AppEnvironment.staging => _stagingApiHost,
        AppEnvironment.production => _productionApiHost,
      };

  static const String apiPrefix = '/api/v1';

  static String get apiUrl => '$apiBaseUrl$apiPrefix';

  /// Sanctum-protected broadcasting channel-auth endpoint (see
  /// routes/api/v1/broadcasting.php on the backend) — NOT the same as
  /// Laravel's default unauthenticated-for-tokens `/broadcasting/auth`.
  static String get broadcastingAuthUrl => '$apiUrl/broadcasting/auth';

  // ── WebSocket (Reverb, Pusher-protocol) ─────────────────────────────────

  static String get wsHost => switch (environment) {
        AppEnvironment.local => _localHost,
        AppEnvironment.staging => _stagingWsHost,
        AppEnvironment.production => _productionWsHost,
      };

  static int get wsPort => switch (environment) {
        AppEnvironment.local => _localWsPort,
        AppEnvironment.staging || AppEnvironment.production => 443,
      };

  /// `ws://` for local plaintext Reverb, `wss://` once TLS-terminated
  /// (staging/production should sit behind a reverse proxy doing TLS).
  static String get wsScheme => isLocal ? 'ws' : 'wss';

  static String get reverbAppKey => switch (environment) {
        AppEnvironment.local => _reverbAppKeyLocal,
        AppEnvironment.staging => _stagingReverbAppKey,
        AppEnvironment.production => _productionReverbAppKey,
      };

  /// Full Pusher-protocol connection URL, e.g.
  /// `ws://172.20.10.3:8080/app/{key}?protocol=7&client=flutter&version=1.0&flash=false`.
  static String get websocketUrl =>
      '$wsScheme://$wsHost:$wsPort/app/$reverbAppKey'
      '?protocol=7&client=flutter&version=1.0&flash=false';

  static const Duration requestTimeout = Duration(seconds: 20);
}
