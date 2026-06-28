import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:lumina_library/features/staff/data/services/staff_api_service.dart';
import 'package:lumina_library/features/staff/presentation/models/staff_report_model.dart';

/// Reports module — Borrow/Return/Overdue (via `loans`+`returns`), Payment,
/// Member, and Book reports, all from the single GET /staff/reports?period=
/// endpoint. Date filtering is the `period` enum the backend already
/// supports (week/month/year); "Search" is the most-borrowed list filter
/// applied client-side (`searchQuery`), since the report payload is a
/// small aggregate, not a paginated table worth round-tripping per
/// keystroke.
class StaffReportController extends GetxController {
  static final _currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  final RxString selectedPeriod = 'month'.obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;

  final Rx<Map<String, dynamic>> _report = Rx<Map<String, dynamic>>({});

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      _report.value = await Get.find<StaffApiService>().getReport(period: selectedPeriod.value);
    } catch (_) {
      _report.value = {};
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reload() => _load();

  void setSelectedPeriod(String value) {
    if (value.trim().isEmpty || selectedPeriod.value == value) return;
    selectedPeriod.value = value;
    _load();
  }

  void setSearchQuery(String value) => searchQuery.value = value;

  String get periodLabel => switch (selectedPeriod.value) {
        'week' => 'This Week',
        'year' => 'This Year',
        _ => 'This Month',
      };

  Map<String, dynamic> get _loans => _report.value['loans'] as Map<String, dynamic>? ?? {};
  Map<String, dynamic> get _returns => _report.value['returns'] as Map<String, dynamic>? ?? {};
  Map<String, dynamic> get _fines => _report.value['fines'] as Map<String, dynamic>? ?? {};
  Map<String, dynamic> get _books => _report.value['books'] as Map<String, dynamic>? ?? {};
  Map<String, dynamic> get _payments => _report.value['payments'] as Map<String, dynamic>? ?? {};
  Map<String, dynamic> get _members => _report.value['members'] as Map<String, dynamic>? ?? {};

  // ── Borrow / Return / Overdue ───────────────────────────────────────────

  int get totalLoans => (_loans['total'] as num?)?.toInt() ?? 0;
  int get activeLoans => (_loans['active'] as num?)?.toInt() ?? 0;
  int get overdueLoans => (_loans['overdue'] as num?)?.toInt() ?? 0;
  int get totalReturns => (_returns['total'] as num?)?.toInt() ?? 0;
  double get onTimeReturnPct => (_returns['on_time_pct'] as num?)?.toDouble() ?? 0;

  // ── Payment ──────────────────────────────────────────────────────────────

  String get totalUnpaidFinesText => _currencyFormat.format((_fines['total_unpaid'] as num?) ?? 0);
  String get totalPaidAmountText => _currencyFormat.format((_payments['total_paid_amount'] as num?) ?? 0);
  int get pendingPaymentsCount => (_payments['pending'] as num?)?.toInt() ?? 0;

  // ── Member ───────────────────────────────────────────────────────────────

  int get newMembersInPeriod => (_members['new_registrations_in_period'] as num?)?.toInt() ?? 0;
  int get totalMembers => (_members['total_members'] as num?)?.toInt() ?? 0;

  // ── Book ─────────────────────────────────────────────────────────────────

  List<MostBorrowedBookData> get mostBorrowedBooks {
    final rawList = _books['most_borrowed'] as List<dynamic>? ?? [];
    final query = searchQuery.value.trim().toLowerCase();

    return rawList
        .whereType<Map<String, dynamic>>()
        .where((row) => query.isEmpty || (row['title']?.toString().toLowerCase().contains(query) ?? false))
        .map((row) => MostBorrowedBookData(
              title: row['title']?.toString() ?? '-',
              borrowCount: (row['borrow_count'] as num?)?.toInt() ?? 0,
              imageUrl: '',
              trend: BookTrend.stable,
            ))
        .toList();
  }

  Map<String, int> get bookItemStatusBreakdown {
    final status = _books['book_item_status'] as Map<String, dynamic>? ?? {};
    return status.map((key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0));
  }
}
