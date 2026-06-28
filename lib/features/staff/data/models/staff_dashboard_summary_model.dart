/// Maps GET /api/v1/staff/dashboard — see StaffDashboardService::getDashboard()
/// on the backend for exactly what each count means.
class StaffDashboardSummaryModel {
  const StaffDashboardSummaryModel({
    required this.branchId,
    required this.branchName,
    required this.staffFirstName,
    required this.totalBooksCount,
    required this.activeCount,
    required this.todayBorrowingsCount,
    required this.returnedTodayCount,
    required this.overdueCount,
    required this.pendingPaymentsCount,
    required this.recentActivities,
  });

  final String branchId;
  final String branchName;
  final String staffFirstName;
  final int totalBooksCount;
  final int activeCount;
  final int todayBorrowingsCount;
  final int returnedTodayCount;
  final int overdueCount;
  final int pendingPaymentsCount;
  final List<StaffRecentActivityModel> recentActivities;

  factory StaffDashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    final branch = json['branch'] as Map<String, dynamic>?;
    final staff = json['staff'] as Map<String, dynamic>?;
    final rawRecent = json['recent_borrowings'] as List<dynamic>? ?? [];
    final fullname = staff?['fullname']?.toString() ?? '';

    return StaffDashboardSummaryModel(
      branchId: branch?['id']?.toString() ?? '',
      branchName: branch?['name']?.toString() ?? '-',
      staffFirstName: fullname.trim().isEmpty ? 'Staff' : fullname.trim().split(' ').first,
      totalBooksCount: (summary['total_books_count'] as num?)?.toInt() ?? 0,
      activeCount: (summary['active_count'] as num?)?.toInt() ?? 0,
      todayBorrowingsCount: (summary['today_borrowings_count'] as num?)?.toInt() ?? 0,
      returnedTodayCount: (summary['returned_today_count'] as num?)?.toInt() ?? 0,
      overdueCount: (summary['overdue_count'] as num?)?.toInt() ?? 0,
      pendingPaymentsCount: (summary['pending_payments_count'] as num?)?.toInt() ?? 0,
      recentActivities: rawRecent
          .whereType<Map<String, dynamic>>()
          .map(StaffRecentActivityModel.fromJson)
          .toList(),
    );
  }
}

class StaffRecentActivityModel {
  const StaffRecentActivityModel({
    required this.borrowingId,
    required this.borrowingCode,
    required this.status,
    required this.memberName,
    required this.itemsCount,
  });

  final String borrowingId;
  final String borrowingCode;
  final String status;
  final String memberName;
  final int itemsCount;

  factory StaffRecentActivityModel.fromJson(Map<String, dynamic> json) {
    final member = json['member'] as Map<String, dynamic>?;

    return StaffRecentActivityModel(
      borrowingId: json['id']?.toString() ?? '',
      borrowingCode: json['borrowing_code']?.toString() ?? '',
      status: json['computed_status']?.toString() ?? json['raw_status']?.toString() ?? '',
      memberName: member?['fullname']?.toString() ?? '-',
      itemsCount: (json['items_count'] as num?)?.toInt() ?? 0,
    );
  }
}
