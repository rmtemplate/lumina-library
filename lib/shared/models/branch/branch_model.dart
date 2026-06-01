import 'package:lumina_library/shared/models/library/library_branch_model.dart';

// ─── Schedule ─────────────────────────────────────────────────────────────────

/// Jam operasional dan status buka/tutup dari field `schedule` response branch.
class BranchScheduleModel {
  const BranchScheduleModel({
    required this.isOpen,
    this.opensAt,
    this.closesAt,
    this.description,
    this.statusLabel,
    this.minutesUntilOpen,
    this.minutesUntilClose,
  });

  final bool isOpen;

  /// e.g. "08:00"
  final String? opensAt;

  /// e.g. "20:00"
  final String? closesAt;

  /// e.g. "Senin - Jumat, 08.00 - 20.00"
  final String? description;

  /// "Buka" / "Tutup"
  final String? statusLabel;
  final int? minutesUntilOpen;
  final int? minutesUntilClose;

  String get scheduleText {
    if (description != null && description!.isNotEmpty) return description!;
    if (opensAt != null && closesAt != null) return '$opensAt – $closesAt';
    return '-';
  }

  String get openLabel => statusLabel ?? (isOpen ? 'Buka' : 'Tutup');

  factory BranchScheduleModel.fromJson(Map<String, dynamic> json) {
    return BranchScheduleModel(
      isOpen: json['is_open'] as bool? ?? false,
      opensAt: json['opens_at'] as String?,
      closesAt: json['closes_at'] as String?,
      description: json['description'] as String?,
      statusLabel: json['status_label'] as String?,
      minutesUntilOpen: (json['minutes_until_open'] as num?)?.toInt(),
      minutesUntilClose: (json['minutes_until_close'] as num?)?.toInt(),
    );
  }
}

// ─── Distance ─────────────────────────────────────────────────────────────────

/// Info jarak dari field `distance` response branch.
class BranchDistanceModel {
  const BranchDistanceModel({required this.km, required this.label});

  final double km;

  /// e.g. "350 m" atau "1.2 km"
  final String label;

  factory BranchDistanceModel.fromJson(Map<String, dynamic> json) {
    return BranchDistanceModel(
      km: (json['km'] as num?)?.toDouble() ?? 0,
      label: json['label'] as String? ?? '-',
    );
  }
}

// ─── Travel estimate ──────────────────────────────────────────────────────────

/// Estimasi waktu tempuh (jalan kaki / berkendara).
class BranchTravelModel {
  const BranchTravelModel({required this.minutes, required this.label});

  final int minutes;

  /// e.g. "5 menit" atau "23 jam 52 menit"
  final String label;

  factory BranchTravelModel.fromJson(Map<String, dynamic> json) {
    return BranchTravelModel(
      minutes: (json['minutes'] as num?)?.toInt() ?? 0,
      label: json['label'] as String? ?? '-',
    );
  }
}

// ─── Branch ───────────────────────────────────────────────────────────────────

/// Model cabang perpustakaan dari `GET /api/v1/public/branches`.
class BranchModel {
  const BranchModel({
    required this.id,
    required this.code,
    required this.name,
    required this.address,
    this.description,
    this.phone,
    this.email,
    this.imageUrl,
    this.latitude,
    this.longitude,
    required this.schedule,
    this.distance,
    this.walkingEstimate,
    this.drivingEstimate,
  });

  final String id;
  final String code;
  final String name;
  final String address;
  final String? description;
  final String? phone;
  final String? email;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final BranchScheduleModel schedule;
  final BranchDistanceModel? distance;
  final BranchTravelModel? walkingEstimate;
  final BranchTravelModel? drivingEstimate;

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    final coords = json['coordinates'] as Map<String, dynamic>?;
    final scheduleJson = json['schedule'] as Map<String, dynamic>?;
    final distanceJson = json['distance'] as Map<String, dynamic>?;
    final travelJson = json['travel_estimate'] as Map<String, dynamic>?;

    return BranchModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      description: json['description'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      imageUrl: json['image_url'] as String?,
      latitude: (coords?['latitude'] as num?)?.toDouble(),
      longitude: (coords?['longitude'] as num?)?.toDouble(),
      schedule: scheduleJson != null
          ? BranchScheduleModel.fromJson(scheduleJson)
          : const BranchScheduleModel(isOpen: false),
      distance: distanceJson != null
          ? BranchDistanceModel.fromJson(distanceJson)
          : null,
      walkingEstimate: (travelJson?['walking'] as Map<String, dynamic>?) != null
          ? BranchTravelModel.fromJson(
              travelJson!['walking'] as Map<String, dynamic>)
          : null,
      drivingEstimate: (travelJson?['driving'] as Map<String, dynamic>?) != null
          ? BranchTravelModel.fromJson(
              travelJson!['driving'] as Map<String, dynamic>)
          : null,
    );
  }

  static List<BranchModel> listFromJson(List<dynamic> list) =>
      list.map((e) => BranchModel.fromJson(e as Map<String, dynamic>)).toList();

  /// Konversi ke `LibraryNearbyLibraryData` untuk kompatibilitas widget existing.
  LibraryNearbyLibraryData toNearbyLibraryData() => LibraryNearbyLibraryData(
        id: id,
        name: name,
        address: address,
        imageUrl: imageUrl ?? '',
        distanceText: distance?.label ?? '-',
        durationText: walkingEstimate?.label ?? '-',
        scheduleText: schedule.scheduleText,
        openStatusText: schedule.openLabel,
        isOpen: schedule.isOpen,
        latitude: latitude,
        longitude: longitude,
      );
}
