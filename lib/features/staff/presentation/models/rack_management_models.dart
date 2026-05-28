class BookModel {
  const BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.cover,
    required this.rackId,
    this.catalogCode,
  });

  final String id;
  final String title;
  final String author;
  final String cover;
  final String rackId;
  final String? catalogCode;

  BookModel copyWith({
    String? id,
    String? title,
    String? author,
    String? cover,
    String? rackId,
    String? catalogCode,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      cover: cover ?? this.cover,
      rackId: rackId ?? this.rackId,
      catalogCode: catalogCode ?? this.catalogCode,
    );
  }
}

class RackModel {
  const RackModel({
    required this.id,
    required this.rackCode,
    required this.name,
    required this.sectionName,
    required this.floorLabel,
    required this.areaLabel,
    required this.aisleCode,
    required this.books,
    this.capacity = 100,
    this.isBasement = false,
    this.notes,
  });

  final String id;

  /// Contoh:
  /// 1RN002, B1-TEC-004, 2HIS011
  final String rackCode;

  final String name;
  final String sectionName;

  /// Contoh:
  /// Lantai 1, Lantai 2, Basement B1
  final String floorLabel;

  /// Contoh:
  /// Area Novel, Academic Wing, Technology Zone
  final String areaLabel;

  /// Contoh:
  /// Lorong N-02, Aisle T-04
  final String aisleCode;

  final List<BookModel> books;
  final int capacity;
  final bool isBasement;
  final String? notes;

  int get bookCount => books.length;

  bool get isFull => capacity > 0 && bookCount >= capacity;

  int get availableSlot {
    final value = capacity - bookCount;
    return value < 0 ? 0 : value;
  }

  double get capacityPercentage {
    if (capacity <= 0) return 0;

    final value = bookCount / capacity;
    return value > 1 ? 1 : value;
  }

  String get locationText {
    return '$floorLabel • $areaLabel • $aisleCode';
  }

  String get capacityText {
    if (isFull) return 'Rak penuh';

    return '$availableSlot slot tersedia';
  }

  List<String> get previewCovers {
    return books.take(3).map((item) => item.cover).toList(growable: false);
  }

  bool matchesKeyword(String keyword) {
    final normalizedKeyword = keyword.trim().toLowerCase();

    if (normalizedKeyword.isEmpty) return true;

    final searchableText = [
      rackCode,
      name,
      sectionName,
      floorLabel,
      areaLabel,
      aisleCode,
      locationText,
      notes ?? '',
    ].join(' ').toLowerCase();

    return searchableText.contains(normalizedKeyword);
  }

  RackModel copyWith({
    String? id,
    String? rackCode,
    String? name,
    String? sectionName,
    String? floorLabel,
    String? areaLabel,
    String? aisleCode,
    List<BookModel>? books,
    int? capacity,
    bool? isBasement,
    String? notes,
  }) {
    return RackModel(
      id: id ?? this.id,
      rackCode: rackCode ?? this.rackCode,
      name: name ?? this.name,
      sectionName: sectionName ?? this.sectionName,
      floorLabel: floorLabel ?? this.floorLabel,
      areaLabel: areaLabel ?? this.areaLabel,
      aisleCode: aisleCode ?? this.aisleCode,
      books: books ?? this.books,
      capacity: capacity ?? this.capacity,
      isBasement: isBasement ?? this.isBasement,
      notes: notes ?? this.notes,
    );
  }
}