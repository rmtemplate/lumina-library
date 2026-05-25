class LibraryCartBook {
  const LibraryCartBook({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.isAvailable,
    required this.libraryId,
    required this.libraryName,
    this.statusLabel = 'Tersedia',
    this.libraryAddress,
    this.libraryImageUrl,
    this.libraryDistanceText,
    this.libraryDurationText,
    this.libraryScheduleText,
    this.libraryLatitude,
    this.libraryLongitude,
  });

  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final bool isAvailable;
  final String statusLabel;

  /// ID perpustakaan/cabang asal buku.
  ///
  /// Dipakai agar cart bisa berisi banyak perpustakaan,
  /// tetapi checkout hanya boleh dari satu perpustakaan.
  final String libraryId;

  /// Nama perpustakaan/cabang asal buku.
  final String libraryName;

  /// Optional metadata perpustakaan.
  /// Berguna jika nanti dari cart/checkout ingin menampilkan detail lokasi.
  final String? libraryAddress;
  final String? libraryImageUrl;
  final String? libraryDistanceText;
  final String? libraryDurationText;
  final String? libraryScheduleText;
  final double? libraryLatitude;
  final double? libraryLongitude;

  bool get isUnavailable => !isAvailable;

  String get displayStatusLabel {
    if (statusLabel.trim().isNotEmpty) {
      return statusLabel;
    }

    return isAvailable ? 'Tersedia' : 'Tidak Tersedia';
  }

  LibraryCartBook copyWith({
    String? id,
    String? title,
    String? author,
    String? imageUrl,
    bool? isAvailable,
    String? statusLabel,
    String? libraryId,
    String? libraryName,
    String? libraryAddress,
    String? libraryImageUrl,
    String? libraryDistanceText,
    String? libraryDurationText,
    String? libraryScheduleText,
    double? libraryLatitude,
    double? libraryLongitude,
  }) {
    return LibraryCartBook(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      statusLabel: statusLabel ?? this.statusLabel,
      libraryId: libraryId ?? this.libraryId,
      libraryName: libraryName ?? this.libraryName,
      libraryAddress: libraryAddress ?? this.libraryAddress,
      libraryImageUrl: libraryImageUrl ?? this.libraryImageUrl,
      libraryDistanceText: libraryDistanceText ?? this.libraryDistanceText,
      libraryDurationText: libraryDurationText ?? this.libraryDurationText,
      libraryScheduleText: libraryScheduleText ?? this.libraryScheduleText,
      libraryLatitude: libraryLatitude ?? this.libraryLatitude,
      libraryLongitude: libraryLongitude ?? this.libraryLongitude,
    );
  }

  factory LibraryCartBook.fromJson(Map<String, dynamic> json) {
    return LibraryCartBook(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      isAvailable: json['isAvailable'] == true,
      statusLabel: json['statusLabel']?.toString() ?? 'Tersedia',
      libraryId: json['libraryId']?.toString() ?? '',
      libraryName: json['libraryName']?.toString() ?? '',
      libraryAddress: json['libraryAddress']?.toString(),
      libraryImageUrl: json['libraryImageUrl']?.toString(),
      libraryDistanceText: json['libraryDistanceText']?.toString(),
      libraryDurationText: json['libraryDurationText']?.toString(),
      libraryScheduleText: json['libraryScheduleText']?.toString(),
      libraryLatitude: _parseDouble(json['libraryLatitude']),
      libraryLongitude: _parseDouble(json['libraryLongitude']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'statusLabel': statusLabel,
      'libraryId': libraryId,
      'libraryName': libraryName,
      'libraryAddress': libraryAddress,
      'libraryImageUrl': libraryImageUrl,
      'libraryDistanceText': libraryDistanceText,
      'libraryDurationText': libraryDurationText,
      'libraryScheduleText': libraryScheduleText,
      'libraryLatitude': libraryLatitude,
      'libraryLongitude': libraryLongitude,
    };
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) return value;
    if (value is int) return value.toDouble();

    return double.tryParse(value.toString());
  }
}