import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/core/routing/lumina_role_router.dart';
import 'package:lumina_library/core/services/lumina_storage_service.dart';
import 'package:lumina_library/core/services/websocket/websocket_service.dart';
import 'package:lumina_library/features/auth/data/services/auth_api_service.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/home/library_home_controller.dart';
import 'package:lumina_library/features/profile/data/services/profile_api_service.dart';
import 'package:lumina_library/features/profile/presentasion/pages/about_page.dart';
import 'package:lumina_library/features/profile/presentasion/pages/change_password_page.dart';
import 'package:lumina_library/features/profile/presentasion/pages/edit_profile_page.dart';
import 'package:lumina_library/features/profile/presentasion/pages/payment_history_page.dart';
import 'package:lumina_library/shared/models/profile/profile_model.dart';
import '../../core/theme/lumina_colors.dart';
import '../models/profile/lumina_profile_models.dart';
import '../widgets/feedback/lumina_toast.dart';

class LuminaProfileController extends GetxController {
  LuminaProfileController({
    required this.role,
  });

  final LuminaProfileRole role;

  static const String userAvatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBvUfI0qnCR0Mqxq5OZ1UI-AKMt4ELnsfDVWA8DmzZgHBmANY-xDLsZpbv1OvvLuG8Indk0dXvCyW-JpSN85Y3AbQudS-3q1Qr2ZoOhPP93jXO3yaIM99_QLoM1LmQhpmry2TZCl0_reyaifv607bFXOCfTwCqytUn0rd1phuWfpZhBNg16w6tqc1-6BMFhZPG8RoSfoZC6XIhx_DqZYAJA8v6Qd_Hf-TBMLQWEMsISywvBSI7K9nd6zYQ5N4q90rt83KJAUUYJOa4P';

  static const String staffAvatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBErNDUhVIPTqmPjcyS1_K6AwClAa2j9oVkgIH9tJNHXdOtTGuHfDDrDK0YXw9GzcJg1OE5wjvw7PGOPhw2Rlz5HX4m5b7Xgr-2q-I8FlCxuoqbk6bNlGUh7jHJneSGfghQLvkY6lxIOUWIvubuo4GIsfHWb_nkCJrCYOlF-A4Vnr_BP4KCsRbkBxsJ6OuFPaODjJR7ZBKcxZzSD5GYFw26vBguz-msysHR_GSXPfTXUdaqur78_nwxKVxgnGKPufaD412b8zL-WBrU';

  static const LuminaProfileTypeModel mahasiswaProfileType =
      LuminaProfileTypeModel(
    id: 'mahasiswa',
    label: 'Mahasiswa',
    description: 'Mahasiswa aktif perguruan tinggi.',
    institutionLabel: 'Nama Kampus',
    majorLabel: 'Program Studi / Jurusan',
    levelLabel: 'Semester',
    showInstitution: true,
    showMajor: true,
    showLevel: true,
    requiresInstitution: true,
    requiresMajor: true,
    requiresLevel: true,
  );

  static const LuminaProfileTypeModel staffProfileType =
      LuminaProfileTypeModel(
    id: 'staff',
    label: 'Staff / Petugas',
    description: 'Petugas perpustakaan yang mengelola layanan operasional.',
    institutionLabel: 'Instansi',
    majorLabel: 'Divisi / Bagian',
    levelLabel: 'Jabatan',
    showInstitution: true,
    showMajor: true,
    showLevel: true,
  );

  static const LuminaProfileDataModel _dummyUserProfile =
      LuminaProfileDataModel(
    id: 'user-001',
    role: LuminaProfileRole.user,
    fullname: 'Budi Santoso',
    email: 'budi.santoso@student.ac.id',
    phone: '081234567890',
    memberCode: '20210045678',
    avatarUrl: userAvatarUrl,
    profileType: mahasiswaProfileType,
    institutionName: 'Universitas Lumina',
    majorName: 'Teknik Informatika',
    currentLevel: 'Semester 6',
  );

  static const LuminaProfileDataModel _dummyStaffProfile =
      LuminaProfileDataModel(
    id: 'staff-001',
    role: LuminaProfileRole.staff,
    fullname: 'Sarah Jenkins',
    email: 'sarah.jenkins@lumina.ac.id',
    phone: '081298765432',
    memberCode: 'STF-88291',
    avatarUrl: staffAvatarUrl,
    profileType: staffProfileType,
    institutionName: 'Lumina Library',
    majorName: 'Library Operations',
    currentLevel: 'Senior Librarian',
    staffPosition: 'Senior Librarian',
    staffLibraryId: 'lib-central',
    staffLibraryName: 'Central Library - Academic Wing',
    staffLibraryAddress: 'Academic Wing, Main Campus',
    staffLibrarySchedule: 'Senin - Jumat, 08.00 - 20.00',
  );

  final Rx<LuminaProfileDataModel> profile = _dummyUserProfile.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxBool isUploadingPhoto = false.obs;

  /// Optimistic local file — set immediately after crop so the avatar shows
  /// the new photo before the network URL is available (storage symlink may
  /// not exist in dev). Cleared only on upload failure so it serves as a
  /// fallback if the network URL never loads.
  final Rx<File?> pendingAvatarFile = Rx<File?>(null);

  ProfileApiService get _service => Get.find<ProfileApiService>();

  @override
  void onInit() {
    super.onInit();
    profile.value = role == LuminaProfileRole.staff
        ? _dummyStaffProfile
        : _dummyUserProfile;
    _loadProfileFromApi();
  }

  Future<void> _loadProfileFromApi() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final apiProfile = await _service.getProfile();
      profile.value = _mergeApiProfile(profile.value, apiProfile);
    } catch (_) {
      // Tetap tampilkan data dummy sebagai fallback, tapi tandai error agar
      // UI bisa menawarkan tombol retry alih-alih diam-diam pakai data palsu.
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProfile() => _loadProfileFromApi();

  LuminaProfileDataModel _mergeApiProfile(LuminaProfileDataModel current, ProfileModel api) {
    return current.copyWith(
      id: api.id.isNotEmpty ? api.id : null,
      fullname: api.fullname.isNotEmpty ? api.fullname : null,
      email: api.email.isNotEmpty ? api.email : null,
      avatarUrl: api.avatarUrl,
      memberCode: api.memberCode,
      phone: api.phone,
      institutionName: api.institutionName,
      majorName: api.majorName,
      currentLevel: api.currentLevel,
      staffPosition: api.staffPosition,
      staffLibraryName: api.staffLibraryName,
      address: api.address,
      dateOfBirth: api.dateOfBirth,
      gender: api.gender,
      membershipStatus: api.membershipStatus,
      totalBorrowed: api.totalBorrowed,
      activeBorrowings: api.activeBorrowings,
      totalReturned: api.totalReturned,
      joinedAt: api.joinedAt,
    );
  }

  bool get isStaff => profile.value.role == LuminaProfileRole.staff;

  String get profileTitle => isStaff ? 'Profile' : 'Profil';

  String get profileSubtitle {
    if (isStaff) {
      return profile.value.staffPosition ?? 'Staff / Petugas';
    }

    return profile.value.profileType.label;
  }

  List<LuminaProfileInfoRowModel> get infoRows {
    final currentProfile = profile.value;
    final profileType = currentProfile.profileType;

    final rows = <LuminaProfileInfoRowModel>[
      LuminaProfileInfoRowModel(
        icon: Icons.badge_outlined,
        label: isStaff ? 'Employee ID' : 'Student ID (NIM)',
        value: currentProfile.memberCode?.trim().isNotEmpty == true ? currentProfile.memberCode! : '-',
      ),
      LuminaProfileInfoRowModel(
        icon: Icons.email_outlined,
        label: 'Email',
        value: currentProfile.email,
      ),
    ];

    if (currentProfile.phone != null &&
        currentProfile.phone!.trim().isNotEmpty) {
      rows.add(
        LuminaProfileInfoRowModel(
          icon: Icons.phone_outlined,
          label: 'Nomor Telepon',
          value: currentProfile.phone!,
        ),
      );
    }

    if (profileType.showInstitution &&
        currentProfile.institutionName != null &&
        currentProfile.institutionName!.trim().isNotEmpty) {
      rows.add(
        LuminaProfileInfoRowModel(
          icon: Icons.account_balance_outlined,
          label: profileType.institutionLabel,
          value: currentProfile.institutionName!,
        ),
      );
    }

    if (profileType.showMajor &&
        currentProfile.majorName != null &&
        currentProfile.majorName!.trim().isNotEmpty) {
      rows.add(
        LuminaProfileInfoRowModel(
          icon: Icons.work_outline_rounded,
          label: profileType.majorLabel,
          value: currentProfile.majorName!,
        ),
      );
    }

    if (profileType.showLevel &&
        currentProfile.currentLevel != null &&
        currentProfile.currentLevel!.trim().isNotEmpty) {
      rows.add(
        LuminaProfileInfoRowModel(
          icon: Icons.badge_outlined,
          label: profileType.levelLabel,
          value: currentProfile.currentLevel!,
        ),
      );
    }

    if (currentProfile.address != null && currentProfile.address!.trim().isNotEmpty) {
      rows.add(
        LuminaProfileInfoRowModel(
          icon: Icons.home_outlined,
          label: 'Alamat',
          value: currentProfile.address!,
        ),
      );
    }

    if (currentProfile.dateOfBirth != null) {
      final dob = currentProfile.dateOfBirth!;
      rows.add(
        LuminaProfileInfoRowModel(
          icon: Icons.cake_outlined,
          label: 'Tanggal Lahir',
          value: '${dob.day.toString().padLeft(2, '0')}/${dob.month.toString().padLeft(2, '0')}/${dob.year}',
        ),
      );
    }

    if (currentProfile.gender != null && currentProfile.gender!.trim().isNotEmpty) {
      rows.add(
        LuminaProfileInfoRowModel(
          icon: Icons.wc_outlined,
          label: 'Jenis Kelamin',
          value: switch (currentProfile.gender) {
            'male' => 'Laki-laki',
            'female' => 'Perempuan',
            _ => 'Lainnya',
          },
        ),
      );
    }

    rows.add(
      LuminaProfileInfoRowModel(
        icon: Icons.verified_user_outlined,
        label: 'Membership Status',
        value: switch (currentProfile.membershipStatus) {
          'inactive' => 'Tidak Aktif',
          'restricted' => 'Dibatasi',
          _ => 'Aktif',
        },
      ),
    );

    if (currentProfile.joinedAt != null) {
      final joined = currentProfile.joinedAt!;
      rows.add(
        LuminaProfileInfoRowModel(
          icon: Icons.calendar_today_outlined,
          label: 'Bergabung Sejak',
          value: '${joined.day.toString().padLeft(2, '0')}/${joined.month.toString().padLeft(2, '0')}/${joined.year}',
        ),
      );
    }

    return rows;
  }

  List<LuminaProfileStatModel> get stats {
    if (isStaff) {
      return [
        LuminaProfileStatModel(
          id: 'scan_today',
          icon: Icons.qr_code_scanner_rounded,
          label: 'Scan Hari Ini',
          value: '18',
          backgroundColor: LuminaColors.primary.withOpacity(0.10),
          iconColor: LuminaColors.primary,
          valueColor: LuminaColors.primary,
        ),
        LuminaProfileStatModel(
          id: 'active_borrowing',
          icon: Icons.book_online_rounded,
          label: 'Pinjaman Aktif',
          value: '126',
          backgroundColor: LuminaColors.secondary.withOpacity(0.12),
          iconColor: LuminaColors.secondary,
          valueColor: LuminaColors.primary,
        ),
        LuminaProfileStatModel(
          id: 'pending_return',
          icon: Icons.assignment_return_rounded,
          label: 'Perlu Dicek',
          value: '7',
          backgroundColor: LuminaColors.error.withOpacity(0.10),
          iconColor: LuminaColors.error,
          valueColor: LuminaColors.error,
        ),
      ];
    }

    final currentProfile = profile.value;

    return [
      LuminaProfileStatModel(
        id: 'total_borrowed',
        icon: Icons.menu_book_rounded,
        label: 'Total Borrowed',
        value: '${currentProfile.totalBorrowed}',
        backgroundColor: LuminaColors.primary.withOpacity(0.10),
        iconColor: LuminaColors.primary,
        valueColor: LuminaColors.primary,
      ),
      LuminaProfileStatModel(
        id: 'active_borrowings',
        icon: Icons.book_online_rounded,
        label: 'Active Borrowings',
        value: '${currentProfile.activeBorrowings}',
        backgroundColor: LuminaColors.secondary.withOpacity(0.12),
        iconColor: LuminaColors.secondary,
        valueColor: LuminaColors.primary,
      ),
      LuminaProfileStatModel(
        id: 'total_returned',
        icon: Icons.assignment_turned_in_rounded,
        label: 'Total Returned',
        value: '${currentProfile.totalReturned}',
        backgroundColor: LuminaColors.secondary.withOpacity(0.10),
        iconColor: LuminaColors.secondary,
        valueColor: LuminaColors.secondary,
      ),
    ];
  }

  void openSettings() {
    LuminaToast.info('Halaman pengaturan belum tersedia.');
  }

  // ── Edit Profile Photo ───────────────────────────────────────────────────

  /// Camera/Gallery picker → crop (square, compressed) → preview confirm →
  /// upload. Each step can be cancelled by the user with no side effects.
  Future<void> editProfilePhoto() async {
    final source = await _pickImageSource();
    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 2000,
      maxHeight: 2000,
    );
    if (picked == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      maxWidth: 1024,
      maxHeight: 1024,
      compressQuality: 85,
      compressFormat: ImageCompressFormat.jpg,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Sesuaikan Foto',
          toolbarColor: LuminaColors.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          cropFrameColor: LuminaColors.primary,
          cropGridColor: LuminaColors.primary.withOpacity(0.4),
        ),
        IOSUiSettings(
          title: 'Sesuaikan Foto',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );
    if (cropped == null) return;

    final confirmed = await _confirmPhotoPreview(File(cropped.path));
    if (confirmed != true) return;

    await _uploadAvatar(File(cropped.path));
  }

  Future<ImageSource?> _pickImageSource() {
    return Get.bottomSheet<ImageSource>(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        decoration: const BoxDecoration(
          color: LuminaColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: LuminaColors.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Ubah Foto Profil',
                style: TextStyle(color: LuminaColors.primary, fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              _PhotoSourceTile(
                icon: Icons.camera_alt_rounded,
                label: 'Ambil Foto (Kamera)',
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              const SizedBox(height: 8),
              _PhotoSourceTile(
                icon: Icons.photo_library_rounded,
                label: 'Pilih dari Galeri',
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<bool?> _confirmPhotoPreview(File file) {
    return Get.dialog<bool>(
      Dialog(
        backgroundColor: LuminaColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Preview Foto Profil',
                style: TextStyle(color: LuminaColors.primary, fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              ClipOval(
                child: Image.file(file, width: 160, height: 160, fit: BoxFit.cover),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LuminaColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _uploadAvatar(File file) async {
    isUploadingPhoto.value = true;
    pendingAvatarFile.value = file; // show new photo immediately (optimistic)
    try {
      final updated = await _service.updateAvatar(file);
      profile.value = _mergeApiProfile(profile.value, updated);
      // Keep pendingAvatarFile set — serves as fallback if the network URL
      // fails to load (e.g. storage symlink missing in dev environment).
      LuminaToast.success('Foto profil berhasil diperbarui.');
    } on LuminaApiException catch (e) {
      pendingAvatarFile.value = null; // revert: upload failed
      LuminaToast.error(e.displayMessage);
    } catch (_) {
      pendingAvatarFile.value = null; // revert: upload failed
      LuminaToast.error('Gagal memperbarui foto profil. Silakan coba lagi.');
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  // ── Edit Profile ─────────────────────────────────────────────────────────

  Future<void> updateProfile({
    String? fullname,
    String? phone,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
  }) async {
    final updated = await _service.updateProfile(
      fullname: fullname,
      phone: phone,
      address: address,
      dateOfBirth: dateOfBirth,
      gender: gender,
    );
    profile.value = _mergeApiProfile(profile.value, updated);
  }

  // ── Menu ─────────────────────────────────────────────────────────────────

  void handleMenuTap(LuminaProfileMenuItemModel item) {
    switch (item.id) {
      case 'update_profile_photo':
        editProfilePhoto();
        return;
      case 'edit_profile':
      case 'personal_information':
        Get.to(() => EditProfilePage(controller: this));
        return;
      case 'change_password':
        Get.to(() => const ChangePasswordPage());
        return;
      case 'borrowing_history':
        if (Get.isRegistered<LibraryHomeController>()) {
          Get.find<LibraryHomeController>().changeNavIndex(2);
        }
        return;
      case 'payment_history':
        Get.to(() => const PaymentHistoryPage());
        return;
      case 'about':
        Get.to(() => const AboutPage());
        return;
      case 'logout':
        _confirmLogout();
        return;
      default:
        LuminaToast.info(item.description ?? 'Menu ${item.label} belum tersedia.');
    }
  }

  void _confirmLogout() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: const BoxDecoration(
          color: LuminaColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: LuminaColors.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: LuminaColors.error.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: LuminaColors.error,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Keluar dari akun?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: LuminaColors.primary,
                  fontSize: 20,
                  height: 1.4,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Anda perlu login kembali untuk mengakses Lumina Library.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: LuminaColors.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: Get.back,
                        child: const Text('Batal'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _executeLogout,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: LuminaColors.error,
                          foregroundColor: LuminaColors.onError,
                        ),
                        child: const Text('Keluar'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _executeLogout() async {
    Get.back(); // tutup bottom sheet

    try {
      // Fire-and-forget: tidak perlu menunggu API logout selesai.
      // Token sudah dihapus dari storage sehingga request berikutnya akan gagal.
      Get.find<AuthApiService>().logout().ignore();
    } catch (_) {
      // Abaikan error jaringan saat logout.
    }

    LuminaStorageService.clearSession();
    Get.find<WebSocketService>().disconnect();
    LuminaRoleRouter.goToLogin();
  }
}

class _PhotoSourceTile extends StatelessWidget {
  const _PhotoSourceTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LuminaColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: LuminaColors.primary, size: 22),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(color: LuminaColors.onSurface, fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
