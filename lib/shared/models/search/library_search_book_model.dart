class LibrarySearchBook {
  const LibrarySearchBook({
    required this.title,
    required this.author,
    required this.rating,
    required this.imageUrl,
    required this.isAvailable,
    this.libraryIds = const [],
  });

  final String title;
  final String author;
  final String rating;
  final String imageUrl;
  final bool isAvailable;

  /// ID perpustakaan/cabang yang menyimpan buku ini.
  ///
  /// Contoh:
  /// - lib-central
  /// - lib-tech
  /// - lib-journal
  final List<String> libraryIds;

  bool isAvailableInLibrary(String libraryId) {
    return libraryIds.contains(libraryId);
  }
}
