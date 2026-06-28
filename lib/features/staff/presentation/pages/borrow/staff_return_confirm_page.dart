import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/staff/data/services/staff_api_service.dart';
import 'package:lumina_library/shared/widgets/feedback/lumina_toast.dart';
import 'package:lumina_library/shared/widgets/popups/realtime_popup_shell.dart';

/// Step 2 of the Return flow — staff already scanned the Return QR
/// (StaffScanController -> previewReturn()); this page lets them record
/// each book's physical condition before the backend finalizes the return
/// and validates payment status.
class StaffReturnConfirmPage extends StatefulWidget {
  const StaffReturnConfirmPage({super.key, required this.preview});

  final Map<String, dynamic> preview;

  @override
  State<StaffReturnConfirmPage> createState() => _StaffReturnConfirmPageState();
}

class _StaffReturnConfirmPageState extends State<StaffReturnConfirmPage> {
  static final _currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  late List<Map<String, dynamic>> _items;
  final Map<String, String> _conditions = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _items = (widget.preview['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
    for (final item in _items) {
      _conditions[item['borrowing_item_id'].toString()] = 'good';
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final borrowing = widget.preview['borrowing'] as Map<String, dynamic>? ?? {};
    final returnReview = widget.preview['return_review'] as Map<String, dynamic>? ?? {};

    try {
      final result = await Get.find<StaffApiService>().confirmReturn(
        qrCode: returnReview['qr_code']?.toString() ?? '',
        borrowingId: borrowing['id']?.toString() ?? '',
        items: _items
            .map((item) => {
                  'borrowing_item_id': item['borrowing_item_id'],
                  'book_item_id': item['book_item_id'],
                  'return_condition': _conditions[item['borrowing_item_id'].toString()] ?? 'good',
                })
            .toList(),
      );

      if (!mounted) return;

      final fine = result['fine'] as Map<String, dynamic>?;
      final returnSummary = result['return_summary'] as Map<String, dynamic>? ?? {};
      final paymentRequired = returnSummary['payment_required'] == true;

      await RealtimePopupShell.show(
        context,
        icon: paymentRequired ? Icons.payments_rounded : Icons.check_circle_rounded,
        iconColor: paymentRequired ? LuminaColors.error : LuminaColors.secondary,
        iconBackgroundColor: (paymentRequired ? LuminaColors.errorContainer : LuminaColors.secondaryContainer).withOpacity(0.35),
        title: paymentRequired ? 'Returned — Fine Due' : 'Return Successful!',
        message: paymentRequired
            ? 'Member harus membayar ${_currencyFormat.format(fine?['total_amount'] ?? 0)} melalui aplikasi.'
            : 'Buku berhasil dikembalikan tanpa biaya.',
        borrowingCode: borrowing['code']?.toString(),
        buttonLabel: 'Selesai',
      );

      Get.until((route) => route.isFirst);
    } on LuminaApiException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      LuminaToast.error(e.displayMessage);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      LuminaToast.error('Gagal memproses pengembalian.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final borrowing = widget.preview['borrowing'] as Map<String, dynamic>? ?? {};
    final member = widget.preview['member'] as Map<String, dynamic>? ?? {};
    final overdueDays = (borrowing['overdue_days'] as num?)?.toInt() ?? 0;

    return Scaffold(
      backgroundColor: LuminaColors.background,
      appBar: AppBar(
        backgroundColor: LuminaColors.surface,
        elevation: 0,
        foregroundColor: LuminaColors.primary,
        title: Text('Confirm Return', style: LuminaTextStyles.titleLg.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(LuminaSpacing.marginMobile, LuminaSpacing.lg, LuminaSpacing.marginMobile, LuminaSpacing.xl),
          children: [
            Container(
              padding: const EdgeInsets.all(LuminaSpacing.md),
              decoration: BoxDecoration(
                color: overdueDays > 0 ? LuminaColors.errorContainer.withOpacity(0.5) : LuminaColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(LuminaRadius.lg),
                border: Border.all(color: LuminaColors.outlineVariant),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member['fullname']?.toString() ?? '-', style: LuminaTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w900)),
                        Text(borrowing['code']?.toString() ?? '-', style: LuminaTextStyles.labelMd.copyWith(color: LuminaColors.outline, letterSpacing: 0)),
                      ],
                    ),
                  ),
                  if (overdueDays > 0)
                    Text('$overdueDays hari telat', style: LuminaTextStyles.labelMd.copyWith(color: LuminaColors.error, fontWeight: FontWeight.w800, letterSpacing: 0)),
                ],
              ),
            ),
            const SizedBox(height: LuminaSpacing.lg),
            Text('Item Condition', style: LuminaTextStyles.titleMd.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w800)),
            const SizedBox(height: LuminaSpacing.sm),
            for (final item in _items) _ReturnItemCard(
              item: item,
              selected: _conditions[item['borrowing_item_id'].toString()] ?? 'good',
              onChanged: (value) => setState(() => _conditions[item['borrowing_item_id'].toString()] = value),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(LuminaSpacing.marginMobile),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: LuminaColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LuminaRadius.full)),
              ),
              child: _isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Confirm Return', style: LuminaTextStyles.titleSm.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReturnItemCard extends StatelessWidget {
  const _ReturnItemCard({required this.item, required this.selected, required this.onChanged});

  final Map<String, dynamic> item;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final book = item['book'] as Map<String, dynamic>? ?? {};
    final options = (item['condition_options'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: LuminaSpacing.sm),
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
        border: Border.all(color: LuminaColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(book['title']?.toString() ?? 'Buku', style: LuminaTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: LuminaSpacing.sm),
          Wrap(
            spacing: LuminaSpacing.xs,
            runSpacing: LuminaSpacing.xs,
            children: options.map((option) {
              final value = option['value'].toString();
              final isSelected = value == selected;
              return ChoiceChip(
                label: Text(option['label'].toString()),
                selected: isSelected,
                onSelected: (_) => onChanged(value),
                selectedColor: LuminaColors.primary.withOpacity(0.15),
                labelStyle: TextStyle(color: isSelected ? LuminaColors.primary : LuminaColors.onSurfaceVariant, fontWeight: FontWeight.w700),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
