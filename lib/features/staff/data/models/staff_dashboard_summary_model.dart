/// Maps GET /api/v1/staff/dashboard — see StaffDashboardService::getDashboard()
/// on the backend for exactly what each count means.
class StaffDashboardSummaryModel {
  const StaffDashboardSummaryModel({
    required this.branchId,
    required this.branchName,
    required this.staffFirstName,
    required this.staffAvatarUrl,
    required this.totalBooksCount,
    required this.availableBooksCount,
    required this.registeredMembersCount,
    required this.activeCount,
    required this.todayBorrowingsCount,
    required this.returnedTodayCount,
    required this.overdueCount,
    required this.pendingPaymentsCount,
    required this.awaitingPickupCount,
    required this.recentActivities,
    required this.charts,
    required this.popularBooks,
    required this.rackOverview,
  });

  final String branchId;
  final String branchName;
  final String staffFirstName;
  final String? staffAvatarUrl;
  final int totalBooksCount;
  final int availableBooksCount;
  final int registeredMembersCount;
  final int activeCount;
  final int todayBorrowingsCount;
  final int returnedTodayCount;
  final int overdueCount;
  final int pendingPaymentsCount;
  final int awaitingPickupCount;
  final List<StaffRecentActivityModel> recentActivities;
  final StaffDashboardChartsModel charts;
  final List<StaffPopularBookModel> popularBooks;
  final List<StaffRackOverviewModel> rackOverview;

  factory StaffDashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    final branch = json['branch'] as Map<String, dynamic>?;
    final staff = json['staff'] as Map<String, dynamic>?;
    final rawRecent = json['recent_borrowings'] as List<dynamic>? ?? [];
    final rawCharts = json['charts'] as Map<String, dynamic>? ?? {};
    final fullname = staff?['fullname']?.toString() ?? '';

    return StaffDashboardSummaryModel(
      branchId: branch?['id']?.toString() ?? '',
      branchName: branch?['name']?.toString() ?? '-',
      staffFirstName: fullname.trim().isEmpty ? 'Staff' : fullname.trim().split(' ').first,
      staffAvatarUrl: staff?['avatar_url']?.toString(),
      totalBooksCount: (summary['total_books_count'] as num?)?.toInt() ?? 0,
      availableBooksCount: (summary['available_books_count'] as num?)?.toInt() ?? 0,
      registeredMembersCount: (summary['registered_members_count'] as num?)?.toInt() ?? 0,
      activeCount: (summary['active_count'] as num?)?.toInt() ?? 0,
      todayBorrowingsCount: (summary['today_borrowings_count'] as num?)?.toInt() ?? 0,
      returnedTodayCount: (summary['returned_today_count'] as num?)?.toInt() ?? 0,
      overdueCount: (summary['overdue_count'] as num?)?.toInt() ?? 0,
      pendingPaymentsCount: (summary['pending_payments_count'] as num?)?.toInt() ?? 0,
      awaitingPickupCount: (summary['awaiting_pickup_count'] as num?)?.toInt() ?? 0,
      recentActivities: rawRecent
          .whereType<Map<String, dynamic>>()
          .map(StaffRecentActivityModel.fromJson)
          .toList(),
      charts: StaffDashboardChartsModel.fromJson(rawCharts),
      popularBooks: ((json['popular_books'] as List<dynamic>?) ?? [])
          .whereType<Map<String, dynamic>>()
          .map(StaffPopularBookModel.fromJson)
          .toList(),
      rackOverview: ((json['rack_overview'] as List<dynamic>?) ?? [])
          .whereType<Map<String, dynamic>>()
          .map(StaffRackOverviewModel.fromJson)
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
    this.memberAvatarUrl,
    this.bookTitle,
    this.bookCoverUrl,
    this.createdAt,
  });

  final String borrowingId;
  final String borrowingCode;
  final String status;
  final String memberName;
  final int itemsCount;
  final String? memberAvatarUrl;
  final String? bookTitle;
  final String? bookCoverUrl;
  final String? createdAt;

  factory StaffRecentActivityModel.fromJson(Map<String, dynamic> json) {
    final member = json['member'] as Map<String, dynamic>?;
    final book = json['book'] as Map<String, dynamic>?;

    return StaffRecentActivityModel(
      borrowingId: json['id']?.toString() ?? '',
      borrowingCode: json['borrowing_code']?.toString() ?? '',
      status: json['computed_status']?.toString() ?? json['raw_status']?.toString() ?? '',
      memberName: member?['fullname']?.toString() ?? '-',
      itemsCount: (json['items_count'] as num?)?.toInt() ?? 0,
      memberAvatarUrl: member?['avatar_url']?.toString(),
      bookTitle: book?['title']?.toString(),
      bookCoverUrl: book?['cover_url']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

/// Chart data returned by the dashboard endpoint.
class StaffDashboardChartsModel {
  const StaffDashboardChartsModel({
    required this.borrowingTrend,
    required this.monthlyBorrowings,
    required this.topCategories,
  });

  final List<StaffTrendPoint> borrowingTrend;
  final List<StaffTrendPoint> monthlyBorrowings;
  final List<StaffCategoryPoint> topCategories;

  factory StaffDashboardChartsModel.fromJson(Map<String, dynamic> json) {
    List<T> parseList<T>(String key, T Function(Map<String, dynamic>) fromJson) =>
        ((json[key] as List<dynamic>?) ?? []).whereType<Map<String, dynamic>>().map(fromJson).toList();

    return StaffDashboardChartsModel(
      borrowingTrend: parseList('borrowing_trend', StaffTrendPoint.fromJson),
      monthlyBorrowings: parseList('monthly_borrowings', StaffTrendPoint.fromJson),
      topCategories: parseList('top_categories', StaffCategoryPoint.fromJson),
    );
  }
}

class StaffTrendPoint {
  const StaffTrendPoint({required this.label, required this.count});
  final String label;
  final int count;
  factory StaffTrendPoint.fromJson(Map<String, dynamic> json) =>
      StaffTrendPoint(label: json['label']?.toString() ?? '', count: (json['count'] as num?)?.toInt() ?? 0);
}

class StaffCategoryPoint {
  const StaffCategoryPoint({required this.name, required this.count});
  final String name;
  final int count;
  factory StaffCategoryPoint.fromJson(Map<String, dynamic> json) =>
      StaffCategoryPoint(name: json['name']?.toString() ?? '', count: (json['count'] as num?)?.toInt() ?? 0);
}

class StaffPopularBookModel {
  const StaffPopularBookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.borrowCount,
    required this.availableCount,
    this.coverUrl,
    this.category,
  });

  final String id;
  final String title;
  final String author;
  final int borrowCount;
  final int availableCount;
  final String? coverUrl;
  final String? category;

  bool get isAvailable => availableCount > 0;

  factory StaffPopularBookModel.fromJson(Map<String, dynamic> json) => StaffPopularBookModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        author: json['author']?.toString() ?? '',
        borrowCount: (json['borrow_count'] as num?)?.toInt() ?? 0,
        availableCount: (json['available_count'] as num?)?.toInt() ?? 0,
        coverUrl: json['cover_url']?.toString(),
        category: json['category']?.toString(),
      );
}

class StaffRackOverviewModel {
  const StaffRackOverviewModel({
    required this.id,
    required this.rackCode,
    required this.name,
    required this.capacity,
    required this.totalBooks,
    required this.availableBooks,
    this.floorLabel,
  });

  final String id;
  final String rackCode;
  final String name;
  final int capacity;
  final int totalBooks;
  final int availableBooks;
  final String? floorLabel;

  double get occupancyRatio => capacity > 0 ? (totalBooks / capacity).clamp(0.0, 1.0) : 0.0;
  int get freeSlots => (capacity - totalBooks).clamp(0, capacity);

  factory StaffRackOverviewModel.fromJson(Map<String, dynamic> json) => StaffRackOverviewModel(
        id: json['id']?.toString() ?? '',
        rackCode: json['rack_code']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        capacity: (json['capacity'] as num?)?.toInt() ?? 0,
        totalBooks: (json['total_books'] as num?)?.toInt() ?? 0,
        availableBooks: (json['available_books'] as num?)?.toInt() ?? 0,
        floorLabel: json['floor_label']?.toString(),
      );
}
