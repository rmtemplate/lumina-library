import 'package:get/get.dart';

import '../../models/rack_management_models.dart';
import 'rack_controller.dart';

class ManageRackController extends GetxController {
  ManageRackController({
    required this.rackId,
    required this.rackController,
  });

  final String rackId;
  final RackController rackController;

  /// Pakai RxList, bukan RxSet.
  ///
  /// RxSet kadang tidak selalu trigger rebuild sesuai ekspektasi ketika
  /// dipakai dengan getter seperti contains/isNotEmpty.
  final RxList<String> selectedBookIds = <String>[].obs;

  RackModel? get rack => rackController.findRackById(rackId);

  List<BookModel> get books => rack?.books ?? const [];

  bool get isSelectionMode => selectedBookIds.isNotEmpty;

  int get selectedCount => selectedBookIds.length;

  List<BookModel> get selectedBooks {
    final selectedIds = selectedBookIds.toSet();

    return books.where((book) {
      return selectedIds.contains(book.id);
    }).toList(growable: false);
  }

  bool isSelected(String bookId) {
    return selectedBookIds.contains(bookId);
  }

  void startSelection(String bookId) {
    if (selectedBookIds.contains(bookId)) return;

    selectedBookIds.assignAll([
      ...selectedBookIds,
      bookId,
    ]);
  }

  void toggleSelection(String bookId) {
    final nextSelectedIds = selectedBookIds.toList(growable: true);

    if (nextSelectedIds.contains(bookId)) {
      nextSelectedIds.remove(bookId);
    } else {
      nextSelectedIds.add(bookId);
    }

    selectedBookIds.assignAll(nextSelectedIds);
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

  void clearSelection() {
    selectedBookIds.clear();
  }

  void selectAll() {
    selectedBookIds.assignAll(
      books.map((book) => book.id).toList(growable: false),
    );
  }

  void syncSelectionWithCurrentBooks() {
    final currentBookIds = books.map((book) => book.id).toSet();

    selectedBookIds.assignAll(
      selectedBookIds.where(currentBookIds.contains).toList(growable: false),
    );
  }
}