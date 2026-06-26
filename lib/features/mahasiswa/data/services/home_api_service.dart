import 'package:flutter/foundation.dart';
import 'package:lumina_library/core/network/lumina_api_client.dart';
import 'package:lumina_library/shared/models/banner/banner_model.dart';
import 'package:lumina_library/shared/models/book/book_model.dart';
import 'package:lumina_library/shared/models/book/library_my_book_item_model.dart';
import 'package:lumina_library/shared/models/borrowing/checkout_result_model.dart';
import 'package:lumina_library/shared/models/branch/branch_detail_model.dart';
import 'package:lumina_library/shared/models/branch/branch_model.dart';
import 'package:lumina_library/shared/models/cart/cart_model.dart';
import 'package:lumina_library/shared/models/category/category_model.dart';
import 'package:lumina_library/shared/models/notification/notification_model.dart';
import 'package:lumina_library/shared/models/profile/home_profile_model.dart';

class HomeApiService {
  const HomeApiService(this._client);

  final LuminaApiClient _client;

  // ── Banners ──────────────────────────────────────────────────────────────

  /// GET /api/v1/public/banners — tidak butuh auth.
  Future<List<BannerModel>> getBanners() async {
    final response = await _client.get<List<dynamic>>(
      '/public/banners',
      fromData: (data) => data as List<dynamic>,
    );
    return BannerModel.listFromJson(response.data ?? []);
  }

  // ── Categories ────────────────────────────────────────────────────────────

  /// GET /api/v1/public/categories — tidak butuh auth.
  Future<List<CategoryModel>> getCategories() async {
    final response = await _client.get<List<dynamic>>(
      '/public/categories',
      fromData: (data) => data as List<dynamic>,
    );
    return CategoryModel.listFromJson(response.data ?? []);
  }

  // ── Branches ─────────────────────────────────────────────────────────────

  /// GET /api/v1/public/branches — tidak butuh auth.
  /// Dengan koordinat → diurutkan berdasarkan jarak terdekat.
  Future<List<BranchModel>> getBranches({
    double? latitude,
    double? longitude,
  }) async {
    final query = <String, String>{};
    if (latitude != null && longitude != null) {
      query['latitude'] = latitude.toString();
      query['longitude'] = longitude.toString();
      query['sort'] = 'nearest';
    }

    final response = await _client.get<List<dynamic>>(
      '/public/branches',
      query: query.isEmpty ? null : query,
      fromData: (data) => data as List<dynamic>,
    );
    return BranchModel.listFromJson(response.data ?? []);
  }

  /// GET /api/v1/public/branches/{branchId} — tidak butuh auth.
  /// Response tambahan: stock_summary, book_item_summary
  Future<BranchDetailModel> getBranchDetail(
    String branchId, {
    double? latitude,
    double? longitude,
  }) async {
    final query = <String, String>{};
    if (latitude != null && longitude != null) {
      query['latitude'] = latitude.toString();
      query['longitude'] = longitude.toString();
    }

    final response = await _client.get<Map<String, dynamic>>(
      '/public/branches/$branchId',
      query: query.isEmpty ? null : query,
      fromData: (data) => data as Map<String, dynamic>,
    );
    return BranchDetailModel.fromJson(response.data!);
  }

  /// GET /api/v1/public/branches/{branchId}/books — tidak butuh auth.
  /// Mendukung filter: status, sort, search, category_id, limit
  Future<List<BookModel>> getBranchBooks(
    String branchId, {
    String? status,
    String sort = 'trending',
    String? search,
    String? categoryId,
    int limit = 12,
  }) async {
    final query = <String, String>{
      'sort': sort,
      'limit': limit.toString(),
    };
    if (status != null) query['status'] = status;
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (categoryId != null) query['category_id'] = categoryId;

    final response = await _client.get<List<dynamic>>(
      '/public/branches/$branchId/books',
      query: query,
      fromData: (data) {
        if (data is List) return data;
        if (data is Map && data.containsKey('data')) {
          return data['data'] as List<dynamic>? ?? <dynamic>[];
        }
        return <dynamic>[];
      },
    );
    return BookModel.listFromJson(response.data ?? []);
  }

  // ── Books ─────────────────────────────────────────────────────────────────

  /// GET /api/v1/books?sort=trending&limit=[limit] — butuh auth.
  Future<List<BookModel>> getTrendingBooks({int limit = 10}) async {
    final response = await _client.get<List<dynamic>>(
      '/books',
      query: {'sort': 'trending', 'limit': limit.toString()},
      fromData: (data) {
        if (data is List) return data;
        if (data is Map && data.containsKey('data')) {
          return data['data'] as List<dynamic>? ?? <dynamic>[];
        }
        return <dynamic>[];
      },
    );
    return BookModel.listFromJson(response.data ?? []);
  }

  /// GET /api/v1/books — butuh auth. Mendukung filter: search, category_slug,
  /// status, year, sort, limit.
  Future<List<BookModel>> getCatalogBooks({
    String? search,
    String? categorySlug,
    String? status,
    int? year,
    String sort = 'trending',
    int limit = 30,
  }) async {
    final query = <String, String>{
      'sort': sort,
      'limit': limit.toString(),
    };
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (categorySlug != null && categorySlug.isNotEmpty) {
      query['category_slug'] = categorySlug;
    }
    if (status != null) query['status'] = status;
    if (year != null) query['year'] = year.toString();

    final response = await _client.get<List<dynamic>>(
      '/books',
      query: query,
      fromData: (data) {
        if (data is List) return data;
        if (data is Map && data.containsKey('data')) {
          return data['data'] as List<dynamic>? ?? <dynamic>[];
        }
        return <dynamic>[];
      },
    );
    return BookModel.listFromJson(response.data ?? []);
  }

  /// GET /api/v1/books/{bookId}/branches/{branchId} — butuh auth.
  /// Mengembalikan detail lengkap satu buku di cabang tertentu.
  Future<BookModel> getBookDetail(String bookId, String branchId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/books/$bookId/branches/$branchId',
      fromData: (data) => data as Map<String, dynamic>,
    );
    return BookModel.fromJson(response.data!);
  }

  // ── Wishlist ──────────────────────────────────────────────────────────────

  /// POST /api/v1/books/{bookId}/wishlist — toggle wishlisted state.
  /// Returns: { wishlisted: bool, message: string }
  Future<bool> toggleWishlist(String bookId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/books/$bookId/wishlist',
      fromData: (data) => data as Map<String, dynamic>,
    );
    return (response.data?['wishlisted'] as bool?) ?? false;
  }

  // ── Cart ──────────────────────────────────────────────────────────────────

  /// GET /api/v1/cart — butuh auth.
  Future<CartModel> getCart() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/cart',
      fromData: (data) => data as Map<String, dynamic>,
    );
    return CartModel.fromJson(response.data!);
  }

  /// POST /api/v1/cart/items — butuh auth.
  /// Body: { book_id, branch_id }
  Future<CartModel> addCartItem({
    required String bookId,
    required String branchId,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/cart/items',
      body: {'book_id': bookId, 'branch_id': branchId},
      fromData: (data) => data as Map<String, dynamic>,
    );
    return CartModel.fromJson(response.data!);
  }

  /// DELETE /api/v1/cart/items/{cartItemId} — butuh auth.
  Future<void> removeCartItem(String cartItemId) async {
    await _client.delete<void>(
      '/cart/items/$cartItemId',
      fromData: (_) {},
    );
  }

  /// DELETE /api/v1/cart — kosongkan seluruh cart.
  Future<void> clearCart() async {
    await _client.delete<void>(
      '/cart',
      fromData: (_) {},
    );
  }

  // ── Notifications ─────────────────────────────────────────────────────────

  /// GET /api/v1/notifications — butuh auth.
  Future<NotificationListResult> getNotifications({
    int perPage = 20,
    bool onlyUnread = false,
  }) async {
    final query = <String, String>{
      'per_page': perPage.toString(),
      if (onlyUnread) 'unread': 'true',
    };
    final response = await _client.get<Map<String, dynamic>>(
      '/notifications',
      query: query,
      fromData: (data) => data as Map<String, dynamic>,
    );
    return NotificationListResult.fromJson(response.data ?? {});
  }

  /// GET /api/v1/notifications/unread-count — butuh auth.
  Future<int> getUnreadNotificationCount() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/notifications/unread-count',
      fromData: (data) => data as Map<String, dynamic>,
    );
    return (response.data?['count'] as num?)?.toInt() ?? 0;
  }

  /// PUT /api/v1/notifications/{id}/read — butuh auth.
  Future<void> markNotificationRead(String notificationId) async {
    await _client.put<void>(
      '/notifications/$notificationId/read',
      fromData: (_) {},
    );
  }

  /// PUT /api/v1/notifications/read-all — butuh auth.
  Future<void> markAllNotificationsRead() async {
    await _client.put<void>(
      '/notifications/read-all',
      fromData: (_) {},
    );
  }

  // ── Profile ──────────────────────────────────────────────────────────────

  /// GET /api/v1/account/profile — butuh auth.
  Future<HomeProfileModel> getProfile() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/account/profile',
      fromData: (data) => data as Map<String, dynamic>,
    );
    return HomeProfileModel.fromJson(response.data!);
  }

  /// PUT /api/v1/account/password — butuh auth.
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _client.put<void>(
      '/account/password',
      body: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': confirmPassword,
      },
      fromData: (_) {},
    );
  }

  // ── Checkout ──────────────────────────────────────────────────────────────

  /// POST /api/v1/checkout — butuh auth.
  /// Body: { branch_id, cart_item_ids?, start_date (yyyy-MM-dd), end_date }
  /// Response data: { borrowing, qr { image: "data:image/png;base64,..." }, rules }
  Future<CheckoutResultModel> checkout({
    required String branchId,
    required List<String> cartItemIds,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/checkout',
      body: {
        'branch_id': branchId,
        'cart_item_ids': cartItemIds,
        'start_date': _formatDate(startDate),
        'end_date': _formatDate(endDate),
      },
      fromData: (data) => data as Map<String, dynamic>,
    );
    return CheckoutResultModel.fromJson(response.data!);
  }

  // ── Borrowing QR ──────────────────────────────────────────────────────────

  /// POST /api/v1/borrowings/{id}/qr/refresh — perbarui QR pickup.
  /// Hanya untuk borrowing dengan status awaiting_pickup.
  Future<CheckoutQrModel> refreshPickupQr(String borrowingId) async {
    debugPrint('[QR][API] refreshPickupQr — borrowingId=$borrowingId');
    debugPrint('[QR][API] Endpoint: POST /api/v1/borrowings/$borrowingId/qr/refresh');
    final response = await _client.post<Map<String, dynamic>>(
      '/borrowings/$borrowingId/qr/refresh',
      fromData: (data) => data as Map<String, dynamic>,
    );
    final qrJson = response.data!['qr'] as Map<String, dynamic>? ?? {};
    debugPrint('[QR][API] Raw qr JSON keys=${qrJson.keys.toList()}');
    final qr = CheckoutQrModel.fromJson(qrJson);
    debugPrint(
      '[QR][API] Parsed — id=${qr.id} code=${qr.code} ttlSeconds=${qr.ttlSeconds} '
      'expiresAt=${qr.expiresAt} declaredMimeType=${qr.declaredMimeType} '
      'isSvgContent=${qr.isSvgContent} isRenderableRasterImage=${qr.isRenderableRasterImage}',
    );
    return qr;
  }

  // ── My Books ──────────────────────────────────────────────────────────────

  /// GET /api/v1/my-books — butuh auth.
  /// Query: status? (active|due_soon|overdue|returned), per_page?, page?
  /// Tanpa status → semua status (termasuk pending, awaiting_pickup).
  Future<({List<LibraryMyBookItemModel> items, bool hasMore})> getMyBooks({
    String? status,
    int perPage = 10,
    int page = 1,
  }) async {
    debugPrint('[MYBOOKS] Fetch started — page=$page status=${status ?? "all"} perPage=$perPage');

    final query = <String, String>{
      'per_page': perPage.toString(),
      'page': page.toString(),
    };
    if (status != null) query['status'] = status;

    debugPrint('[MYBOOKS] Endpoint: GET /api/v1/my-books  query=$query');

    final response = await _client.get<List<dynamic>>(
      '/my-books',
      query: query,
      fromData: (data) {
        if (data is List) return data;
        return <dynamic>[];
      },
    );

    final rawList = response.data ?? [];
    debugPrint('[MYBOOKS] Raw item count from API: ${rawList.length}');

    final items = rawList
        .whereType<Map<String, dynamic>>()
        .map((json) {
          final item = LibraryMyBookItemModel.fromApiJson(json);
          debugPrint('[MYBOOKS] Parsed: ${item.bookCode} status=${item.rawStatus} → ${item.status.name}');
          return item;
        })
        .toList();

    final pending = items.where((i) => i.isPending).length;
    final awaiting = items.where((i) => i.isAwaitingPickup).length;
    final active = items.where((i) => i.isActive || i.isDueSoon || i.isOverdue).length;
    final done = items.where((i) => i.isFinished || i.isExpired || i.isCancelled).length;
    debugPrint('[MYBOOKS] Parsed items: total=${items.length} pending=$pending awaitingPickup=$awaiting active=$active done=$done');

    // Heuristic: fewer items than requested → no more pages
    final hasMore = rawList.length >= perPage;
    debugPrint('[MYBOOKS] hasMore=$hasMore');

    return (items: items, hasMore: hasMore);
  }

  /// GET /api/v1/my-books/{borrowingId} — detail peminjaman.
  Future<LibraryMyBookItemModel> getMyBookDetail(String borrowingId) async {
    debugPrint('[MYBOOK_DETAIL] Fetch started — borrowingId=$borrowingId');
    debugPrint('[MYBOOK_DETAIL] Endpoint: GET /api/v1/my-books/$borrowingId');

    final response = await _client.get<Map<String, dynamic>>(
      '/my-books/$borrowingId',
      fromData: (data) => data as Map<String, dynamic>,
    );

    final item = LibraryMyBookItemModel.fromApiJson(response.data!);
    debugPrint('[MYBOOK_DETAIL] Response received — status=${item.rawStatus} canReturn=${item.canReturn} canPickup=${item.canPickup}');

    return item;
  }

  /// POST /api/v1/my-books/{borrowingId}/return-qr/refresh
  /// Buat/perbarui QR pengembalian buku.
  Future<CheckoutQrModel> refreshReturnQr(String borrowingId) async {
    debugPrint('[QR][API] refreshReturnQr — borrowingId=$borrowingId');
    debugPrint('[QR][API] Endpoint: POST /api/v1/my-books/$borrowingId/return-qr/refresh');

    final response = await _client.post<Map<String, dynamic>>(
      '/my-books/$borrowingId/return-qr/refresh',
      fromData: (data) => data as Map<String, dynamic>,
    );
    final qrJson = response.data!['qr'] as Map<String, dynamic>? ?? {};
    debugPrint('[QR][API] Raw qr JSON keys=${qrJson.keys.toList()}');
    final qr = CheckoutQrModel.fromJson(qrJson);
    debugPrint(
      '[QR][API] Parsed — id=${qr.id} code=${qr.code} ttlSeconds=${qr.ttlSeconds} '
      'expiresAt=${qr.expiresAt} declaredMimeType=${qr.declaredMimeType} '
      'isSvgContent=${qr.isSvgContent} isRenderableRasterImage=${qr.isRenderableRasterImage}',
    );
    return qr;
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
