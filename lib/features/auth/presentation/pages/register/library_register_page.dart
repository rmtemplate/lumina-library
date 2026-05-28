import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina_library/features/auth/data/controllers/library_register_controller.dart';
import 'package:lumina_library/features/auth/data/models/library_register_models.dart';

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
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const _RegisterTopAccent(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              LuminaSpacing.md, // Diperkecil dari lg
              LuminaSpacing.lg, // Diperkecil dari xl
              LuminaSpacing.md,
              LuminaSpacing.md,
            ),
            child: Form(
              key: controller.formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  _RegisterHeader(logoAssetPath: logoAssetPath),
                  const SizedBox(height: LuminaSpacing.lg), // Diperkecil dari xl
                  
                  _RegisterIdentitySection(controller: controller),
                  const SizedBox(height: LuminaSpacing.md), // Diperkecil dari lg
                  
                  _RegisterProfileSection(controller: controller),
                  const SizedBox(height: LuminaSpacing.md),
                  
                  _RegisterPasswordSection(
                    controller: controller,
                    onRegisterSuccess: onRegisterSuccess,
                  ),
                  const SizedBox(height: LuminaSpacing.md),
                  
                  _RegisterAgreement(controller: controller),
                  const SizedBox(height: LuminaSpacing.md),
                  
                  _RegisterSubmitButton(
                    controller: controller,
                    onRegisterSuccess: onRegisterSuccess,
                  ),
                  const SizedBox(height: LuminaSpacing.md),
                  
                  const _RegisterDivider(),
                  const SizedBox(height: LuminaSpacing.sm), // Diperkecil
                  
                  _LoginTextButton(onLoginTap: onLoginTap),
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
      height: 5, // Diperkecil dari 7 agar lebih proporsional
      width: double.infinity,
      color: LuminaColors.primary,
    );
  }
}

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader({required this.logoAssetPath});

  final String? logoAssetPath;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RegisterLogo(logoAssetPath: logoAssetPath),
        const SizedBox(height: LuminaSpacing.md),
        Text(
          'Buat Akun Baru',
          textAlign: TextAlign.center,
          style: LuminaTextStyles.displayLgMobile.copyWith(
            color: LuminaColors.primary,
            fontWeight: FontWeight.w900,
            fontSize: 22, // Sedikit disesuaikan agar lebih compact
            height: 1.12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Daftar sebagai siswa, mahasiswa, pekerja, atau pengguna umum.',
          textAlign: TextAlign.center,
          style: LuminaTextStyles.bodyMd.copyWith(
            color: LuminaColors.onSurfaceVariant,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _RegisterLogo extends StatelessWidget {
  const _RegisterLogo({required this.logoAssetPath});

  final String? logoAssetPath;

  @override
  Widget build(BuildContext context) {
    final hasLogo = logoAssetPath != null && logoAssetPath!.trim().isNotEmpty;

    if (!hasLogo) {
      return const _RegisterLogoFallback();
    }

    return SizedBox(
      width: 64, // Diperkecil dari 86
      height: 64,
      child: Image.asset(
        logoAssetPath!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const _RegisterLogoFallback(),
      ),
    );
  }
}

class _RegisterLogoFallback extends StatelessWidget {
  const _RegisterLogoFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64, // Diperkecil dari 86
      height: 64,
      decoration: BoxDecoration(
        color: LuminaColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
        border: Border.all(
          color: LuminaColors.primary.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: const Icon(
        Icons.local_library_rounded,
        color: LuminaColors.primary,
        size: 32, // Diperkecil dari 42
      ),
    );
  }
}

class _RegisterIdentitySection extends StatelessWidget {
  const _RegisterIdentitySection({required this.controller});

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
        const SizedBox(height: LuminaSpacing.sm), // Jarak antar field diperkecil
        _AuthTextField(
          controller: controller.emailController,
          label: 'Email',
          hintText: 'Masukkan email aktif',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: controller.validateEmail,
        ),
        const SizedBox(height: LuminaSpacing.sm),
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
  const _RegisterProfileSection({required this.controller});

  final LibraryRegisterController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final profileType = controller.selectedProfileType;

      return Column(
        children: [
          _ProfileTypeBottomSheetField(
            selectedItem: profileType,
            onTap: () => _openProfileTypeSheet(context),
          ),
          const SizedBox(height: LuminaSpacing.xs),
          _SelectedProfileInfo(
            title: profileType.label,
            description: profileType.description,
          ),
          if (profileType.showInstitution) ...[
            const SizedBox(height: LuminaSpacing.sm),
            _AuthTextField(
              controller: controller.institutionController,
              label: profileType.institutionLabel,
              hintText: profileType.requiresInstitution ? 'Wajib diisi' : 'Opsional',
              icon: Icons.account_balance_outlined,
              textInputAction: TextInputAction.next,
              validator: controller.validateInstitution,
            ),
          ],
          if (profileType.showMajor) ...[
            const SizedBox(height: LuminaSpacing.sm),
            _AuthTextField(
              controller: controller.majorController,
              label: profileType.majorLabel,
              hintText: profileType.requiresMajor ? 'Wajib diisi' : 'Opsional',
              icon: Icons.school_outlined,
              textInputAction: TextInputAction.next,
              validator: controller.validateMajor,
            ),
          ],
          if (profileType.showLevel) ...[
            const SizedBox(height: LuminaSpacing.sm),
            _AuthTextField(
              controller: controller.levelController,
              label: profileType.levelLabel,
              hintText: profileType.requiresLevel ? 'Wajib diisi' : 'Opsional',
              icon: Icons.badge_outlined,
              textInputAction: TextInputAction.next,
              validator: controller.validateLevel,
            ),
          ],
        ],
      );
    });
  }

  Future<void> _openProfileTypeSheet(BuildContext context) async {
    final selectedId = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return _ProfileTypePickerSheet(
          selectedId: controller.selectedProfileTypeId.value,
        );
      },
    );

    if (selectedId == null || selectedId.isEmpty) return;
    controller.setProfileType(selectedId);
  }
}

class _ProfileTypeBottomSheetField extends StatelessWidget {
  const _ProfileTypeBottomSheetField({
    required this.selectedItem,
    required this.onTap,
  });

  final LibraryRegisterProfileTypeModel selectedItem;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LuminaColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(LuminaRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12), // Diperkecil dari LuminaSpacing.md
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LuminaRadius.lg),
            border: Border.all(
              color: LuminaColors.outlineVariant,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36, // Diperkecil dari 44
                height: 36,
                decoration: BoxDecoration(
                  color: LuminaColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(LuminaRadius.sm),
                ),
                child: const Icon(
                  Icons.workspace_premium_outlined,
                  color: LuminaColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: LuminaSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sedang apa saat ini?',
                      style: LuminaTextStyles.labelMd.copyWith(
                        color: LuminaColors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        fontSize: 11, // Agar lebih hemat ruang vertikal
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selectedItem.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LuminaTextStyles.bodyLg.copyWith(
                        color: LuminaColors.onSurface,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: LuminaSpacing.sm),
              const Icon(
                Icons.expand_more_rounded,
                color: LuminaColors.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ... _ProfileTypePickerSheet dan _ProfileTypeOptionTile tetap sama logikanya,
// hanya saya lewati duplikasi panjangnya untuk fokus pada form utama. Jika Anda ingin 
// mengubah bagian BottomSheet juga, Anda bisa menerapkan pengurangan padding yang sama.

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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Lebih compact
      decoration: BoxDecoration(
        color: LuminaColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(LuminaRadius.md), // Radius diperkecil
        border: Border.all(
          color: LuminaColors.primary.withOpacity(0.10),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.info_outline_rounded,
              color: LuminaColors.primary,
              size: 16, // Lebih kecil
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: LuminaTextStyles.labelMd.copyWith(
                color: LuminaColors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                height: 1.3,
                fontSize: 11,
              ),
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
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: controller.togglePasswordVisibility,
              icon: Icon(
                isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                color: LuminaColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: LuminaSpacing.sm), // Diperkecil dari md
          _AuthTextField(
            controller: controller.confirmPasswordController,
            label: 'Konfirmasi Password',
            hintText: 'Ulangi password',
            icon: Icons.lock_reset_rounded,
            obscureText: !isConfirmVisible,
            textInputAction: TextInputAction.done,
            validator: controller.validateConfirmPassword,
            suffixIcon: IconButton(
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: controller.toggleConfirmPasswordVisibility,
              icon: Icon(
                isConfirmVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                color: LuminaColors.onSurfaceVariant,
              ),
            ),
            onSubmitted: (_) {
              controller.submitRegister(onSuccess: onRegisterSuccess);
            },
          ),
        ],
      );
    });
  }
}

class _RegisterAgreement extends StatelessWidget {
  const _RegisterAgreement({required this.controller});

  final LibraryRegisterController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return InkWell(
        onTap: () => controller.setAgreementChecked(!controller.isAgreementChecked.value),
        borderRadius: BorderRadius.circular(LuminaRadius.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 24, // Membatasi tinggi checkbox agar tidak memakan ruang
              width: 24,
              child: Checkbox(
                value: controller.isAgreementChecked.value,
                onChanged: controller.setAgreementChecked,
                activeColor: LuminaColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(LuminaRadius.sm),
                ),
              ),
            ),
            const SizedBox(width: LuminaSpacing.sm),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2), // Disesuaikan agar sejajar
                child: Text(
                  'Saya menyetujui bahwa data yang saya isi benar dan dapat digunakan untuk kebutuhan layanan perpustakaan.',
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: LuminaColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                    fontSize: 11,
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
        height: 46, // Diperkecil dari 52
        child: ElevatedButton(
          onPressed: isLoading
              ? null
              : () => controller.submitRegister(onSuccess: onRegisterSuccess),
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
                    width: 20, // Loading indicator sedikit dikecilkan
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
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
                          fontWeight: FontWeight.w800,
                          fontSize: 16, // Font size disesuaikan dengan tinggi button
                        ),
                      ),
                      const SizedBox(width: LuminaSpacing.xs),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: LuminaColors.onPrimary,
                        size: 18,
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
        const Expanded(child: Divider(color: LuminaColors.surfaceVariant, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.sm),
          child: Text(
            'LUMINA LIBRARY',
            style: LuminaTextStyles.labelMd.copyWith(
              color: LuminaColors.outline,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              fontSize: 10,
            ),
          ),
        ),
        const Expanded(child: Divider(color: LuminaColors.surfaceVariant, height: 1)),
      ],
    );
  }
}

class _LoginTextButton extends StatelessWidget {
  const _LoginTextButton({required this.onLoginTap});

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
            fontSize: 13,
          ),
        ),
        TextButton(
          onPressed: onLoginTap ?? Get.back,
          style: TextButton.styleFrom(
            foregroundColor: LuminaColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Masuk disini',
            style: LuminaTextStyles.bodyMd.copyWith(
              color: LuminaColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
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
        fontSize: 14, // Teks field sedikit dirampingkan
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(
          icon,
          color: LuminaColors.onSurfaceVariant,
          size: 20, // Diperkecil dari 22
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
          vertical: 12, // Dibuat lebih compact dari sebelumnya (15)
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaRadius.md), // Radius field disesuaikan
          borderSide: const BorderSide(
            color: LuminaColors.outlineVariant,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaRadius.md),
          borderSide: const BorderSide(
            color: LuminaColors.primary,
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaRadius.md),
          borderSide: const BorderSide(
            color: LuminaColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaRadius.md),
          borderSide: const BorderSide(
            color: LuminaColors.error,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}

class _ProfileTypePickerSheet extends StatelessWidget {
  const _ProfileTypePickerSheet({
    required this.selectedId,
  });

  final String selectedId;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      padding: const EdgeInsets.fromLTRB(
        LuminaSpacing.marginMobile,
        LuminaSpacing.sm,
        LuminaSpacing.marginMobile,
        LuminaSpacing.marginMobile,
      ),
      decoration: const BoxDecoration(
        color: LuminaColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(LuminaRadius.xl),
          topRight: Radius.circular(LuminaRadius.xl),
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
                borderRadius: BorderRadius.circular(LuminaRadius.full),
              ),
            ),
            const SizedBox(height: LuminaSpacing.lg),
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: LuminaColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(LuminaRadius.lg),
                  ),
                  child: const Icon(
                    Icons.school_outlined,
                    color: LuminaColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: LuminaSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih Status',
                        style: LuminaTextStyles.headlineSm.copyWith(
                          color: LuminaColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Field register akan menyesuaikan pilihan Anda.',
                        style: LuminaTextStyles.bodyMd.copyWith(
                          color: LuminaColors.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: LuminaSpacing.lg),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: LibraryRegisterController.profileTypes.length,
                separatorBuilder: (_, __) {
                  return const SizedBox(height: LuminaSpacing.sm);
                },
                itemBuilder: (context, index) {
                  final item = LibraryRegisterController.profileTypes[index];
                  final isSelected = item.id == selectedId;

                  return _ProfileTypeOptionTile(
                    item: item,
                    isSelected: isSelected,
                    onTap: () {
                      Navigator.of(context).pop(item.id);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTypeOptionTile extends StatelessWidget {
  const _ProfileTypeOptionTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final LibraryRegisterProfileTypeModel item;
  final bool isSelected;
  final VoidCallback onTap;

  String get _fieldSummary {
    final fields = <String>[];

    if (item.showInstitution) {
      fields.add(item.institutionLabel);
    }

    if (item.showMajor) {
      fields.add(item.majorLabel);
    }

    if (item.showLevel) {
      fields.add(item.levelLabel);
    }

    if (fields.isEmpty) {
      return 'Tidak ada field tambahan';
    }

    return fields.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? LuminaColors.primary.withOpacity(0.08)
          : LuminaColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(LuminaRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(LuminaSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LuminaRadius.lg),
            border: Border.all(
              color: isSelected
                  ? LuminaColors.primary.withOpacity(0.28)
                  : LuminaColors.outlineVariant,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isSelected
                      ? LuminaColors.primary
                      : LuminaColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSelected
                      ? Icons.check_rounded
                      : Icons.person_search_outlined,
                  color: isSelected
                      ? LuminaColors.onPrimary
                      : LuminaColors.onSurfaceVariant,
                  size: 21,
                ),
              ),
              const SizedBox(width: LuminaSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: LuminaTextStyles.bodyLg.copyWith(
                        color: LuminaColors.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.description,
                      style: LuminaTextStyles.labelMd.copyWith(
                        color: LuminaColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        height: 1.32,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _fieldSummary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: LuminaTextStyles.labelMd.copyWith(
                        color: LuminaColors.primary,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}