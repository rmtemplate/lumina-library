/// Mirrors the backend's `BorrowingPaymentService::formatPayment()` shape
/// (see app/Http/Controllers/Api/V1/Member/PaymentController.php) — used by
/// every `/api/v1/payments/*` response.
class BorrowingPaymentModel {
  const BorrowingPaymentModel({
    required this.id,
    required this.borrowingId,
    required this.midtransOrderId,
    required this.purpose,
    required this.paymentMethod,
    required this.totalAmount,
    required this.status,
    this.paymentType,
    this.paymentChannel,
    this.vaNumber,
    this.qrString,
    this.actions = const [],
    this.paidAt,
    this.expiredAt,
    this.isExpired = false,
    this.createdAt,
    this.borrowingCode,
    this.borrowingStatus,
    this.memberName,
  });

  final String id;
  final String borrowingId;
  final String midtransOrderId;

  // Only populated by GET /api/v1/staff/payments (the member-facing
  // endpoints don't include this nested context).
  final String? borrowingCode;
  final String? borrowingStatus;
  final String? memberName;

  /// overdue_fine | return_condition | pickup_no_show — see
  /// docs/borrowing-lifecycle.md on the backend for what each means.
  final String purpose;

  /// qris | bca_va | bni_va | bri_va | mandiri_bill | permata_va | gopay | shopeepay
  final String? paymentMethod;

  final double totalAmount;

  /// pending | paid | expired | failed | cancelled
  final String status;

  final String? paymentType;
  final String? paymentChannel;
  final String? vaNumber;
  final String? qrString;
  final List<Map<String, dynamic>> actions;
  final DateTime? paidAt;
  final DateTime? expiredAt;
  final bool isExpired;
  final DateTime? createdAt;

  bool get isPending => status == 'pending';
  bool get isPaid => status == 'paid';
  bool get isQris => paymentMethod == 'qris';
  bool get isVirtualAccount =>
      paymentMethod != null && paymentMethod!.endsWith('_va');
  bool get isEWallet => paymentMethod == 'gopay' || paymentMethod == 'shopeepay';
  bool get isMandiriBill => paymentMethod == 'mandiri_bill';

  /// Deeplink URL for GoPay/ShopeePay — extracted from the raw Core API
  /// `actions` array (`deeplink-redirect` or `generate-qr-code`).
  String? get deeplinkUrl {
    for (final action in actions) {
      final name = action['name']?.toString();
      if (name == 'deeplink-redirect' || name == 'generate-qr-code') {
        return action['url']?.toString();
      }
    }
    return null;
  }

  /// Method-specific "how to pay" copy — single source of truth so the
  /// Payment Detail page doesn't duplicate this text per method section.
  String get instructionsText => switch (paymentMethod) {
        'qris' => 'Buka aplikasi e-wallet atau m-banking apa pun yang mendukung QRIS, lalu pindai (scan) kode di bawah ini.',
        'gopay' => 'Buka aplikasi Gojek, pilih GoPay, lalu pindai kode QR atau ketuk tombol di bawah untuk membuka otomatis.',
        'shopeepay' => 'Buka aplikasi Shopee, pilih ShopeePay, lalu pindai kode QR atau ketuk tombol di bawah untuk membuka otomatis.',
        'mandiri_bill' => 'Buka ATM atau aplikasi Livin\' by Mandiri, pilih Bayar/Bill Payment, masukkan kode biller dan Bill Key di bawah.',
        _ => 'Buka ATM, m-banking, atau internet banking, pilih Transfer ke Virtual Account, lalu masukkan nomor di bawah.',
      };

  factory BorrowingPaymentModel.fromJson(Map<String, dynamic> json) {
    final rawActions = json['actions'] as List<dynamic>? ?? const [];
    final borrowing = json['borrowing'] as Map<String, dynamic>?;
    final member = borrowing?['member'] as Map<String, dynamic>?;

    return BorrowingPaymentModel(
      id: json['id']?.toString() ?? '',
      borrowingId: json['borrowing_id']?.toString() ?? '',
      midtransOrderId: json['midtrans_order_id']?.toString() ?? '',
      purpose: json['purpose']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString(),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      status: json['status']?.toString() ?? 'pending',
      paymentType: json['payment_type']?.toString(),
      paymentChannel: json['payment_channel']?.toString(),
      vaNumber: json['va_number']?.toString(),
      qrString: json['qr_string']?.toString(),
      actions: rawActions.whereType<Map<String, dynamic>>().toList(),
      paidAt: _parseDate(json['paid_at']),
      expiredAt: _parseDate(json['expired_at']),
      isExpired: json['is_expired'] == true,
      createdAt: _parseDate(json['created_at']),
      borrowingCode: borrowing?['code']?.toString(),
      borrowingStatus: borrowing?['status']?.toString(),
      memberName: member?['fullname']?.toString(),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString())?.toLocal();
  }
}

/// Member-facing label/grouping for each supported payment method, used by
/// PaymentMethodSelector. Kept here (not hardcoded in the widget) so adding
/// a method later is a one-line change.
class PaymentMethodOption {
  const PaymentMethodOption({
    required this.value,
    required this.label,
    required this.group,
    required this.description,
  });

  final String value;
  final String label;
  final String group;
  final String description;

  static const List<PaymentMethodOption> all = [
    PaymentMethodOption(value: 'qris', label: 'QRIS', group: 'QR', description: 'Scan dengan e-wallet/m-banking apa pun'),
    PaymentMethodOption(value: 'bca_va', label: 'BCA Virtual Account', group: 'Virtual Account', description: 'Transfer via ATM, m-banking, atau internet banking BCA'),
    PaymentMethodOption(value: 'bni_va', label: 'BNI Virtual Account', group: 'Virtual Account', description: 'Transfer via ATM, m-banking, atau internet banking BNI'),
    PaymentMethodOption(value: 'bri_va', label: 'BRI Virtual Account', group: 'Virtual Account', description: 'Transfer via ATM, m-banking, atau internet banking BRI'),
    PaymentMethodOption(value: 'permata_va', label: 'Permata Virtual Account', group: 'Virtual Account', description: 'Transfer via ATM atau m-banking Permata'),
    PaymentMethodOption(value: 'mandiri_bill', label: 'Mandiri Bill Payment', group: 'Virtual Account', description: 'Bayar dengan kode biller di ATM/m-banking Mandiri'),
    PaymentMethodOption(value: 'gopay', label: 'GoPay', group: 'E-Wallet', description: 'Bayar langsung dari aplikasi Gojek'),
    PaymentMethodOption(value: 'shopeepay', label: 'ShopeePay', group: 'E-Wallet', description: 'Bayar langsung dari aplikasi Shopee'),
  ];
}
