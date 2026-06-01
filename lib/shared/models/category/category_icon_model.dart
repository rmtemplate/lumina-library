/// Icon metadata untuk kategori.
/// Field: name (Material icon name), image_url, is_external
class CategoryIconModel {
  const CategoryIconModel({
    this.name,
    this.imageUrl,
    this.isExternal = false,
  });

  /// Nama Material icon, e.g. "auto_stories", "computer"
  final String? name;

  /// URL gambar eksternal (lebih diutamakan dari [name])
  final String? imageUrl;
  final bool isExternal;

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  factory CategoryIconModel.fromJson(Map<String, dynamic> json) {
    return CategoryIconModel(
      name: json['name'] as String?,
      imageUrl: json['image_url'] as String?,
      isExternal: json['is_external'] as bool? ?? false,
    );
  }
}
