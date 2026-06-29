import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../shared/widgets/feedback/lumina_toast.dart';
import '../../../data/services/staff_api_service.dart';
import '../../models/rack_management_models.dart';

class RackController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  final RxString searchKeyword = ''.obs;
  final RxList<RackModel> racks = <RackModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadRacks();
  }

  Future<void> _loadRacks() async {
    isLoading.value = true;
    try {
      final raw = await Get.find<StaffApiService>().getRacks();
      racks.assignAll(raw.map(RackModel.fromJson));
    } catch (_) {
      // Keep existing list on error; page shows empty state if list was empty.
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshRacks() => _loadRacks();

  List<RackModel> get filteredRacks {
    final keyword = searchKeyword.value.trim();
    if (keyword.isEmpty) return racks.toList(growable: false);
    return racks.where((r) => r.matchesKeyword(keyword)).toList(growable: false);
  }

  bool get isSearching => searchKeyword.value.trim().isNotEmpty;

  void setSearchKeyword(String value) => searchKeyword.value = value;

  void clearSearch() {
    searchController.clear();
    searchKeyword.value = '';
  }

  RackModel? findRackById(String rackId) {
    for (final rack in racks) {
      if (rack.id == rackId) return rack;
    }
    return null;
  }

  // ponytail: local-only move; no backend move endpoint exists yet.
  bool moveBooks({
    required String sourceRackId,
    required String destinationRackId,
    required List<String> bookIds,
  }) {
    if (sourceRackId == destinationRackId || bookIds.isEmpty) return false;

    final srcIdx = racks.indexWhere((r) => r.id == sourceRackId);
    final dstIdx = racks.indexWhere((r) => r.id == destinationRackId);
    if (srcIdx < 0 || dstIdx < 0) return false;

    final dst = racks[dstIdx];
    if (dst.availableSlot < bookIds.length) {
      LuminaToast.warning(
        'Rak ${dst.rackCode} hanya memiliki ${dst.availableSlot} slot tersedia.',
      );
      return false;
    }

    final idSet = bookIds.toSet();
    final src = racks[srcIdx];
    final moved = src.books.where((b) => idSet.contains(b.id)).map((b) => b.copyWith(rackId: destinationRackId)).toList();
    if (moved.isEmpty) return false;

    racks[srcIdx] = src.copyWith(books: src.books.where((b) => !idSet.contains(b.id)).toList());
    racks[dstIdx] = dst.copyWith(books: [...dst.books, ...moved]);
    racks.refresh();
    return true;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
