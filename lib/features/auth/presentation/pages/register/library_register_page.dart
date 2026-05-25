import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina_library/features/auth/data/controllers/library_register_controller.dart';

import '../../../../../core/theme/lumina_colors.dart';
import '../../../../../core/theme/lumina_radius.dart';
import '../../../../../core/theme/lumina_spacing.dart';
import '../../../../../core/theme/lumina_text_styles.dart';

class LibraryRegisterPage extends StatelessWidget {
  const LibraryRegisterPage({
    super.key,
    this.logoAssetPath,
    this.onRegisterSuccess,
    this.onLoginTap,
  });

  final String? logoAssetPath;
  final VoidCallback? onRegisterSuccess;
  final VoidCallback? onLoginTap;

  LibraryRegisterController get controller {
    if (Get.isRegistered<LibraryRegisterController>()) {
      return Get.find<LibraryRegisterController>();
    }

    return Get.put(LibraryRegisterController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuminaColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(LuminaSpacing.marginMobile),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 460,
              ),
              child: _RegisterCard(
                controller: controller,
                logoAssetPath: logoAssetPath,
                onRegisterSuccess: onRegisterSuccess,
                onLoginTap: onLoginTap,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterCard extends StatelessWidget {
  const _RegisterCard({
    required this.controller,
    required this.logoAssetPath,
    required this.onRegisterSuccess,
    required this.onLoginTap,
  });

  final LibraryRegisterController controller;
  final String? logoAssetPath;
  final VoidCallback? onRegisterSuccess;
  final VoidCallback? onLoginTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(
          color: LuminaColors.surfaceVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.055),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const _RegisterTopAccent(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              LuminaSpacing.lg,
              LuminaSpacing.xl,
              LuminaSpacing.lg,
              LuminaSpacing.lg,
            ),
            child: Form(
              key: controller.formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  _RegisterHeader(
                    logoAssetPath: logoAssetPath,
                  ),
                  const SizedBox(height: LuminaSpacing.xl),
                  _RegisterIdentitySection(
                    controller: controller,
                  ),
                  const SizedBox(height: LuminaSpacing.lg),
                  _RegisterProfileSection(
                    controller: controller,
                  ),
                  const SizedBox(height: LuminaSpacing.lg),
                  _RegisterPasswordSection(
                    controller: controller,
                    onRegisterSuccess: onRegisterSuccess,
                  ),
                  const SizedBox(height: LuminaSpacing.lg),
                  _RegisterAgreement(
                    controller: controller,
                  ),
                  const SizedBox(height: LuminaSpacing.lg),
                  _RegisterSubmitButton(
                    controller: controller,
                    onRegisterSuccess: onRegisterSuccess,
                  ),
                  const SizedBox(height: LuminaSpacing.xl),
                  const _RegisterDivider(),
                  const SizedBox(height: LuminaSpacing.lg),
                  _LoginTextButton(
                    onLoginTap: onLoginTap,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterTopAccent extends StatelessWidget {
  const _RegisterTopAccent();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 7,
      width: double.infinity,
      color: LuminaColors.primary,
    );
  }
}

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader({
    required this.logoAssetPath,
  });

  final String? logoAssetPath;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RegisterLogo(
          logoAssetPath: logoAssetPath,
        ),
        const SizedBox(height: LuminaSpacing.lg),
        Text(
          'Buat Akun Baru',
          textAlign: TextAlign.center,
          style: LuminaTextStyles.displayLgMobile.copyWith(
            color: LuminaColors.primary,
            fontWeight: FontWeight.w900,
            height: 1.12,
          ),
        ),
        const SizedBox(height: LuminaSpacing.xs),
        Text(
          'Daftar sebagai siswa, mahasiswa, pekerja, atau pengguna umum.',
          textAlign: TextAlign.center,
          style: LuminaTextStyles.bodyMd.copyWith(
            color: LuminaColors.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _RegisterLogo extends StatelessWidget {
  const _RegisterLogo({
    required this.logoAssetPath,
  });

  final String? logoAssetPath;

  @override
  Widget build(BuildContext context) {
    final hasLogo = logoAssetPath != null && logoAssetPath!.trim().isNotEmpty;

    if (!hasLogo) {
      return const _RegisterLogoFallback();
    }

    return SizedBox(
      width: 86,
      height: 86,
      child: Image.asset(
        logoAssetPath!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return const _RegisterLogoFallback();
        },
      ),
    );
  }
}

class _RegisterLogoFallback extends StatelessWidget {
  const _RegisterLogoFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        color: LuminaColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(
          color: LuminaColors.primary.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: const Icon(
        Icons.local_library_rounded,
        color: LuminaColors.primary,
        size: 42,
      ),
    );
  }
}

class _RegisterIdentitySection extends StatelessWidget {
  const _RegisterIdentitySection({
    required this.controller,
  });

  final LibraryRegisterController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AuthTextField(
          controller: controller.fullnameController,
          label: 'Nama Lengkap',
          hintText: 'Masukkan nama lengkap',
          icon: Icons.person_outline_rounded,
          textInputAction: TextInputAction.next,
          validator: controller.validateFullname,
        ),
        const SizedBox(height: LuminaSpacing.md),
        _AuthTextField(
          controller: controller.emailController,
          label: 'Email',
          hintText: 'Masukkan email aktif',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: controller.validateEmail,
        ),
        const SizedBox(height: LuminaSpacing.md),
        _AuthTextField(
          controller: controller.phoneController,
          label: 'Nomor Telepon',
          hintText: 'Opsional',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          validator: controller.validatePhone,
        ),
      ],
    );
  }
}

class _RegisterProfileSection extends StatelessWidget {
  const _RegisterProfileSection({
    required this.controller,
  });

  final LibraryRegisterController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final profileType = controller.selectedProfileType;

      return Column(
        children: [
          _RegisterProfileTypeDropdown(
            controller: controller,
          ),
          const SizedBox(height: LuminaSpacing.sm),
          _SelectedProfileInfo(
            title: profileType.label,
            description: profileType.description,
          ),
          const SizedBox(height: LuminaSpacing.md),
          _AuthTextField(
            controller: controller.institutionController,
            label: profileType.institutionLabel,
            hintText: profileType.requiresInstitution
                ? 'Wajib diisi'
                : 'Opsional',
            icon: Icons.account_balance_outlined,
            textInputAction: TextInputAction.next,
            validator: controller.validateInstitution,
          ),
          const SizedBox(height: LuminaSpacing.md),
          _AuthTextField(
            controller: controller.majorController,
            label: profileType.majorLabel,
            hintText: profileType.requiresMajor ? 'Wajib diisi' : 'Opsional',
            icon: Icons.school_outlined,
            textInputAction: TextInputAction.next,
            validator: controller.validateMajor,
          ),
          const SizedBox(height: LuminaSpacing.md),
          _AuthTextField(
            controller: controller.levelController,
            label: profileType.levelLabel,
            hintText: profileType.requiresLevel ? 'Wajib diisi' : 'Opsional',
            icon: Icons.badge_outlined,
            textInputAction: TextInputAction.next,
            validator: controller.validateLevel,
          ),
        ],
      );
    });
  }
}

class _RegisterProfileTypeDropdown extends StatelessWidget {
  const _RegisterProfileTypeDropdown({
    required this.controller,
  });

  final LibraryRegisterController controller;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: controller.selectedProfileTypeId.value,
      isExpanded: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Status pendidikan/pekerjaan wajib dipilih.';
        }

        return null;
      },
      items: LibraryRegisterController.profileTypes.map((item) {
        return DropdownMenuItem<String>(
          value: item.id,
          child: Text(
            item.label,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: controller.setProfileType,
      decoration: InputDecoration(
        labelText: 'Sedang apa saat ini?',
        prefixIcon: const Icon(
          Icons.workspace_premium_outlined,
          color: LuminaColors.onSurfaceVariant,
          size: 22,
        ),
        filled: true,
        fillColor: LuminaColors.surfaceContainerLowest,
        labelStyle: LuminaTextStyles.bodyMd.copyWith(
          color: LuminaColors.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: LuminaSpacing.md,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaRadius.lg),
          borderSide: const BorderSide(
            color: LuminaColors.outlineVariant,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaRadius.lg),
          borderSide: const BorderSide(
            color: LuminaColors.primary,
            width: 1.3,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaRadius.lg),
          borderSide: const BorderSide(
            color: LuminaColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaRadius.lg),
          borderSide: const BorderSide(
            color: LuminaColors.error,
            width: 1.3,
          ),
        ),
      ),
    );
  }
}

class _SelectedProfileInfo extends StatelessWidget {
  const _SelectedProfileInfo({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(LuminaSpacing.sm),
      decoration: BoxDecoration(
        color: LuminaColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
        border: Border.all(
          color: LuminaColors.primary.withOpacity(0.10),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: LuminaColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: LuminaColors.primary,
              size: 19,
            ),
          ),
          const SizedBox(width: LuminaSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: LuminaColors.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: LuminaColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterPasswordSection extends StatelessWidget {
  const _RegisterPasswordSection({
    required this.controller,
    required this.onRegisterSuccess,
  });

  final LibraryRegisterController controller;
  final VoidCallback? onRegisterSuccess;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isPasswordVisible = controller.isPasswordVisible.value;
      final isConfirmVisible = controller.isConfirmPasswordVisible.value;

      return Column(
        children: [
          _AuthTextField(
            controller: controller.passwordController,
            label: 'Password',
            hintText: 'Minimal 6 karakter',
            icon: Icons.lock_outline_rounded,
            obscureText: !isPasswordVisible,
            textInputAction: TextInputAction.next,
            validator: controller.validatePassword,
            suffixIcon: IconButton(
              onPressed: controller.togglePasswordVisibility,
              icon: Icon(
                isPasswordVisible
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                color: LuminaColors.onSurfaceVariant,
                size: 21,
              ),
            ),
          ),

          const SizedBox(height: LuminaSpacing.md),

          _AuthTextField(
            controller: controller.confirmPasswordController,
            label: 'Konfirmasi Password',
            hintText: 'Ulangi password',
            icon: Icons.lock_reset_rounded,
            obscureText: !isConfirmVisible,
            textInputAction: TextInputAction.done,
            validator: controller.validateConfirmPassword,
            suffixIcon: IconButton(
              onPressed: controller.toggleConfirmPasswordVisibility,
              icon: Icon(
                isConfirmVisible
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                color: LuminaColors.onSurfaceVariant,
                size: 21,
              ),
            ),
            onSubmitted: (_) {
              controller.submitRegister(
                onSuccess: onRegisterSuccess,
              );
            },
          ),
        ],
      );
    });
  }
}

class _RegisterAgreement extends StatelessWidget {
  const _RegisterAgreement({
    required this.controller,
  });

  final LibraryRegisterController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return InkWell(
        onTap: () {
          controller.setAgreementChecked(
            !controller.isAgreementChecked.value,
          );
        },
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: controller.isAgreementChecked.value,
              onChanged: controller.setAgreementChecked,
              activeColor: LuminaColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(LuminaRadius.sm),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 11),
                child: Text(
                  'Saya menyetujui bahwa data yang saya isi benar dan dapat digunakan untuk kebutuhan layanan perpustakaan.',
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: LuminaColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _RegisterSubmitButton extends StatelessWidget {
  const _RegisterSubmitButton({
    required this.controller,
    required this.onRegisterSuccess,
  });

  final LibraryRegisterController controller;
  final VoidCallback? onRegisterSuccess;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;

      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: isLoading
              ? null
              : () {
                  controller.submitRegister(
                    onSuccess: onRegisterSuccess,
                  );
                },
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: LuminaColors.primary,
            disabledBackgroundColor: LuminaColors.surfaceContainerHigh,
            foregroundColor: LuminaColors.onPrimary,
            disabledForegroundColor: LuminaColors.onSurfaceVariant,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(LuminaRadius.lg),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: isLoading
                ? const SizedBox(
                    key: ValueKey('register-loading'),
                    width: 23,
                    height: 23,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: LuminaColors.onPrimary,
                    ),
                  )
                : Row(
                    key: const ValueKey('register-label'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Daftar',
                        style: LuminaTextStyles.titleLg.copyWith(
                          color: LuminaColors.onPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: LuminaSpacing.xs),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: LuminaColors.onPrimary,
                        size: 22,
                      ),
                    ],
                  ),
          ),
        ),
      );
    });
  }
}

class _RegisterDivider extends StatelessWidget {
  const _RegisterDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: LuminaColors.surfaceVariant,
            height: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LuminaSpacing.sm,
          ),
          child: Text(
            'LUMINA LIBRARY',
            style: LuminaTextStyles.labelMd.copyWith(
              color: LuminaColors.outline,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            color: LuminaColors.surfaceVariant,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _LoginTextButton extends StatelessWidget {
  const _LoginTextButton({
    required this.onLoginTap,
  });

  final VoidCallback? onLoginTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Sudah memiliki akun?',
          style: LuminaTextStyles.bodyMd.copyWith(
            color: LuminaColors.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: onLoginTap ?? Get.back,
          style: TextButton.styleFrom(
            foregroundColor: LuminaColors.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: LuminaSpacing.xs,
              vertical: LuminaSpacing.xs,
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Masuk disini',
            style: LuminaTextStyles.bodyMd.copyWith(
              color: LuminaColors.primary,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.underline,
              decorationColor: LuminaColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      cursorColor: LuminaColors.primary,
      style: LuminaTextStyles.bodyLg.copyWith(
        color: LuminaColors.onSurface,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(
          icon,
          color: LuminaColors.onSurfaceVariant,
          size: 22,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: LuminaColors.surfaceContainerLowest,
        labelStyle: LuminaTextStyles.bodyMd.copyWith(
          color: LuminaColors.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: LuminaTextStyles.bodyMd.copyWith(
          color: LuminaColors.outline,
        ),
        errorStyle: LuminaTextStyles.labelMd.copyWith(
          color: LuminaColors.error,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: LuminaSpacing.md,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaRadius.lg),
          borderSide: const BorderSide(
            color: LuminaColors.outlineVariant,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaRadius.lg),
          borderSide: const BorderSide(
            color: LuminaColors.primary,
            width: 1.3,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaRadius.lg),
          borderSide: const BorderSide(
            color: LuminaColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaRadius.lg),
          borderSide: const BorderSide(
            color: LuminaColors.error,
            width: 1.3,
          ),
        ),
      ),
    );
  }
}