/// Full profile shape parsed from `AccountProfileResource` —
/// GET/PUT /api/v1/account/profile, POST/DELETE /api/v1/account/avatar.
/// Unlike [HomeProfileModel] (a lean snapshot for the home top bar), this
/// carries everything the Profile module's view/edit screens need.
class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.fullname,
    required this.email,
    required this.memberCode,
    this.phone,
    this.avatarUrl,
    this.primaryRoleCode,
    this.profileTypeCode,
    this.institutionName,
    this.majorName,
    this.currentLevel,
    this.staffPosition,
    this.staffLibraryName,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.isVerified = false,
    this.isActive = true,
    this.membershipStatus = 'active',
    this.totalBorrowed = 0,
    this.activeBorrowings = 0,
    this.totalReturned = 0,
    this.joinedAt,
  });

  final String id;
  final String fullname;
  final String email;
  final String memberCode;
  final String? phone;
  final String? avatarUrl;

  final String? primaryRoleCode;
  final String? profileTypeCode;

  final String? institutionName;
  final String? majorName;
  final String? currentLevel;
  final String? staffPosition;
  final String? staffLibraryName;

  final String? address;
  final DateTime? dateOfBirth;

  /// male | female | other
  final String? gender;

  final bool isVerified;
  final bool isActive;

  /// active | inactive | restricted — see AccountService::attachComputedFields
  /// on the backend for what "restricted" means (an unpaid no-show fine).
  final String membershipStatus;

  final int totalBorrowed;
  final int activeBorrowings;
  final int totalReturned;

  final DateTime? joinedAt;

  bool get isStaff => primaryRoleCode == 'staff' || primaryRoleCode == 'admin';

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final primaryRole = json['primary_role'] as Map<String, dynamic>?;
    final profileType = json['profile_type'] as Map<String, dynamic>?;
    final staffLibrary = json['staff_library'] as Map<String, dynamic>?;
    final stats = json['stats'] as Map<String, dynamic>? ?? const {};

    return ProfileModel(
      id: json['id']?.toString() ?? '',
      fullname: json['fullname']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      memberCode: json['member_code']?.toString() ?? '',
      phone: json['phone']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      primaryRoleCode: primaryRole?['code']?.toString(),
      profileTypeCode: profileType?['code']?.toString(),
      institutionName: json['institution_name']?.toString(),
      majorName: json['major_name']?.toString(),
      currentLevel: json['current_level']?.toString(),
      staffPosition: json['staff_position']?.toString(),
      staffLibraryName: staffLibrary?['name']?.toString(),
      address: json['address']?.toString(),
      dateOfBirth: _parseDate(json['date_of_birth']),
      gender: json['gender']?.toString(),
      isVerified: json['is_verified'] == true,
      isActive: json['is_active'] == true,
      membershipStatus: json['membership_status']?.toString() ?? 'active',
      totalBorrowed: (stats['total_borrowed'] as num?)?.toInt() ?? 0,
      activeBorrowings: (stats['active_borrowings'] as num?)?.toInt() ?? 0,
      totalReturned: (stats['total_returned'] as num?)?.toInt() ?? 0,
      joinedAt: _parseDate(json['joined_at'] ?? json['created_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString())?.toLocal();
  }
}
