import 'package:lumina_library/shared/models/category/category_icon_model.dart';

/// Model kategori buku dari `GET /api/v1/public/categories`.
/// Field: id, code, name, slug, description, icon, display.sort_order
class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.code,
    required this.name,
    required this.slug,
    this.description,
    this.icon,
    this.sortOrder = 0,
  });

  final String id;
  final String code;
  final String name;
  final String slug;
  final String? description;
  final CategoryIconModel? icon;
  final int sortOrder;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final iconJson = json['icon'] as Map<String, dynamic>?;
    final displayJson = json['display'] as Map<String, dynamic>?;

    return CategoryModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      icon: iconJson != null ? CategoryIconModel.fromJson(iconJson) : null,
      sortOrder: (displayJson?['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  static List<CategoryModel> listFromJson(List<dynamic> list) => (list
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList())
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
}
