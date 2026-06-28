import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/staff/data/models/staff_member_model.dart';
import 'package:lumina_library/features/staff/data/services/staff_api_service.dart';
import 'package:lumina_library/shared/widgets/feedback/lumina_toast.dart';

/// Member Registration — staff onboards a walk-in member on the spot.
/// On success, the auto-generated password is shown ONCE (it's only ever
/// stored hashed) and the new member is returned to the caller via
/// `Get.back(result: member)` so the Borrow flow can continue immediately.
class StaffMemberRegistrationPage extends StatefulWidget {
  const StaffMemberRegistrationPage({super.key});

  @override
  State<StaffMemberRegistrationPage> createState() => _StaffMemberRegistrationPageState();
}

class _StaffMemberRegistrationPageState extends State<StaffMemberRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _studentIdCtrl = TextEditingController();
  final _fullnameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _facultyCtrl = TextEditingController();
  final _studyProgramCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String? _gender;
  File? _photo;
  bool _isSaving = false;

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1024, maxHeight: 1024);
    if (picked != null) setState(() => _photo = File(picked.path));
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_gender == null) {
      LuminaToast.warning('Gender wajib dipilih.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final result = await Get.find<StaffApiService>().registerMember(
        studentId: _studentIdCtrl.text.trim(),
        fullname: _fullnameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        faculty: _facultyCtrl.text.trim(),
        studyProgram: _studyProgramCtrl.text.trim(),
        gender: _gender!,
        address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
        photo: _photo,
      );

      if (!mounted) return;
      await _showCredentialsDialog(result.member, result.generatedPassword);
      if (mounted) Get.back(result: result.member);
    } on LuminaApiException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      LuminaToast.error(e.displayMessage);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      LuminaToast.error('Gagal mendaftarkan member.');
    }
  }

  Future<void> _showCredentialsDialog(StaffMemberModel member, String password) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: LuminaColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LuminaRadius.xl)),
        icon: const Icon(Icons.verified_user_rounded, color: LuminaColors.secondary, size: 40),
        title: Text('Member Registered', textAlign: TextAlign.center, style: LuminaTextStyles.titleMd.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${member.fullname} (${member.memberCode})', textAlign: TextAlign.center, style: LuminaTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: LuminaSpacing.md),
            Text('Temporary Password', style: LuminaTextStyles.labelMd.copyWith(color: LuminaColors.outline, letterSpacing: 0)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.md, vertical: LuminaSpacing.sm),
              decoration: BoxDecoration(color: LuminaColors.surfaceContainerLow, borderRadius: BorderRadius.circular(LuminaRadius.md)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(password, style: LuminaTextStyles.titleMd.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  const SizedBox(width: LuminaSpacing.xs),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: password));
                      LuminaToast.success('Password disalin.');
                    },
                    child: const Icon(Icons.copy_rounded, size: 18, color: LuminaColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: LuminaSpacing.sm),
            Text(
              'Catat dan sampaikan password ini kepada member sekarang — password tidak dapat ditampilkan ulang.',
              textAlign: TextAlign.center,
              style: LuminaTextStyles.labelMd.copyWith(color: LuminaColors.error, letterSpacing: 0),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: LuminaColors.primary, foregroundColor: Colors.white),
            child: const Text('OK, Sudah Dicatat'),
          ),
        ],
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
        title: Text('Register Member', style: LuminaTextStyles.titleLg.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(LuminaSpacing.marginMobile, LuminaSpacing.lg, LuminaSpacing.marginMobile, LuminaSpacing.xl),
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: LuminaColors.surfaceContainerHigh,
                    backgroundImage: _photo != null ? FileImage(_photo!) : null,
                    child: _photo == null ? const Icon(Icons.add_a_photo_rounded, color: LuminaColors.primary, size: 28) : null,
                  ),
                ),
              ),
              const SizedBox(height: LuminaSpacing.lg),
              _Field(label: 'Student ID (NIM)', controller: _studentIdCtrl, required: true),
              const SizedBox(height: LuminaSpacing.md),
              _Field(label: 'Full Name', controller: _fullnameCtrl, required: true),
              const SizedBox(height: LuminaSpacing.md),
              _Field(label: 'Email', controller: _emailCtrl, required: true, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: LuminaSpacing.md),
              _Field(label: 'Phone', controller: _phoneCtrl, required: true, keyboardType: TextInputType.phone),
              const SizedBox(height: LuminaSpacing.md),
              _Field(label: 'Faculty', controller: _facultyCtrl, required: true),
              const SizedBox(height: LuminaSpacing.md),
              _Field(label: 'Study Program', controller: _studyProgramCtrl, required: true),
              const SizedBox(height: LuminaSpacing.md),
              _GenderField(value: _gender, onChanged: (v) => setState(() => _gender = v)),
              const SizedBox(height: LuminaSpacing.md),
              _Field(label: 'Address (optional)', controller: _addressCtrl, required: false, maxLines: 3),
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
                      : Text('Register Member', style: LuminaTextStyles.titleSm.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.controller, required this.required, this.keyboardType, this.maxLines = 1});

  final String label;
  final TextEditingController controller;
  final bool required;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? '$label wajib diisi.' : null : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: LuminaColors.surfaceContainerLowest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(LuminaRadius.md), borderSide: BorderSide(color: LuminaColors.outlineVariant)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(LuminaRadius.md), borderSide: const BorderSide(color: LuminaColors.primary, width: 1.5)),
      ),
    );
  }
}

class _GenderField extends StatelessWidget {
  const _GenderField({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  static const _options = [(value: 'male', label: 'Male'), (value: 'female', label: 'Female'), (value: 'other', label: 'Other')];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender', style: LuminaTextStyles.labelMd.copyWith(color: LuminaColors.outline, fontWeight: FontWeight.w700, letterSpacing: 0)),
        const SizedBox(height: LuminaSpacing.xs),
        Row(
          children: [
            for (final option in _options) ...[
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(option.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: LuminaSpacing.sm),
                    decoration: BoxDecoration(
                      color: value == option.value ? LuminaColors.primary.withOpacity(0.10) : LuminaColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(LuminaRadius.md),
                      border: Border.all(color: value == option.value ? LuminaColors.primary : LuminaColors.outlineVariant, width: value == option.value ? 1.5 : 1),
                    ),
                    child: Text(option.label, textAlign: TextAlign.center, style: TextStyle(color: value == option.value ? LuminaColors.primary : LuminaColors.onSurfaceVariant, fontWeight: FontWeight.w700)),
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
