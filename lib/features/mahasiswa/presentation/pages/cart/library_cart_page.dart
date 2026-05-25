import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/shared/models/book/cart_book_model.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/cart/library_cart_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/cart/library_cart_book_tile.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/layout/library_transaction_top_bar.dart';
import 'package:lumina_library/features/mahasiswa/presentation/pages/checkout/library_checkout_page.dart';

import 'package:lumina_library/shared/models/book/cart_library_group_model.dart';

class LibraryCartPage extends StatelessWidget {
  LibraryCartPage({
    super.key,
  });

  final LibraryCartController controller =
      Get.isRegistered<LibraryCartController>()
          ? Get.find<LibraryCartController>()
          : Get.put(LibraryCartController());

  void _goToCheckout() {
    if (!controller.hasCheckedItems) {
      controller.showNoCheckedWarning();
      return;
    }

    Get.to(() => const LibraryCheckoutPage());
  }

  Map<String, CartLibraryGroupModel> _buildLibraryGroups() {
    final groups = <String, CartLibraryGroupModel>{};

    for (final item in controller.cartItems) {
      final group = groups.putIfAbsent(
        item.libraryId,
        () => CartLibraryGroupModel(
          libraryId: item.libraryId,
          libraryName: item.libraryName,
          items: [],
        ),
      );

      group.items.add(item);
    }

    return groups;
  }

  Future<bool> _showDeleteConfirmSheet(
    BuildContext context,
    LibraryCartBook book,
  ) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return _DeleteCartBookSheet(
          book: book,
        );
      },
    );

    return result == true;
  }

  Future<void> _handleDeleteTap(
    BuildContext context,
    LibraryCartBook book,
  ) async {
    final shouldDelete = await _showDeleteConfirmSheet(context, book);

    if (!shouldDelete) return;

    controller.removeBook(book.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuminaColors.surface,
      bottomNavigationBar: _CartBottomAction(
        controller: controller,
        onCheckoutTap: _goToCheckout,
      ),
      body: Column(
        children: [
          const LibraryTransactionTopBar(
            title: 'Keranjang Pinjaman',
          ),
          Expanded(
            child: Obx(() {
              if (!controller.hasItems) {
                return const _CartEmptyState();
              }

              final groups = _buildLibraryGroups().values.toList(
                    growable: false,
                  );

              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  LuminaSpacing.marginMobile,
                  LuminaSpacing.md,
                  LuminaSpacing.marginMobile,
                  LuminaSpacing.lg,
                ),
                children: [
                  ...List.generate(groups.length, (groupIndex) {
                    final group = groups[groupIndex];

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: groupIndex == groups.length - 1
                            ? 0
                            : LuminaSpacing.lg,
                      ),
                      child: _CartLibrarySection(
                        controller: controller,
                        group: group,
                        onDeleteRequested: (book) {
                          return _showDeleteConfirmSheet(context, book);
                        },
                        onDeleteTap: (book) {
                          _handleDeleteTap(context, book);
                        },
                      ),
                    );
                  }),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}


class _SummaryMiniStat extends StatelessWidget {
  const _SummaryMiniStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.sm,
        vertical: LuminaSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: LuminaTextStyles.headlineSm.copyWith(
              color: LuminaColors.onPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: LuminaTextStyles.labelMd.copyWith(
              color: LuminaColors.onPrimary.withOpacity(0.70),
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartLibrarySection extends StatelessWidget {
  const _CartLibrarySection({
    required this.controller,
    required this.group,
    required this.onDeleteRequested,
    required this.onDeleteTap,
  });

  final LibraryCartController controller;
  final CartLibraryGroupModel group;
  final Future<bool> Function(LibraryCartBook book) onDeleteRequested;
  final ValueChanged<LibraryCartBook> onDeleteTap;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activeLibraryId = controller.selectedLibraryId;
      final isLockedByOtherLibrary =
          activeLibraryId != null && activeLibraryId != group.libraryId;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: LuminaColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(LuminaRadius.xl),
          border: Border.all(
            color: isLockedByOtherLibrary
                ? LuminaColors.outlineVariant.withOpacity(0.55)
                : LuminaColors.surfaceVariant,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                isLockedByOtherLibrary ? 0.02 : 0.045,
              ),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _CartLibraryHeader(
              controller: controller,
              group: group,
              isLockedByOtherLibrary: isLockedByOtherLibrary,
            ),
            if (isLockedByOtherLibrary)
              _CartLibraryLockedBanner(
                activeLibraryName:
                    controller.selectedLibraryName ?? 'perpustakaan lain',
              ),
            ...List.generate(group.items.length, (index) {
              final item = group.items[index];
              final isChecked = controller.checkedBookIds.contains(item.id);
              final isDisabledByLibrary =
                  controller.isBookDisabledByLibraryRule(item.id);

              return _SwipeDeleteCartItem(
                key: ValueKey(item.id),
                book: item,
                isFirst: index == 0,
                isDisabledByLibrary: isDisabledByLibrary,
                confirmDelete: () => onDeleteRequested(item),
                onDeleted: () => controller.removeBook(item.id),
                child: Opacity(
                  opacity: isDisabledByLibrary ? 0.48 : 1,
                  child: LibraryCartBookTile(
                    book: item,
                    isChecked: isChecked,
                    showCheckbox: true,
                    showDeleteButton: true,
                    onTap: () {
                      controller.toggleBookCheckedWithLibraryRule(item.id);
                    },
                    onCheckedChanged: (_) {
                      controller.toggleBookCheckedWithLibraryRule(item.id);
                    },
                    onDeleteTap: () => onDeleteTap(item),
                  ),
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}

class _CartLibraryHeader extends StatelessWidget {
  const _CartLibraryHeader({
    required this.controller,
    required this.group,
    required this.isLockedByOtherLibrary,
  });

  final LibraryCartController controller;
  final CartLibraryGroupModel group;
  final bool isLockedByOtherLibrary;

  @override
  Widget build(BuildContext context) {
    final checkedCount = controller.checkedCountForLibrary(group.libraryId);
    final availableCount = controller.availableCountForLibrary(group.libraryId);
    final isAllChecked =
        controller.isAllAvailableCheckedForLibrary(group.libraryId);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        LuminaSpacing.sm,
        LuminaSpacing.sm,
        LuminaSpacing.md,
        LuminaSpacing.sm,
      ),
      color: isLockedByOtherLibrary
          ? LuminaColors.surfaceContainerLow
          : LuminaColors.surfaceContainerLow.withOpacity(0.72),
      child: Row(
        children: [
          Checkbox(
            value: isAllChecked,
            activeColor: LuminaColors.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(LuminaRadius.sm),
            ),
            onChanged: (_) {
              controller.toggleSelectAllAvailableForLibrary(group.libraryId);
            },
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isLockedByOtherLibrary
                  ? LuminaColors.surfaceContainer
                  : LuminaColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(LuminaRadius.md),
            ),
            child: Icon(
              isLockedByOtherLibrary
                  ? Icons.lock_rounded
                  : Icons.local_library_rounded,
              color: isLockedByOtherLibrary
                  ? LuminaColors.outline
                  : LuminaColors.primary,
              size: 21,
            ),
          ),
          const SizedBox(width: LuminaSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.libraryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LuminaTextStyles.bodyMd.copyWith(
                    color: LuminaColors.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$checkedCount/$availableCount buku tersedia dipilih',
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: LuminaColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeDeleteCartItem extends StatelessWidget {
  const _SwipeDeleteCartItem({
    super.key,
    required this.book,
    required this.child,
    required this.isFirst,
    required this.isDisabledByLibrary,
    required this.confirmDelete,
    required this.onDeleted,
  });

  final LibraryCartBook book;
  final Widget child;
  final bool isFirst;
  final bool isDisabledByLibrary;
  final Future<bool> Function() confirmDelete;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('dismiss-${book.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return confirmDelete();
      },
      onDismissed: (_) => onDeleted(),
      background: const SizedBox.shrink(),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: LuminaSpacing.lg),
        color: LuminaColors.error,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.delete_rounded,
              color: LuminaColors.onError,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              'Hapus',
              style: LuminaTextStyles.labelMd.copyWith(
                color: LuminaColors.onError,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: LuminaColors.surfaceContainerLowest,
          border: isFirst
              ? null
              : const Border(
                  top: BorderSide(
                    color: LuminaColors.surfaceVariant,
                    width: 1,
                  ),
                ),
        ),
        padding: const EdgeInsets.all(LuminaSpacing.md),
        child: child,
      ),
    );
  }
}

class _CartLibraryLockedBanner extends StatelessWidget {
  const _CartLibraryLockedBanner({
    required this.activeLibraryName,
  });

  final String activeLibraryName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.md,
        vertical: LuminaSpacing.sm,
      ),
      color: LuminaColors.surfaceContainer,
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: LuminaColors.onSurfaceVariant,
            size: 18,
          ),
          const SizedBox(width: LuminaSpacing.xs),
          Expanded(
            child: Text(
              'Nonaktif karena Anda sedang memilih dari $activeLibraryName.',
              style: LuminaTextStyles.labelMd.copyWith(
                color: LuminaColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartBottomAction extends StatelessWidget {
  const _CartBottomAction({
    required this.controller,
    required this.onCheckoutTap,
  });

  final LibraryCartController controller;
  final VoidCallback onCheckoutTap;

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
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            LuminaSpacing.marginMobile,
            LuminaSpacing.md,
            LuminaSpacing.marginMobile,
            LuminaSpacing.md,
          ),
          child: Obx(() {
            final count = controller.checkedCount;
            final selectedLibraryName = controller.selectedLibraryName;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedLibraryName == null
                            ? 'Total Dipilih'
                            : 'Checkout dari $selectedLibraryName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LuminaTextStyles.bodyLg.copyWith(
                          color: LuminaColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: LuminaSpacing.sm),
                    Text(
                      '$count Buku',
                      style: LuminaTextStyles.headlineSm.copyWith(
                        color: LuminaColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: LuminaSpacing.md),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: count == 0 ? null : onCheckoutTap,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: LuminaColors.primary,
                      disabledBackgroundColor:
                          LuminaColors.surfaceContainerHigh,
                      foregroundColor: LuminaColors.onPrimary,
                      disabledForegroundColor:
                          LuminaColors.onSurfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(LuminaRadius.lg),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Lanjutkan ke Checkout',
                          style: LuminaTextStyles.titleLg.copyWith(
                            color: count == 0
                                ? LuminaColors.onSurfaceVariant
                                : LuminaColors.onPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: LuminaSpacing.xs),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 21,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _DeleteCartBookSheet extends StatelessWidget {
  const _DeleteCartBookSheet({
    required this.book,
  });

  final LibraryCartBook book;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        LuminaSpacing.marginMobile,
        LuminaSpacing.lg,
        LuminaSpacing.marginMobile,
        LuminaSpacing.marginMobile,
      ),
      decoration: const BoxDecoration(
        color: LuminaColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(LuminaRadius.xl),
          topRight: Radius.circular(LuminaRadius.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: LuminaColors.outlineVariant,
                borderRadius: BorderRadius.circular(LuminaRadius.full),
              ),
            ),
            const SizedBox(height: LuminaSpacing.lg),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: LuminaColors.error.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: LuminaColors.error,
                size: 34,
              ),
            ),
            const SizedBox(height: LuminaSpacing.md),
            Text(
              'Hapus Buku dari Keranjang?',
              textAlign: TextAlign.center,
              style: LuminaTextStyles.headlineSm.copyWith(
                color: LuminaColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: LuminaSpacing.xs),
            Text(
              'Buku ini akan dihapus dari daftar peminjaman Anda.',
              textAlign: TextAlign.center,
              style: LuminaTextStyles.bodyMd.copyWith(
                color: LuminaColors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: LuminaSpacing.lg),
            Container(
              padding: const EdgeInsets.all(LuminaSpacing.sm),
              decoration: BoxDecoration(
                color: LuminaColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(LuminaRadius.lg),
                border: Border.all(
                  color: LuminaColors.outlineVariant,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 64,
                    decoration: BoxDecoration(
                      color: LuminaColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(LuminaRadius.md),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      book.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return const Icon(
                          Icons.menu_book_rounded,
                          color: LuminaColors.primary,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: LuminaSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: LuminaTextStyles.bodyLg.copyWith(
                            color: LuminaColors.onSurface,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          book.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: LuminaTextStyles.bodyMd.copyWith(
                            color: LuminaColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.libraryName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: LuminaTextStyles.labelMd.copyWith(
                            color: LuminaColors.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: LuminaSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: LuminaColors.primary,
                        side: const BorderSide(
                          color: LuminaColors.outlineVariant,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(LuminaRadius.lg),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: LuminaTextStyles.titleLg.copyWith(
                          color: LuminaColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: LuminaSpacing.sm),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: LuminaColors.error,
                        foregroundColor: LuminaColors.onError,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(LuminaRadius.lg),
                        ),
                      ),
                      child: Text(
                        'Hapus',
                        style: LuminaTextStyles.titleLg.copyWith(
                          color: LuminaColors.onError,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CartEmptyState extends StatelessWidget {
  const _CartEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LuminaSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: LuminaColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: LuminaColors.outline,
                size: 36,
              ),
            ),
            const SizedBox(height: LuminaSpacing.md),
            Text(
              'Keranjang Kosong',
              style: LuminaTextStyles.titleLg.copyWith(
                color: LuminaColors.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: LuminaSpacing.xs),
            Text(
              'Anda belum menambahkan buku untuk dipinjam.',
              textAlign: TextAlign.center,
              style: LuminaTextStyles.bodyMd.copyWith(
                color: LuminaColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

