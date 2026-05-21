class LibraryCartBook {
  const LibraryCartBook({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.isAvailable,
    this.statusLabel = 'Tersedia',
  });

  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final bool isAvailable;
  final String statusLabel;

  LibraryCartBook copyWith({
    String? id,
    String? title,
    String? author,
    String? imageUrl,
    bool? isAvailable,
    String? statusLabel,
  }) {
    return LibraryCartBook(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      statusLabel: statusLabel ?? this.statusLabel,
    );
  }
}
