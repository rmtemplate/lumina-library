class LibraryRegisterProfileTypeModel {
  const LibraryRegisterProfileTypeModel({
    required this.id,
    required this.label,
    required this.description,
    required this.institutionLabel,
    required this.majorLabel,
    required this.levelLabel,
    this.showInstitution = true,
    this.showMajor = true,
    this.showLevel = true,
    this.requiresInstitution = false,
    this.requiresMajor = false,
    this.requiresLevel = false,
  });

  final String id;
  final String label;
  final String description;

  final String institutionLabel;
  final String majorLabel;
  final String levelLabel;

  final bool showInstitution;
  final bool showMajor;
  final bool showLevel;

  final bool requiresInstitution;
  final bool requiresMajor;
  final bool requiresLevel;
}

class LibraryRegisterPayload {
  const LibraryRegisterPayload({
    required this.fullname,
    required this.email,
    required this.password,
    required this.profileTypeId,
    required this.profileTypeLabel,
    this.phone,
    this.institutionName,
    this.majorName,
    this.currentLevel,
  });

  final String fullname;
  final String email;
  final String password;
  final String profileTypeId;
  final String profileTypeLabel;
  final String? phone;
  final String? institutionName;
  final String? majorName;
  final String? currentLevel;

  Map<String, dynamic> toJson() {
    return {
      'Fullname': fullname,
      'Email': email,
      'Password': password,
      'Phone': phone,
      'ProfileTypeId': profileTypeId,
      'ProfileTypeLabel': profileTypeLabel,
      'InstitutionName': institutionName,
      'MajorName': majorName,
      'CurrentLevel': currentLevel,
    };
  }
}