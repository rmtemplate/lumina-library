import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/profile/data/services/profile_api_service.dart';
import 'package:lumina_library/shared/widgets/feedback/lumina_toast.dart';
import 'package:lumina_library/shared/widgets/profile/change_password_form.dart';

/// Dedicated Change Password page (Design.md-consistent — gradient-free
/// Material 3 page, not the old bottom sheet) reached from the Profile
/// menu's "Change Password" item.
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _logoutOtherSessions = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      await Get.find<ProfileApiService>().updatePassword(
        currentPassword: _currentCtrl.text,
        newPassword: _newCtrl.text,
        confirmPassword: _confirmCtrl.text,
        logoutOtherSessions: _logoutOtherSessions,
      );
      if (!mounted) return;
      await _showSuccessDialog();
      if (mounted) Get.back();
    } on LuminaApiException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      LuminaToast.error(e.displayMessage);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      LuminaToast.error('Gagal memperbarui password. Silakan coba lagi.');
    }
  }

  Future<void> _showSuccessDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: LuminaColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LuminaRadius.xl)),
        child: Padding(
          padding: const EdgeInsets.all(LuminaSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 320),
                curve: Curves.elasticOut,
                builder: (context, value, child) => Transform.scale(scale: value, child: child),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: LuminaColors.secondaryContainer.withOpacity(0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: LuminaColors.secondary, size: 36),
                ),
              ),
              const SizedBox(height: LuminaSpacing.md),
              Text(
                'Password Berhasil Diperbarui',
                textAlign: TextAlign.center,
                style: LuminaTextStyles.titleMd.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: LuminaSpacing.xs),
              Text(
                'Gunakan password baru Anda untuk login selanjutnya.',
                textAlign: TextAlign.center,
                style: LuminaTextStyles.bodyMd.copyWith(color: LuminaColors.onSurfaceVariant),
              ),
              const SizedBox(height: LuminaSpacing.md),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Get.back<void>(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LuminaColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LuminaRadius.full)),
                  ),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuminaColors.background,
      appBar: AppBar(
        backgroundColor: LuminaColors.surface,
        elevation: 0,
        foregroundColor: LuminaColors.primary,
        title: Text(
          'Change Password',
          style: LuminaTextStyles.titleLg.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            LuminaSpacing.marginMobile,
            LuminaSpacing.lg,
            LuminaSpacing.marginMobile,
            LuminaSpacing.xl,
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(LuminaSpacing.md),
              decoration: BoxDecoration(
                color: LuminaColors.primaryFixed.withOpacity(0.35),
                borderRadius: BorderRadius.circular(LuminaRadius.lg),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: LuminaColors.primary, size: 20),
                  const SizedBox(width: LuminaSpacing.sm),
                  Expanded(
                    child: Text(
                      'Gunakan kombinasi huruf, angka, dan simbol untuk password yang lebih kuat.',
                      style: LuminaTextStyles.labelMd.copyWith(color: LuminaColors.primary, letterSpacing: 0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: LuminaSpacing.lg),
            ChangePasswordForm(
              formKey: _formKey,
              currentPasswordController: _currentCtrl,
              newPasswordController: _newCtrl,
              confirmPasswordController: _confirmCtrl,
              logoutOtherSessions: _logoutOtherSessions,
              onLogoutOtherSessionsChanged: (value) => setState(() => _logoutOtherSessions = value),
            ),
            const SizedBox(height: LuminaSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: LuminaColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LuminaRadius.full)),
                ),
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                        'Save Password',
                        style: LuminaTextStyles.titleSm.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
