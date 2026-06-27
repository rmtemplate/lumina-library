import 'package:flutter/foundation.dart';

import 'package:lumina_library/core/network/lumina_api_client.dart';
import 'package:lumina_library/shared/models/payment/borrowing_payment_model.dart';

/// Member-facing Midtrans Core API payment endpoints
/// (see routes/api/v1/member.php `payments.*` on the backend).
class PaymentApiService {
  const PaymentApiService(this._client);

  final LuminaApiClient _client;

  /// POST /api/v1/payments/create
  /// Creates a Core API charge for whatever the borrowing currently owes.
  /// Calling again with a DIFFERENT [paymentMethod] supersedes (cancels)
  /// any still-pending charge first — this is how "Change Payment Method"
  /// works, there's no separate endpoint for it.
  Future<BorrowingPaymentModel> create({
    required String borrowingId,
    required String paymentMethod,
  }) async {
    debugPrint('[PAYMENT][API] create — borrowingId=$borrowingId method=$paymentMethod');

    final response = await _client.post<Map<String, dynamic>>(
      '/payments/create',
      body: {
        'borrowing_id': borrowingId,
        'payment_method': paymentMethod,
      },
      fromData: (data) => data as Map<String, dynamic>,
    );

    return BorrowingPaymentModel.fromJson(response.data ?? {});
  }

  /// GET /api/v1/payments/by-borrowing/{borrowingId}
  /// Recovers the current/latest payment for a borrowing on cold start
  /// (e.g. the page was closed mid-payment). Returns null if no payment
  /// has been created yet — that's the page's cue to show the method
  /// selector instead of payment details.
  Future<BorrowingPaymentModel?> byBorrowing(String borrowingId) async {
    final response = await _client.get<Map<String, dynamic>?>(
      '/payments/by-borrowing/$borrowingId',
      fromData: (data) => data as Map<String, dynamic>?,
    );

    final data = response.data;
    if (data == null) return null;

    return BorrowingPaymentModel.fromJson(data);
  }

  /// GET /api/v1/payments/{id}
  Future<BorrowingPaymentModel> show(String paymentId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/payments/$paymentId',
      fromData: (data) => data as Map<String, dynamic>,
    );

    return BorrowingPaymentModel.fromJson(response.data ?? {});
  }

  /// POST /api/v1/payments/{id}/refresh — force a Midtrans status check
  /// when the webhook hasn't arrived yet ("Refresh Status" button).
  Future<BorrowingPaymentModel> refresh(String paymentId) async {
    debugPrint('[PAYMENT][API] refresh — paymentId=$paymentId');

    final response = await _client.post<Map<String, dynamic>>(
      '/payments/$paymentId/refresh',
      fromData: (data) => data as Map<String, dynamic>,
    );

    return BorrowingPaymentModel.fromJson(response.data ?? {});
  }

  /// GET /api/v1/payments/history
  Future<({List<BorrowingPaymentModel> items, bool hasMore})> history({
    int perPage = 10,
    int page = 1,
  }) async {
    final response = await _client.get<List<dynamic>>(
      '/payments/history',
      query: {'per_page': '$perPage', 'page': '$page'},
      fromData: (data) => data as List<dynamic>,
    );

    final rawList = response.data ?? [];
    final items = rawList
        .whereType<Map<String, dynamic>>()
        .map(BorrowingPaymentModel.fromJson)
        .toList();

    return (items: items, hasMore: rawList.length >= perPage);
  }

  /// GET /api/v1/staff/payments — branch-scoped list backing the staff
  /// payments page (Pending/Paid/Failed tabs). [status] is one of
  /// pending|paid|expired|failed|cancelled.
  Future<({List<BorrowingPaymentModel> items, bool hasMore})> staffList({
    String? status,
    int perPage = 10,
    int page = 1,
  }) async {
    debugPrint('[PAYMENT][API] staffList — status=${status ?? "all"} page=$page');

    final query = <String, String>{'per_page': '$perPage', 'page': '$page'};
    if (status != null) query['status'] = status;

    final response = await _client.get<List<dynamic>>(
      '/staff/payments',
      query: query,
      fromData: (data) => data as List<dynamic>,
    );

    final rawList = response.data ?? [];
    final items = rawList
        .whereType<Map<String, dynamic>>()
        .map(BorrowingPaymentModel.fromJson)
        .toList();

    return (items: items, hasMore: rawList.length >= perPage);
  }
}
