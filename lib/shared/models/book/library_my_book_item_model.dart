enum LibraryMyBookStatus {
  active,
  dueSoon,
  overdue,
  finished,
}

class LibraryMyBookItemModel {
  const LibraryMyBookItemModel({
    required this.loanId,
    required this.bookCode,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.libraryName,
    required this.libraryAddress,
    required this.borrowDateText,
    required this.borrowTimeText,
    required this.dueDateText,
    required this.dueTimeText,
    required this.status,
    required this.destinationLatitude,
    required this.destinationLongitude,
    this.returnLocationName,
    this.returnLocationDetail,
    this.category,
    this.isbn,
    this.returnedDateText,
    this.returnedTimeText,
    this.remainingDays = 0,
    this.overdueDays = 0,
    this.finePerDay = 0,
    this.fineAmount = 0,
    this.notes,
  });

  final String loanId;
  final String bookCode;
  final String title;
  final String author;
  final String imageUrl;

  final String libraryName;
  final String libraryAddress;
  final String? returnLocationName;
  final String? returnLocationDetail;

  final String borrowDateText;
  final String borrowTimeText;
  final String dueDateText;
  final String dueTimeText;
  final String? returnedDateText;
  final String? returnedTimeText;

  final LibraryMyBookStatus status;

  final double destinationLatitude;
  final double destinationLongitude;

  final String? category;
  final String? isbn;
  final int remainingDays;
  final int overdueDays;
  final int finePerDay;
  final int fineAmount;
  final String? notes;

  bool get isActive => status == LibraryMyBookStatus.active;
  bool get isDueSoon => status == LibraryMyBookStatus.dueSoon;
  bool get isOverdue => status == LibraryMyBookStatus.overdue;
  bool get isFinished => status == LibraryMyBookStatus.finished;
  bool get hasFine => fineAmount > 0;
  bool get mustPayFine => isOverdue && hasFine;

  String get effectiveReturnLocationName {
    final value = returnLocationName;
    if (value == null || value.trim().isEmpty) return libraryName;

    return value;
  }

  String get effectiveReturnLocationDetail {
    final value = returnLocationDetail;
    if (value == null || value.trim().isEmpty) return libraryAddress;

    return value;
  }

  String get statusLabel {
    switch (status) {
      case LibraryMyBookStatus.active:
        return 'Active Loan';
      case LibraryMyBookStatus.dueSoon:
        return 'Due Soon';
      case LibraryMyBookStatus.overdue:
        return 'Overdue';
      case LibraryMyBookStatus.finished:
        return 'Returned';
    }
  }

  String get statusLabelId {
    switch (status) {
      case LibraryMyBookStatus.active:
        return 'Peminjaman Aktif';
      case LibraryMyBookStatus.dueSoon:
        return 'Segera Dikembalikan';
      case LibraryMyBookStatus.overdue:
        return 'Kadaluwarsa';
      case LibraryMyBookStatus.finished:
        return 'Selesai';
    }
  }

  String get dueStatusText {
    switch (status) {
      case LibraryMyBookStatus.active:
        return 'Jatuh tempo dalam $remainingDays hari';
      case LibraryMyBookStatus.dueSoon:
        return 'Jatuh tempo dalam $remainingDays hari';
      case LibraryMyBookStatus.overdue:
        return 'Lewat jatuh tempo $overdueDays hari';
      case LibraryMyBookStatus.finished:
        return returnedDateText == null
            ? 'Sudah dikembalikan'
            : 'Dikembalikan pada $returnedDateText';
    }
  }

  String get timelineBorrowedText => '$borrowDateText, $borrowTimeText';
  String get timelineDueText => '$dueDateText, $dueTimeText';

  String? get timelineReturnedText {
    if (returnedDateText == null) return null;

    final time = returnedTimeText;
    if (time == null || time.trim().isEmpty) return returnedDateText;

    return '$returnedDateText, $time';
  }

  String get fineAmountText => _formatCurrency(fineAmount);
  String get finePerDayText => _formatCurrency(finePerDay);

  static String _formatCurrency(int value) {
    final raw = value.abs().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < raw.length; i++) {
      final positionFromEnd = raw.length - i;

      buffer.write(raw[i]);

      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return 'Rp ${buffer.toString()}';
  }
}