import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lumina_library/core/config/app_config.dart';
import 'package:lumina_library/core/network/lumina_api_client.dart';
import 'package:lumina_library/features/auth/data/models/auth_models.dart';

class AuthApiService {
  const AuthApiService(this._client);

  final LuminaApiClient _client;

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    final stopwatch = Stopwatch()..start();

    _log(requestId, 'login() started');
    _log(requestId, 'getting device name...');

    final deviceName = await AppConfig.getDeviceName().timeout(
      const Duration(seconds: 8),
      onTimeout: () {
        _log(requestId, 'getDeviceName() timeout, fallback used');
        return 'lumina-android-timeout';
      },
    );

    _log(requestId, 'deviceName="$deviceName"');
    _log(requestId, 'POST /auth/login email="$email"');

    final response = await _client.post<Map<String, dynamic>>(
      '/auth/login',
      body: {
        'email': email.trim(),
        'password': password,
        'device_name': deviceName,
      },
      fromData: (data) => data as Map<String, dynamic>,
    );

    _log(
      requestId,
      'POST /auth/login completed. dataKeys=${response.data?.keys.toList()}',
    );

    final model = LoginResponseModel.fromJson(response.data!);

    stopwatch.stop();
    _log(
      requestId,
      'login() parsed success in ${stopwatch.elapsedMilliseconds}ms. user=${model.user.email}',
    );

    return model;
  }

  Future<RegisterResponseModel> register({
    required String fullname,
    required String email,
    required String profileTypeId,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? institutionName,
    String? majorName,
    String? currentLevel,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/register',
      body: {
        'fullname': fullname,
        'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'profile_type_id': profileTypeId,
        if (institutionName != null && institutionName.isNotEmpty)
          'institution_name': institutionName,
        if (majorName != null && majorName.isNotEmpty)
          'major_name': majorName,
        if (currentLevel != null && currentLevel.isNotEmpty)
          'current_level': currentLevel,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'agreement': true,
        'device_name': await AppConfig.getDeviceName(),
      },
      fromData: (data) => data as Map<String, dynamic>,
    );

    return RegisterResponseModel.fromJson(response.data!);
  }

  Future<AuthUserModel> me() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/auth/me',
      fromData: (data) => data as Map<String, dynamic>,
    );

    final data = response.data!;
    final userJson = data['user'] as Map<String, dynamic>? ?? {};
    final rawRoles = data['roles'];
    final roleCodes = rawRoles is List ? rawRoles.cast<String>() : <String>[];

    return AuthUserModel.fromMeJson(userJson, roleCodes);
  }

  Future<void> logout() async {
    await _client.post('/auth/logout');
  }

  static void _log(String requestId, String message) {
    if (!kDebugMode) return;
    debugPrint('[AUTH_API][$requestId] $message');
  }
}