/// Profil ringkas user untuk top bar home.
/// Diparse dari `GET /api/v1/account/profile` (AccountProfileResource).
class HomeProfileModel {
  const HomeProfileModel({
    required this.id,
    required this.fullname,
    required this.email,
    this.avatarUrl,
    this.memberCode,
  });

  final String id;
  final String fullname;
  final String email;
  final String? avatarUrl;
  final String? memberCode;

  /// Nama depan saja untuk sapaan di top bar.
  String get firstName {
    final trimmed = fullname.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(' ').first;
  }

  factory HomeProfileModel.fromJson(Map<String, dynamic> json) {
    return HomeProfileModel(
      id: json['id'] as String? ?? '',
      fullname: json['fullname'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      memberCode: json['member_code'] as String?,
    );
  }
}
