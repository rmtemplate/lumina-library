import 'package:lumina_library/core/network/lumina_api_client.dart';
import 'package:lumina_library/shared/models/banner/banner_model.dart';
import 'package:lumina_library/shared/models/book/book_model.dart';
import 'package:lumina_library/shared/models/branch/branch_detail_model.dart';
import 'package:lumina_library/shared/models/branch/branch_model.dart';
import 'package:lumina_library/shared/models/category/category_model.dart';
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

  // ── Profile ──────────────────────────────────────────────────────────────

  /// GET /api/v1/account/profile — butuh auth.
  Future<HomeProfileModel> getProfile() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/account/profile',
      fromData: (data) => data as Map<String, dynamic>,
    );
    return HomeProfileModel.fromJson(response.data!);
  }
}
