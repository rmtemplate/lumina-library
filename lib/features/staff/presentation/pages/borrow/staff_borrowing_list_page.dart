import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/theme/lumina_colors.dart';
import '../../../../../core/theme/lumina_radius.dart';
import '../../../../../core/theme/lumina_spacing.dart';
import '../../../../../core/theme/lumina_text_styles.dart';
import '../../../data/services/staff_api_service.dart';
import 'staff_borrowing_detail_page.dart';

/// Branch-scoped borrowing list, reused for all KPI card navigation.
/// [initialStatus]: awaiting_pickup | active | overdue | returned | null (all)
class StaffBorrowingListPage extends StatefulWidget {
  const StaffBorrowingListPage({super.key, this.title, this.initialStatus});

  final String? title;
  final String? initialStatus;

  @override
  State<StaffBorrowingListPage> createState() => _StaffBorrowingListPageState();
}

class _StaffBorrowingListPageState extends State<StaffBorrowingListPage> {
  final _items = <Map<String, dynamic>>[];
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
      final items = await Get.find<StaffApiService>().listBorrowings(
        status: widget.initialStatus,
        perPage: 50,
      );
      if (!mounted) return;
      setState(() {
        _items.clear();
        _items.addAll(items);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat data peminjaman.';
        _isLoading = false;
      });
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
        title: Text(
          widget.title ?? 'Peminjaman',
          style: LuminaTextStyles.titleLg.copyWith(
            color: LuminaColors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error, style: LuminaTextStyles.bodyMd.copyWith(color: LuminaColors.error)),
                      const SizedBox(height: LuminaSpacing.sm),
                      OutlinedButton(onPressed: _load, child: const Text('Coba Lagi')),
                    ],
                  ),
                )
              : _items.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada data peminjaman.',
                        style: LuminaTextStyles.bodyMd.copyWith(color: LuminaColors.onSurfaceVariant),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          LuminaSpacing.marginMobile,
                          LuminaSpacing.md,
                          LuminaSpacing.marginMobile,
                          LuminaSpacing.xl,
                        ),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: LuminaSpacing.sm),
                        itemBuilder: (_, i) => _BorrowingTile(item: _items[i]),
                      ),
                    ),
    );
  }
}

class _BorrowingTile extends StatelessWidget {
  const _BorrowingTile({required this.item});

  final Map<String, dynamic> item;

  String get _status => (item['computed_status'] ?? item['raw_status'] ?? '').toString();
  String get _memberName => ((item['member'] as Map<String, dynamic>?)?['fullname'] ?? '-').toString();
  String get _code => (item['borrowing_code'] ?? '').toString();
  String get _borrowDate => (item['borrow_date'] ?? '').toString();
  String get _dueDate => (item['due_date'] ?? '').toString();
  int get _itemsCount => (item['items_count'] as num?)?.toInt() ?? 0;

  Color get _statusColor => switch (_status) {
        'overdue' || 'waiting_payment' => LuminaColors.error,
        'returned' => LuminaColors.onSurfaceVariant,
        'awaiting_pickup' => const Color(0xFF1A73E8),
        'ready_for_return' => LuminaColors.secondary,
        _ => LuminaColors.primary,
      };

  String get _statusLabel => switch (_status) {
        'awaiting_pickup' => 'Menunggu',
        'active' => 'Dipinjam',
        'overdue' => 'Terlambat',
        'ready_for_return' => 'Siap Kembali',
        'waiting_payment' => 'Bayar',
        'returned' => 'Selesai',
        _ => _status,
      };

  String get _id => (item['id'] ?? '').toString();

  void _openDetail() {
    if (_id.isEmpty) return;
    Get.to(() => StaffBorrowingDetailPage(borrowingId: _id, borrowingCode: _code));
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor;

    return Material(
      color: LuminaColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(LuminaRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _openDetail,
        child: _body(color),
      ),
    );
  }

  Widget _body(Color color) => Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
        border: Border.all(color: LuminaColors.outlineVariant.withOpacity(0.40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar circle
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _memberName.isNotEmpty ? _memberName[0].toUpperCase() : '?',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: LuminaSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _memberName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LuminaTextStyles.bodyMd.copyWith(
                    color: LuminaColors.onBackground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$_code · $_itemsCount buku',
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: LuminaColors.onSurfaceVariant,
                    letterSpacing: 0,
                  ),
                ),
                if (_borrowDate.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Pinjam: $_borrowDate${_dueDate.isNotEmpty ? ' · Jatuh: $_dueDate' : ''}',
                    style: LuminaTextStyles.labelMd.copyWith(
                      color: LuminaColors.onSurfaceVariant,
                      letterSpacing: 0,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: LuminaSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(LuminaRadius.full),
            ),
            child: Text(
              _statusLabel,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
}
