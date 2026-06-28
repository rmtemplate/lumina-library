import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/mahasiswa/data/services/home_api_service.dart';
import 'package:lumina_library/features/staff/data/services/staff_api_service.dart';
import 'package:lumina_library/shared/models/category/category_model.dart';
import 'package:lumina_library/shared/widgets/feedback/lumina_toast.dart';

/// Book Registration — creates the catalog entry + `quantity` physical
/// copies, each with a printable QR. Opened either from the dashboard
/// quick action or automatically from the Universal Scanner's
/// "Book Not Registered" dialog (with the scanned code pre-filled as the
/// Book Code, since that's almost always what a librarian scanned).
class StaffBookRegistrationPage extends StatefulWidget {
  const StaffBookRegistrationPage({super.key, this.scannedCode});

  final String? scannedCode;

  @override
  State<StaffBookRegistrationPage> createState() => _StaffBookRegistrationPageState();
}

class _StaffBookRegistrationPageState extends State<StaffBookRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _isbnCtrl = TextEditingController();
  final _bookCodeCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _publisherCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController(text: '1');
  File? _cover;
  String? _categoryId;
  String? _rackId;
  bool _isSaving = false;
  bool _isLoadingOptions = true;
  List<CategoryModel> _categories = [];
  List<Map<String, dynamic>> _racks = [];

  @override
  void initState() {
    super.initState();
    _bookCodeCtrl.text = widget.scannedCode ?? '';
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    try {
      final categories = await Get.find<HomeApiService>().getCategories();
      final racks = await Get.find<StaffApiService>().getRacks();
      setState(() {
        _categories = categories;
        _racks = racks;
        _isLoadingOptions = false;
      });
    } catch (_) {
      setState(() => _isLoadingOptions = false);
    }
  }

  Future<void> _pickCover() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1200, maxHeight: 1600);
    if (picked != null) setState(() => _cover = File(picked.path));
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_categoryId == null) {
      LuminaToast.warning('Category wajib dipilih.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final result = await Get.find<StaffApiService>().registerBook(
        isbn: _isbnCtrl.text.trim().isEmpty ? null : _isbnCtrl.text.trim(),
        bookCode: _bookCodeCtrl.text.trim(),
        title: _titleCtrl.text.trim(),
        author: _authorCtrl.text.trim(),
        publisher: _publisherCtrl.text.trim().isEmpty ? null : _publisherCtrl.text.trim(),
        categoryId: _categoryId!,
        rackId: _rackId,
        quantity: int.tryParse(_quantityCtrl.text.trim()) ?? 1,
        cover: _cover,
      );

      if (!mounted) return;
      final items = (result['items'] as List<dynamic>? ?? []).whereType<Map<String, dynamic>>().toList();
      await Get.to(() => _StaffBookQrResultPage(title: _titleCtrl.text.trim(), items: items));
      if (mounted) Get.back();
    } on LuminaApiException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      LuminaToast.error(e.displayMessage);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      LuminaToast.error('Gagal mendaftarkan buku.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuminaColors.background,
      appBar: AppBar(
        backgroundColor: LuminaColors.surface,
        elevation: 0,
        foregroundColor: LuminaColors.primary,
        title: Text('Register Book', style: LuminaTextStyles.titleLg.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: _isLoadingOptions
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(LuminaSpacing.marginMobile, LuminaSpacing.lg, LuminaSpacing.marginMobile, LuminaSpacing.xl),
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickCover,
                        child: Container(
                          width: 110,
                          height: 150,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: LuminaColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(LuminaRadius.md),
                          ),
                          child: _cover != null
                              ? Image.file(_cover!, fit: BoxFit.cover)
                              : const Icon(Icons.add_photo_alternate_rounded, color: LuminaColors.primary, size: 32),
                        ),
                      ),
                    ),
                    const SizedBox(height: LuminaSpacing.lg),
                    _Field(label: 'ISBN (optional)', controller: _isbnCtrl, required: false),
                    const SizedBox(height: LuminaSpacing.md),
                    _Field(label: 'Book Code', controller: _bookCodeCtrl, required: true),
                    const SizedBox(height: LuminaSpacing.md),
                    _Field(label: 'Title', controller: _titleCtrl, required: true),
                    const SizedBox(height: LuminaSpacing.md),
                    _Field(label: 'Author', controller: _authorCtrl, required: true),
                    const SizedBox(height: LuminaSpacing.md),
                    _Field(label: 'Publisher (optional)', controller: _publisherCtrl, required: false),
                    const SizedBox(height: LuminaSpacing.md),
                    _Dropdown(
                      label: 'Category',
                      value: _categoryId,
                      items: _categories.map((c) => (value: c.id, label: c.name)).toList(),
                      onChanged: (v) => setState(() => _categoryId = v),
                    ),
                    const SizedBox(height: LuminaSpacing.md),
                    _Dropdown(
                      label: 'Shelf / Location (optional)',
                      value: _rackId,
                      items: _racks.map((r) => (value: r['id'].toString(), label: r['name']?.toString() ?? r['rack_code']?.toString() ?? '-')).toList(),
                      onChanged: (v) => setState(() => _rackId = v),
                    ),
                    const SizedBox(height: LuminaSpacing.md),
                    _Field(label: 'Quantity', controller: _quantityCtrl, required: true, keyboardType: TextInputType.number),
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
                            : Text('Register Book', style: LuminaTextStyles.titleSm.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
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
  const _Field({required this.label, required this.controller, required this.required, this.keyboardType});

  final String label;
  final TextEditingController controller;
  final bool required;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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

class _Dropdown extends StatelessWidget {
  const _Dropdown({required this.label, required this.value, required this.items, required this.onChanged});

  final String label;
  final String? value;
  final List<({String value, String label})> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items.map((item) => DropdownMenuItem(value: item.value, child: Text(item.label, overflow: TextOverflow.ellipsis))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: LuminaColors.surfaceContainerLowest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(LuminaRadius.md), borderSide: BorderSide(color: LuminaColors.outlineVariant)),
      ),
    );
  }
}

class _StaffBookQrResultPage extends StatelessWidget {
  const _StaffBookQrResultPage({required this.title, required this.items});

  final String title;
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuminaColors.background,
      appBar: AppBar(
        backgroundColor: LuminaColors.surface,
        elevation: 0,
        foregroundColor: LuminaColors.primary,
        title: Text('"$title" Registered', style: LuminaTextStyles.titleMd.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(LuminaSpacing.marginMobile),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: LuminaSpacing.md, crossAxisSpacing: LuminaSpacing.md, childAspectRatio: 0.8),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final qrImage = item['qr_image']?.toString() ?? '';
            return Container(
              padding: const EdgeInsets.all(LuminaSpacing.sm),
              decoration: BoxDecoration(color: LuminaColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(LuminaRadius.lg), border: Border.all(color: LuminaColors.outlineVariant)),
              child: Column(
                children: [
                  Expanded(
                    child: qrImage.startsWith('data:image')
                        ? Image.memory(
                            UriData.parse(qrImage).contentAsBytes(),
                            fit: BoxFit.contain,
                          )
                        : const Icon(Icons.qr_code_2_rounded, size: 64),
                  ),
                  const SizedBox(height: LuminaSpacing.xs),
                  Text(item['item_code']?.toString() ?? '', style: LuminaTextStyles.labelMd.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
