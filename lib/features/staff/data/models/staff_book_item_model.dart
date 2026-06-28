/// A single physical copy (BookItem) as returned by /staff/books/search and
/// the universal scan endpoint's `book_intake` data block.
class StaffBookItemModel {
  const StaffBookItemModel({
    required this.id,
    required this.itemCode,
    required this.barcode,
    required this.bookTitle,
    required this.bookAuthor,
    this.isbn,
    this.coverUrl,
    this.category,
    this.rackName,
  });

  final String id;
  final String itemCode;
  final String barcode;
  final String bookTitle;
  final String bookAuthor;
  final String? isbn;
  final String? coverUrl;
  final String? category;
  final String? rackName;

  /// Parses the /staff/books/search row shape:
  /// { id, item_code, barcode, book: {title, author, isbn, cover_url, category}, rack: {name} }
  factory StaffBookItemModel.fromSearchJson(Map<String, dynamic> json) {
    final book = json['book'] as Map<String, dynamic>? ?? {};
    final rack = json['rack'] as Map<String, dynamic>?;

    return StaffBookItemModel(
      id: json['id']?.toString() ?? '',
      itemCode: json['item_code']?.toString() ?? '',
      barcode: json['barcode']?.toString() ?? '',
      bookTitle: book['title']?.toString() ?? 'Buku',
      bookAuthor: book['author']?.toString() ?? '-',
      isbn: book['isbn']?.toString(),
      coverUrl: book['cover_url']?.toString(),
      category: book['category']?.toString(),
      rackName: rack?['name']?.toString(),
    );
  }

  /// Parses the universal-scan `book_intake` data shape — the outer `data`
  /// block IS the raw StaffQrScanService::scanBook() result:
  /// { scan_type: 'book_item', data: { book_item: {...}, book: {...}, rack: {...} } }
  /// (StaffBookScanResource on the backend).
  factory StaffBookItemModel.fromScanJson(Map<String, dynamic> scanData) {
    final inner = scanData['data'] as Map<String, dynamic>? ?? {};
    final bookItem = inner['book_item'] as Map<String, dynamic>? ?? {};
    final book = inner['book'] as Map<String, dynamic>? ?? {};
    final rack = inner['rack'] as Map<String, dynamic>?;
    final category = book['category'] as Map<String, dynamic>?;

    return StaffBookItemModel(
      id: bookItem['id']?.toString() ?? '',
      itemCode: bookItem['item_code']?.toString() ?? '',
      barcode: bookItem['barcode']?.toString() ?? '',
      bookTitle: book['title']?.toString() ?? 'Buku',
      bookAuthor: book['author']?.toString() ?? '-',
      isbn: book['isbn']?.toString(),
      coverUrl: book['cover_url']?.toString(),
      category: category?['name']?.toString(),
      rackName: rack?['name']?.toString(),
    );
  }
}
