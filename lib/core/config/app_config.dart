import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

  /// Base URL backend Laravel.
  /// Android emulator  → http://10.0.2.2
  /// Laragon (host OS) → http://lumina-library.test
  static const String baseUrl = 'http://172.20.10.2:8000';

  static const String apiPrefix = '/api/v1';
  static const Duration requestTimeout = Duration(seconds: 20);

  static Future<String> getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (kIsWeb) {
        final web = await deviceInfo.webBrowserInfo;

        return _sanitizeDeviceName(
          'web-${web.browserName.name}-${web.platform ?? 'browser'}',
        );
      }

      if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;

        return _sanitizeDeviceName(
          'android-${android.manufacturer}-${android.model}-${android.id}',
        );
      }

      if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;

        return _sanitizeDeviceName(
          'ios-${ios.name}-${ios.model}-${ios.identifierForVendor ?? 'unknown'}',
        );
      }

      if (Platform.isMacOS) {
        final mac = await deviceInfo.macOsInfo;

        return _sanitizeDeviceName(
          'macos-${mac.computerName}-${mac.systemGUID ?? 'unknown'}',
        );
      }

      if (Platform.isWindows) {
        final windows = await deviceInfo.windowsInfo;

        return _sanitizeDeviceName(
          'windows-${windows.computerName}-${windows.deviceId}',
        );
      }

      if (Platform.isLinux) {
        final linux = await deviceInfo.linuxInfo;

        return _sanitizeDeviceName(
          'linux-${linux.name}-${linux.machineId ?? 'unknown'}',
        );
      }

      return 'lumina-device';
    } catch (_) {
      return 'lumina-device';
    }
  }

  static String _sanitizeDeviceName(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9._-]'), '-')
        .replaceAll(RegExp(r'-+'), '-');

    if (normalized.isEmpty) {
      return 'lumina-device';
    }

    return normalized.length > 100
        ? normalized.substring(0, 100)
        : normalized;
  }
}