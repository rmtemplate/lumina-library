import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/theme/lumina_colors.dart';
import '../../../../../core/theme/lumina_radius.dart';
import '../../../../../core/theme/lumina_spacing.dart';
import '../../../../../core/theme/lumina_text_styles.dart';
import '../../../../../shared/widgets/feedback/lumina_toast.dart';
import '../../controllers/rack/move_books_controller.dart';
import '../../controllers/rack/rack_controller.dart';
import '../../models/rack_management_models.dart';
import '../../widgets/rack/rack_management_widgets.dart';

class MoveBooksPage extends StatelessWidget {
  const MoveBooksPage({
    super.key,
    required this.sourceRackId,
    required this.selectedBookIds,
    required this.selectedBooks,
  });

  final String sourceRackId;
  final List<String> selectedBookIds;
  final List<BookModel> selectedBooks;

  String get _controllerTag {
    return 'move-books-$sourceRackId-${selectedBookIds.join('-')}';
  }

  RackController get rackController {
    if (Get.isRegistered<RackController>()) {
      return Get.find<RackController>();
    }

    return Get.put(
      RackController(),
      permanent: true,
    );
  }

  MoveBooksController get controller {
    if (Get.isRegistered<MoveBooksController>(tag: _controllerTag)) {
      return Get.find<MoveBooksController>(tag: _controllerTag);
    }

    return Get.put(
      MoveBooksController(
        sourceRackId: sourceRackId,
        bookIds: selectedBookIds,
        rackController: rackController,
        selectedBooks: selectedBooks,
      ),
      tag: _controllerTag,
    );
  }

  Future<void> _confirmMove(BuildContext context) async {
    final moveController = controller;
    final destinationRack = moveController.selectedDestinationRack;

    if (destinationRack == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return ConfirmationDialog(
          title: 'Pindahkan Buku?',
          description:
              '${selectedBookIds.length} buku akan dipindahkan ke ${destinationRack.name}.',
          confirmLabel: 'Pindahkan',
          cancelLabel: 'Batal',
          icon: Icons.swap_horiz_rounded,
        );
      },
    );

    if (confirmed != true) return;

    final success = moveController.moveBooks();

    if (!success) {
      LuminaToast.error('Buku belum berhasil dipindahkan.');
      return;
    }

    LuminaToast.success(
      '${selectedBookIds.length} buku berhasil dipindahkan ke ${destinationRack.name}.',
    );

    Get.back<bool>(result: true);
  }

  @override
  Widget build(BuildContext context) {
    final moveController = controller;

    return Scaffold(
      backgroundColor: LuminaColors.surface,
      bottomNavigationBar: _MoveBottomAction(
        controller: moveController,
        onConfirmTap: () => _confirmMove(context),
      ),
      body: Column(
        children: [
          RackTopAppBar(
            title: 'Move Book',
            onLeadingTap: Get.back,
            trailingIcon: Icons.more_vert_rounded,
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 820,
                ),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    LuminaSpacing.marginMobile,
                    LuminaSpacing.lg,
                    LuminaSpacing.marginMobile,
                    112,
                  ),
                  children: [
                    _MoveSelectedBooksSection(
                      controller: moveController,
                    ),
                    const SizedBox(height: LuminaSpacing.lg),
                    _MoveDestinationSection(
                      controller: moveController,
                    ),
                    const SizedBox(height: LuminaSpacing.lg),
                    _MoveReasonSection(
                      controller: moveController,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoveSelectedBooksSection extends StatelessWidget {
  const _MoveSelectedBooksSection({
    required this.controller,
  });

  final MoveBooksController controller;

  @override
  Widget build(BuildContext context) {
    final selectedBooks = controller.selectedBooks;
    final sourceRack = controller.sourceRack;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MoveSectionTitle(
          title: selectedBooks.length == 1 ? 'Book to Move' : 'Books to Move',
        ),
        const SizedBox(height: LuminaSpacing.sm),
        Container(
          padding: const EdgeInsets.all(LuminaSpacing.md),
          decoration: BoxDecoration(
            color: LuminaColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(LuminaRadius.xl),
            border: Border.all(
              color: LuminaColors.surfaceVariant,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _SelectedBooksPreview(
                books: selectedBooks,
              ),
              const SizedBox(width: LuminaSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedBooks.length == 1
                          ? selectedBooks.first.title
                          : '${selectedBooks.length} buku dipilih',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: LuminaTextStyles.titleLg.copyWith(
                        color: LuminaColors.primary,
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedBooks.length == 1
                          ? selectedBooks.first.author
                          : 'Buku akan dipindahkan bersama ke rak tujuan.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: LuminaTextStyles.bodyMd.copyWith(
                        color: LuminaColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: LuminaSpacing.sm),
        Container(
          padding: const EdgeInsets.all(LuminaSpacing.sm),
          decoration: BoxDecoration(
            color: LuminaColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(LuminaRadius.lg),
            border: Border.all(
              color: LuminaColors.surfaceVariant,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: LuminaColors.onSurfaceVariant,
                size: 23,
              ),
              const SizedBox(width: LuminaSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT LOCATION',
                      style: LuminaTextStyles.labelMd.copyWith(
                        color: LuminaColors.onSurfaceVariant,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sourceRack == null
                          ? '-'
                          : '${sourceRack.name} (${sourceRack.sectionName})',
                      style: LuminaTextStyles.bodyMd.copyWith(
                        color: LuminaColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectedBooksPreview extends StatelessWidget {
  const _SelectedBooksPreview({
    required this.books,
  });

  final List books;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return Container(
        width: 80,
        height: 112,
        decoration: BoxDecoration(
          color: LuminaColors.surfaceContainer,
          borderRadius: BorderRadius.circular(LuminaRadius.md),
        ),
        child: const Icon(
          Icons.menu_book_rounded,
          color: LuminaColors.primary,
        ),
      );
    }

    return SizedBox(
      width: 86,
      height: 112,
      child: Stack(
        children: List.generate(books.length.clamp(0, 3), (index) {
          final book = books[index];
          final left = index * 8.0;
          final top = index * 4.0;

          return Positioned(
            left: left,
            top: top,
            child: Container(
              width: 70,
              height: 104,
              decoration: BoxDecoration(
                color: LuminaColors.surfaceContainer,
                borderRadius: BorderRadius.circular(LuminaRadius.md),
                border: Border.all(
                  color: LuminaColors.surfaceContainerLowest,
                  width: 2,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                book.cover,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return const Icon(
                    Icons.menu_book_rounded,
                    color: LuminaColors.primary,
                  );
                },
              ),
            ),
          );
        }).reversed.toList(),
      ),
    );
  }
}

class _MoveDestinationSection extends StatelessWidget {
  const _MoveDestinationSection({
    required this.controller,
  });

  final MoveBooksController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final racks = controller.destinationRacks;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MoveSectionTitle(
            title: 'Destination',
          ),
          const SizedBox(height: LuminaSpacing.sm),
          TextField(
            controller: controller.searchController,
            onChanged: controller.setSearchKeyword,
            cursorColor: LuminaColors.primary,
            decoration: InputDecoration(
              hintText: 'Search target rack...',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: LuminaColors.onSurfaceVariant,
              ),
              filled: true,
              fillColor: LuminaColors.surfaceContainerLowest,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: LuminaSpacing.sm,
                vertical: LuminaSpacing.sm,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(LuminaRadius.lg),
                borderSide: const BorderSide(
                  color: LuminaColors.outlineVariant,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(LuminaRadius.lg),
                borderSide: const BorderSide(
                  color: LuminaColors.primary,
                  width: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: LuminaSpacing.sm),
          if (racks.isEmpty)
            const EmptyStateWidget(
              icon: Icons.search_off_rounded,
              title: 'Rak Tidak Ditemukan',
              description: 'Coba kata kunci lain untuk mencari rak tujuan.',
            )
          else
            Column(
              children: List.generate(racks.length, (index) {
                final rack = racks[index];
                final selected =
                    controller.selectedDestinationRackId.value == rack.id;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == racks.length - 1 ? 0 : LuminaSpacing.sm,
                  ),
                  child: MoveRackTile(
                    rack: rack,
                    isSelected: selected,
                    onTap: () => controller.selectDestinationRack(rack.id),
                  ),
                );
              }),
            ),
        ],
      );
    });
  }
}

class _MoveReasonSection extends StatelessWidget {
  const _MoveReasonSection({
    required this.controller,
  });

  final MoveBooksController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MoveSectionTitle(
            title: 'Move Reason',
          ),
          const SizedBox(height: LuminaSpacing.sm),
          DropdownButtonFormField<String>(
            initialValue: controller.selectedReason.value,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: LuminaColors.surfaceContainerLowest,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: LuminaSpacing.sm,
                vertical: LuminaSpacing.sm,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(LuminaRadius.lg),
                borderSide: const BorderSide(
                  color: LuminaColors.outlineVariant,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(LuminaRadius.lg),
                borderSide: const BorderSide(
                  color: LuminaColors.primary,
                  width: 1.2,
                ),
              ),
            ),
            items: controller.reasons.map((item) {
              return DropdownMenuItem<String>(
                value: item.id,
                child: Text(item.label),
              );
            }).toList(),
            onChanged: controller.setReason,
          ),
          const SizedBox(height: LuminaSpacing.sm),
          TextField(
            controller: controller.notesController,
            maxLines: 4,
            cursorColor: LuminaColors.primary,
            decoration: InputDecoration(
              hintText: 'Add optional notes...',
              filled: true,
              fillColor: LuminaColors.surfaceContainerLowest,
              contentPadding: const EdgeInsets.all(LuminaSpacing.sm),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(LuminaRadius.lg),
                borderSide: const BorderSide(
                  color: LuminaColors.outlineVariant,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(LuminaRadius.lg),
                borderSide: const BorderSide(
                  color: LuminaColors.primary,
                  width: 1.2,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _MoveSectionTitle extends StatelessWidget {
  const _MoveSectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: LuminaTextStyles.titleLg.copyWith(
        color: LuminaColors.primary,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _MoveBottomAction extends StatelessWidget {
  const _MoveBottomAction({
    required this.controller,
    required this.onConfirmTap,
  });

  final MoveBooksController controller;
  final VoidCallback onConfirmTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        border: const Border(
          top: BorderSide(
            color: LuminaColors.surfaceVariant,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(LuminaSpacing.marginMobile),
          child: Obx(() {
            return SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: controller.canSubmit ? onConfirmTap : null,
                icon: const Icon(Icons.swap_horiz_rounded),
                label: Text(
                  'Confirm Move',
                  style: LuminaTextStyles.titleLg.copyWith(
                    color: controller.canSubmit
                        ? LuminaColors.onPrimary
                        : LuminaColors.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: LuminaColors.primary,
                  disabledBackgroundColor: LuminaColors.surfaceContainerHigh,
                  foregroundColor: LuminaColors.onPrimary,
                  disabledForegroundColor: LuminaColors.onSurfaceVariant,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(LuminaRadius.full),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}