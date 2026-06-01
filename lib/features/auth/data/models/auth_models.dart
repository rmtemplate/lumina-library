/// Model untuk data user yang dikembalikan backend setelah login / GET /auth/me.
class AuthUserModel {
  const AuthUserModel({
    required this.id,
    required this.fullname,
    required this.email,
    required this.roles,
    required this.isStaff,
    required this.isMember,
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
  final List<String> roles;
  final bool isStaff;
  final bool isMember;

  /// Parsing dari response login: `data.user`
  factory AuthUserModel.fromLoginJson(Map<String, dynamic> json) {
    final rawRoles = json['roles'];
    final roles = rawRoles is List ? rawRoles.cast<String>() : <String>[];

    return AuthUserModel(
      id: json['id'] as String? ?? '',
      fullname: json['fullname'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      memberCode: json['member_code'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      roles: roles,
      isStaff: json['is_staff'] as bool? ?? false,
      isMember: json['is_member'] as bool? ?? true,
    );
  }

  /// Parsing dari response GET /auth/me: `data.roles` (array of code strings).
  factory AuthUserModel.fromMeJson(Map<String, dynamic> userJson, List<String> roleCodes) {
    final isStaff = roleCodes.contains('staff');

    return AuthUserModel(
      id: userJson['id'] as String? ?? '',
      fullname: userJson['fullname'] as String? ?? '',
      email: userJson['email'] as String? ?? '',
      phone: userJson['phone'] as String?,
      memberCode: userJson['member_code'] as String?,
      avatarUrl: userJson['avatar_url'] as String?,
      roles: roleCodes,
      isStaff: isStaff,
      isMember: roleCodes.contains('member'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullname': fullname,
        'email': email,
        'phone': phone,
        'member_code': memberCode,
        'avatar_url': avatarUrl,
        'roles': roles,
        'is_staff': isStaff,
        'is_member': isMember,
      };

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['roles'];
    final roles = rawRoles is List ? rawRoles.cast<String>() : <String>[];

    return AuthUserModel(
      id: json['id'] as String? ?? '',
      fullname: json['fullname'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      memberCode: json['member_code'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      roles: roles,
      isStaff: json['is_staff'] as bool? ?? false,
      isMember: json['is_member'] as bool? ?? true,
    );
  }
}

/// Model untuk response login.
class LoginResponseModel {
  const LoginResponseModel({
    required this.token,
    required this.user,
  });

  final String token;
  final AuthUserModel user;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'] as String? ?? '',
      user: AuthUserModel.fromLoginJson(
        json['user'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

/// Model untuk response register.
class RegisterResponseModel {
  const RegisterResponseModel({
    required this.requiresEmailVerification,
    required this.verificationSent,
    required this.verificationExpiresInMinutes,
  });

  final bool requiresEmailVerification;
  final bool verificationSent;
  final int verificationExpiresInMinutes;

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      requiresEmailVerification: json['requires_email_verification'] as bool? ?? true,
      verificationSent: json['verification_sent'] as bool? ?? false,
      verificationExpiresInMinutes:
          json['verification_expires_in_minutes'] as int? ?? 60,
    );
  }
}
