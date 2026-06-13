import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/core/routing/lumina_role_router.dart';
import 'package:lumina_library/core/services/lumina_storage_service.dart';
import 'package:lumina_library/features/auth/data/services/auth_api_service.dart';
import 'package:lumina_library/features/mahasiswa/data/services/home_api_service.dart';
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

  @override
  void onInit() {
    super.onInit();
    profile.value = role == LuminaProfileRole.staff
        ? _dummyStaffProfile
        : _dummyUserProfile;
    _loadProfileFromApi();
  }

  Future<void> _loadProfileFromApi() async {
    if (role == LuminaProfileRole.staff) return;
    try {
      final apiProfile = await Get.find<HomeApiService>().getProfile();
      profile.value = profile.value.copyWith(
        id: apiProfile.id.isNotEmpty ? apiProfile.id : null,
        fullname: apiProfile.fullname.isNotEmpty ? apiProfile.fullname : null,
        email: apiProfile.email.isNotEmpty ? apiProfile.email : null,
        avatarUrl: apiProfile.avatarUrl,
        memberCode: apiProfile.memberCode,
      );
    } catch (_) {
      // fallback ke dummy — tidak perlu crash
    }
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

    return [
      LuminaProfileStatModel(
        id: 'borrowed_books',
        icon: Icons.menu_book_rounded,
        label: 'Buku Dipinjam',
        value: '42',
        backgroundColor: LuminaColors.primary.withOpacity(0.10),
        iconColor: LuminaColors.primary,
        valueColor: LuminaColors.primary,
      ),
      LuminaProfileStatModel(
        id: 'active_books',
        icon: Icons.book_online_rounded,
        label: 'Aktif',
        value: '3',
        backgroundColor: LuminaColors.secondary.withOpacity(0.12),
        iconColor: LuminaColors.secondary,
        valueColor: LuminaColors.primary,
      ),
      LuminaProfileStatModel(
        id: 'total_fine',
        icon: Icons.account_balance_wallet_rounded,
        label: 'Total Denda',
        value: 'Rp 0',
        backgroundColor: LuminaColors.error.withOpacity(0.10),
        iconColor: LuminaColors.error,
        valueColor: LuminaColors.error,
      ),
    ];
  }

  void openSettings() {
    LuminaToast.info('Halaman pengaturan belum tersedia.');
  }

  void editProfilePhoto() {
    LuminaToast.info('Fitur update foto profil belum tersedia.');
  }

  void handleMenuTap(LuminaProfileMenuItemModel item) {
    switch (item.id) {
      case 'update_profile_photo':
        editProfilePhoto();
        return;
      case 'change_password':
        _showChangePasswordSheet();
        return;
      case 'logout':
        _confirmLogout();
        return;
      default:
        LuminaToast.info(item.description ?? 'Menu ${item.label} belum tersedia.');
    }
  }

  void _showChangePasswordSheet() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final isSaving = false.obs;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: 20 + (Get.mediaQuery.viewInsets.bottom),
        ),
        decoration: const BoxDecoration(
          color: LuminaColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: LuminaColors.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Ganti Password',
                  style: TextStyle(
                    color: LuminaColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                _PasswordField(controller: currentCtrl, label: 'Password Saat Ini'),
                const SizedBox(height: 12),
                _PasswordField(controller: newCtrl, label: 'Password Baru'),
                const SizedBox(height: 12),
                _PasswordField(controller: confirmCtrl, label: 'Konfirmasi Password Baru'),
                const SizedBox(height: 24),
                Obx(() => SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isSaving.value
                        ? null
                        : () async {
                            if (currentCtrl.text.isEmpty ||
                                newCtrl.text.isEmpty ||
                                confirmCtrl.text.isEmpty) {
                              LuminaToast.warning('Isi semua kolom password.');
                              return;
                            }
                            if (newCtrl.text != confirmCtrl.text) {
                              LuminaToast.warning('Konfirmasi password tidak sesuai.');
                              return;
                            }
                            isSaving.value = true;
                            try {
                              await Get.find<HomeApiService>().updatePassword(
                                currentPassword: currentCtrl.text,
                                newPassword: newCtrl.text,
                                confirmPassword: confirmCtrl.text,
                              );
                              Get.back<void>();
                              LuminaToast.success('Password berhasil diperbarui.');
                            } on LuminaApiException catch (e) {
                              LuminaToast.error(e.displayMessage);
                            } catch (_) {
                              LuminaToast.error('Gagal memperbarui password.');
                            } finally {
                              isSaving.value = false;
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: LuminaColors.primary,
                      foregroundColor: LuminaColors.onPrimary,
                    ),
                    child: isSaving.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Simpan Password',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
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
    LuminaRoleRouter.goToLogin();
  }
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}