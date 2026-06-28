import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';

/// Reusable Current/New/Confirm password form with built-in frontend
/// validation (min length, match check) — used by the dedicated Change
/// Password page. Submission/business-logic (calling the API, mapping
/// backend errors) stays in the page/controller, not here.
class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({
    super.key,
    required this.formKey,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    this.logoutOtherSessions = false,
    this.onLogoutOtherSessionsChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final bool logoutOtherSessions;
  final ValueChanged<bool>? onLogoutOtherSessionsChanged;

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PasswordField(
            label: 'Current Password',
            controller: widget.currentPasswordController,
            obscure: _obscureCurrent,
            onToggleObscure: () => setState(() => _obscureCurrent = !_obscureCurrent),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password saat ini wajib diisi.';
              return null;
            },
          ),
          const SizedBox(height: LuminaSpacing.md),
          _PasswordField(
            label: 'New Password',
            controller: widget.newPasswordController,
            obscure: _obscureNew,
            onToggleObscure: () => setState(() => _obscureNew = !_obscureNew),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password baru wajib diisi.';
              if (value.length < 8) return 'Password baru minimal 8 karakter.';
              if (value == widget.currentPasswordController.text) {
                return 'Password baru tidak boleh sama dengan password lama.';
              }
              return null;
            },
          ),
          const SizedBox(height: LuminaSpacing.md),
          _PasswordField(
            label: 'Confirm New Password',
            controller: widget.confirmPasswordController,
            obscure: _obscureConfirm,
            onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Konfirmasi password wajib diisi.';
              if (value != widget.newPasswordController.text) return 'Konfirmasi password tidak cocok.';
              return null;
            },
          ),
          const SizedBox(height: LuminaSpacing.md),
          InkWell(
            borderRadius: BorderRadius.circular(LuminaRadius.md),
            onTap: widget.onLogoutOtherSessionsChanged == null
                ? null
                : () => widget.onLogoutOtherSessionsChanged!(!widget.logoutOtherSessions),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: LuminaSpacing.xs),
              child: Row(
                children: [
                  Checkbox(
                    value: widget.logoutOtherSessions,
                    activeColor: LuminaColors.primary,
                    onChanged: widget.onLogoutOtherSessionsChanged == null
                        ? null
                        : (value) => widget.onLogoutOtherSessionsChanged!(value ?? false),
                  ),
                  Expanded(
                    child: Text(
                      'Log out from all other devices',
                      style: LuminaTextStyles.bodyMd.copyWith(
                        color: LuminaColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggleObscure,
    required this.validator,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: LuminaTextStyles.bodyMd.copyWith(color: LuminaColors.onSurface),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: LuminaColors.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaRadius.md),
          borderSide: BorderSide(color: LuminaColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaRadius.md),
          borderSide: BorderSide(color: LuminaColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaRadius.md),
          borderSide: const BorderSide(color: LuminaColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaRadius.md),
          borderSide: const BorderSide(color: LuminaColors.error),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: LuminaColors.outline,
          ),
          onPressed: onToggleObscure,
        ),
      ),
    );
  }
}
