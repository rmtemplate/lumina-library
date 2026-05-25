import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina_library/core/routing/lumina_role_router.dart';

class LibraryLoginController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;

  String get email => emailController.text.trim();
  String get password => passwordController.text;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
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

  Future<void> submitLogin({
    VoidCallback? onSuccess,
  }) async {
    final isValid = formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    isLoading.value = true;

    try {
      // TODO:
      // Ganti simulasi ini dengan hit API login.
      // Contoh payload:
      // {
      //   "Email": email,
      //   "Password": password
      // }
      await Future<void>.delayed(const Duration(milliseconds: 900));

      if (onSuccess != null) {
        onSuccess();
        return;
      }

      Get.snackbar(
        'Login Berhasil',
        'Selamat datang kembali di Lumina Library.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );

      LuminaRoleRouter.goToMahasiswaHome();
    } catch (_) {
      Get.snackbar(
        'Login Gagal',
        'Terjadi kesalahan saat login. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}