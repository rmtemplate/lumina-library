import 'package:flutter/material.dart';

enum LuminaProfileRole {
  user,
  staff,
}

class LuminaProfileTypeModel {
  const LuminaProfileTypeModel({
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

class LuminaProfileDataModel {
  const LuminaProfileDataModel({
    required this.id,
    required this.role,
    required this.fullname,
    required this.email,
    required this.avatarUrl,
    required this.profileType,
    this.phone,
    this.memberCode,
    this.institutionName,
    this.majorName,
    this.currentLevel,
    this.staffPosition,
    this.staffLibraryId,
    this.staffLibraryName,
    this.staffLibraryAddress,
    this.staffLibrarySchedule,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.membershipStatus = 'active',
    this.totalBorrowed = 0,
    this.activeBorrowings = 0,
    this.totalReturned = 0,
    this.joinedAt,
  });

  final String id;
  final LuminaProfileRole role;
  final String fullname;
  final String email;
  final String avatarUrl;
  final LuminaProfileTypeModel profileType;

  final String? phone;
  final String? memberCode;
  final String? institutionName;
  final String? majorName;
  final String? currentLevel;

  final String? staffPosition;
  final String? staffLibraryId;
  final String? staffLibraryName;
  final String? staffLibraryAddress;
  final String? staffLibrarySchedule;

  final String? address;
  final DateTime? dateOfBirth;

  /// male | female | other
  final String? gender;

  /// active | inactive | restricted
  final String membershipStatus;

  final int totalBorrowed;
  final int activeBorrowings;
  final int totalReturned;
  final DateTime? joinedAt;

  bool get isStaff => role == LuminaProfileRole.staff;

  bool get hasStaffLibrary {
    return isStaff &&
        staffLibraryName != null &&
        staffLibraryName!.trim().isNotEmpty;
  }

  LuminaProfileDataModel copyWith({
    String? id,
    LuminaProfileRole? role,
    String? fullname,
    String? email,
    String? avatarUrl,
    LuminaProfileTypeModel? profileType,
    String? phone,
    String? memberCode,
    String? institutionName,
    String? majorName,
    String? currentLevel,
    String? staffPosition,
    String? staffLibraryId,
    String? staffLibraryName,
    String? staffLibraryAddress,
    String? staffLibrarySchedule,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
    String? membershipStatus,
    int? totalBorrowed,
    int? activeBorrowings,
    int? totalReturned,
    DateTime? joinedAt,
  }) {
    return LuminaProfileDataModel(
      id: id ?? this.id,
      role: role ?? this.role,
      fullname: fullname ?? this.fullname,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      profileType: profileType ?? this.profileType,
      phone: phone ?? this.phone,
      memberCode: memberCode ?? this.memberCode,
      institutionName: institutionName ?? this.institutionName,
      majorName: majorName ?? this.majorName,
      currentLevel: currentLevel ?? this.currentLevel,
      staffPosition: staffPosition ?? this.staffPosition,
      staffLibraryId: staffLibraryId ?? this.staffLibraryId,
      staffLibraryName: staffLibraryName ?? this.staffLibraryName,
      staffLibraryAddress: staffLibraryAddress ?? this.staffLibraryAddress,
      staffLibrarySchedule: staffLibrarySchedule ?? this.staffLibrarySchedule,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      membershipStatus: membershipStatus ?? this.membershipStatus,
      totalBorrowed: totalBorrowed ?? this.totalBorrowed,
      activeBorrowings: activeBorrowings ?? this.activeBorrowings,
      totalReturned: totalReturned ?? this.totalReturned,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

class LuminaProfileInfoRowModel {
  const LuminaProfileInfoRowModel({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class LuminaProfileStatModel {
  const LuminaProfileStatModel({
    required this.id,
    required this.icon,
    required this.label,
    required this.value,
    required this.backgroundColor,
    required this.iconColor,
    this.valueColor,
  });

  final String id;
  final IconData icon;
  final String label;
  final String value;
  final Color backgroundColor;
  final Color iconColor;
  final Color? valueColor;
}

class LuminaProfileMenuItemModel {
  const LuminaProfileMenuItemModel({
    required this.id,
    required this.icon,
    required this.label,
    this.description,
    this.trailingText,
    this.isDestructive = false,
  });

  final String id;
  final IconData icon;
  final String label;
  final String? description;
  final String? trailingText;
  final bool isDestructive;
}