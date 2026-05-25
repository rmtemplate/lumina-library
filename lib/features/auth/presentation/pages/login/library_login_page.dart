import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/theme/lumina_colors.dart';
import '../../../../../core/theme/lumina_radius.dart';
import '../../../../../core/theme/lumina_spacing.dart';
import '../../../../../core/theme/lumina_text_styles.dart';
import '../../../data/controllers/library_login_controller.dart';

class LibraryLoginPage extends StatelessWidget {
  const LibraryLoginPage({
    super.key,
    this.logoAssetPath,
    this.onLoginSuccess,
    this.onRegisterTap,
    this.onForgotPasswordTap,
  });

  /// Isi nanti dengan path logo kamu.
  ///
  /// Contoh:
  /// logoAssetPath: 'assets/images/lumina_logo.png'
  final String? logoAssetPath;

  final VoidCallback? onLoginSuccess;
  final VoidCallback? onRegisterTap;
  final VoidCallback? onForgotPasswordTap;

  LibraryLoginController get controller {
    if (Get.isRegistered<LibraryLoginController>()) {
      return Get.find<LibraryLoginController>();
    }

    return Get.put(LibraryLoginController());
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
                maxWidth: 430,
              ),
              child: _LoginCard(
                controller: controller,
                logoAssetPath: logoAssetPath,
                onLoginSuccess: onLoginSuccess,
                onRegisterTap: onRegisterTap,
                onForgotPasswordTap: onForgotPasswordTap,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.controller,
    required this.logoAssetPath,
    required this.onLoginSuccess,
    required this.onRegisterTap,
    required this.onForgotPasswordTap,
  });

  final LibraryLoginController controller;
  final String? logoAssetPath;
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onRegisterTap;
  final VoidCallback? onForgotPasswordTap;

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
          const _LoginTopAccent(),

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
                  _LoginHeader(
                    logoAssetPath: logoAssetPath,
                  ),

                  const SizedBox(height: LuminaSpacing.xl),

                  _LoginEmailField(
                    controller: controller,
                  ),

                  const SizedBox(height: LuminaSpacing.md),

                  _LoginPasswordField(
                    controller: controller,
                  ),

                  const SizedBox(height: LuminaSpacing.sm),

                  _ForgotPasswordButton(
                    onTap: onForgotPasswordTap,
                  ),

                  const SizedBox(height: LuminaSpacing.md),

                  _LoginSubmitButton(
                    controller: controller,
                    onLoginSuccess: onLoginSuccess,
                  ),

                  const SizedBox(height: LuminaSpacing.xl),

                  const _LoginDivider(),

                  const SizedBox(height: LuminaSpacing.lg),

                  _RegisterTextButton(
                    onRegisterTap: onRegisterTap,
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

class _LoginTopAccent extends StatelessWidget {
  const _LoginTopAccent();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 7,
      width: double.infinity,
      color: LuminaColors.primary,
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader({
    required this.logoAssetPath,
  });

  final String? logoAssetPath;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _LoginLogo(
          logoAssetPath: logoAssetPath,
        ),

        const SizedBox(height: LuminaSpacing.lg),

        Text(
          'Selamat Datang',
          textAlign: TextAlign.center,
          style: LuminaTextStyles.displayLgMobile.copyWith(
            color: LuminaColors.primary,
            fontWeight: FontWeight.w900,
            height: 1.12,
          ),
        ),

        const SizedBox(height: LuminaSpacing.xs),

        Text(
          'Masuk ke akun Lumina Library Anda.',
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

class _LoginLogo extends StatelessWidget {
  const _LoginLogo({
    required this.logoAssetPath,
  });

  final String? logoAssetPath;

  @override
  Widget build(BuildContext context) {
    final hasLogo = logoAssetPath != null && logoAssetPath!.trim().isNotEmpty;

    if (!hasLogo) {
      return const _LoginLogoFallback();
    }

    return SizedBox(
      width: 86,
      height: 86,
      child: Image.asset(
        logoAssetPath!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return const _LoginLogoFallback();
        },
      ),
    );
  }
}

class _LoginLogoFallback extends StatelessWidget {
  const _LoginLogoFallback();

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

class _LoginEmailField extends StatelessWidget {
  const _LoginEmailField({
    required this.controller,
  });

  final LibraryLoginController controller;

  @override
  Widget build(BuildContext context) {
    return _AuthTextField(
      controller: controller.emailController,
      label: 'Email',
      hintText: 'Masukkan email Anda',
      icon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: controller.validateEmail,
    );
  }
}

class _LoginPasswordField extends StatelessWidget {
  const _LoginPasswordField({
    required this.controller,
  });

  final LibraryLoginController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isVisible = controller.isPasswordVisible.value;

      return _AuthTextField(
        controller: controller.passwordController,
        label: 'Password',
        hintText: 'Masukkan password',
        icon: Icons.lock_outline_rounded,
        obscureText: !isVisible,
        textInputAction: TextInputAction.done,
        validator: controller.validatePassword,
        onSubmitted: (_) {
          controller.submitLogin();
        },
        suffixIcon: IconButton(
          onPressed: controller.togglePasswordVisibility,
          icon: Icon(
            isVisible
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            color: LuminaColors.onSurfaceVariant,
            size: 21,
          ),
        ),
      );
    });
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

class _ForgotPasswordButton extends StatelessWidget {
  const _ForgotPasswordButton({
    required this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onTap ??
            () {
              Get.snackbar(
                'Lupa Password',
                'Fitur lupa password belum tersedia.',
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 2),
              );
            },
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
          'Lupa Password?',
          style: LuminaTextStyles.labelMd.copyWith(
            color: LuminaColors.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
            decoration: TextDecoration.underline,
            decorationColor: LuminaColors.primary,
          ),
        ),
      ),
    );
  }
}

class _LoginSubmitButton extends StatelessWidget {
  const _LoginSubmitButton({
    required this.controller,
    required this.onLoginSuccess,
  });

  final LibraryLoginController controller;
  final VoidCallback? onLoginSuccess;

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
                  controller.submitLogin(
                    onSuccess: onLoginSuccess,
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
                    key: ValueKey('login-loading'),
                    width: 23,
                    height: 23,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: LuminaColors.onPrimary,
                    ),
                  )
                : Row(
                    key: const ValueKey('login-label'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Masuk',
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

class _LoginDivider extends StatelessWidget {
  const _LoginDivider();

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

class _RegisterTextButton extends StatelessWidget {
  const _RegisterTextButton({
    required this.onRegisterTap,
  });

  final VoidCallback? onRegisterTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Belum memiliki akun?',
          style: LuminaTextStyles.bodyMd.copyWith(
            color: LuminaColors.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: onRegisterTap ??
              () {
                Get.snackbar(
                  'Register',
                  'Halaman register belum tersedia.',
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 2),
                );
              },
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
            'Register disini',
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