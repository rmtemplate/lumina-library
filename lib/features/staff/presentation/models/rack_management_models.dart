class BookModel {
  const BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.cover,
    required this.rackId,
    this.catalogCode,
    this.status,
    this.itemCode,
    this.barcode,
  });

  final String id;
  final String title;
  final String author;
  final String cover;
  final String rackId;
  final String? catalogCode;
  final String? status;
  final String? itemCode;
  final String? barcode;

  factory BookModel.fromJson(Map<String, dynamic> json, {String rackId = ''}) {
    final book = json['book'] as Map<String, dynamic>? ?? {};
    return BookModel(
      id: json['id']?.toString() ?? '',
      title: book['title']?.toString() ?? json['title']?.toString() ?? '-',
      author: book['author']?.toString() ?? json['author']?.toString() ?? '-',
      cover: book['cover_url']?.toString() ?? json['cover_url']?.toString() ?? '',
      rackId: rackId,
      catalogCode: book['book_code']?.toString() ?? json['book_code']?.toString(),
      status: json['status']?.toString(),
      itemCode: json['item_code']?.toString(),
      barcode: json['barcode']?.toString(),
    );
  }

  BookModel copyWith({
    String? id,
    String? title,
    String? author,
    String? cover,
    String? rackId,
    String? catalogCode,
    String? status,
    String? itemCode,
    String? barcode,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      cover: cover ?? this.cover,
      rackId: rackId ?? this.rackId,
      catalogCode: catalogCode ?? this.catalogCode,
      status: status ?? this.status,
      itemCode: itemCode ?? this.itemCode,
      barcode: barcode ?? this.barcode,
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
    this.books = const [],
    this.capacity = 100,
    this.isBasement = false,
    this.notes,
    this.apiTotalBooks,
  });

  final String id;
  final String rackCode;
  final String name;
  final String sectionName;
  final String floorLabel;
  final String areaLabel;
  final String aisleCode;
  final List<BookModel> books;
  final int capacity;
  final bool isBasement;
  final String? notes;
  // Populated from list API; overrides books.length when books aren't loaded.
  final int? apiTotalBooks;

  factory RackModel.fromJson(Map<String, dynamic> json) {
    return RackModel(
      id: json['id']?.toString() ?? '',
      rackCode: json['rack_code']?.toString() ?? '',
      name: json['name']?.toString() ?? '-',
      sectionName: json['section_name']?.toString() ?? '',
      floorLabel: json['floor_label']?.toString() ?? '',
      areaLabel: json['area_label']?.toString() ?? '',
      aisleCode: json['aisle_code']?.toString() ?? '',
      capacity: (json['capacity'] as num?)?.toInt() ?? 100,
      isBasement: json['is_basement'] == true || json['is_basement'] == 1,
      notes: json['notes']?.toString(),
      apiTotalBooks: (json['total_books_count'] as num?)?.toInt(),
    );
  }

  static RackModel fromDetailJson(Map<String, dynamic> rack, List<dynamic> rawBooks) {
    final model = RackModel.fromJson(rack);
    final books = rawBooks
        .whereType<Map<String, dynamic>>()
        .map((b) => BookModel.fromJson(b, rackId: model.id))
        .toList();
    return model.copyWith(books: books, apiTotalBooks: books.length);
  }

  int get bookCount => apiTotalBooks ?? books.length;

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
    int? apiTotalBooks,
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
      apiTotalBooks: apiTotalBooks ?? this.apiTotalBooks,
    );
  }
}