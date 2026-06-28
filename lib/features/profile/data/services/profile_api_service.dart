import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:lumina_library/core/network/lumina_api_client.dart';
import 'package:lumina_library/shared/models/profile/profile_model.dart';

/// Profile module endpoints — GET/PUT /api/v1/account/profile,
/// POST/DELETE /api/v1/account/avatar, PUT /api/v1/account/password.
/// Separate from [HomeApiService]'s lightweight `getProfile()` (which
/// returns the lean `HomeProfileModel` for the home top bar greeting only)
/// — this service is the full Profile module's single source of truth.
class ProfileApiService {
  const ProfileApiService(this._client);

  final LuminaApiClient _client;

  /// GET /api/v1/account/profile
  Future<ProfileModel> getProfile() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/account/profile',
      fromData: (data) => data as Map<String, dynamic>,
    );
    return ProfileModel.fromJson(response.data ?? {});
  }

  /// PUT /api/v1/account/profile
  /// Only includes keys the caller actually wants to change — `sometimes`
  /// validation on the backend means omitted fields are left untouched.
  Future<ProfileModel> updateProfile({
    String? fullname,
    String? phone,
    String? institutionName,
    String? majorName,
    String? currentLevel,
    String? staffPosition,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
  }) async {
    final body = <String, dynamic>{
      if (fullname != null) 'fullname': fullname,
      if (phone != null) 'phone': phone,
      if (institutionName != null) 'institution_name': institutionName,
      if (majorName != null) 'major_name': majorName,
      if (currentLevel != null) 'current_level': currentLevel,
      if (staffPosition != null) 'staff_position': staffPosition,
      if (address != null) 'address': address,
      if (dateOfBirth != null) 'date_of_birth': _formatDate(dateOfBirth),
      if (gender != null) 'gender': gender,
    };

    debugPrint('[PROFILE][API] updateProfile — fields=${body.keys.toList()}');

    final response = await _client.put<Map<String, dynamic>>(
      '/account/profile',
      body: body,
      fromData: (data) => data as Map<String, dynamic>,
    );
    return ProfileModel.fromJson(response.data ?? {});
  }

  /// POST /api/v1/account/avatar (multipart)
  Future<ProfileModel> updateAvatar(File file) async {
    debugPrint('[PROFILE][API] updateAvatar — path=${file.path}');

    final response = await _client.postMultipart<Map<String, dynamic>>(
      '/account/avatar',
      fileField: 'avatar',
      file: file,
      fromData: (data) => data as Map<String, dynamic>,
    );
    return ProfileModel.fromJson(response.data ?? {});
  }

  /// DELETE /api/v1/account/avatar
  Future<ProfileModel> deleteAvatar() async {
    final response = await _client.delete<Map<String, dynamic>>(
      '/account/avatar',
      fromData: (data) => data as Map<String, dynamic>,
    );
    return ProfileModel.fromJson(response.data ?? {});
  }

  /// PUT /api/v1/account/password
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
    bool logoutOtherSessions = false,
  }) async {
    await _client.put<void>(
      '/account/password',
      body: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': confirmPassword,
        'logout_other_sessions': logoutOtherSessions,
      },
      fromData: (_) {},
    );
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
