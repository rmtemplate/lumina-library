import 'package:lumina_library/shared/models/banner/library_banner_model.dart';

/// Model API untuk banner dari `GET /api/v1/public/banners`.
/// Response field: id, title, subtitle, image, action_url
class BannerModel {
  const BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.actionUrl,
  });

  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? actionUrl;

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      imageUrl: json['image'] as String?,
      actionUrl: json['action_url'] as String?,
    );
  }

  static List<BannerModel> listFromJson(List<dynamic> list) =>
      list.map((e) => BannerModel.fromJson(e as Map<String, dynamic>)).toList();

  /// Konversi ke `LibraryBannerData` yang digunakan widget carousel existing.
  LibraryBannerData toLibraryBannerData() => LibraryBannerData(
        title: title,
        subtitle: subtitle,
        imageUrl: imageUrl,
      );
}
