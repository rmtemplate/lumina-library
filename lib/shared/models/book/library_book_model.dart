class LibraryBookModel {
  const LibraryBookModel({
    required this.title,
    required this.author,
    required this.rating,
    required this.imageUrl,
    required this.isAvailable,
    required this.stockText,
  });

  final String title;
  final String author;
  final String rating;
  final String imageUrl;
  final bool isAvailable;
  final String stockText;
}
