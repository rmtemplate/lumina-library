import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/core/routing/lumina_role_router.dart';
import 'package:lumina_library/features/auth/data/services/auth_api_service.dart';
import 'package:lumina_library/shared/widgets/feedback/lumina_toast.dart';
import '../models/library_register_models.dart';

class LibraryRegisterController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController institutionController = TextEditingController();
  final TextEditingController majorController = TextEditingController();
  final TextEditingController levelController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RxString selectedProfileTypeId = 'mahasiswa'.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool isAgreementChecked = false.obs;
  final RxBool isLoading = false.obs;

  /// Mapping dari local profile type id → UUID di backend (dari ProfileTypeSeeder).
  static const Map<String, String> _profileTypeUuids = {
    'tk_paud': 'a1b2c3d4-0001-4000-8000-000000000001',
    'sd_mi': 'a1b2c3d4-0001-4000-8000-000000000002',
    'smp_mts': 'a1b2c3d4-0001-4000-8000-000000000003',
    'sma_smk_ma': 'a1b2c3d4-0001-4000-8000-000000000004',
    'mahasiswa': 'a1b2c3d4-0001-4000-8000-000000000005',
    'bekerja': 'a1b2c3d4-0001-4000-8000-000000000006',
    'umum': 'a1b2c3d4-0001-4000-8000-000000000007',
  };

  static const List<LibraryRegisterProfileTypeModel> profileTypes = [
    LibraryRegisterProfileTypeModel(
      id: 'tk_paud',
      label: 'TK / PAUD',
      description: 'Untuk peserta didik usia dini. Jurusan tidak diperlukan.',
      institutionLabel: 'Nama Sekolah / Lembaga',
      majorLabel: 'Jurusan',
      levelLabel: 'Kelompok / Kelas',
      showInstitution: true,
      showMajor: false,
      showLevel: true,
      requiresInstitution: true,
      requiresMajor: false,
      requiresLevel: false,
    ),
    LibraryRegisterProfileTypeModel(
      id: 'sd_mi',
      label: 'SD / MI',
      description: 'Untuk siswa sekolah dasar. Jurusan tidak diperlukan.',
      institutionLabel: 'Nama Sekolah',
      majorLabel: 'Jurusan',
      levelLabel: 'Kelas',
      showInstitution: true,
      showMajor: false,
      showLevel: true,
      requiresInstitution: true,
      requiresMajor: false,
      requiresLevel: true,
    ),
    LibraryRegisterProfileTypeModel(
      id: 'smp_mts',
      label: 'SMP / MTs',
      description: 'Untuk siswa tingkat menengah pertama.',
      institutionLabel: 'Nama Sekolah',
      majorLabel: 'Jurusan',
      levelLabel: 'Kelas',
      showInstitution: true,
      showMajor: false,
      showLevel: true,
      requiresInstitution: true,
      requiresMajor: false,
      requiresLevel: true,
    ),
    LibraryRegisterProfileTypeModel(
      id: 'sma_smk_ma',
      label: 'SMA / SMK / MA',
      description:
          'Untuk siswa tingkat menengah atas. Jurusan bisa diisi jika tersedia.',
      institutionLabel: 'Nama Sekolah',
      majorLabel: 'Jurusan / Peminatan',
      levelLabel: 'Kelas',
      showInstitution: true,
      showMajor: true,
      showLevel: true,
      requiresInstitution: true,
      requiresMajor: false,
      requiresLevel: true,
    ),
    LibraryRegisterProfileTypeModel(
      id: 'mahasiswa',
      label: 'Mahasiswa',
      description: 'Untuk mahasiswa aktif perguruan tinggi.',
      institutionLabel: 'Nama Kampus',
      majorLabel: 'Program Studi / Jurusan',
      levelLabel: 'Semester',
      showInstitution: true,
      showMajor: true,
      showLevel: true,
      requiresInstitution: true,
      requiresMajor: true,
      requiresLevel: true,
    ),
    LibraryRegisterProfileTypeModel(
      id: 'bekerja',
      label: 'Sudah Bekerja',
      description: 'Untuk pengguna yang sedang bekerja.',
      institutionLabel: 'Nama Perusahaan / Instansi',
      majorLabel: 'Divisi / Bidang',
      levelLabel: 'Posisi / Jabatan',
      showInstitution: true,
      showMajor: true,
      showLevel: true,
      requiresInstitution: false,
      requiresMajor: false,
      requiresLevel: false,
    ),
    LibraryRegisterProfileTypeModel(
      id: 'umum',
      label: 'Umum',
      description: 'Untuk pengguna umum yang tidak sedang sekolah/kuliah.',
      institutionLabel: 'Instansi / Komunitas',
      majorLabel: 'Bidang Minat',
      levelLabel: 'Aktivitas Saat Ini',
      showInstitution: false,
      showMajor: true,
      showLevel: true,
      requiresInstitution: false,
      requiresMajor: false,
      requiresLevel: false,
    ),
  ];

  LibraryRegisterProfileTypeModel get selectedProfileType {
    return profileTypes.firstWhere(
      (item) => item.id == selectedProfileTypeId.value,
      orElse: () => profileTypes.first,
    );
  }

  String get fullname => fullnameController.text.trim();
  String get email => emailController.text.trim();
  String get phone => phoneController.text.trim();
  String get institutionName => institutionController.text.trim();
  String get majorName => majorController.text.trim();
  String get currentLevel => levelController.text.trim();
  String get password => passwordController.text;
  String get confirmPassword => confirmPasswordController.text;

  void setProfileType(String value) {
    if (value.trim().isEmpty) return;

    selectedProfileTypeId.value = value;

    institutionController.clear();
    majorController.clear();
    levelController.clear();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void setAgreementChecked(bool? value) {
    isAgreementChecked.value = value ?? false;
  }

  String? validateFullname(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Nama lengkap wajib diisi.';
    }

    if (text.length < 3) {
      return 'Nama lengkap minimal 3 karakter.';
    }

    return null;
  }

  String? validateEmail(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Email wajib diisi.';
    }

    if (!GetUtils.isEmail(text)) {
      return 'Format email tidak valid.';
    }

    return null;
  }

  String? validatePhone(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) return null;

    if (text.length < 8) {
      return 'Nomor telepon minimal 8 digit.';
    }

    return null;
  }

  String? validateInstitution(String? value) {
    final profileType = selectedProfileType;
    final text = value?.trim() ?? '';

    if (!profileType.showInstitution) return null;
    if (!profileType.requiresInstitution) return null;

    if (text.isEmpty) {
      return '${profileType.institutionLabel} wajib diisi.';
    }

    return null;
  }

  String? validateMajor(String? value) {
    final profileType = selectedProfileType;
    final text = value?.trim() ?? '';

    if (!profileType.showMajor) return null;
    if (!profileType.requiresMajor) return null;

    if (text.isEmpty) {
      return '${profileType.majorLabel} wajib diisi.';
    }

    return null;
  }

  String? validateLevel(String? value) {
    final profileType = selectedProfileType;
    final text = value?.trim() ?? '';

    if (!profileType.showLevel) return null;
    if (!profileType.requiresLevel) return null;

    if (text.isEmpty) {
      return '${profileType.levelLabel} wajib diisi.';
    }

    return null;
  }

  String? validatePassword(String? value) {
    final text = value ?? '';

    if (text.isEmpty) {
      return 'Password wajib diisi.';
    }

    if (text.length < 6) {
      return 'Password minimal 6 karakter.';
    }

    return null;
  }

  String? validateConfirmPassword(String? value) {
    final text = value ?? '';

    if (text.isEmpty) {
      return 'Konfirmasi password wajib diisi.';
    }

    if (text != password) {
      return 'Konfirmasi password tidak sama.';
    }

    return null;
  }

  LibraryRegisterPayload buildPayload() {
    final profileType = selectedProfileType;

    return LibraryRegisterPayload(
      fullname: fullname,
      email: email,
      phone: phone.isEmpty ? null : phone,
      password: password,
      profileTypeId: profileType.id,
      profileTypeLabel: profileType.label,
      institutionName: !profileType.showInstitution || institutionName.isEmpty
          ? null
          : institutionName,
      majorName: !profileType.showMajor || majorName.isEmpty ? null : majorName,
      currentLevel:
          !profileType.showLevel || currentLevel.isEmpty ? null : currentLevel,
    );
  }

  Future<void> submitRegister({VoidCallback? onSuccess}) async {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (!isAgreementChecked.value) {
      LuminaToast.warning('Centang persetujuan untuk melanjutkan registrasi.');
      return;
    }

    final profileType = selectedProfileType;
    final profileTypeUuid = _profileTypeUuids[profileType.id];
    if (profileTypeUuid == null) {
      LuminaToast.error('Tipe profil tidak valid. Silakan pilih ulang.');
      return;
    }

    isLoading.value = true;

    try {
      final authService = Get.find<AuthApiService>();
      await authService.register(
        fullname: fullname,
        email: email,
        phone: phone.isEmpty ? null : phone,
        profileTypeId: profileTypeUuid,
        institutionName: profileType.showInstitution && institutionName.isNotEmpty
            ? institutionName
            : null,
        majorName: profileType.showMajor && majorName.isNotEmpty
            ? majorName
            : null,
        currentLevel: profileType.showLevel && currentLevel.isNotEmpty
            ? currentLevel
            : null,
        password: password,
        passwordConfirmation: confirmPassword,
      );

      if (onSuccess != null) {
        onSuccess();
        return;
      }

      LuminaToast.success(
        'Akun berhasil dibuat. Cek email untuk verifikasi.',
        duration: const Duration(seconds: 4),
      );

      LuminaRoleRouter.goToLogin();
    } on LuminaApiException catch (e) {
      LuminaToast.error(e.displayMessage);
    } catch (_) {
      LuminaToast.error('Terjadi kesalahan. Silakan coba lagi.');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fullnameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    institutionController.dispose();
    majorController.dispose();
    levelController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}