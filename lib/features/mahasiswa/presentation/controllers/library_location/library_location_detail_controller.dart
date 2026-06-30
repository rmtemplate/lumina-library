import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/features/mahasiswa/data/services/home_api_service.dart';
import 'package:lumina_library/shared/models/book/book_model.dart';

class LibraryLocationDetailController extends GetxController {
  static const int _perPage = 15;

  final RxBool isFavorite = false.obs;
  final RxBool isLoadingBooks = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMorePages = true.obs;
  final RxString loadMoreError = ''.obs;
  final RxList<BookModel> branchBooks = <BookModel>[].obs;

  String? _loadedBranchId;
  int _currentPage = 1;

  void toggleFavorite() => isFavorite.toggle();

  Future<void> loadBranchBooks(String branchId, {bool forceRefresh = false}) async {
    if (!forceRefresh && (branchId.isEmpty || branchId == _loadedBranchId)) return;

    _loadedBranchId = branchId;
    _currentPage = 1;
    hasMorePages.value = true;
    loadMoreError.value = '';
    isLoadingBooks.value = true;
    branchBooks.clear();

    try {
      final result = await Get.find<HomeApiService>().getBranchBooksPage(
        branchId,
        page: 1,
        perPage: _perPage,
        sort: 'trending',
      );
      branchBooks.addAll(result.items);
      hasMorePages.value = result.hasMorePages;
    } on LuminaApiException catch (_) {
      // leave list empty — page shows empty state
    } catch (_) {
      // leave list empty
    } finally {
      isLoadingBooks.value = false;
    }
  }

  Future<void> loadMoreBranchBooks() async {
    final branchId = _loadedBranchId;
    if (branchId == null || branchId.isEmpty) return;
    if (!hasMorePages.value || isLoadingMore.value || isLoadingBooks.value) return;

    loadMoreError.value = '';
    isLoadingMore.value = true;
    _currentPage++;

    final before = branchBooks.length;
    debugPrint(
      '[PAGINATION][BRANCH] nextPageRequest=$_currentPage itemsLoaded=$before',
    );

    try {
      final result = await Get.find<HomeApiService>().getBranchBooksPage(
        branchId,
        page: _currentPage,
        perPage: _perPage,
        sort: 'trending',
      );
      branchBooks.addAll(result.items);
      hasMorePages.value = result.hasMorePages;
      debugPrint(
        '[PAGINATION][BRANCH] appended=${result.items.length} '
        'itemsAfterAppend=${branchBooks.length} hasMorePages=${hasMorePages.value}',
      );
    } on LuminaApiException catch (e) {
      _currentPage--;
      loadMoreError.value = e.displayMessage;
    } catch (_) {
      _currentPage--;
      loadMoreError.value = 'Gagal memuat lebih banyak buku.';
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshBranchBooks(String branchId) =>
      loadBranchBooks(branchId, forceRefresh: true);
}
