enum LibraryMyBookStatus {
  pending,         // belum diproses
  awaitingPickup,  // reservasi berhasil, menunggu pengambilan di perpustakaan
  active,          // sedang dipinjam, masa pinjam normal
  dueSoon,         // akan jatuh tempo dalam beberapa hari
  overdue,         // melewati batas pengembalian
  readyForReturn,  // denda dilunasi, buku siap dikembalikan
  returnPendingVerification, // petugas sudah scan Return QR, sedang verifikasi buku
  finished,        // sudah dikembalikan (completed)
  waitingPayment,  // menunggu pembayaran denda
  expired,         // reservasi kadaluwarsa
  cancelled,       // dibatalkan
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
    // Fields added from API integration
    this.rawStatus = '',
    this.canReturn = false,
    this.canPickup = false,
    this.reservationExpiresAt,
    this.itemsCount = 1,
    // ── Backend-decided workflow + action flags (single source of truth) ──
    this.canGenerateReturnQr = false,
    this.canRefreshQr = false,
    this.canPayOverdue = false,
    this.canPayDamage = false,
    this.canCancel = false,
    this.canViewPaymentHistory = false,
    this.workflowStep = '',
    this.workflowNextAction = 'none',
    this.workflowStepLabel = '',
    this.workflowStepDescription = '',
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

  // From backend `actions` block
  final String rawStatus;
  final bool canReturn;
  final bool canPickup;
  // ISO-8601 string, only set for awaiting_pickup borrowings
  final String? reservationExpiresAt;
  final int itemsCount;

  // Backend-decided action flags — the UI renders each button ONLY when its
  // flag is true. The client never infers these from status/overdue/fine.
  final bool canGenerateReturnQr;
  final bool canRefreshQr;
  final bool canPayOverdue;
  final bool canPayDamage;
  final bool canCancel;
  final bool canViewPaymentHistory;

  // Backend workflow (where the loan is in the return flow) — for labels.
  final String workflowStep;
  final String workflowNextAction;
  final String workflowStepLabel;
  final String workflowStepDescription;

  /// True when EITHER separate payment stage is currently payable — the only
  /// thing that should surface a payment button. Backend-driven, not inferred.
  bool get canPay => canPayOverdue || canPayDamage;

  // ── Computed booleans ────────────────────────────────────────────────────

  bool get isActive => status == LibraryMyBookStatus.active;
  bool get isDueSoon => status == LibraryMyBookStatus.dueSoon;
  bool get isOverdue => status == LibraryMyBookStatus.overdue;
  bool get isReadyForReturn => status == LibraryMyBookStatus.readyForReturn;
  bool get isFinished => status == LibraryMyBookStatus.finished;
  bool get isAwaitingPickup => status == LibraryMyBookStatus.awaitingPickup;
  bool get isPending => status == LibraryMyBookStatus.pending;
  bool get isExpired => status == LibraryMyBookStatus.expired;
  bool get isCancelled => status == LibraryMyBookStatus.cancelled;
  bool get isWaitingPayment => status == LibraryMyBookStatus.waitingPayment;
  bool get isReturnPendingVerification =>
      status == LibraryMyBookStatus.returnPendingVerification;

  bool get hasFine => fineAmount > 0;

  /// True when the backend has confirmed payment is required (status ==
  /// waiting_payment). The backend runtime backstop (BorrowingOverdueService
  /// flagOne/flagDueOverdueBorrowings) always runs on every detail fetch, so
  /// by the time this field is read, an overdue borrowing will already be in
  /// waiting_payment if payment is needed. After payment succeeds, the borrowing
  /// returns to active/overdue with total_fine > 0 — we must NOT re-trigger the
  /// payment flow in that case, so the old `|| (isOverdue && hasFine)` arm is
  /// intentionally removed.
  bool get mustPayFine => isWaitingPayment;

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

  // ── Labels ────────────────────────────────────────────────────────────────

  String get statusLabel {
    switch (status) {
      case LibraryMyBookStatus.pending:
        return 'Pending';
      case LibraryMyBookStatus.awaitingPickup:
        return 'Awaiting Pickup';
      case LibraryMyBookStatus.active:
        return 'Active Loan';
      case LibraryMyBookStatus.dueSoon:
        return 'Due Soon';
      case LibraryMyBookStatus.overdue:
        return 'Overdue';
      case LibraryMyBookStatus.readyForReturn:
        return 'Ready to Return';
      case LibraryMyBookStatus.returnPendingVerification:
        return 'Verifying Return';
      case LibraryMyBookStatus.finished:
        return 'Completed';
      case LibraryMyBookStatus.waitingPayment:
        return 'Waiting Payment';
      case LibraryMyBookStatus.expired:
        return 'Expired';
      case LibraryMyBookStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get statusLabelId {
    switch (status) {
      case LibraryMyBookStatus.pending:
        return 'Menunggu Konfirmasi';
      case LibraryMyBookStatus.awaitingPickup:
        return 'Siap Diambil';
      case LibraryMyBookStatus.active:
        return 'Peminjaman Aktif';
      case LibraryMyBookStatus.dueSoon:
        return 'Segera Dikembalikan';
      case LibraryMyBookStatus.overdue:
        return 'Terlambat';
      case LibraryMyBookStatus.readyForReturn:
        return 'Siap Dikembalikan';
      case LibraryMyBookStatus.returnPendingVerification:
        return 'Menunggu Verifikasi';
      case LibraryMyBookStatus.finished:
        return 'Selesai';
      case LibraryMyBookStatus.waitingPayment:
        return 'Menunggu Pembayaran';
      case LibraryMyBookStatus.expired:
        return 'Reservasi Kadaluwarsa';
      case LibraryMyBookStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  String get dueStatusText {
    switch (status) {
      case LibraryMyBookStatus.pending:
        return 'Sedang menunggu konfirmasi perpustakaan';
      case LibraryMyBookStatus.awaitingPickup:
        return reservationExpiresAt != null
            ? 'Ambil sebelum reservasi habis'
            : 'Buku siap diambil di perpustakaan';
      case LibraryMyBookStatus.active:
        return 'Jatuh tempo dalam $remainingDays hari';
      case LibraryMyBookStatus.dueSoon:
        return 'Jatuh tempo dalam $remainingDays hari';
      case LibraryMyBookStatus.overdue:
        return 'Lewat jatuh tempo $overdueDays hari';
      case LibraryMyBookStatus.readyForReturn:
        return 'Denda lunas · kembalikan buku ke perpustakaan';
      case LibraryMyBookStatus.returnPendingVerification:
        return 'Petugas sedang memverifikasi buku Anda';
      case LibraryMyBookStatus.finished:
        return returnedDateText == null
            ? 'Sudah dikembalikan'
            : 'Dikembalikan pada $returnedDateText';
      case LibraryMyBookStatus.waitingPayment:
        return 'Menunggu pembayaran denda $fineAmountText';
      case LibraryMyBookStatus.expired:
        return 'Reservasi telah kadaluwarsa';
      case LibraryMyBookStatus.cancelled:
        return 'Peminjaman dibatalkan';
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

  // ── API Mapping ───────────────────────────────────────────────────────────

  /// Map dari response MyBookResource (GET /api/v1/my-books atau /my-books/{id}).
  factory LibraryMyBookItemModel.fromApiJson(Map<String, dynamic> json) {
    final branch = json['branch'] as Map<String, dynamic>? ?? {};
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final actions = json['actions'] as Map<String, dynamic>? ?? {};
    final workflow = json['workflow'] as Map<String, dynamic>? ?? {};

    // Ambil buku pertama dari items untuk representasi visual
    final firstItem = rawItems.isNotEmpty
        ? rawItems.first as Map<String, dynamic>? ?? {}
        : <String, dynamic>{};
    final firstBook = firstItem['book'] as Map<String, dynamic>? ?? {};
    final firstBookCategory = firstBook['category'] as Map<String, dynamic>?;

    final statusStr = (json['status'] as String?)?.toLowerCase() ?? '';
    final status = _statusFromString(statusStr);

    final rawReturnDate = json['return_date'] as String?;
    final formattedReturn =
        rawReturnDate != null ? _formatApiDate(rawReturnDate) : null;

    return LibraryMyBookItemModel(
      loanId: json['borrowing_id']?.toString() ?? '',
      bookCode: json['borrowing_code']?.toString() ?? '',
      title: firstBook['title']?.toString() ?? 'Buku Dipinjam',
      author: firstBook['author']?.toString() ?? '-',
      imageUrl: firstBook['cover_url']?.toString() ?? '',
      libraryName: branch['name']?.toString() ?? 'Perpustakaan',
      libraryAddress: branch['address']?.toString() ?? '',
      borrowDateText: _formatApiDate(json['borrow_date']?.toString() ?? ''),
      borrowTimeText: '',
      dueDateText: _formatApiDate(json['due_date']?.toString() ?? ''),
      dueTimeText: '',
      returnedDateText: formattedReturn,
      returnedTimeText: null,
      status: status,
      remainingDays: (json['days_remaining'] as num?)?.toInt() ?? 0,
      overdueDays: (json['overdue_days'] as num?)?.toInt() ?? 0,
      // Backend is the single source of truth for this number — see
      // FineCalculator::overdueFineAmount() — Flutter never derives it
      // from overdueDays/finePerDay itself.
      fineAmount: ((json['total_fine'] as num?)?.toDouble() ?? 0).toInt(),
      finePerDay: ((json['fine_per_day'] as num?)?.toDouble() ?? 0).toInt(),
      destinationLatitude: 0.0,
      destinationLongitude: 0.0,
      category: firstBookCategory?['name']?.toString(),
      isbn: firstBook['isbn']?.toString(),
      notes: (json['detail'] as Map<String, dynamic>?)?['notes']?.toString(),
      // New API fields
      rawStatus: json['raw_status']?.toString() ?? statusStr,
      canReturn: actions['can_return'] == true,
      canPickup: actions['can_pickup'] == true,
      reservationExpiresAt: json['reservation_expires_at']?.toString(),
      itemsCount: (json['items_count'] as num?)?.toInt() ?? rawItems.length,
      // Backend-decided flags + workflow (single source of truth).
      canGenerateReturnQr: actions['can_generate_return_qr'] == true,
      canRefreshQr: actions['can_refresh_qr'] == true,
      canPayOverdue: actions['can_pay_overdue'] == true,
      canPayDamage: actions['can_pay_damage'] == true,
      canCancel: actions['can_cancel'] == true,
      canViewPaymentHistory: actions['can_view_payment_history'] == true,
      workflowStep: (workflow['current_step'] as String?) ?? '',
      workflowNextAction: (workflow['next_action'] as String?) ?? 'none',
      workflowStepLabel: (workflow['step_label'] as String?) ?? '',
      workflowStepDescription: (workflow['step_description'] as String?) ?? '',
    );
  }

  static LibraryMyBookStatus _statusFromString(String s) {
    switch (s) {
      case 'pending':
        return LibraryMyBookStatus.pending;
      case 'awaiting_pickup':
        return LibraryMyBookStatus.awaitingPickup;
      case 'due_soon':
        return LibraryMyBookStatus.dueSoon;
      case 'overdue':
        return LibraryMyBookStatus.overdue;
      case 'ready_for_return':
        return LibraryMyBookStatus.readyForReturn;
      // ── Two-stage return flow ────────────────────────────────────────────
      // Books received & staff inspecting → "waiting for verification" UI.
      case 'return_received':
      case 'book_inspection':
      case 'return_pending_verification':
        return LibraryMyBookStatus.returnPendingVerification;
      // Either separate payment stage outstanding → the payment UI. Only one
      // type is ever outstanding at a time, so total_fine reflects the stage.
      case 'waiting_overdue_payment':
      case 'waiting_damage_payment':
        return LibraryMyBookStatus.waitingPayment;
      case 'completed':
        return LibraryMyBookStatus.finished;
      case 'returned':
      case 'returned_with_fine':
        return LibraryMyBookStatus.finished;
      case 'waiting_payment':
        return LibraryMyBookStatus.waitingPayment;
      case 'expired':
        return LibraryMyBookStatus.expired;
      case 'cancelled':
        return LibraryMyBookStatus.cancelled;
      case 'active':
      default:
        return LibraryMyBookStatus.active;
    }
  }

  /// Format tanggal ISO "2026-06-14" atau datetime "2026-06-14T..." → "14 Jun 2026"
  static String _formatApiDate(String isoDate) {
    if (isoDate.isEmpty) return '';
    try {
      // Strip time part if present
      final datePart = isoDate.split('T').first;
      final parts = datePart.split('-');
      if (parts.length < 3) return isoDate;
      final day = int.parse(parts[2].split(' ').first);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[0]);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '$day ${months[month - 1]} $year';
    } catch (_) {
      return isoDate;
    }
  }
}
