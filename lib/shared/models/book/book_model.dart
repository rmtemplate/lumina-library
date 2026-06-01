import 'package:lumina_library/shared/models/category/category_model.dart';

// ─── Book branch (simplified) ─────────────────────────────────────────────────

/// Info cabang yang tersimpan di dalam data buku (berbeda dari [BranchModel]).
/// Field: id, code, name, address, latitude, longitude, distance_km
class BookBranchModel {
  const BookBranchModel({
    required this.id,
    required this.name,
    this.code,
    this.address,
    this.latitude,
    this.longitude,
    this.distanceKm,
  });

  final String id;
  final String name;
  final String? code;
  final String? address;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;

  String? get distanceLabel {
    if (distanceKm == null) return null;
    return distanceKm! < 1
        ? '${(distanceKm! * 1000).round()} m'
        : '${distanceKm!.toStringAsFixed(1)} km';
  }

  factory BookBranchModel.fromJson(Map<String, dynamic> json) {
    return BookBranchModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }
}

// ─── Availability ─────────────────────────────────────────────────────────────

class BookRackModel {
  const BookRackModel({
    required this.id,
    required this.code,
    required this.name,
    this.sectionName,
    this.floorLabel,
    this.areaLabel,
    required this.availableItems,
  });

  final String id;
  final String code;
  final String name;
  final String? sectionName;
  final String? floorLabel;
  final String? areaLabel;
  final int availableItems;

  factory BookRackModel.fromJson(Map<String, dynamic> json) {
    return BookRackModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sectionName: json['section_name'] as String?,
      floorLabel: json['floor_label'] as String?,
      areaLabel: json['area_label'] as String?,
      availableItems: (json['available_items'] as num?)?.toInt() ?? 0,
    );
  }
}

class BookAvailabilityModel {
  const BookAvailabilityModel({
    required this.totalItems,
    required this.availableItems,
    required this.isAvailable,
    this.racks = const [],
  });

  final int totalItems;
  final int availableItems;
  final bool isAvailable;
  final List<BookRackModel> racks;

  factory BookAvailabilityModel.fromJson(Map<String, dynamic> json) {
    final racksJson = json['racks'] as List<dynamic>? ?? [];
    return BookAvailabilityModel(
      totalItems: (json['total_items'] as num?)?.toInt() ?? 0,
      availableItems: (json['available_items'] as num?)?.toInt() ?? 0,
      isAvailable: json['is_available'] as bool? ?? false,
      racks: racksJson
          .map((r) => BookRackModel.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ─── User context ─────────────────────────────────────────────────────────────

class BookUserContextModel {
  const BookUserContextModel({
    this.isWishlisted = false,
    this.hasReviewed = false,
    this.myRating,
    this.isRecommended = false,
    this.recommendationScore,
  });

  final bool isWishlisted;
  final bool hasReviewed;
  final int? myRating;
  final bool isRecommended;
  final double? recommendationScore;

  factory BookUserContextModel.fromJson(Map<String, dynamic> json) {
    return BookUserContextModel(
      isWishlisted: json['is_wishlisted'] as bool? ?? false,
      hasReviewed: json['has_reviewed'] as bool? ?? false,
      myRating: (json['my_rating'] as num?)?.toInt(),
      isRecommended: json['is_recommended'] as bool? ?? false,
      recommendationScore:
          (json['recommendation_score'] as num?)?.toDouble(),
    );
  }
}

// ─── Book ─────────────────────────────────────────────────────────────────────

/// Model buku dari `BookCatalogLocationResource` (GET /api/v1/books, branch books, dll).
/// Dipakai bersama di: home trending, catalog, branch detail, book detail.
class BookModel {
  const BookModel({
    required this.id,
    required this.bookId,
    this.branchId,
    required this.title,
    required this.author,
    this.isbn,
    this.publisher,
    this.publishYear,
    this.language,
    this.description,
    this.coverUrl,
    this.category,
    this.branch,
    required this.ratingAverage,
    required this.ratingCount,
    required this.availability,
    this.borrowCount = 0,
    this.viewsCount = 0,
    this.wishlistCount = 0,
    this.userContext,
  });

  final String id;
  final String bookId;
  final String? branchId;
  final String title;
  final String author;
  final String? isbn;
  final String? publisher;
  final int? publishYear;
  final String? language;
  final String? description;
  final String? coverUrl;

  /// Sama struktur dengan [CategoryModel] — field `icon.image_url` dipakai.
  final CategoryModel? category;
  final BookBranchModel? branch;
  final double ratingAverage;
  final int ratingCount;
  final BookAvailabilityModel availability;
  final int borrowCount;
  final int viewsCount;
  final int wishlistCount;
  final BookUserContextModel? userContext;

  // ── Computed helpers ──────────────────────────────────────────────────────

  bool get isAvailable => availability.isAvailable;
  String get ratingLabel =>
      ratingAverage > 0 ? ratingAverage.toStringAsFixed(1) : '-';

  String? get locationLabel {
    final b = branch;
    if (b == null) return null;
    final dist = b.distanceLabel;
    if (dist == null) return b.name;
    return '${b.name} • $dist';
  }

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final ratingMap = json['rating'] as Map<String, dynamic>? ?? {};
    final availMap = json['availability'] as Map<String, dynamic>? ?? {};
    final analyticsMap = json['analytics'] as Map<String, dynamic>? ?? {};
    final categoryJson = json['category'] as Map<String, dynamic>?;
    final branchJson = json['branch'] as Map<String, dynamic>?;
    final userCtxJson = json['user_context'] as Map<String, dynamic>?;

    return BookModel(
      id: json['id'] as String? ?? json['book_id'] as String? ?? '',
      bookId: json['book_id'] as String? ?? json['id'] as String? ?? '',
      branchId: json['branch_id'] as String?,
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      isbn: json['isbn'] as String?,
      publisher: json['publisher'] as String?,
      publishYear: (json['publish_year'] as num?)?.toInt(),
      language: json['language'] as String?,
      description: json['description'] as String?,
      coverUrl: json['cover_url'] as String?,
      // CategoryModel reuse — same JSON structure
      category: categoryJson != null
          ? CategoryModel.fromJson(categoryJson)
          : null,
      branch:
          branchJson != null ? BookBranchModel.fromJson(branchJson) : null,
      ratingAverage: (ratingMap['average'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (ratingMap['count'] as num?)?.toInt() ?? 0,
      availability: BookAvailabilityModel.fromJson(availMap),
      borrowCount: (analyticsMap['borrow_count'] as num?)?.toInt() ?? 0,
      viewsCount: (analyticsMap['views_count'] as num?)?.toInt() ?? 0,
      wishlistCount: (analyticsMap['wishlist_count'] as num?)?.toInt() ?? 0,
      userContext: userCtxJson != null
          ? BookUserContextModel.fromJson(userCtxJson)
          : null,
    );
  }

  static List<BookModel> listFromJson(List<dynamic> list) =>
      list.map((e) => BookModel.fromJson(e as Map<String, dynamic>)).toList();
}
