import 'package:get/get.dart';

import '../../../data/services/staff_api_service.dart';
import '../../models/rack_management_models.dart';
import 'rack_controller.dart';

class ManageRackController extends GetxController {
  ManageRackController({
    required this.rackId,
    required this.rackController,
  });

  final String rackId;
  final RackController rackController;

  final Rx<RackModel?> _rack = Rx<RackModel?>(null);
  final RxBool isDetailLoading = false.obs;
  final RxList<String> selectedBookIds = <String>[].obs;

  RackModel? get rack => _rack.value ?? rackController.findRackById(rackId);
  List<BookModel> get books => _rack.value?.books ?? rackController.findRackById(rackId)?.books ?? const [];

  bool get isSelectionMode => selectedBookIds.isNotEmpty;
  int get selectedCount => selectedBookIds.length;

  List<BookModel> get selectedBooks {
    final ids = selectedBookIds.toSet();
    return books.where((b) => ids.contains(b.id)).toList(growable: false);
  }

  @override
  void onInit() {
    super.onInit();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    isDetailLoading.value = true;
    try {
      final raw = await Get.find<StaffApiService>().getRackDetail(rackId);
      final rackJson = raw['rack'] as Map<String, dynamic>? ?? {};
      final rawBooks = raw['books'] as List<dynamic>? ?? [];
      _rack.value = RackModel.fromDetailJson(rackJson, rawBooks);
    } catch (_) {
      // Fall back to whatever RackController has (list data, no books).
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<void> refreshDetail() => _loadDetail();

  bool isSelected(String bookId) => selectedBookIds.contains(bookId);

  void startSelection(String bookId) {
    if (!selectedBookIds.contains(bookId)) selectedBookIds.add(bookId);
  }

  void toggleSelection(String bookId) {
    if (selectedBookIds.contains(bookId)) {
      selectedBookIds.remove(bookId);
    } else {
      selectedBookIds.add(bookId);
    }
  }

  void handleBookTap(BookModel book) {
    if (!isSelectionMode) return;
    toggleSelection(book.id);
  }

  void handleBookLongPress(BookModel book) {
    if (!isSelectionMode) {
      startSelection(book.id);
      return;
    }
    toggleSelection(book.id);
  }

  void clearSelection() => selectedBookIds.clear();

  void selectAll() => selectedBookIds.assignAll(books.map((b) => b.id));

  void syncSelectionWithCurrentBooks() {
    final ids = books.map((b) => b.id).toSet();
    selectedBookIds.assignAll(selectedBookIds.where(ids.contains));
  }
}
