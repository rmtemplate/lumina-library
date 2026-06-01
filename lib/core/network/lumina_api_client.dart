import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:lumina_library/core/config/app_config.dart';
import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/core/network/lumina_api_response.dart';
import 'package:lumina_library/core/services/lumina_storage_service.dart';

class LuminaApiClient {
  const LuminaApiClient();

  // ── Headers ──────────────────────────────────────────────────────────────
  // Evaluated ONCE per request and passed explicitly — no double-read risk.

  Map<String, String> _buildHeaders() {
    final token = LuminaStorageService.getToken();

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ── URI builder ───────────────────────────────────────────────────────────

  Uri _uri(String path, [Map<String, String>? query]) {
    final cleanBase = AppConfig.baseUrl.endsWith('/')
        ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1)
        : AppConfig.baseUrl;

    final cleanPrefix = AppConfig.apiPrefix.startsWith('/')
        ? AppConfig.apiPrefix
        : '/${AppConfig.apiPrefix}';

    final cleanPath = path.startsWith('/') ? path : '/$path';

    final uri = Uri.parse('$cleanBase$cleanPrefix$cleanPath');

    if (query == null || query.isEmpty) return uri;

    return uri.replace(queryParameters: query);
  }

  // ── Public HTTP methods ───────────────────────────────────────────────────

  Future<LuminaApiResponse<T>> get<T>(
    String path, {
    Map<String, String>? query,
    T Function(dynamic)? fromData,
  }) async {
    final uri = _uri(path, query);
    final headers = _buildHeaders(); // ← evaluated once

    return _execute(
      method: 'GET',
      uri: uri,
      headers: headers,
      fromData: fromData,
      send: () => http.get(uri, headers: headers).timeout(AppConfig.requestTimeout),
    );
  }

  Future<LuminaApiResponse<T>> post<T>(
    String path, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromData,
  }) async {
    final uri = _uri(path);
    final headers = _buildHeaders();
    final encodedBody = jsonEncode(body ?? <String, dynamic>{});

    return _execute(
      method: 'POST',
      uri: uri,
      headers: headers,
      body: body,
      fromData: fromData,
      send: () => http
          .post(uri, headers: headers, body: encodedBody)
          .timeout(AppConfig.requestTimeout),
    );
  }

  Future<LuminaApiResponse<T>> put<T>(
    String path, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromData,
  }) async {
    final uri = _uri(path);
    final headers = _buildHeaders();
    final encodedBody = jsonEncode(body ?? <String, dynamic>{});

    return _execute(
      method: 'PUT',
      uri: uri,
      headers: headers,
      body: body,
      fromData: fromData,
      send: () => http
          .put(uri, headers: headers, body: encodedBody)
          .timeout(AppConfig.requestTimeout),
    );
  }

  Future<LuminaApiResponse<T>> patch<T>(
    String path, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromData,
  }) async {
    final uri = _uri(path);
    final headers = _buildHeaders();
    final encodedBody = jsonEncode(body ?? <String, dynamic>{});

    return _execute(
      method: 'PATCH',
      uri: uri,
      headers: headers,
      body: body,
      fromData: fromData,
      send: () => http
          .patch(uri, headers: headers, body: encodedBody)
          .timeout(AppConfig.requestTimeout),
    );
  }

  Future<LuminaApiResponse<T>> delete<T>(
    String path, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromData,
  }) async {
    final uri = _uri(path);
    final headers = _buildHeaders();

    return _execute(
      method: 'DELETE',
      uri: uri,
      headers: headers,
      body: body,
      fromData: fromData,
      send: () => http
          .delete(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(AppConfig.requestTimeout),
    );
  }

  // ── Core executor — single try/catch for all methods ─────────────────────

  Future<LuminaApiResponse<T>> _execute<T>({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    required Future<http.Response> Function() send,
    Map<String, dynamic>? body,
    T Function(dynamic)? fromData,
  }) async {
    _logRequest(method: method, uri: uri, headers: headers, body: body);

    try {
      final response = await send();
      _logResponse(response);
      return _parse<T>(response, fromData: fromData);
    } on SocketException catch (error, stackTrace) {
      _logException(label: 'SocketException [$method]', error: error, stackTrace: stackTrace);
      throw const LuminaApiException(
        message:
            'Tidak bisa terhubung ke server. Pastikan jaringan aktif, IP benar, dan server sedang berjalan.',
      );
    } on TimeoutException catch (error, stackTrace) {
      _logException(label: 'TimeoutException [$method]', error: error, stackTrace: stackTrace);
      throw const LuminaApiException(
        message: 'Koneksi timeout. Silakan coba lagi.',
      );
    } on LuminaApiException {
      rethrow;
    } catch (error, stackTrace) {
      _logException(label: 'Unexpected Error [$method]', error: error, stackTrace: stackTrace);
      throw const LuminaApiException(
        message: 'Terjadi kesalahan koneksi. Silakan coba lagi.',
      );
    }
  }

  // ── Response parser ───────────────────────────────────────────────────────

  LuminaApiResponse<T> _parse<T>(
    http.Response response, {
    T Function(dynamic)? fromData,
  }) {
    final Map<String, dynamic> json;

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Response root is not a JSON object.');
      }

      json = decoded;
    } catch (error, stackTrace) {
      _logException(
        label: 'Invalid JSON Response',
        error: error,
        stackTrace: stackTrace,
      );

      throw LuminaApiException(
        message:
            'Response tidak valid dari server. Pastikan URL API benar dan server tidak mengembalikan HTML.',
        statusCode: response.statusCode,
      );
    }

    final message = json['message'] as String?;
    final code = json['code'] as String?;
    final errors = _parseFieldErrors(json['errors']);

    // Handle known HTTP error codes first.
    switch (response.statusCode) {
      case 401:
        throw LuminaApiException(
          message: message ?? 'Sesi telah berakhir. Silakan login kembali.',
          code: code,
          statusCode: 401,
          fieldErrors: errors,
        );
      case 403:
        throw LuminaApiException(
          message: message ?? 'Anda tidak memiliki akses.',
          code: code,
          statusCode: 403,
          fieldErrors: errors,
        );
      case 404:
        throw LuminaApiException(
          message: message ?? 'Data atau endpoint tidak ditemukan.',
          code: code,
          statusCode: 404,
          fieldErrors: errors,
        );
      case 422:
        throw LuminaApiException(
          message: message ?? 'Validasi gagal.',
          code: code,
          statusCode: 422,
          fieldErrors: errors,
        );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LuminaApiException(
        message: message ?? 'Terjadi kesalahan pada server.',
        code: code,
        statusCode: response.statusCode,
        fieldErrors: errors,
      );
    }

    // Some APIs return { status: false } with HTTP 200.
    if (json['status'] == false) {
      throw LuminaApiException(
        message: message ?? 'Request gagal.',
        code: code,
        statusCode: response.statusCode,
        fieldErrors: errors,
      );
    }

    return LuminaApiResponse<T>.fromJson(json, fromData: fromData);
  }

  // ── Field error parser ────────────────────────────────────────────────────

  Map<String, List<String>>? _parseFieldErrors(dynamic rawErrors) {
    if (rawErrors is! Map) return null;

    final fieldErrors = <String, List<String>>{};

    rawErrors.forEach((key, value) {
      final field = key.toString();

      if (value is List) {
        fieldErrors[field] = value.map((item) => item.toString()).toList();
      } else if (value is String) {
        fieldErrors[field] = [value];
      }
    });

    return fieldErrors.isEmpty ? null : fieldErrors;
  }

  // ── Logging ───────────────────────────────────────────────────────────────

  void _logRequest({
    required String method,
    required Uri uri,
    required Map<String, String> headers, // receives the already-built headers
    Map<String, dynamic>? body,
  }) {
    if (!kDebugMode) return;

    debugPrint('────────────────────────────────────────');
    debugPrint('[LuminaApi] ▶ $method $uri');
    debugPrint('[LuminaApi] HEADERS ${_safeHeadersForLog(headers)}');

    if (body != null) {
      debugPrint('[LuminaApi] BODY ${jsonEncode(_safeBodyForLog(body))}');
    }
  }

  void _logResponse(http.Response response) {
    if (!kDebugMode) return;

    debugPrint('[LuminaApi] ◀ ${response.statusCode}');
    debugPrint('[LuminaApi] BODY ${response.body}');
    debugPrint('────────────────────────────────────────');
  }

  void _logException({
    required String label,
    required Object error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;

    debugPrint('[LuminaApi][$label] $error');

    if (stackTrace != null) {
      debugPrint('[LuminaApi][$label][STACK] $stackTrace');
    }
  }

  Map<String, String> _safeHeadersForLog(Map<String, String> headers) {
    return {
      ...headers,
      if (headers.containsKey('Authorization')) 'Authorization': 'Bearer ******',
    };
  }

  Map<String, dynamic> _safeBodyForLog(Map<String, dynamic> body) {
    const sensitiveKeys = {
      'password',
      'password_confirmation',
      'current_password',
      'token',
      'access_token',
      'refresh_token',
    };

    return {
      for (final entry in body.entries)
        entry.key: sensitiveKeys.contains(entry.key) ? '******' : entry.value,
    };
  }
}