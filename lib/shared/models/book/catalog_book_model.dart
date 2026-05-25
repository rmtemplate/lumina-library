class CatalogBookModel {
  const CatalogBookModel({
    required this.title,
    required this.author,
    required this.rating,
    required this.isAvailable,
    required this.imageUrl,
    required this.category,
    required this.libraryName,
    required this.libraryDistanceKm,
    required this.publishedYear,
    this.borrowCount = 0,
  });

  final String title;
  final String author;
  final String rating;
  final bool isAvailable;
  final String imageUrl;

  final String category;
  final String libraryName;
  final double libraryDistanceKm;
  final int publishedYear;
  final int borrowCount;

  String get libraryLocationLabel {
    final distanceText = libraryDistanceKm < 1
        ? '${(libraryDistanceKm * 1000).round()} m'
        : '${libraryDistanceKm.toStringAsFixed(1)} km';

    return '$libraryName • $distanceText';
  }
}