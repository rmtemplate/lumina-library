import 'package:get/get.dart';

import 'package:lumina_library/features/staff/data/models/staff_book_item_model.dart';
import 'package:lumina_library/shared/widgets/feedback/lumina_toast.dart';

/// Shared cart state for the staff-initiated Borrow flow — survives
/// navigation between the Scan page, the Cart page, and the manual-search
/// sheet (registered with `fenix: true` so it's recreated on demand but the
/// SAME instance is reused across that whole flow until explicitly
/// cleared). Pure state; the actual "confirm borrowing" API call lives in
/// whichever page submits it, not here.
class StaffBorrowCartController extends GetxController {
  final RxList<StaffBookItemModel> items = <StaffBookItemModel>[].obs;

  bool get isEmpty => items.isEmpty;
  int get count => items.length;

  /// Adds a scanned/searched book item, de-duplicating by id and warning
  /// (rather than silently ignoring) if it's already in the cart — the
  /// staff scanned/picked the same physical copy twice, which usually
  /// means they didn't notice it already got added.
  void addItem(StaffBookItemModel item) {
    if (items.any((existing) => existing.id == item.id)) {
      LuminaToast.warning('${item.bookTitle} sudah ada di keranjang.');
      return;
    }

    items.add(item);
    LuminaToast.success('${item.bookTitle} ditambahkan ke keranjang.');
  }

  void removeItem(String itemId) {
    items.removeWhere((item) => item.id == itemId);
  }

  void clear() {
    items.clear();
  }
}
