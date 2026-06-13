import 'dart:convert';
import 'dart:typed_data';

/// Response dari POST /api/v1/checkout
class CheckoutResultModel {
  const CheckoutResultModel({
    required this.borrowing,
    required this.qr,
    required this.rules,
  });

  final CheckoutBorrowingModel borrowing;
  final CheckoutQrModel qr;
  final CheckoutRulesModel rules;

  factory CheckoutResultModel.fromJson(Map<String, dynamic> json) {
    return CheckoutResultModel(
      borrowing: CheckoutBorrowingModel.fromJson(
        json['borrowing'] as Map<String, dynamic>? ?? {},
      ),
      qr: CheckoutQrModel.fromJson(
        json['qr'] as Map<String, dynamic>? ?? {},
      ),
      rules: CheckoutRulesModel.fromJson(
        json['rules'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class CheckoutBorrowingModel {
  const CheckoutBorrowingModel({
    required this.id,
    required this.code,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.branchId,
    required this.branchName,
    required this.items,
    this.branchAddress,
    this.reservationExpiresAt,
  });

  final String id;
  final String code;
  final String status;
  final String startDate;
  final String endDate;
  final int totalDays;
  final String branchId;
  final String branchName;
  final String? branchAddress;
  final String? reservationExpiresAt;
  final List<CheckoutItemModel> items;

  factory CheckoutBorrowingModel.fromJson(Map<String, dynamic> json) {
    final branch = json['branch'] as Map<String, dynamic>? ?? {};
    final rawItems = json['items'] as List<dynamic>? ?? [];

    return CheckoutBorrowingModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      totalDays: (json['total_days'] as num?)?.toInt() ?? 1,
      branchId: branch['id']?.toString() ?? '',
      branchName: branch['name']?.toString() ?? '',
      branchAddress: branch['address']?.toString(),
      reservationExpiresAt: json['reservation_expires_at']?.toString(),
      items: rawItems
          .map((i) => CheckoutItemModel.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CheckoutItemModel {
  const CheckoutItemModel({
    required this.id,
    required this.title,
    required this.author,
    this.coverUrl,
  });

  final String id;
  final String title;
  final String author;
  final String? coverUrl;

  factory CheckoutItemModel.fromJson(Map<String, dynamic> json) {
    final book = json['book'] as Map<String, dynamic>? ?? {};
    return CheckoutItemModel(
      id: json['book_id']?.toString() ?? '',
      title: book['title']?.toString() ?? '',
      author: book['author']?.toString() ?? '',
      coverUrl: book['cover_url']?.toString(),
    );
  }
}

class CheckoutQrModel {
  const CheckoutQrModel({
    required this.id,
    required this.code,
    required this.imageDataUri,
    required this.ttlSeconds,
    required this.status,
    this.expiresAt,
  });

  final String id;
  final String code;

  /// Data URI format: "data:image/png;base64,..."
  final String imageDataUri;
  final int ttlSeconds;
  final String status;
  final String? expiresAt;

  Uint8List? get imageBytes {
    if (!imageDataUri.contains(';base64,')) return null;
    try {
      return base64Decode(imageDataUri.split(';base64,').last);
    } catch (_) {
      return null;
    }
  }

  factory CheckoutQrModel.fromJson(Map<String, dynamic> json) {
    return CheckoutQrModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      imageDataUri: json['image']?.toString() ?? '',
      ttlSeconds: (json['ttl_seconds'] as num?)?.toInt() ?? 60,
      status: json['status']?.toString() ?? '',
      expiresAt: json['expires_at']?.toString(),
    );
  }

  CheckoutQrModel copyWith({
    String? imageDataUri,
    String? status,
    String? expiresAt,
    int? ttlSeconds,
    String? code,
  }) {
    return CheckoutQrModel(
      id: id,
      code: code ?? this.code,
      imageDataUri: imageDataUri ?? this.imageDataUri,
      ttlSeconds: ttlSeconds ?? this.ttlSeconds,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class CheckoutRulesModel {
  const CheckoutRulesModel({
    required this.maxBorrowDays,
    required this.maxBorrowBooks,
    required this.reservationHoldHours,
  });

  final int maxBorrowDays;
  final int maxBorrowBooks;
  final int reservationHoldHours;

  factory CheckoutRulesModel.fromJson(Map<String, dynamic> json) {
    return CheckoutRulesModel(
      maxBorrowDays: (json['max_borrow_days'] as num?)?.toInt() ?? 14,
      maxBorrowBooks: (json['max_borrow_books'] as num?)?.toInt() ?? 5,
      reservationHoldHours:
          (json['reservation_hold_hours'] as num?)?.toInt() ?? 24,
    );
  }
}
