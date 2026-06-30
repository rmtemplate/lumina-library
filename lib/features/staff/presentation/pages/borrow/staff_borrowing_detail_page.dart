import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/staff/data/services/staff_api_service.dart';
import 'package:lumina_library/features/staff/presentation/controllers/payment/staff_payments_controller.dart';
import 'package:lumina_library/features/staff/presentation/pages/payment/staff_payments_page.dart';
import 'package:lumina_library/features/staff/presentation/pages/scan/staff_scan_page.dart';

class StaffBorrowingDetailPage extends StatefulWidget {
  const StaffBorrowingDetailPage({
    super.key,
    required this.borrowingId,
    this.borrowingCode,
  });

  final String borrowingId;
  final String? borrowingCode;

  @override
  State<StaffBorrowingDetailPage> createState() => _StaffBorrowingDetailPageState();
}

class _StaffBorrowingDetailPageState extends State<StaffBorrowingDetailPage> {
  static final _currency = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  Map<String, dynamic> _data = {};
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final data = await Get.find<StaffApiService>().getBorrowingDetail(widget.borrowingId);
      if (!mounted) return;
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat detail peminjaman.';
        _isLoading = false;
      });
    }
  }

  String get _status => (_data['computed_status'] ?? _data['raw_status'] ?? '').toString();
  String get _code => (_data['borrowing_code'] ?? widget.borrowingCode ?? '-').toString();
  Map<String, dynamic> get _member => (_data['member'] as Map<String, dynamic>?) ?? {};
  List<dynamic> get _items => (_data['items'] as List<dynamic>?) ?? [];
  Map<String, dynamic> get _actions => (_data['actions'] as Map<String, dynamic>?) ?? {};
  List<dynamic> get _timeline => (_data['timeline'] as List<dynamic>?) ?? [];
  double get _totalFine => ((_data['total_fine'] as num?)?.toDouble() ?? 0.0);
  int get _overdueDays => ((_data['overdue_days'] as num?)?.toInt() ?? 0);

  static (Color bg, Color fg, String label) statusStyle(String s) => switch (s) {
        'awaiting_pickup' => (const Color(0xFFE8F0FE), const Color(0xFF1A73E8), 'Menunggu Pengambilan'),
        'active' => (LuminaColors.primaryContainer, LuminaColors.onPrimaryContainer, 'Sedang Dipinjam'),
        'overdue' => (LuminaColors.errorContainer, LuminaColors.onErrorContainer, 'Terlambat'),
        'ready_for_return' => (
            LuminaColors.secondaryContainer,
            LuminaColors.onSecondaryContainer,
            'Siap Dikembalikan',
          ),
        'waiting_payment' => (const Color(0xFFFFF3E0), const Color(0xFFE65100), 'Menunggu Pembayaran'),
        'returned' || 'returned_with_fine' => (
            LuminaColors.surfaceContainerHighest,
            LuminaColors.onSurfaceVariant,
            'Selesai',
          ),
        'cancelled' => (LuminaColors.surfaceContainer, LuminaColors.onSurfaceVariant, 'Dibatalkan'),
        _ => (LuminaColors.surfaceContainer, LuminaColors.onSurfaceVariant, s),
      };

  @override
  Widget build(BuildContext context) {
    final (statusBg, statusFg, statusLabel) = statusStyle(_status);

    return Scaffold(
      backgroundColor: LuminaColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(LuminaSpacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 48, color: LuminaColors.error),
                        const SizedBox(height: LuminaSpacing.sm),
                        Text(_error, style: LuminaTextStyles.bodyMd.copyWith(color: LuminaColors.error)),
                        const SizedBox(height: LuminaSpacing.sm),
                        FilledButton(onPressed: _load, child: const Text('Coba Lagi')),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        backgroundColor: LuminaColors.surface,
                        foregroundColor: LuminaColors.primary,
                        elevation: 0,
                        pinned: true,
                        toolbarHeight: 64,
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _code,
                              style: LuminaTextStyles.titleMd.copyWith(
                                color: LuminaColors.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            _StatusChip(bg: statusBg, fg: statusFg, label: statusLabel),
                          ],
                        ),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded),
                            onPressed: _load,
                            tooltip: 'Muat Ulang',
                          ),
                        ],
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: LuminaSpacing.md)),

                      // ── Borrower Card ──────────────────────────────────
                      SliverToBoxAdapter(child: _BorrowerCard(member: _member)),
                      const SliverToBoxAdapter(child: SizedBox(height: LuminaSpacing.md)),

                      // ── Borrowing Info ─────────────────────────────────
                      SliverToBoxAdapter(child: _BorrowingInfoCard(data: _data)),
                      const SliverToBoxAdapter(child: SizedBox(height: LuminaSpacing.md)),

                      // ── Books ──────────────────────────────────────────
                      if (_items.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: _SectionLabel(
                            title: 'Buku yang Dipinjam',
                            trailing: Text(
                              '${_items.length} item',
                              style: LuminaTextStyles.labelMd.copyWith(
                                color: LuminaColors.onSurfaceVariant,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: LuminaSpacing.sm)),
                        SliverList.separated(
                          itemCount: _items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: LuminaSpacing.xs),
                          itemBuilder: (_, i) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: LuminaSpacing.marginMobile,
                            ),
                            child: _BookItemCard(
                              item: _items[i] as Map<String, dynamic>,
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: LuminaSpacing.md)),
                      ],

                      // ── Fine ──────────────────────────────────────────
                      if (_totalFine > 0 || _overdueDays > 0) ...[
                        SliverToBoxAdapter(
                          child: _FineCard(
                            data: _data,
                            currency: _currency,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: LuminaSpacing.md)),
                      ],

                      // ── Actions ────────────────────────────────────────
                      SliverToBoxAdapter(
                        child: _ActionsSection(
                          status: _status,
                          actions: _actions,
                          borrowingId: widget.borrowingId,
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: LuminaSpacing.md)),

                      // ── Timeline ───────────────────────────────────────
                      if (_timeline.isNotEmpty) ...[
                        SliverToBoxAdapter(child: _SectionLabel(title: 'Timeline Aktivitas')),
                        const SliverToBoxAdapter(child: SizedBox(height: LuminaSpacing.sm)),
                        SliverToBoxAdapter(child: _TimelineSection(timeline: _timeline)),
                        const SliverToBoxAdapter(child: SizedBox(height: LuminaSpacing.md)),
                      ],

                      // ── Staff Notes ────────────────────────────────────
                      if ((_data['notes'] as String?)?.isNotEmpty == true) ...[
                        SliverToBoxAdapter(child: _SectionLabel(title: 'Catatan Staff')),
                        const SliverToBoxAdapter(child: SizedBox(height: LuminaSpacing.sm)),
                        SliverToBoxAdapter(
                          child: _NotesCard(notes: _data['notes'].toString()),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: LuminaSpacing.md)),
                      ],

                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: LuminaSpacing.xl + MediaQuery.of(context).padding.bottom,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────────

String _fmtDate(String? iso) {
  if (iso == null || iso.isEmpty) return '-';
  try {
    return DateFormat('d MMM yyyy', 'id_ID').format(DateTime.parse(iso));
  } catch (_) {
    return iso;
  }
}

String _fmtDatetime(String? iso) {
  if (iso == null || iso.isEmpty) return '-';
  try {
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(DateTime.parse(iso).toLocal());
  } catch (_) {
    return iso;
  }
}

Widget _card({required Widget child}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.marginMobile),
      child: Container(
        decoration: BoxDecoration(
          color: LuminaColors.surfaceContainerLowest,
          borderRadius: LuminaRadius.card,
          border: Border.all(color: LuminaColors.outlineVariant.withValues(alpha: 0.30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(LuminaSpacing.md),
        child: child,
      ),
    );

Widget _infoRow(String label, String value, {bool mono = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 126,
            child: Text(
              label,
              style: LuminaTextStyles.labelMd.copyWith(
                color: LuminaColors.onSurfaceVariant,
                letterSpacing: 0,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: LuminaTextStyles.bodyMd.copyWith(
                color: LuminaColors.onBackground,
                fontWeight: FontWeight.w600,
                fontFamily: mono ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.bg, required this.fg, required this.label});
  final Color bg;
  final Color fg;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(
          label,
          style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0),
        ),
      );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.marginMobile),
        child: Row(
          children: [
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: LuminaColors.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            if (trailing != null) ...[const Spacer(), trailing!],
          ],
        ),
      );
}

// ── Borrower Card ──────────────────────────────────────────────────────────────

class _BorrowerCard extends StatelessWidget {
  const _BorrowerCard({required this.member});
  final Map<String, dynamic> member;

  String get _name => (member['fullname'] as String?) ?? '-';
  String get _code => (member['member_code'] as String?) ?? '';
  String get _phone => (member['phone'] as String?) ?? '';
  String get _email => (member['email'] as String?) ?? '';
  String get _institution => (member['institution_name'] as String?) ?? '';
  String get _major => (member['major_name'] as String?) ?? '';
  String get _level => (member['current_level'] as String?) ?? '';
  String get _gender => _humanizeGender((member['gender'] as String?) ?? '');
  String get _address => (member['address'] as String?) ?? '';
  String get _since => _fmtDate(member['member_since'] as String?);
  bool get _isActive => (member['is_active'] as bool?) ?? false;
  bool get _isVerified => (member['is_verified'] as bool?) ?? false;
  int get _totalBorrowings => (member['total_borrowings'] as num?)?.toInt() ?? 0;
  int get _activeBorrowings => (member['active_borrowings'] as num?)?.toInt() ?? 0;
  String? get _avatarUrl => member['avatar_url'] as String?;

  static String _humanizeGender(String g) => switch (g.toLowerCase()) {
        'male' || 'm' || 'laki-laki' => 'Laki-laki',
        'female' || 'f' || 'perempuan' => 'Perempuan',
        _ => g,
      };

  @override
  Widget build(BuildContext context) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + name row
          Row(
            children: [
              _Avatar(url: _avatarUrl, name: _name),
              const SizedBox(width: LuminaSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name,
                      style: LuminaTextStyles.titleMd.copyWith(
                        color: LuminaColors.onBackground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (_code.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          _chip(_code, LuminaColors.primaryContainer, LuminaColors.onPrimaryContainer),
                          if (_isVerified) ...[
                            const SizedBox(width: 6),
                            _chip('Terverifikasi', LuminaColors.secondaryContainer, LuminaColors.onSecondaryContainer),
                          ],
                          if (!_isActive) ...[
                            const SizedBox(width: 6),
                            _chip('Nonaktif', LuminaColors.errorContainer, LuminaColors.onErrorContainer),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: LuminaSpacing.lg, color: LuminaColors.outlineVariant),

          // Details
          if (_institution.isNotEmpty) _infoRow('Institusi', _institution),
          if (_major.isNotEmpty) _infoRow('Program Studi', '$_major${_level.isNotEmpty ? " · $_level" : ""}'),
          if (_gender.isNotEmpty) _infoRow('Jenis Kelamin', _gender),
          if (_address.isNotEmpty) _infoRow('Alamat', _address),
          _infoRow('Anggota Sejak', _since),

          const Divider(height: LuminaSpacing.lg, color: LuminaColors.outlineVariant),

          // Quick actions
          Row(
            children: [
              if (_phone.isNotEmpty) ...[
                Expanded(
                  child: _actionButton(
                    icon: Icons.call_rounded,
                    label: 'Telepon',
                    color: LuminaColors.secondary,
                    onTap: () => _launch('tel:$_phone'),
                  ),
                ),
                const SizedBox(width: LuminaSpacing.xs),
              ],
              if (_email.isNotEmpty) ...[
                Expanded(
                  child: _actionButton(
                    icon: Icons.email_rounded,
                    label: 'Email',
                    color: LuminaColors.primary,
                    onTap: () => _launch('mailto:$_email'),
                  ),
                ),
                const SizedBox(width: LuminaSpacing.xs),
              ],
              Expanded(
                child: _actionButton(
                  icon: Icons.history_rounded,
                  label: 'Riwayat',
                  color: LuminaColors.onSurfaceVariant,
                  onTap: () => _copyToClipboard(_code),
                ),
              ),
            ],
          ),

          const SizedBox(height: LuminaSpacing.sm),

          // Stats
          Row(
            children: [
              _statBubble('Total Pinjam', '$_totalBorrowings', LuminaColors.primaryContainer, LuminaColors.onPrimaryContainer),
              const SizedBox(width: LuminaSpacing.xs),
              _statBubble('Aktif', '$_activeBorrowings', LuminaColors.secondaryContainer, LuminaColors.onSecondaryContainer),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: TextStyle(color: fg, fontSize: 9, fontWeight: FontWeight.w800)),
      );

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) =>
      Material(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(LuminaRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(LuminaRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _statBubble(String label, String value, Color bg, Color fg) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: LuminaSpacing.sm),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(LuminaRadius.base)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(color: fg, fontSize: 20, fontWeight: FontWeight.w900)),
              Text(label, style: TextStyle(color: fg.withValues(alpha: 0.80), fontSize: 10, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) return;
    await launchUrl(uri);
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar('Disalin', 'Kode member "$text" telah disalin.',
        snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2));
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.url, required this.name});
  final String? url;
  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: LuminaColors.primaryContainer,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: url != null && url!.isNotEmpty
          ? Image.network(
              url!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _initials(initial),
            )
          : _initials(initial),
    );
  }

  Widget _initials(String ch) => Center(
        child: Text(
          ch,
          style: LuminaTextStyles.titleLg.copyWith(
            color: LuminaColors.onPrimaryContainer,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
}

// ── Borrowing Info Card ────────────────────────────────────────────────────────

class _BorrowingInfoCard extends StatelessWidget {
  const _BorrowingInfoCard({required this.data});
  final Map<String, dynamic> data;

  String _pickupMethod(String? m) => switch (m) {
        'staff_bypass' => 'Diambil Staff',
        'qr_scan' => 'Scan QR',
        'dev_bypass' => 'Dev Bypass',
        _ => m ?? '-',
      };

  @override
  Widget build(BuildContext context) {
    final branch = (data['branch'] as Map<String, dynamic>?) ?? {};

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded, size: 18, color: LuminaColors.primary),
              const SizedBox(width: LuminaSpacing.xs),
              Text(
                'Informasi Peminjaman',
                style: LuminaTextStyles.titleSm.copyWith(
                  color: LuminaColors.onBackground,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: LuminaSpacing.sm),
          _infoRow('Kode Pinjam', (data['borrowing_code'] as String?) ?? '-', mono: true),
          _infoRow('Tgl Pinjam', _fmtDate(data['borrow_date'] as String?)),
          _infoRow('Jatuh Tempo', _fmtDate(data['due_date'] as String?)),
          if ((data['approved_at'] as String?)?.isNotEmpty == true)
            _infoRow('Tgl Diambil', _fmtDatetime(data['approved_at'] as String?)),
          if ((data['return_date'] as String?)?.isNotEmpty == true)
            _infoRow('Tgl Kembali', _fmtDate(data['return_date'] as String?)),
          if ((data['reservation_expires_at'] as String?)?.isNotEmpty == true)
            _infoRow('Reservasi Berakhir', _fmtDatetime(data['reservation_expires_at'] as String?)),
          _infoRow('Cabang', (branch['name'] as String?) ?? '-'),
          _infoRow('Metode Pickup', _pickupMethod(data['pickup_method'] as String?)),
          if ((data['approved_by_name'] as String?)?.isNotEmpty == true)
            _infoRow('Disetujui Oleh', data['approved_by_name'].toString()),
          _infoRow('Dibuat', _fmtDatetime(data['created_at'] as String?)),
          _infoRow('Diperbarui', _fmtDatetime(data['updated_at'] as String?)),
        ],
      ),
    );
  }
}

// ── Book Item Card ─────────────────────────────────────────────────────────────

class _BookItemCard extends StatelessWidget {
  const _BookItemCard({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final book = (item['book'] as Map<String, dynamic>?) ?? {};
    final bookItem = (item['book_item'] as Map<String, dynamic>?) ?? {};
    final rack = item['rack'] as Map<String, dynamic>?;
    final branch = item['branch'] as Map<String, dynamic>?;
    final category = book['category'] as Map<String, dynamic>?;
    final coverUrl = book['cover_url'] as String?;
    final itemStatus = (item['status'] as String?) ?? '';

    final (statusBg, statusFg, statusLabel) =
        _StaffBorrowingDetailPageState.statusStyle(itemStatus);

    return Material(
      color: LuminaColors.surfaceContainerLowest,
      borderRadius: LuminaRadius.card,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showBookDetail(context, book, bookItem, rack, branch),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: LuminaRadius.card,
            border: Border.all(color: LuminaColors.outlineVariant.withValues(alpha: 0.30)),
          ),
          padding: const EdgeInsets.all(LuminaSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover
              ClipRRect(
                borderRadius: LuminaRadius.bookCover,
                child: SizedBox(
                  width: 52,
                  height: 72,
                  child: coverUrl != null && coverUrl.isNotEmpty
                      ? Image.network(
                          coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _coverPlaceholder(),
                        )
                      : _coverPlaceholder(),
                ),
              ),
              const SizedBox(width: LuminaSpacing.sm),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            (book['title'] as String?) ?? '-',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: LuminaTextStyles.bodyMd.copyWith(
                              color: LuminaColors.onBackground,
                              fontWeight: FontWeight.w800,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _StatusChip(bg: statusBg, fg: statusFg, label: statusLabel),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      (book['author'] as String?) ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LuminaTextStyles.bodySm.copyWith(color: LuminaColors.onSurfaceVariant),
                    ),
                    if (category != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: LuminaColors.tertiaryContainer.withValues(alpha: 0.50),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          (category['name'] as String?) ?? '',
                          style: TextStyle(
                            color: LuminaColors.onTertiaryContainer,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if ((bookItem['item_code'] as String?)?.isNotEmpty == true)
                          _metaChip(Icons.qr_code_rounded, bookItem['item_code'].toString()),
                        if (rack != null)
                          _metaChip(Icons.shelves, [rack['name'], rack['section_name']].where((e) => e != null && (e as String).isNotEmpty).join(' · ')),
                        if (branch != null)
                          _metaChip(Icons.location_on_rounded, (branch['name'] as String?) ?? ''),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right_rounded, size: 16, color: LuminaColors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _coverPlaceholder() => Container(
        color: LuminaColors.surfaceContainerLow,
        child: const Center(
          child: Icon(Icons.menu_book_rounded, size: 24, color: LuminaColors.onSurfaceVariant),
        ),
      );

  Widget _metaChip(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: LuminaColors.onSurfaceVariant),
          const SizedBox(width: 3),
          Text(
            text,
            style: const TextStyle(
              color: LuminaColors.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );

  void _showBookDetail(
    BuildContext context,
    Map<String, dynamic> book,
    Map<String, dynamic> bookItem,
    Map<String, dynamic>? rack,
    Map<String, dynamic>? branch,
  ) {
    Get.bottomSheet(
      _BookDetailSheet(book: book, bookItem: bookItem, rack: rack, branch: branch),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _BookDetailSheet extends StatelessWidget {
  const _BookDetailSheet({
    required this.book,
    required this.bookItem,
    this.rack,
    this.branch,
  });

  final Map<String, dynamic> book;
  final Map<String, dynamic> bookItem;
  final Map<String, dynamic>? rack;
  final Map<String, dynamic>? branch;

  @override
  Widget build(BuildContext context) {
    final coverUrl = book['cover_url'] as String?;
    final category = book['category'] as Map<String, dynamic>?;

    return Container(
      decoration: const BoxDecoration(
        color: LuminaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: LuminaSpacing.xs),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: LuminaColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              LuminaSpacing.marginMobile,
              LuminaSpacing.md,
              LuminaSpacing.marginMobile,
              LuminaSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 72,
                        height: 100,
                        child: coverUrl != null && coverUrl.isNotEmpty
                            ? Image.network(coverUrl, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _placeholder())
                            : _placeholder(),
                      ),
                    ),
                    const SizedBox(width: LuminaSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (book['title'] as String?) ?? '-',
                            style: LuminaTextStyles.titleMd.copyWith(
                              color: LuminaColors.onBackground,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (book['author'] as String?) ?? '-',
                            style: LuminaTextStyles.bodyMd.copyWith(
                              color: LuminaColors.onSurfaceVariant,
                            ),
                          ),
                          if (category != null) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: LuminaColors.tertiaryContainer.withValues(alpha: 0.50),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                (category['name'] as String?) ?? '',
                                style: TextStyle(
                                  color: LuminaColors.onTertiaryContainer,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: LuminaSpacing.md),
                const Divider(color: LuminaColors.outlineVariant),
                const SizedBox(height: LuminaSpacing.xs),
                if ((book['isbn'] as String?)?.isNotEmpty == true)
                  _infoRow('ISBN', book['isbn'].toString(), mono: true),
                if ((bookItem['item_code'] as String?)?.isNotEmpty == true)
                  _infoRow('Kode Item', bookItem['item_code'].toString(), mono: true),
                if ((bookItem['barcode'] as String?)?.isNotEmpty == true)
                  _infoRow('Barcode', bookItem['barcode'].toString(), mono: true),
                if (rack != null)
                  _infoRow('Rak', [rack!['name'], rack!['section_name'], rack!['floor_label']]
                      .where((e) => e != null && (e as String).isNotEmpty)
                      .join(', ')),
                if (branch != null)
                  _infoRow('Cabang', (branch!['name'] as String?) ?? '-'),
                if ((bookItem['condition_note'] as String?)?.isNotEmpty == true)
                  _infoRow('Kondisi', bookItem['condition_note'].toString()),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        color: LuminaColors.surfaceContainerLow,
        child: const Center(
          child: Icon(Icons.menu_book_rounded, size: 28, color: LuminaColors.onSurfaceVariant),
        ),
      );
}

// ── Fine Card ─────────────────────────────────────────────────────────────────

class _FineCard extends StatelessWidget {
  const _FineCard({required this.data, required this.currency});
  final Map<String, dynamic> data;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final overdueDays = (data['overdue_days'] as num?)?.toInt() ?? 0;
    final finePerDay = (data['fine_per_day'] as num?)?.toDouble() ?? 0;
    final totalFine = (data['total_fine'] as num?)?.toDouble() ?? 0;
    final payment = data['payment'] as Map<String, dynamic>?;
    final isPaid = payment != null && payment['status'] == 'paid';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.marginMobile),
      child: Container(
        decoration: BoxDecoration(
          color: LuminaColors.errorContainer,
          borderRadius: LuminaRadius.card,
          border: Border.all(color: LuminaColors.error.withValues(alpha: 0.20)),
        ),
        padding: const EdgeInsets.all(LuminaSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 18, color: LuminaColors.error),
                const SizedBox(width: LuminaSpacing.xs),
                Text(
                  'Informasi Denda',
                  style: LuminaTextStyles.titleSm.copyWith(
                    color: LuminaColors.onErrorContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                if (isPaid)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: LuminaColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Lunas',
                      style: TextStyle(
                        color: LuminaColors.onSecondaryContainer,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: LuminaSpacing.sm),
            _fineRow('Keterlambatan', '$overdueDays hari'),
            _fineRow('Denda/Hari', currency.format(finePerDay)),
            const Divider(color: LuminaColors.error, height: LuminaSpacing.md),
            _fineRow(
              isPaid ? 'Denda Dibayar' : 'Total Denda',
              currency.format(totalFine),
              bold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _fineRow(String label, String value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text(
              label,
              style: LuminaTextStyles.bodyMd.copyWith(
                color: LuminaColors.onErrorContainer.withValues(alpha: 0.80),
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: LuminaTextStyles.bodyMd.copyWith(
                color: LuminaColors.onErrorContainer,
                fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ],
        ),
      );
}

// ── Actions Section ────────────────────────────────────────────────────────────

class _ActionsSection extends StatelessWidget {
  const _ActionsSection({
    required this.status,
    required this.actions,
    required this.borrowingId,
  });

  final String status;
  final Map<String, dynamic> actions;
  final String borrowingId;

  @override
  Widget build(BuildContext context) {
    final canScanPickup = (actions['can_scan_pickup'] as bool?) ?? false;
    final canScanReturn = (actions['can_scan_return'] as bool?) ?? false;
    final paymentRequired = (actions['payment_required'] as bool?) ?? false;

    final buttons = <Widget>[];

    if (canScanPickup) {
      buttons.add(_ActionButton(
        icon: Icons.qr_code_scanner_rounded,
        label: 'Scan QR Pickup',
        filled: true,
        onTap: () => Get.to(() => const StaffScanPage()),
      ));
    }

    if (canScanReturn) {
      buttons.add(_ActionButton(
        icon: Icons.qr_code_scanner_rounded,
        label: 'Proses Pengembalian',
        filled: true,
        onTap: () => Get.to(() => const StaffScanPage()),
      ));
    }

    if (paymentRequired || status == 'waiting_payment') {
      buttons.add(_ActionButton(
        icon: Icons.payments_rounded,
        label: 'Lihat Pembayaran',
        filled: false,
        onTap: () {
          final c = Get.isRegistered<StaffPaymentsController>()
              ? Get.find<StaffPaymentsController>()
              : Get.put(StaffPaymentsController(), permanent: true);
          c.selectedTabIndex.value = 0;
          Get.to(() => const StaffPaymentsPage());
        },
      ));
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.marginMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons
            .expand((b) => [b, const SizedBox(height: LuminaSpacing.xs)])
            .toList()
          ..removeLast(),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: LuminaColors.primary,
          foregroundColor: LuminaColors.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: LuminaRadius.button),
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: LuminaColors.primary,
        side: const BorderSide(color: LuminaColors.primary),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: LuminaRadius.button),
      ),
    );
  }
}

// ── Timeline ───────────────────────────────────────────────────────────────────

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({required this.timeline});
  final List<dynamic> timeline;

  static IconData _iconForType(String type) => switch (type) {
        'borrow' => Icons.outbox_rounded,
        'return' => Icons.move_to_inbox_rounded,
        'overdue' => Icons.warning_rounded,
        'fine' => Icons.payments_rounded,
        'scan' => Icons.qr_code_scanner_rounded,
        _ => Icons.circle_notifications_rounded,
      };

  static Color _colorForType(String type) => switch (type) {
        'borrow' => LuminaColors.primary,
        'return' => LuminaColors.secondary,
        'overdue' => LuminaColors.error,
        'fine' => LuminaColors.error,
        _ => LuminaColors.onSurfaceVariant,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.marginMobile),
      child: Container(
        decoration: BoxDecoration(
          color: LuminaColors.surfaceContainerLowest,
          borderRadius: LuminaRadius.card,
          border: Border.all(color: LuminaColors.outlineVariant.withValues(alpha: 0.30)),
        ),
        padding: const EdgeInsets.symmetric(vertical: LuminaSpacing.sm, horizontal: LuminaSpacing.md),
        child: Column(
          children: List.generate(timeline.length, (i) {
            final entry = timeline[i] as Map<String, dynamic>;
            final type = (entry['type'] as String?) ?? '';
            final isLast = i == timeline.length - 1;
            final color = _colorForType(type);

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Line + dot
                  SizedBox(
                    width: 28,
                    child: Column(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_iconForType(type), size: 14, color: color),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: LuminaColors.outlineVariant.withValues(alpha: 0.40),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: LuminaSpacing.sm),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : LuminaSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (entry['title'] as String?) ?? type,
                            style: LuminaTextStyles.bodyMd.copyWith(
                              color: LuminaColors.onBackground,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if ((entry['subtitle'] as String?)?.isNotEmpty == true) ...[
                            const SizedBox(height: 2),
                            Text(
                              entry['subtitle'].toString(),
                              style: LuminaTextStyles.bodySm.copyWith(
                                color: LuminaColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                          const SizedBox(height: 3),
                          Text(
                            _fmtDatetime(entry['created_at'] as String?),
                            style: LuminaTextStyles.labelMd.copyWith(
                              color: LuminaColors.onSurfaceVariant.withValues(alpha: 0.70),
                              letterSpacing: 0,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ── Notes Card ─────────────────────────────────────────────────────────────────

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.notes});
  final String notes;

  @override
  Widget build(BuildContext context) => _card(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.sticky_note_2_rounded, size: 18, color: LuminaColors.onSurfaceVariant),
            const SizedBox(width: LuminaSpacing.xs),
            Expanded(
              child: Text(
                notes,
                style: LuminaTextStyles.bodyMd.copyWith(
                  color: LuminaColors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
}
