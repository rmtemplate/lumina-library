import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:map_launcher/map_launcher.dart' as map_launcher;
import 'package:url_launcher/url_launcher.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';

class LibraryRouteMapPage extends StatefulWidget {
  const LibraryRouteMapPage({
    super.key,
    required this.destinationName,
    required this.destinationAddress,
    required this.destinationLatitude,
    required this.destinationLongitude,
  });

  final String destinationName;
  final String destinationAddress;
  final double destinationLatitude;
  final double destinationLongitude;

  @override
  State<LibraryRouteMapPage> createState() => _LibraryRouteMapPageState();
}

class _LibraryRouteMapPageState extends State<LibraryRouteMapPage> {
  final MapController _mapController = MapController();

  bool _isLoadingLocation = true;
  bool _isLoadingRoute = false;

  String? _locationError;
  String? _routeError;

  LatLng? _origin;
  List<LatLng> _roadRoutePoints = [];

  double? _routeDistanceKm;
  double? _routeDurationMinutes;

  late final LatLng _destination = LatLng(
    widget.destinationLatitude,
    widget.destinationLongitude,
  );

  double? get _distanceKm {
    if (_routeDistanceKm != null) return _routeDistanceKm;

    final origin = _origin;
    if (origin == null) return null;

    return _calculateDistanceKm(origin, _destination);
  }

  int? get _walkingMinutes {
    final distance = _distanceKm;
    if (distance == null) return null;

    return max(1, ((distance / 4.8) * 60).round());
  }

  int? get _drivingMinutes {
    if (_routeDurationMinutes != null) {
      return max(1, _routeDurationMinutes!.round());
    }

    final distance = _distanceKm;
    if (distance == null) return null;

    return max(1, ((distance / 25) * 60).round());
  }

  List<LatLng> get _displayRoutePoints {
    final origin = _origin;

    if (_roadRoutePoints.length >= 2) {
      return _roadRoutePoints;
    }

    if (origin == null) {
      return [_destination];
    }

    return [
      origin,
      _destination,
    ];
  }

  @override
  void initState() {
    super.initState();
    unawaited(_loadCurrentLocation());
  }

  Future<void> _loadCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _isLoadingRoute = false;
      _locationError = null;
      _routeError = null;
      _roadRoutePoints = [];
      _routeDistanceKm = null;
      _routeDurationMinutes = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        setState(() {
          _locationError = 'Layanan lokasi belum aktif.';
          _isLoadingLocation = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _fitRouteBounds();
        });

        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;

        setState(() {
          _locationError = 'Izin lokasi belum diberikan.';
          _isLoadingLocation = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _fitRouteBounds();
        });

        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final origin = LatLng(position.latitude, position.longitude);

      if (!mounted) return;

      setState(() {
        _origin = origin;
        _isLoadingLocation = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitRouteBounds();
      });

      await _loadRoadRoute(origin);

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitRouteBounds();
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _locationError =
            'Lokasi belum bisa diambil. Gunakan Google Maps untuk navigasi langsung.';
        _isLoadingLocation = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitRouteBounds();
      });
    }
  }

  Future<void> _loadRoadRoute(LatLng origin) async {
    setState(() {
      _isLoadingRoute = true;
      _routeError = null;
      _roadRoutePoints = [
        origin,
        _destination,
      ];
      _routeDistanceKm = null;
      _routeDurationMinutes = null;
    });

    try {
      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${origin.longitude},${origin.latitude};'
        '${_destination.longitude},${_destination.latitude}',
      ).replace(
        queryParameters: const {
          'overview': 'full',
          'geometries': 'geojson',
          'alternatives': 'false',
          'steps': 'false',
        },
      );

      final response = await http.get(uri).timeout(
            const Duration(seconds: 12),
          );

      if (response.statusCode != 200) {
        throw Exception('OSRM response status: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid OSRM response.');
      }

      final code = decoded['code'];

      if (code != 'Ok') {
        throw Exception('OSRM route code: $code');
      }

      final routes = decoded['routes'];

      if (routes is! List || routes.isEmpty) {
        throw Exception('OSRM route not found.');
      }

      final route = routes.first;

      if (route is! Map<String, dynamic>) {
        throw Exception('Invalid OSRM route item.');
      }

      final geometry = route['geometry'];

      if (geometry is! Map<String, dynamic>) {
        throw Exception('Invalid OSRM geometry.');
      }

      final coordinates = geometry['coordinates'];

      if (coordinates is! List || coordinates.length < 2) {
        throw Exception('OSRM route coordinates not enough.');
      }

      final routePoints = coordinates
          .whereType<List>()
          .where((coordinate) => coordinate.length >= 2)
          .map((coordinate) {
        final longitude = _toDouble(coordinate[0]);
        final latitude = _toDouble(coordinate[1]);

        if (latitude == null || longitude == null) {
          return null;
        }

        return LatLng(latitude, longitude);
      }).whereType<LatLng>().toList();

      if (routePoints.length < 2) {
        throw Exception('OSRM route points not enough.');
      }

      final distanceMeters = _toDouble(route['distance']);
      final durationSeconds = _toDouble(route['duration']);

      if (!mounted) return;

      setState(() {
        _roadRoutePoints = routePoints;
        _routeDistanceKm =
            distanceMeters == null ? null : distanceMeters / 1000;
        _routeDurationMinutes =
            durationSeconds == null ? null : durationSeconds / 60;
        _isLoadingRoute = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _roadRoutePoints = [
          origin,
          _destination,
        ];
        _routeDistanceKm = null;
        _routeDurationMinutes = null;
        _routeError =
            'Rute jalan belum bisa dimuat. Menampilkan estimasi jarak langsung.';
        _isLoadingRoute = false;
      });
    }
  }

  double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);

    return null;
  }

  void _fitRouteBounds() {
    final points = _displayRoutePoints;

    if (points.length < 2) {
      _mapController.move(_destination, 15);
      return;
    }

    final bounds = LatLngBounds.fromPoints(points);

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.fromLTRB(48, 120, 48, 220),
      ),
    );
  }

  Future<void> _openRouteOptions() async {
    if (kIsWeb) {
      await _openGoogleMapsWeb();
      return;
    }

    try {
      final availableMaps = await map_launcher.MapLauncher.installedMaps;

      if (!mounted) return;

      if (availableMaps.isEmpty) {
        await _openGoogleMapsWeb();
        return;
      }

      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return _MapAppPickerSheet(
            maps: availableMaps,
            destinationName: widget.destinationName,
            onMapTap: _openInstalledMap,
            onGoogleWebTap: _openGoogleMapsWeb,
          );
        },
      );
    } catch (_) {
      await _openGoogleMapsWeb();
    }
  }

  Future<void> _openInstalledMap(
    map_launcher.AvailableMap selectedMap,
  ) async {
    if (!mounted) return;

    Navigator.of(context).maybePop();

    final origin = _origin;

    await selectedMap.showDirections(
      destination: map_launcher.Coords(
        widget.destinationLatitude,
        widget.destinationLongitude,
      ),
      destinationTitle: widget.destinationName,
      origin: origin == null
          ? null
          : map_launcher.Coords(
              origin.latitude,
              origin.longitude,
            ),
      originTitle: origin == null ? null : 'Lokasi Saya',
      directionsMode: map_launcher.DirectionsMode.driving,
    );
  }

  Future<void> _openGoogleMapsWeb() async {
    final origin = _origin;

    final queryParameters = <String, String>{
      'api': '1',
      'destination':
          '${widget.destinationLatitude},${widget.destinationLongitude}',
      'travelmode': 'driving',
    };

    if (origin != null) {
      queryParameters['origin'] = '${origin.latitude},${origin.longitude}';
    }

    final uri = Uri.https(
      'www.google.com',
      '/maps/dir/',
      queryParameters,
    );

    final canLaunch = await canLaunchUrl(uri);

    if (!canLaunch) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google Maps belum bisa dibuka.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  double _calculateDistanceKm(LatLng origin, LatLng destination) {
    const earthRadiusKm = 6371.0;

    final dLat = _degreeToRadian(destination.latitude - origin.latitude);
    final dLon = _degreeToRadian(destination.longitude - origin.longitude);

    final originLat = _degreeToRadian(origin.latitude);
    final destinationLat = _degreeToRadian(destination.latitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) *
            sin(dLon / 2) *
            cos(originLat) *
            cos(destinationLat);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _degreeToRadian(double degree) {
    return degree * pi / 180;
  }

  String _formatDistance(double? value) {
    if (value == null) return '-';

    if (value < 1) {
      return '${(value * 1000).round()} m';
    }

    return '${value.toStringAsFixed(1)} km';
  }

  String _formatMinute(int? value) {
    if (value == null) return '-';

    return '$value min';
  }

  @override
  Widget build(BuildContext context) {
    final routePoints = _displayRoutePoints;

    return Scaffold(
      backgroundColor: LuminaColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _destination,
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.rezamaulana.lumina_library',
                ),
                if (_origin != null && routePoints.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        color: LuminaColors.primary,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (_origin != null)
                      Marker(
                        width: 56,
                        height: 56,
                        point: _origin!,
                        child: const _RouteMarker(
                          icon: Icons.my_location_rounded,
                          backgroundColor: LuminaColors.secondary,
                          iconColor: LuminaColors.onSecondary,
                        ),
                      ),
                    Marker(
                      width: 60,
                      height: 60,
                      point: _destination,
                      child: const _RouteMarker(
                        icon: Icons.local_library_rounded,
                        backgroundColor: LuminaColors.primary,
                        iconColor: LuminaColors.onPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: _RouteTopBar(
              title: 'Rute Perpustakaan',
              onBackTap: Get.back,
              onRefreshTap: _loadCurrentLocation,
            ),
          ),
          Positioned(
            left: LuminaSpacing.marginMobile,
            right: LuminaSpacing.marginMobile,
            bottom: LuminaSpacing.marginMobile,
            child: _RouteInfoCard(
              destinationName: widget.destinationName,
              destinationAddress: widget.destinationAddress,
              isLoadingLocation: _isLoadingLocation,
              isLoadingRoute: _isLoadingRoute,
              locationError: _locationError,
              routeError: _routeError,
              distanceText: _formatDistance(_distanceKm),
              walkingText: _formatMinute(_walkingMinutes),
              drivingText: _formatMinute(_drivingMinutes),
              onOpenRouteTap: _openRouteOptions,
              onRetryLocationTap: _loadCurrentLocation,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteTopBar extends StatelessWidget {
  const _RouteTopBar({
    required this.title,
    required this.onBackTap,
    required this.onRefreshTap,
  });

  final String title;
  final VoidCallback onBackTap;
  final VoidCallback onRefreshTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LuminaColors.surface.withOpacity(0.94),
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(
            horizontal: LuminaSpacing.marginMobile,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: LuminaColors.outlineVariant.withOpacity(0.36),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              _CircleMapButton(
                icon: Icons.arrow_back_rounded,
                onTap: onBackTap,
              ),
              const SizedBox(width: LuminaSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: LuminaTextStyles.headlineSm.copyWith(
                    color: LuminaColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _CircleMapButton(
                icon: Icons.refresh_rounded,
                onTap: onRefreshTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteInfoCard extends StatelessWidget {
  const _RouteInfoCard({
    required this.destinationName,
    required this.destinationAddress,
    required this.isLoadingLocation,
    required this.isLoadingRoute,
    required this.locationError,
    required this.routeError,
    required this.distanceText,
    required this.walkingText,
    required this.drivingText,
    required this.onOpenRouteTap,
    required this.onRetryLocationTap,
  });

  final String destinationName;
  final String destinationAddress;
  final bool isLoadingLocation;
  final bool isLoadingRoute;
  final String? locationError;
  final String? routeError;
  final String distanceText;
  final String walkingText;
  final String drivingText;
  final VoidCallback onOpenRouteTap;
  final VoidCallback onRetryLocationTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest.withOpacity(0.98),
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(
          color: LuminaColors.outlineVariant.withOpacity(0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: LuminaColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(LuminaRadius.lg),
                  ),
                  child: const Icon(
                    Icons.local_library_rounded,
                    color: LuminaColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: LuminaSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destinationName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LuminaTextStyles.titleLg.copyWith(
                          color: LuminaColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        destinationAddress,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: LuminaTextStyles.bodyMd.copyWith(
                          color: LuminaColors.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: LuminaSpacing.md),
            if (isLoadingLocation)
              const _LocationLoadingBox()
            else if (locationError != null)
              _LocationErrorBox(
                message: locationError!,
                onRetryTap: onRetryLocationTap,
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: _RouteMetricItem(
                      icon: Icons.near_me_rounded,
                      label: 'Jarak',
                      value: distanceText,
                    ),
                  ),
                  Expanded(
                    child: _RouteMetricItem(
                      icon: Icons.directions_walk_rounded,
                      label: 'Jalan',
                      value: walkingText,
                    ),
                  ),
                  Expanded(
                    child: _RouteMetricItem(
                      icon: Icons.directions_car_rounded,
                      label: 'Mobil',
                      value: drivingText,
                    ),
                  ),
                ],
              ),
              if (isLoadingRoute || routeError != null) ...[
                const SizedBox(height: LuminaSpacing.sm),
                _RouteStatusBox(
                  isLoading: isLoadingRoute,
                  message: isLoadingRoute
                      ? 'Mengambil rute mengikuti jalan...'
                      : routeError!,
                ),
              ],
            ],
            const SizedBox(height: LuminaSpacing.md),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onOpenRouteTap,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: LuminaColors.primary,
                  foregroundColor: LuminaColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(LuminaRadius.lg),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.route_rounded, size: 21),
                    const SizedBox(width: LuminaSpacing.xs),
                    Text(
                      'Buka Rute',
                      style: LuminaTextStyles.titleLg.copyWith(
                        color: LuminaColors.onPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteStatusBox extends StatelessWidget {
  const _RouteStatusBox({
    required this.isLoading,
    required this.message,
  });

  final bool isLoading;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.sm,
        vertical: LuminaSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isLoading
            ? LuminaColors.surfaceContainerLow
            : LuminaColors.errorContainer.withOpacity(0.36),
        borderRadius: BorderRadius.circular(LuminaRadius.md),
        border: Border.all(
          color: isLoading
              ? LuminaColors.outlineVariant.withOpacity(0.42)
              : LuminaColors.error.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: LuminaColors.secondary,
              ),
            )
          else
            const Icon(
              Icons.info_outline_rounded,
              color: LuminaColors.error,
              size: 18,
            ),
          const SizedBox(width: LuminaSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: LuminaTextStyles.labelMd.copyWith(
                color: isLoading
                    ? LuminaColors.onSurfaceVariant
                    : LuminaColors.onErrorContainer,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteMetricItem extends StatelessWidget {
  const _RouteMetricItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: LuminaColors.primary,
          size: 22,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: LuminaTextStyles.labelMd.copyWith(
            color: LuminaColors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: LuminaTextStyles.bodyMd.copyWith(
            color: LuminaColors.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _LocationLoadingBox extends StatelessWidget {
  const _LocationLoadingBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: LuminaColors.secondary,
            ),
          ),
          const SizedBox(width: LuminaSpacing.sm),
          Expanded(
            child: Text(
              'Mengambil lokasi Anda...',
              style: LuminaTextStyles.bodyMd.copyWith(
                color: LuminaColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationErrorBox extends StatelessWidget {
  const _LocationErrorBox({
    required this.message,
    required this.onRetryTap,
  });

  final String message;
  final VoidCallback onRetryTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.errorContainer.withOpacity(0.52),
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
        border: Border.all(
          color: LuminaColors.error.withOpacity(0.18),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_off_rounded,
            color: LuminaColors.error,
            size: 24,
          ),
          const SizedBox(width: LuminaSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: LuminaTextStyles.bodyMd.copyWith(
                color: LuminaColors.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetryTap,
            child: Text(
              'Retry',
              style: LuminaTextStyles.labelMd.copyWith(
                color: LuminaColors.error,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteMarker extends StatelessWidget {
  const _RouteMarker({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.34),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 25,
        ),
      ),
    );
  }
}

class _CircleMapButton extends StatelessWidget {
  const _CircleMapButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LuminaColors.surfaceContainerLowest,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            color: LuminaColors.primary,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _MapAppPickerSheet extends StatelessWidget {
  const _MapAppPickerSheet({
    required this.maps,
    required this.destinationName,
    required this.onMapTap,
    required this.onGoogleWebTap,
  });

  final List<map_launcher.AvailableMap> maps;
  final String destinationName;
  final ValueChanged<map_launcher.AvailableMap> onMapTap;
  final VoidCallback onGoogleWebTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        LuminaSpacing.marginMobile,
        LuminaSpacing.lg,
        LuminaSpacing.marginMobile,
        LuminaSpacing.marginMobile,
      ),
      decoration: const BoxDecoration(
        color: LuminaColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(LuminaRadius.xl),
          topRight: Radius.circular(LuminaRadius.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: LuminaColors.outlineVariant,
                borderRadius: BorderRadius.circular(LuminaRadius.full),
              ),
            ),
            const SizedBox(height: LuminaSpacing.lg),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pilih Aplikasi Maps',
                style: LuminaTextStyles.headlineSm.copyWith(
                  color: LuminaColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Buka rute menuju $destinationName.',
                style: LuminaTextStyles.bodyMd.copyWith(
                  color: LuminaColors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: LuminaSpacing.md),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...maps.map((map) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: LuminaColors.primary.withOpacity(0.07),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.map_rounded,
                            color: LuminaColors.primary,
                          ),
                        ),
                        title: Text(
                          map.mapName,
                          style: LuminaTextStyles.bodyLg.copyWith(
                            color: LuminaColors.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.open_in_new_rounded,
                          color: LuminaColors.onSurfaceVariant,
                          size: 20,
                        ),
                        onTap: () => onMapTap(map),
                      );
                    }),
                    const Divider(
                      color: LuminaColors.surfaceVariant,
                      height: 1,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: LuminaColors.secondary.withOpacity(0.10),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.public_rounded,
                          color: LuminaColors.secondary,
                        ),
                      ),
                      title: Text(
                        'Google Maps Web',
                        style: LuminaTextStyles.bodyLg.copyWith(
                          color: LuminaColors.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(
                        'Fallback jika aplikasi maps tidak tersedia',
                        style: LuminaTextStyles.labelMd.copyWith(
                          color: LuminaColors.onSurfaceVariant,
                          letterSpacing: 0,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.open_in_browser_rounded,
                        color: LuminaColors.onSurfaceVariant,
                        size: 20,
                      ),
                      onTap: () {
                        Navigator.of(context).maybePop();
                        onGoogleWebTap();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}