import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/shared/controllers/lumina_profile_controller.dart';
import 'package:lumina_library/shared/models/profile/lumina_profile_models.dart';
import 'package:lumina_library/shared/widgets/feedback/lumina_toast.dart';
import 'package:lumina_library/shared/widgets/profile/profile_avatar.dart';

/// Edit Profile page — full name, phone, address, date of birth, gender are
/// editable; Student ID / Membership Number are shown read-only and never
/// sent in the update payload (mirrors the backend's allowedFields guard
/// in AccountService::updateProfile, which would silently ignore them
/// anyway — this is the UI-side reinforcement of that same rule).
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.controller});

  final LuminaProfileController controller;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullnameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  DateTime? _dateOfBirth;
  String? _gender;
  bool _isSaving = false;

  LuminaProfileDataModel get _profile => widget.controller.profile.value;

  @override
  void initState() {
    super.initState();
    _fullnameCtrl = TextEditingController(text: _profile.fullname);
    _phoneCtrl = TextEditingController(text: _profile.phone ?? '');
    _addressCtrl = TextEditingController(text: _profile.address ?? '');
    _dateOfBirth = _profile.dateOfBirth;
    _gender = _profile.gender;
  }

  @override
  void dispose() {
    _fullnameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 20),
      firstDate: DateTime(1940),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: LuminaColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      await widget.controller.updateProfile(
        fullname: _fullnameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
        dateOfBirth: _dateOfBirth,
        gender: _gender,
      );
      if (!mounted) return;
      LuminaToast.success('Profil berhasil diperbarui.');
      Get.back();
    } on LuminaApiException catch (e) {
      if (!mounted) return;
      LuminaToast.error(e.displayMessage);
    } catch (_) {
      if (!mounted) return;
      LuminaToast.error('Gagal memperbarui profil. Silakan coba lagi.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    final dobText = _dateOfBirth == null
        ? 'Belum diatur'
        : '${_dateOfBirth!.day.toString().padLeft(2, '0')}/${_dateOfBirth!.month.toString().padLeft(2, '0')}/${_dateOfBirth!.year}';

    return Scaffold(
      backgroundColor: LuminaColors.background,
      appBar: AppBar(
        backgroundColor: LuminaColors.surface,
        elevation: 0,
        foregroundColor: LuminaColors.primary,
        title: Text(
          'Edit Profile',
          style: LuminaTextStyles.titleLg.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              LuminaSpacing.marginMobile,
              LuminaSpacing.lg,
              LuminaSpacing.marginMobile,
              LuminaSpacing.xl,
            ),
            children: [
              Center(
                child: Obx(() => ProfileAvatar(
                  avatarUrl: profile.avatarUrl,
                  localFile: widget.controller.pendingAvatarFile.value,
                  size: 88,
                  isUploading: widget.controller.isUploadingPhoto.value,
                  onEditTap: widget.controller.editProfilePhoto,
                )),
              ),
              const SizedBox(height: LuminaSpacing.lg),
              _ReadOnlyField(label: 'Student ID / NIM', value: profile.memberCode ?? '-'),
              const SizedBox(height: LuminaSpacing.md),
              _ReadOnlyField(label: 'Email', value: profile.email),
              const SizedBox(height: LuminaSpacing.lg),
              _SectionLabel('Editable Information'),
              const SizedBox(height: LuminaSpacing.xs),
              _EditableField(
                label: 'Full Name',
                controller: _fullnameCtrl,
                validator: (v) => (v == null || v.trim().length < 2) ? 'Nama lengkap minimal 2 karakter.' : null,
              ),
              const SizedBox(height: LuminaSpacing.md),
              _EditableField(
                label: 'Phone Number',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: LuminaSpacing.md),
              _EditableField(
                label: 'Address (optional)',
                controller: _addressCtrl,
                maxLines: 3,
              ),
              const SizedBox(height: LuminaSpacing.md),
              InkWell(
                borderRadius: BorderRadius.circular(LuminaRadius.md),
                onTap: _pickDateOfBirth,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date of Birth (optional)',
                    filled: true,
                    fillColor: LuminaColors.surfaceContainerLowest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(LuminaRadius.md),
                      borderSide: BorderSide(color: LuminaColors.outlineVariant),
                    ),
                    suffixIcon: const Icon(Icons.calendar_today_rounded, color: LuminaColors.outline, size: 18),
                  ),
                  child: Text(dobText, style: LuminaTextStyles.bodyMd.copyWith(color: LuminaColors.onSurface)),
                ),
              ),
              const SizedBox(height: LuminaSpacing.md),
              _GenderSelector(value: _gender, onChanged: (v) => setState(() => _gender = v)),
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
                          'Save Changes',
                          style: LuminaTextStyles.titleSm.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: LuminaTextStyles.labelMd.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w900, letterSpacing: 1),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: LuminaColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaRadius.md),
          borderSide: BorderSide(color: LuminaColors.outlineVariant),
        ),
        suffixIcon: const Icon(Icons.lock_outline_rounded, color: LuminaColors.outline, size: 16),
      ),
      child: Text(
        value,
        style: LuminaTextStyles.bodyMd.copyWith(color: LuminaColors.onSurfaceVariant, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  const _EditableField({
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: LuminaTextStyles.bodyMd.copyWith(color: LuminaColors.onSurface),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: LuminaColors.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaRadius.md),
          borderSide: BorderSide(color: LuminaColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LuminaRadius.md),
          borderSide: const BorderSide(color: LuminaColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _GenderSelector extends StatelessWidget {
  const _GenderSelector({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  static const _options = [
    (value: 'male', label: 'Male'),
    (value: 'female', label: 'Female'),
    (value: 'other', label: 'Other'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender (optional)',
          style: LuminaTextStyles.labelMd.copyWith(color: LuminaColors.outline, fontWeight: FontWeight.w700, letterSpacing: 0),
        ),
        const SizedBox(height: LuminaSpacing.xs),
        Row(
          children: [
            for (final option in _options) ...[
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(value == option.value ? null : option.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: LuminaSpacing.sm),
                    decoration: BoxDecoration(
                      color: value == option.value ? LuminaColors.primary.withOpacity(0.10) : LuminaColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(LuminaRadius.md),
                      border: Border.all(
                        color: value == option.value ? LuminaColors.primary : LuminaColors.outlineVariant,
                        width: value == option.value ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      option.label,
                      textAlign: TextAlign.center,
                      style: LuminaTextStyles.bodyMd.copyWith(
                        color: value == option.value ? LuminaColors.primary : LuminaColors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              if (option != _options.last) const SizedBox(width: LuminaSpacing.xs),
            ],
          ],
        ),
      ],
    );
  }
}
