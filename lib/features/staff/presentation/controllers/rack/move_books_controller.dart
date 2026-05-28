import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina_library/features/staff/presentation/models/rack_management_models.dart';
import 'rack_controller.dart';

class MoveBooksController extends GetxController {
  MoveBooksController({
    required this.sourceRackId,
    required this.bookIds,
    required this.rackController,
  });

  final String sourceRackId;
  final List<String> bookIds;
  final RackController rackController;

  final TextEditingController searchController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final RxString searchKeyword = ''.obs;
  final RxString selectedDestinationRackId = ''.obs;
  final RxString selectedReason = 'reorganization'.obs;

  RackModel? get sourceRack => rackController.findRackById(sourceRackId);

  List<BookModel> get selectedBooks {
    return rackController.findBooksByIds(bookIds);
  }

  List<RackModel> get destinationRacks {
    final keyword = searchKeyword.value.trim().toLowerCase();

    return rackController.racks.where((rack) {
      if (rack.id == sourceRackId) return false;

      if (keyword.isEmpty) return true;

      final name = rack.name.toLowerCase();
      final section = rack.sectionName.toLowerCase();

      return name.contains(keyword) || section.contains(keyword);
    }).toList(growable: false);
  }

  RackModel? get selectedDestinationRack {
    final selectedId = selectedDestinationRackId.value;

    if (selectedId.isEmpty) return null;

    return rackController.findRackById(selectedId);
  }

  bool get canSubmit {
    return selectedDestinationRackId.value.trim().isNotEmpty;
  }

  List<MoveReasonModel> get reasons {
    return const [
      MoveReasonModel(
        id: 'reorganization',
        label: 'Reorganization',
      ),
      MoveReasonModel(
        id: 'new_collection',
        label: 'New Collection',
      ),
      MoveReasonModel(
        id: 'damaged_area',
        label: 'Damaged Item Area',
      ),
      MoveReasonModel(
        id: 'archival',
        label: 'Archival Storage',
      ),
    ];
  }

  void setSearchKeyword(String value) {
    searchKeyword.value = value;
  }

  void selectDestinationRack(String rackId) {
    if (rackId == sourceRackId) return;

    selectedDestinationRackId.value = rackId;
  }

  void setReason(String? value) {
    if (value == null || value.isEmpty) return;

    selectedReason.value = value;
  }

  bool moveBooks() {
    final destinationId = selectedDestinationRackId.value;

    if (destinationId.isEmpty) return false;

    return rackController.moveBooks(
      sourceRackId: sourceRackId,
      destinationRackId: destinationId,
      bookIds: bookIds,
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    notesController.dispose();
    super.onClose();
  }
}

class MoveReasonModel {
  const MoveReasonModel({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;
}