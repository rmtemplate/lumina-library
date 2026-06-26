import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/core/routing/lumina_role_router.dart';
import 'package:lumina_library/core/services/lumina_storage_service.dart';
import 'package:lumina_library/core/services/websocket/websocket_service.dart';
import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/auth/data/services/auth_api_service.dart';
import 'package:lumina_library/shared/widgets/feedback/lumina_toast.dart';

class LibraryLoginController extends GetxController {
  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;

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
    required String email,
    required String password,
    VoidCallback? onSuccess,
  }) async {
    if (isLoading.value) {
      return;
    }

    final cleanEmail = email.trim();

    if (cleanEmail.isEmpty || password.isEmpty) {
      LuminaToast.error('Email dan password wajib diisi.');
      return;
    }

    isLoading.value = true;

    try {
      final authService = Get.find<AuthApiService>();

      final result = await authService.login(
        email: cleanEmail,
        password: password,
      );

      if (isClosed) {
        return;
      }

      LuminaStorageService.saveSession(
        token: result.token,
        user: result.user.toJson(),
      );

      unawaited(Get.find<WebSocketService>().connectForCurrentUser());

      if (onSuccess != null) {
        onSuccess();
        return;
      }

      LuminaRoleRouter.navigateAfterLogin(
        result.user.isStaff ? 'STAFF' : 'MEMBER',
      );
    } on LuminaApiException catch (error) {
      if (isClosed) {
        return;
      }

      _handleApiError(
        error,
        email: cleanEmail,
      );
    } catch (_) {
      if (isClosed) {
        return;
      }

      LuminaToast.error('Terjadi kesalahan. Silakan coba lagi.');
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }

  void _handleApiError(
    LuminaApiException error, {
    required String email,
  }) {
    final emailError = error.fieldError('email');

    if (emailError != null &&
        emailError.toLowerCase().contains('belum diverifikasi')) {
      _showEmailNotVerifiedSheet(email);
      return;
    }

    LuminaToast.error(error.displayMessage);
  }

  void _showEmailNotVerifiedSheet(String email) {
    if (Get.isBottomSheetOpen == true) {
      Get.back<void>();
    }

    Get.bottomSheet<void>(
      _EmailNotVerifiedSheet(email: email),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
    );
  }
}

// ─── Email Not Verified Bottom Sheet ─────────────────────────────────────────

class _EmailNotVerifiedSheet extends StatelessWidget {
  const _EmailNotVerifiedSheet({
    required this.email,
  });

  final String email;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        LuminaSpacing.lg,
        LuminaSpacing.lg,
        LuminaSpacing.lg,
        LuminaSpacing.lg + viewInsets,
      ),
      decoration: const BoxDecoration(
        color: LuminaColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(LuminaRadius.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _SheetHandle(),
              const SizedBox(height: LuminaSpacing.xl),
              const _EmailIcon(),
              const SizedBox(height: LuminaSpacing.lg),
              Text(
                'Verifikasi Email Diperlukan',
                textAlign: TextAlign.center,
                style: LuminaTextStyles.headlineSm.copyWith(
                  color: LuminaColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: LuminaSpacing.xs),
              Text(
                'Akun Anda belum diaktifkan. Silakan cek inbox email Anda dan klik tautan verifikasi yang dikirimkan.',
                textAlign: TextAlign.center,
                style: LuminaTextStyles.bodyMd.copyWith(
                  color: LuminaColors.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: LuminaSpacing.sm),
              _EmailChip(email: email),
              const SizedBox(height: LuminaSpacing.xl),
              const _VerificationTips(),
              const SizedBox(height: LuminaSpacing.lg),
              const _CloseButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: LuminaColors.outlineVariant,
        borderRadius: BorderRadius.circular(LuminaRadius.full),
      ),
    );
  }
}

class _EmailIcon extends StatelessWidget {
  const _EmailIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: LuminaColors.secondary.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.mark_email_unread_rounded,
        color: LuminaColors.secondary,
        size: 36,
      ),
    );
  }
}

class _EmailChip extends StatelessWidget {
  const _EmailChip({
    required this.email,
  });

  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.md,
        vertical: LuminaSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(LuminaRadius.full),
        border: Border.all(
          color: LuminaColors.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.email_outlined,
            color: LuminaColors.onSurfaceVariant,
            size: 16,
          ),
          const SizedBox(width: LuminaSpacing.xs),
          Flexible(
            child: Text(
              email,
              overflow: TextOverflow.ellipsis,
              style: LuminaTextStyles.labelMd.copyWith(
                color: LuminaColors.onSurface,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationTips extends StatelessWidget {
  const _VerificationTips();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
      ),
      child: const Column(
        children: [
          _TipRow(
            icon: Icons.inbox_rounded,
            text: 'Cek folder Inbox atau Spam di email Anda.',
          ),
          SizedBox(height: LuminaSpacing.xs),
          _TipRow(
            icon: Icons.timer_outlined,
            text: 'Tautan verifikasi berlaku selama 60 menit.',
          ),
          SizedBox(height: LuminaSpacing.xs),
          _TipRow(
            icon: Icons.link_rounded,
            text: 'Klik tautan di email untuk mengaktifkan akun.',
          ),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => Get.back<void>(),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: LuminaColors.primary,
          foregroundColor: LuminaColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LuminaRadius.md),
          ),
        ),
        child: Text(
          'Tutup',
          style: LuminaTextStyles.titleMd.copyWith(
            color: LuminaColors.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: LuminaColors.onSurfaceVariant,
        ),
        const SizedBox(width: LuminaSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: LuminaTextStyles.bodySm.copyWith(
              color: LuminaColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}