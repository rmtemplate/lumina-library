/// Member shape returned by /staff/members/search, /staff/members/lookup,
/// and as the `member` block inside borrowing detail resources.
class StaffMemberModel {
  const StaffMemberModel({
    required this.id,
    required this.fullname,
    required this.email,
    this.phone,
    this.memberCode,
    this.avatarUrl,
  });

  final String id;
  final String fullname;
  final String email;
  final String? phone;
  final String? memberCode;
  final String? avatarUrl;

  factory StaffMemberModel.fromJson(Map<String, dynamic> json) {
    return StaffMemberModel(
      id: json['id']?.toString() ?? '',
      fullname: json['fullname']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      memberCode: json['member_code']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
    );
  }
}
