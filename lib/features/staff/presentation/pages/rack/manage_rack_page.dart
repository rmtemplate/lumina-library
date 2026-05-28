import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/theme/lumina_colors.dart';
import '../../../../../core/theme/lumina_spacing.dart';
import '../../controllers/rack/manage_rack_controller.dart';
import '../../controllers/rack/rack_controller.dart';
import '../../widgets/rack/rack_management_widgets.dart';
import 'move_books_page.dart';

class ManageRackPage extends StatelessWidget {
  const ManageRackPage({
    super.key,
    required this.rackId,
  });

  final String rackId;

  String get _controllerTag => 'manage-rack-$rackId';

  RackController get rackController {
    if (Get.isRegistered<RackController>()) {
      return Get.find<RackController>();
    }

    return Get.put(
      RackController(),
      permanent: true,
    );
  }

  ManageRackController get controller {
    if (Get.isRegistered<ManageRackController>(tag: _controllerTag)) {
      return Get.find<ManageRackController>(tag: _controllerTag);
    }

    return Get.put(
      ManageRackController(
        rackId: rackId,
        rackController: rackController,
      ),
      tag: _controllerTag,
    );
  }

  Future<void> _goToMoveBooksPage() async {
    final manageController = controller;

    final selectedBookIds = manageController.selectedBookIds.toList(
      growable: false,
    );

    if (selectedBookIds.isEmpty) return;

    final result = await Get.to<bool>(
      () => MoveBooksPage(
        sourceRackId: rackId,
        selectedBookIds: selectedBookIds,
      ),
      transition: Transition.cupertino,
    );

    if (result == true) {
      manageController.clearSelection();
      manageController.syncSelectionWithCurrentBooks();
    }
  }

  @override
  Widget build(BuildContext context) {
    final manageController = controller;

    return Scaffold(
      backgroundColor: LuminaColors.background,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Obx(() {
        return CustomFloatingButton(
          visible: manageController.isSelectionMode,
          label: 'Pindahkan Buku',
          icon: Icons.swap_horiz_rounded,
          onTap: _goToMoveBooksPage,
        );
      }),
      body: Column(
        children: [
          Obx(() {
            if (manageController.isSelectionMode) {
              return SelectionAppBar(
                selectedCount: manageController.selectedCount,
                onCloseTap: manageController.clearSelection,
                onSelectAllTap: manageController.selectAll,
              );
            }

            final rack = manageController.rack;

            return RackTopAppBar(
              title: rack?.name ?? 'Atur Rak',
              subtitle: rack == null
                  ? null
                  : '${rack.rackCode} • ${rack.bookCount} buku • ${rack.floorLabel}',
              onLeadingTap: Get.back,
              trailingIcon: Icons.more_vert_rounded,
            );
          }),
          Expanded(
            child: Obx(() {
              final rack = manageController.rack;
              final books = manageController.books;

              if (rack == null) {
                return const EmptyStateWidget(
                  icon: Icons.error_outline_rounded,
                  title: 'Rak Tidak Ditemukan',
                  description: 'Rak yang Anda pilih tidak tersedia.',
                );
              }

              if (books.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.inventory_2_outlined,
                  title: '${rack.name} Kosong',
                  description:
                      'Belum ada buku di rak ini. Buku yang dipindahkan ke rak ini akan muncul di sini.',
                );
              }

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 900,
                  ),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      LuminaSpacing.marginMobile,
                      LuminaSpacing.lg,
                      LuminaSpacing.marginMobile,
                      118,
                    ),
                    itemCount: books.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 190,
                      mainAxisSpacing: LuminaSpacing.md,
                      crossAxisSpacing: LuminaSpacing.md,
                      childAspectRatio: 0.60,
                    ),
                    itemBuilder: (context, index) {
                      final book = books[index];

                      /// Obx per item supaya selected state langsung repaint
                      /// ketika long press / tap, tanpa menunggu full page rebuild.
                      return Obx(() {
                        final isSelectionMode =
                            manageController.isSelectionMode;
                        final isSelected =
                            manageController.isSelected(book.id);

                        return BookCard(
                          key: ValueKey(
                            '${book.id}-$isSelectionMode-$isSelected',
                          ),
                          book: book,
                          isSelectionMode: isSelectionMode,
                          isSelected: isSelected,
                          onTap: () {
                            manageController.handleBookTap(book);
                          },
                          onLongPress: () {
                            manageController.handleBookLongPress(book);
                          },
                        );
                      });
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}