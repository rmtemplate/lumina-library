import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';

class LuminaPermissionItem {
  const LuminaPermissionItem({
    required this.permission,
    required this.title,
    required this.reason,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });

  final Permission permission;
  final String title;
  final String reason;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
}

class LuminaPermissionService {
  const LuminaPermissionService._();

  static int? _cachedAndroidSdkInt;

  static Future<int> get _androidSdkInt async {
    if (!Platform.isAndroid) return 999;

    if (_cachedAndroidSdkInt != null) {
      return _cachedAndroidSdkInt!;
    }

    try {
      final info = await DeviceInfoPlugin().androidInfo;
      _cachedAndroidSdkInt = info.version.sdkInt;
      return _cachedAndroidSdkInt!;
    } catch (_) {
      // Default ke Android 13+ agar tidak memakai storage legacy pada device baru.
      _cachedAndroidSdkInt = 33;
      return _cachedAndroidSdkInt!;
    }
  }

  static Future<Permission> get _galleryPermission async {
    if (kIsWeb) {
      return Permission.photos;
    }

    if (Platform.isIOS) {
      return Permission.photos;
    }

    if (!Platform.isAndroid) {
      return Permission.photos;
    }

    final sdkInt = await _androidSdkInt;

    // Android 10-12 = API 29-32
    if (sdkInt >= 29 && sdkInt <= 32) {
      return Permission.storage;
    }

    // Android 13, 14, 15+ = API 33+
    if (sdkInt >= 33) {
      return Permission.photos;
    }

    // Android lama, fallback.
    return Permission.storage;
  }

  static Future<List<LuminaPermissionItem>> getItems() async {
    final galleryPermission = await _galleryPermission;

    return [
      LuminaPermissionItem(
        permission: Permission.camera,
        title: 'Kamera',
        reason: 'Digunakan untuk memindai QR kode buku saat peminjaman & pengembalian.',
        icon: Icons.camera_alt_rounded,
        iconColor: LuminaColors.primary,
        iconBackground: const Color(0x1A031632),
      ),
      LuminaPermissionItem(
        permission: Permission.locationWhenInUse,
        title: 'Lokasi',
        reason: 'Digunakan untuk menampilkan perpustakaan terdekat dari posisi Anda.',
        icon: Icons.location_on_rounded,
        iconColor: LuminaColors.secondary,
        iconBackground: const Color(0x1A006C49),
      ),
      LuminaPermissionItem(
        permission: galleryPermission,
        title: 'Galeri / Foto',
        reason: 'Digunakan untuk memperbarui foto profil akun Anda.',
        icon: Icons.photo_library_rounded,
        iconColor: const Color(0xFF7B4F9E),
        iconBackground: const Color(0x1A7B4F9E),
      ),
    ];
  }

  static Future<Map<Permission, PermissionStatus>> checkAll() async {
    if (kIsWeb) return {};

    final items = await getItems();
    final result = <Permission, PermissionStatus>{};

    for (final item in items) {
      result[item.permission] = await item.permission.status;
    }

    return result;
  }

  static Future<Map<Permission, PermissionStatus>> requestAll() async {
    if (kIsWeb) return {};

    final items = await getItems();

    final permissions = items
        .map((item) => item.permission)
        .toSet()
        .toList();

    return permissions.request();
  }

  static bool allGranted(Map<Permission, PermissionStatus> statuses) {
    if (kIsWeb) return true;
    if (statuses.isEmpty) return false;

    return statuses.values.every(
      (status) => status.isGranted || status.isLimited,
    );
  }

  static Future<bool> areAllGranted() async {
    if (kIsWeb) return true;

    final statuses = await checkAll();
    return allGranted(statuses);
  }

  static Future<void> navigateWithCheck(VoidCallback onGranted) async {
    if (kIsWeb) {
      onGranted();
      return;
    }

    final granted = await areAllGranted();

    if (granted) {
      onGranted();
      return;
    }

    Get.off(
      () => PermissionGatePage(onComplete: onGranted),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 400),
    );
  }
}

class PermissionGatePage extends StatefulWidget {
  const PermissionGatePage({
    super.key,
    required this.onComplete,
  });

  final VoidCallback onComplete;

  @override
  State<PermissionGatePage> createState() => _PermissionGatePageState();
}

class _PermissionGatePageState extends State<PermissionGatePage>
    with WidgetsBindingObserver {
  List<LuminaPermissionItem> _items = [];
  Map<Permission, PermissionStatus> _statuses = {};

  bool _isLoading = false;
  bool _hasRequested = false;
  bool _hasOpenedSettings = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAndRefreshStatuses(autoContinue: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _hasOpenedSettings) {
      _hasOpenedSettings = false;
      _loadAndRefreshStatuses(autoContinue: true);
    }
  }

  Future<void> _loadAndRefreshStatuses({
    bool autoContinue = false,
  }) async {
    final items = await LuminaPermissionService.getItems();
    final statuses = await LuminaPermissionService.checkAll();

    if (!mounted) return;

    setState(() {
      _items = items;
      _statuses = statuses;
    });

    if (autoContinue && LuminaPermissionService.allGranted(statuses)) {
      _complete();
    }
  }

  bool get _anyPermanentlyDenied {
    return _statuses.values.any((status) => status.isPermanentlyDenied);
  }

  bool get _allGranted {
    return LuminaPermissionService.allGranted(_statuses);
  }

  void _complete() {
    if (_completed) return;

    _completed = true;
    widget.onComplete();
  }

  Future<void> _requestPermissions() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final results = await LuminaPermissionService.requestAll();

    if (!mounted) return;

    setState(() {
      _statuses = results;
      _isLoading = false;
      _hasRequested = true;
    });

    if (LuminaPermissionService.allGranted(results)) {
      await Future<void>.delayed(const Duration(milliseconds: 280));

      if (mounted) {
        _complete();
      }
    }
  }

  Future<void> _openAppSettings() async {
    _hasOpenedSettings = true;
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuminaColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 5,
              color: LuminaColors.primary,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/logo/lumina-logo.png',
                        width: 68,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Izin Akses\nDiperlukan',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: LuminaColors.primary,
                        height: 1.25,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Lumina Library memerlukan akses berikut agar semua fitur berjalan dengan optimal.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: LuminaColors.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (_items.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      ..._items.map(
                        (item) => _PermissionTile(
                          item: item,
                          status: _statuses[item.permission],
                          hasRequested: _hasRequested,
                        ),
                      ),
                    if (_hasRequested && _anyPermanentlyDenied) ...[
                      const SizedBox(height: 4),
                      _PermanentlyDeniedBanner(
                        onOpenSettings: _openAppSettings,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _BottomBar(
              isLoading: _isLoading,
              hasRequested: _hasRequested,
              allGranted: _allGranted,
              anyPermanentlyDenied: _anyPermanentlyDenied,
              onRequest: _requestPermissions,
              onRetry: _requestPermissions,
              onOpenSettings: _openAppSettings,
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.item,
    required this.status,
    required this.hasRequested,
  });

  final LuminaPermissionItem item;
  final PermissionStatus? status;
  final bool hasRequested;

  bool get _granted {
    return status?.isGranted == true || status?.isLimited == true;
  }

  bool get _denied {
    return hasRequested &&
        (status?.isDenied == true || status?.isPermanentlyDenied == true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _granted
              ? LuminaColors.secondary.withValues(alpha: 0.3)
              : _denied
                  ? LuminaColors.error.withValues(alpha: 0.25)
                  : LuminaColors.outlineVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              color: item.iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: LuminaColors.onSurface,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.reason,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: LuminaColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _StatusDot(
            granted: _granted,
            denied: _denied,
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({
    required this.granted,
    required this.denied,
  });

  final bool granted;
  final bool denied;

  @override
  Widget build(BuildContext context) {
    if (granted) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: LuminaColors.secondary.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          color: LuminaColors.secondary,
          size: 16,
        ),
      );
    }

    if (denied) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: LuminaColors.error.withValues(alpha: 0.10),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.close_rounded,
          color: LuminaColors.error,
          size: 16,
        ),
      );
    }

    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: LuminaColors.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.hourglass_empty_rounded,
        color: LuminaColors.outline,
        size: 15,
      ),
    );
  }
}

class _PermanentlyDeniedBanner extends StatelessWidget {
  const _PermanentlyDeniedBanner({
    required this.onOpenSettings,
  });

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LuminaColors.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: LuminaColors.error.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: LuminaColors.onErrorContainer,
            size: 18,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Beberapa izin ditolak permanen. Aktifkan melalui Pengaturan aplikasi.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: LuminaColors.onErrorContainer,
                height: 1.5,
              ),
            ),
          ),
          TextButton(
            onPressed: onOpenSettings,
            child: const Text('Buka'),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.isLoading,
    required this.hasRequested,
    required this.allGranted,
    required this.anyPermanentlyDenied,
    required this.onRequest,
    required this.onRetry,
    required this.onOpenSettings,
  });

  final bool isLoading;
  final bool hasRequested;
  final bool allGranted;
  final bool anyPermanentlyDenied;
  final VoidCallback onRequest;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;

  String get _label {
    if (anyPermanentlyDenied) return 'Buka Pengaturan';
    if (hasRequested && !allGranted) return 'Coba Lagi';
    return 'Izinkan Akses';
  }

  VoidCallback get _action {
    if (anyPermanentlyDenied) return onOpenSettings;
    if (hasRequested && !allGranted) return onRetry;
    return onRequest;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        border: const Border(
          top: BorderSide(
            color: LuminaColors.surfaceContainerHigh,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: isLoading ? null : _action,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: LuminaColors.primary,
                disabledBackgroundColor: LuminaColors.surfaceContainerHigh,
                foregroundColor: LuminaColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: LuminaColors.onPrimary,
                      ),
                    )
                  : Text(
                      _label,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Izin hanya digunakan saat fitur terkait aktif dan tidak dibagikan ke pihak lain.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: LuminaColors.outline,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}