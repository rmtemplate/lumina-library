import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/core/services/websocket/websocket_event.dart';
import 'package:lumina_library/core/services/websocket/websocket_service.dart';
import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/staff/data/services/staff_api_service.dart';
import 'package:lumina_library/shared/widgets/feedback/lumina_toast.dart';
import 'package:lumina_library/shared/widgets/popups/realtime_popup_shell.dart';

/// Step 3 of the two-stage Return flow — staff already scanned the Return QR
/// (StaffScanController -> previewReturn()). If the loan was overdue, scanning
/// created a SEPARATE overdue payment and the loan is `waiting_overdue_payment`:
/// this page BLOCKS inspection until the student pays (realtime, via the
/// `borrowing.{id}` channel → action `overdue_payment_paid`). Once inspection is
/// allowed, staff verify each book, add manual charges, then confirm — which
/// creates the separate DAMAGE_CHARGE payment (or completes the loan).
class StaffReturnConfirmPage extends StatefulWidget {
  const StaffReturnConfirmPage({super.key, required this.preview});

  final Map<String, dynamic> preview;

  @override
  State<StaffReturnConfirmPage> createState() => _StaffReturnConfirmPageState();
}

class _StaffReturnConfirmPageState extends State<StaffReturnConfirmPage> {
  static final _currencyFormat =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  late List<Map<String, dynamic>> _items;
  final Map<String, String> _conditions = {};
  final List<_ManualCharge> _manualCharges = [];
  bool _isSubmitting = false;

  // ── Overdue gating ─────────────────────────────────────────────────────────
  // Inspection is blocked while the student still owes the separate overdue
  // payment. Realtime `overdue_payment_paid` on the borrowing channel unlocks it.
  bool _overdueRequired = false;
  bool _overduePaid = false;
  StreamSubscription<WebSocketEvent>? _wsSubscription;
  String? _channelName;

  bool get _canInspect => !_overdueRequired || _overduePaid;

  @override
  void initState() {
    super.initState();
    _items = (widget.preview['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
    for (final item in _items) {
      _conditions[item['borrowing_item_id'].toString()] = 'good';
    }

    // Scanning already set the loan's status: waiting_overdue_payment means the
    // student must pay overdue before staff may inspect.
    final rawStatus = _borrowing['raw_status']?.toString() ?? '';
    _overdueRequired = rawStatus == 'waiting_overdue_payment';
    _overduePaid = !_overdueRequired;

    _listenForOverduePayment();
  }

  void _listenForOverduePayment() {
    if (!_overdueRequired) return;
    if (!Get.isRegistered<WebSocketService>()) return;

    final ws = Get.find<WebSocketService>();
    final borrowingId = _borrowing['id']?.toString() ?? '';
    if (borrowingId.isEmpty) return;

    _channelName = 'borrowing.$borrowingId';
    ws.subscribeToPrivateChannel(_channelName!);

    _wsSubscription = ws.events.listen((event) {
      if (event.borrowingId != borrowingId) return;
      if (event.name != 'borrowing.updated') return;
      if (event.data['action'] == 'overdue_payment_paid') {
        if (mounted) {
          setState(() => _overduePaid = true);
          LuminaToast.success('Denda keterlambatan telah dibayar. Inspeksi buku dapat dilanjutkan.');
        }
      }
    });
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    if (_channelName != null && Get.isRegistered<WebSocketService>()) {
      Get.find<WebSocketService>().unsubscribe(_channelName!);
    }
    for (final c in _manualCharges) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Money ───────────────────────────────────────────────────────────────

  Map<String, dynamic> get _borrowing =>
      widget.preview['borrowing'] as Map<String, dynamic>? ?? {};

  /// Overdue fine (backend-computed) is a SEPARATE payment paid before
  /// inspection — shown here for context only, never part of the damage total.
  double get _overdueFine => (_borrowing['total_fine'] as num?)?.toDouble() ?? 0;

  double _feeForItem(Map<String, dynamic> item, String condition) {
    final options = (item['condition_options'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>();
    for (final o in options) {
      if (o['value'].toString() == condition) {
        return (o['fee'] as num?)?.toDouble() ?? 0;
      }
    }
    return 0;
  }

  double get _damageTotal => _items.fold(0, (sum, item) {
        final condition = _conditions[item['borrowing_item_id'].toString()] ?? 'good';
        return sum + _feeForItem(item, condition);
      });

  double get _manualTotal =>
      _manualCharges.fold(0, (sum, c) => sum + c.amount);

  /// Inspection stage total = damage + manual ONLY. Overdue is its own payment.
  double get _grandTotal => _damageTotal + _manualTotal;

  // ── Manual charges ────────────────────────────────────────────────────────

  void _addManualCharge() {
    setState(() => _manualCharges.add(_ManualCharge()));
  }

  void _removeManualCharge(int index) {
    setState(() => _manualCharges.removeAt(index)..dispose());
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (_isSubmitting) return;

    // Reject half-filled manual charges up-front (backend also validates).
    for (final c in _manualCharges) {
      if (c.titleController.text.trim().isEmpty || c.amount <= 0) {
        LuminaToast.error('Setiap biaya manual butuh judul dan nominal > 0.');
        return;
      }
    }

    setState(() => _isSubmitting = true);
    final returnReview = widget.preview['return_review'] as Map<String, dynamic>? ?? {};

    try {
      final result = await Get.find<StaffApiService>().confirmReturn(
        qrCode: returnReview['qr_code']?.toString() ?? '',
        borrowingId: _borrowing['id']?.toString() ?? '',
        items: _items
            .map((item) => {
                  'borrowing_item_id': item['borrowing_item_id'],
                  'book_item_id': item['book_item_id'],
                  'return_condition':
                      _conditions[item['borrowing_item_id'].toString()] ?? 'good',
                })
            .toList(),
        manualCharges: _manualCharges
            .map((c) => {
                  'title': c.titleController.text.trim(),
                  'description': c.descController.text.trim(),
                  'amount': c.amount,
                })
            .toList(),
      );

      if (!mounted) return;

      final returnSummary = result['return_summary'] as Map<String, dynamic>? ?? {};
      final paymentRequired = returnSummary['payment_required'] == true;

      await RealtimePopupShell.show(
        context,
        icon: paymentRequired ? Icons.payments_rounded : Icons.check_circle_rounded,
        iconColor: paymentRequired ? LuminaColors.error : LuminaColors.secondary,
        iconBackgroundColor: (paymentRequired
                ? LuminaColors.errorContainer
                : LuminaColors.secondaryContainer)
            .withOpacity(0.35),
        title: paymentRequired ? 'Terverifikasi — Ada Tagihan' : 'Pengembalian Selesai!',
        message: paymentRequired
            ? 'Member akan menerima tagihan ${_currencyFormat.format(_grandTotal)} secara realtime dan membayar via aplikasi.'
            : 'Buku berhasil dikembalikan tanpa biaya.',
        borrowingCode: _borrowing['code']?.toString(),
        buttonLabel: 'Selesai',
      );

      // Pop ONLY this confirm page. The scanner that pushed us (via Get.to in
      // StaffScanController.handleScan) then closes itself when handleScan
      // returns false. Using Get.until(isFirst) here popped the scanner too,
      // then the scanner's own pop() ran one extra time → past root → black
      // screen.
      if (Get.isDialogOpen ?? false) Get.back();
      Get.back();
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
    final member = widget.preview['member'] as Map<String, dynamic>? ?? {};
    final overdueDays = (_borrowing['overdue_days'] as num?)?.toInt() ?? 0;
    final dueDate = _borrowing['due_date']?.toString();

    return Scaffold(
      backgroundColor: LuminaColors.background,
      appBar: AppBar(
        backgroundColor: LuminaColors.surface,
        elevation: 0,
        foregroundColor: LuminaColors.primary,
        title: Text('Verifikasi Pengembalian',
            style: LuminaTextStyles.titleLg
                .copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(LuminaSpacing.marginMobile,
              LuminaSpacing.lg, LuminaSpacing.marginMobile, LuminaSpacing.xl),
          children: [
            // ── Overdue payment gate ──────────────────────────────────────
            if (_overdueRequired)
              _OverdueGateBanner(
                paid: _overduePaid,
                amountText: _currencyFormat.format(_overdueFine),
                overdueDays: overdueDays,
              ),

            // ── Borrower ──────────────────────────────────────────────────
            _Section(
              title: 'Peminjam',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member['fullname']?.toString() ?? '-',
                      style: LuminaTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(
                    '${_borrowing['code'] ?? '-'} · ${member['member_code'] ?? member['email'] ?? '-'}',
                    style: LuminaTextStyles.labelMd
                        .copyWith(color: LuminaColors.outline, letterSpacing: 0),
                  ),
                  const SizedBox(height: LuminaSpacing.sm),
                  Row(
                    children: [
                      _MiniStat(
                        label: 'Jatuh Tempo',
                        value: dueDate ?? '-',
                        color: LuminaColors.primary,
                      ),
                      const SizedBox(width: LuminaSpacing.sm),
                      _MiniStat(
                        label: 'Terlambat',
                        value: overdueDays > 0 ? '$overdueDays hari' : 'Tepat waktu',
                        color: overdueDays > 0 ? LuminaColors.error : LuminaColors.secondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Books / condition ─────────────────────────────────────────
            _Section(
              title: 'Kondisi Buku',
              child: Column(
                children: [
                  for (final item in _items)
                    _ReturnItemCard(
                      item: item,
                      selected: _conditions[item['borrowing_item_id'].toString()] ?? 'good',
                      currencyFormat: _currencyFormat,
                      onChanged: (value) => setState(() =>
                          _conditions[item['borrowing_item_id'].toString()] = value),
                    ),
                ],
              ),
            ),

            // ── Manual charges ────────────────────────────────────────────
            _Section(
              title: 'Biaya Manual',
              trailing: TextButton.icon(
                onPressed: _addManualCharge,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Tambah'),
                style: TextButton.styleFrom(foregroundColor: LuminaColors.primary),
              ),
              child: _manualCharges.isEmpty
                  ? Text('Belum ada biaya tambahan. Contoh: sampul rusak, biaya kebersihan, dll.',
                      style: LuminaTextStyles.labelMd
                          .copyWith(color: LuminaColors.outline, letterSpacing: 0))
                  : Column(
                      children: [
                        for (var i = 0; i < _manualCharges.length; i++)
                          _ManualChargeCard(
                            charge: _manualCharges[i],
                            currencyFormat: _currencyFormat,
                            onRemove: () => _removeManualCharge(i),
                            onChanged: () => setState(() {}),
                          ),
                      ],
                    ),
            ),

            // ── Payment summary ───────────────────────────────────────────
            _Section(
              title: 'Ringkasan Biaya Kerusakan',
              child: Column(
                children: [
                  _SummaryRow(label: 'Biaya Kerusakan', value: _currencyFormat.format(_damageTotal)),
                  _SummaryRow(label: 'Biaya Lain', value: _currencyFormat.format(_manualTotal)),
                  const Divider(height: LuminaSpacing.lg),
                  _SummaryRow(
                    label: 'Total Tagihan Kerusakan',
                    value: _currencyFormat.format(_grandTotal),
                    emphasize: true,
                  ),
                  const SizedBox(height: LuminaSpacing.xs),
                  Text(
                    _grandTotal > 0
                        ? 'Tagihan kerusakan ini terpisah dari denda keterlambatan. Member membayarnya via aplikasi setelah dikonfirmasi.'
                        : 'Tidak ada biaya kerusakan — pengembalian langsung selesai.',
                    style: LuminaTextStyles.labelMd
                        .copyWith(color: LuminaColors.outline, letterSpacing: 0),
                  ),
                ],
              ),
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
            height: 52,
            child: ElevatedButton(
              onPressed: (_isSubmitting || !_canInspect) ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: LuminaColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: LuminaColors.outlineVariant,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(LuminaRadius.full)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(
                      !_canInspect
                          ? 'Menunggu Pembayaran Denda'
                          : _grandTotal > 0
                              ? 'Konfirmasi & Tagih ${_currencyFormat.format(_grandTotal)}'
                              : 'Konfirmasi Pengembalian',
                      style: LuminaTextStyles.titleSm
                          .copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Realtime overdue-payment gate shown above the inspection form. Flips from
/// "waiting" (amber, form disabled) to "paid" (green) when the student settles
/// the separate overdue payment — driven by the `overdue_payment_paid` event.
class _OverdueGateBanner extends StatelessWidget {
  const _OverdueGateBanner({
    required this.paid,
    required this.amountText,
    required this.overdueDays,
  });

  final bool paid;
  final String amountText;
  final int overdueDays;

  @override
  Widget build(BuildContext context) {
    final color = paid ? LuminaColors.secondary : LuminaColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: LuminaSpacing.md),
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            paid ? Icons.verified_rounded : Icons.hourglass_top_rounded,
            color: color,
            size: 24,
          ),
          const SizedBox(width: LuminaSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paid ? 'Denda Keterlambatan Lunas' : 'Menunggu Pembayaran Denda',
                  style: LuminaTextStyles.bodyMd
                      .copyWith(color: color, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  paid
                      ? 'Pembayaran denda telah diterima. Silakan lanjutkan inspeksi buku.'
                      : 'Denda keterlambatan $amountText ($overdueDays hari) dibayar terpisah oleh member. Inspeksi buku aktif otomatis setelah lunas.',
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: LuminaColors.onSurfaceVariant,
                    letterSpacing: 0,
                    height: 1.35,
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

/// One staff-added manual charge — bundles its controllers so parse + dispose
/// stay together.
class _ManualCharge {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  double get amount =>
      double.tryParse(amountController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

  void dispose() {
    titleController.dispose();
    descController.dispose();
    amountController.dispose();
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: LuminaSpacing.md),
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.surface,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(color: LuminaColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title,
                  style: LuminaTextStyles.titleMd
                      .copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w900)),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: LuminaSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: LuminaSpacing.sm, vertical: LuminaSpacing.xs),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(LuminaRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: LuminaTextStyles.labelMd
                    .copyWith(color: LuminaColors.outline, letterSpacing: 0)),
            Text(value,
                style: LuminaTextStyles.bodyMd
                    .copyWith(color: color, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.emphasize = false});

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? LuminaTextStyles.titleMd.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w900)
        : LuminaTextStyles.bodyMd.copyWith(color: LuminaColors.onSurfaceVariant);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
}

class _ManualChargeCard extends StatelessWidget {
  const _ManualChargeCard({
    required this.charge,
    required this.currencyFormat,
    required this.onRemove,
    required this.onChanged,
  });

  final _ManualCharge charge;
  final NumberFormat currencyFormat;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: LuminaSpacing.sm),
      padding: const EdgeInsets.all(LuminaSpacing.sm),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
        border: Border.all(color: LuminaColors.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: charge.titleController,
                  onChanged: (_) => onChanged(),
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'Judul (mis. Sampul Rusak)',
                    border: InputBorder.none,
                  ),
                  style: LuminaTextStyles.bodyMd.copyWith(
                    color: LuminaColors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: onRemove,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close_rounded, color: LuminaColors.error, size: 20),
              ),
            ],
          ),
          TextField(
            controller: charge.descController,
            onChanged: (_) => onChanged(),
            decoration: const InputDecoration(
              isDense: true,
              hintText: 'Deskripsi (opsional)',
              border: InputBorder.none,
            ),
            style: LuminaTextStyles.labelMd.copyWith(
              color: LuminaColors.onSurface,
              letterSpacing: 0,
            ),
          ),
          const Divider(height: LuminaSpacing.sm),
          Row(
            children: [
              const Icon(Icons.payments_outlined, size: 16, color: LuminaColors.outline),
              const SizedBox(width: LuminaSpacing.xs),
              Text('Rp', style: LuminaTextStyles.bodyMd.copyWith(color: LuminaColors.outline)),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: charge.amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => onChanged(),
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: '0',
                    border: InputBorder.none,
                  ),
                  style: LuminaTextStyles.bodyMd.copyWith(
                    color: LuminaColors.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReturnItemCard extends StatelessWidget {
  const _ReturnItemCard({
    required this.item,
    required this.selected,
    required this.currencyFormat,
    required this.onChanged,
  });

  final Map<String, dynamic> item;
  final String selected;
  final NumberFormat currencyFormat;
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
          Text(book['title']?.toString() ?? 'Buku',
              style: LuminaTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: LuminaSpacing.sm),
          Wrap(
            spacing: LuminaSpacing.xs,
            runSpacing: LuminaSpacing.xs,
            children: options.map((option) {
              final value = option['value'].toString();
              final fee = (option['fee'] as num?)?.toDouble() ?? 0;
              final isSelected = value == selected;
              final label = fee > 0
                  ? '${option['label']} (+${currencyFormat.format(fee)})'
                  : option['label'].toString();
              return ChoiceChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (_) => onChanged(value),
                selectedColor: LuminaColors.primary.withOpacity(0.15),
                labelStyle: TextStyle(
                    color: isSelected ? LuminaColors.primary : LuminaColors.onSurfaceVariant,
                    fontWeight: FontWeight.w700),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
