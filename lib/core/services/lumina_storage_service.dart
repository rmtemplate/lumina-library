import 'package:get_storage/get_storage.dart';

/// Wrapper tipis untuk GetStorage.
/// Semua method bersifat static — tidak perlu di-register sebagai GetX service.
/// Pastikan [GetStorage.init()] dipanggil sebelum class ini digunakan (di main.dart).
class LuminaStorageService {
  LuminaStorageService._();

  static final _box = GetStorage();

  static const _keyToken = 'auth_token';
  static const _keyUser = 'auth_user';
  static const _keyOnboardingDone = 'onboarding_done';

  // ── Token ──────────────────────────────────────────────────────────────────

  static String? getToken() => _box.read<String>(_keyToken);

  static void saveToken(String token) => _box.write(_keyToken, token);

  static void clearToken() => _box.remove(_keyToken);

  // ── User ───────────────────────────────────────────────────────────────────

  static Map<String, dynamic>? getUser() {
    final data = _box.read(_keyUser);
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  static void saveUser(Map<String, dynamic> user) => _box.write(_keyUser, user);

  static void clearUser() => _box.remove(_keyUser);

  // ── Session helpers ────────────────────────────────────────────────────────

  static bool get hasSession => getToken() != null;

  static void saveSession({
    required String token,
    required Map<String, dynamic> user,
  }) {
    saveToken(token);
    saveUser(user);
  }

  static void clearSession() {
    clearToken();
    clearUser();
  }

  // ── Onboarding ─────────────────────────────────────────────────────────────

  static bool get isOnboardingDone => _box.read<bool>(_keyOnboardingDone) ?? false;

  static void markOnboardingDone() => _box.write(_keyOnboardingDone, true);
}
