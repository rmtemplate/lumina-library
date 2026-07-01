import 'dart:convert';

import 'package:flutter/foundation.dart';

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
  CheckoutQrModel({
    required this.id,
    required this.code,
    required this.imageDataUri,
    required this.ttlSeconds,
    required this.status,
    this.expiresAt,
  });

  final String id;
  final String code;

  /// Raw value of the `image` field as returned by the backend. Expected
  /// format is a data URI ("data:image/png;base64,..."), but this is logged
  /// and defended against in [imageBytes] since the backend QR library may
  /// emit raw base64, a bare URL, or (notably) SVG instead of a raster PNG.
  final String imageDataUri;
  final int ttlSeconds;
  final String status;
  final String? expiresAt;

  static final RegExp _dataUriPattern =
      RegExp(r'^data:([^;]+);base64,', caseSensitive: false);

  /// The MIME type declared in the data URI prefix, if present
  /// (e.g. "image/png", "image/svg+xml"). Null if no data URI prefix found.
  String? get declaredMimeType =>
      _dataUriPattern.firstMatch(imageDataUri.trim())?.group(1);

  /// Decodes [imageDataUri] to raw bytes. Handles a data URI prefix, a bare
  /// base64 payload, or stray whitespace/newlines. Returns null (with a
  /// debug log explaining why) if the string is empty, is a bare URL
  /// (cannot be decoded in-memory), or fails to base64-decode.
  ///
  /// NOTE: a non-null result only means base64 decoding succeeded — it does
  /// NOT guarantee the bytes are a renderable raster image. Check
  /// [isRenderableRasterImage] / [isSvgContent] before passing to
  /// `Image.memory`.
  // Memoized so repeated access returns the SAME Uint8List instance. Without
  // this, every rebuild (e.g. a 1s countdown tick) hands Image.memory a fresh
  // byte list, forcing a re-decode that visibly flickers the QR. Decode once.
  Uint8List? _decodedBytes;
  bool _didDecode = false;

  Uint8List? get imageBytes {
    if (_didDecode) return _decodedBytes;
    _didDecode = true;
    return _decodedBytes = _decodeImageBytes();
  }

  Uint8List? _decodeImageBytes() {
    final raw = imageDataUri.trim();
    if (raw.isEmpty) {
      debugPrint('[QR][DECODE] imageDataUri is empty — nothing to decode');
      return null;
    }

    final dataUriMatch = _dataUriPattern.firstMatch(raw);
    String base64Payload;
    if (dataUriMatch != null) {
      base64Payload = raw.substring(dataUriMatch.end);
      debugPrint('[QR][DECODE] Data URI detected — mime=${dataUriMatch.group(1)} payloadLength=${base64Payload.length}');
    } else if (raw.startsWith('http://') || raw.startsWith('https://')) {
      debugPrint('[QR][DECODE] imageDataUri is a bare URL, not base64 — cannot decode in-memory: $raw');
      return null;
    } else {
      debugPrint('[QR][DECODE] No data URI prefix found — treating entire string as raw base64 (length=${raw.length})');
      base64Payload = raw;
    }

    // Strip whitespace/newlines that can leak in from server-side chunking.
    base64Payload = base64Payload.replaceAll(RegExp(r'\s'), '');

    try {
      final bytes = base64Decode(base64Payload);
      debugPrint('[QR][DECODE] base64Decode success — ${bytes.length} bytes');
      return bytes;
    } catch (e) {
      final preview = base64Payload.length > 100
          ? base64Payload.substring(0, 100)
          : base64Payload;
      debugPrint('[QR][DECODE] base64Decode FAILED: $e');
      debugPrint('[QR][DECODE] payloadLength=${base64Payload.length} first100Chars="$preview"');
      return null;
    }
  }

  /// True if [imageBytes] looks like SVG markup. `Image.memory` cannot
  /// render SVG — this is the most common cause of "invalid image" QR
  /// failures, since PHP QR packages (e.g. simplesoftwareio/simple-qrcode)
  /// default to SVG output unless explicitly configured for PNG/Imagick.
  bool get isSvgContent {
    final bytes = imageBytes;
    if (bytes == null || bytes.isEmpty) return false;
    final headLength = bytes.length < 200 ? bytes.length : 200;
    final head = String.fromCharCodes(bytes.sublist(0, headLength)).trimLeft().toLowerCase();
    return head.startsWith('<?xml') || head.startsWith('<svg');
  }

  /// True if [imageBytes] starts with a recognized raster-image signature
  /// (PNG/JPEG/GIF/BMP/WebP) that `Image.memory` can decode.
  bool get isRenderableRasterImage {
    final bytes = imageBytes;
    if (bytes == null || bytes.length < 8) return false;
    // PNG: 89 50 4E 47
    if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
      return true;
    }
    // JPEG: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) return true;
    // GIF: 47 49 46
    if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) return true;
    // BMP: 42 4D
    if (bytes[0] == 0x42 && bytes[1] == 0x4D) return true;
    // WebP: "RIFF"...."WEBP"
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46 &&
        bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50) {
      return true;
    }
    return false;
  }

  factory CheckoutQrModel.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image']?.toString() ?? '';
    debugPrint(
      '[QR][PARSE] image field — length=${rawImage.length} '
      'startsWithDataImage=${rawImage.startsWith('data:image')} '
      'startsWithHttp=${rawImage.startsWith('http')} '
      'first100="${rawImage.length > 100 ? rawImage.substring(0, 100) : rawImage}"',
    );

    return CheckoutQrModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      imageDataUri: rawImage,
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
