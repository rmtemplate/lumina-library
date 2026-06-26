import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import 'package:lumina_library/core/config/network_config.dart';

class AppConfig {
  const AppConfig._();

  /// Delegates to [NetworkConfig] — the single source of truth for every
  /// network endpoint (API + WebSocket). Change the IP/host there, not here.
  static String get baseUrl => NetworkConfig.apiBaseUrl;

  static String get apiPrefix => NetworkConfig.apiPrefix;
  static Duration get requestTimeout => NetworkConfig.requestTimeout;

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