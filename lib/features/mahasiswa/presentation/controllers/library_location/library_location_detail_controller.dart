import 'package:get/get.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/features/mahasiswa/data/services/home_api_service.dart';
import 'package:lumina_library/shared/models/book/book_model.dart';

class LibraryLocationDetailController extends GetxController {
  final RxBool isFavorite = false.obs;
  final RxBool isLoadingBooks = false.obs;
  final RxList<BookModel> branchBooks = <BookModel>[].obs;

  String? _loadedBranchId;

  void toggleFavorite() => isFavorite.toggle();

  Future<void> loadBranchBooks(String branchId) async {
    if (branchId.isEmpty || branchId == _loadedBranchId) return;

    _loadedBranchId = branchId;
    isLoadingBooks.value = true;
    branchBooks.clear();

    try {
      final service = Get.find<HomeApiService>();
      final result = await service.getBranchBooks(
        branchId,
        sort: 'trending',
        limit: 12,
      );
      branchBooks.assignAll(result);
    } on LuminaApiException catch (_) {
      // leave list empty — page shows empty state
    } catch (_) {
      // leave list empty
    } finally {
      isLoadingBooks.value = false;
    }
  }
}
