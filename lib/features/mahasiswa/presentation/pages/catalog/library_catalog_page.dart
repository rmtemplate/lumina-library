import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/catalog/library_catalog_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/pages/cart/library_cart_page.dart';
import 'package:lumina_library/features/mahasiswa/presentation/pages/catalog/library_book_detail_page.dart';
import 'package:lumina_library/features/mahasiswa/presentation/pages/search/library_search_page.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/catalog/library_book_detail_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/catalog/library_trending_book_card.dart';
import 'package:lumina_library/shared/models/book/book_model.dart';
import 'package:lumina_library/shared/widgets/skeleton/lumina_skeleton.dart';

class LibraryCatalogPage extends StatefulWidget {
  const LibraryCatalogPage({
    super.key,
    this.title = 'Catalog',
    this.initialCategoryKey,
    this.hideCart = false,
    this.showBackButton = false,
  });

  final String title;
  final String? initialCategoryKey;
  final bool hideCart;
  final bool showBackButton;

  @override
  State<LibraryCatalogPage> createState() => _LibraryCatalogPageState();
}

class _LibraryCatalogPageState extends State<LibraryCatalogPage> {
  late final ScrollController _scrollController;

  LibraryCatalogController get controller =>
      Get.isRegistered<LibraryCatalogController>()
          ? Get.find<LibraryCatalogController>()
          : Get.put(LibraryCatalogController(), permanent: true);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyInitialCategoryFilter();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LibraryCatalogPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCategoryKey != widget.initialCategoryKey) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyInitialCategoryFilter();
      });
    }
  }

  void _applyInitialCategoryFilter() {
    final categoryKey = widget.initialCategoryKey;
    if (categoryKey == null || categoryKey.trim().isEmpty) return;
    controller.applyInitialCategory(categoryKey.trim());
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;
    if (max > 0 && current >= max * 0.75) {
      controller.loadMoreBooks();
    }
  }

  void _handleBookTap(BookModel book) {
    Get.find<LibraryBookDetailController>().setBook(book);
    Get.to(
      () => const LibraryBookDetailPage(),
      transition: Transition.cupertino,
    );
  }

  void _goToSearchPage() {
    Get.to(
      () => const LibrarySearchPage(),
      transition: Transition.cupertino,
    );
  }

  void _goToCartPage() {
    Get.to(
      () => LibraryCartPage(),
      transition: Transition.cupertino,
    );
  }

  void _openFilterSheet(LibraryCatalogController catalogController) {
    Get.bottomSheet<void>(
      _CatalogFilterBottomSheet(controller: catalogController),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogController = controller;

    return ColoredBox(
      color: LuminaColors.background,
      child: Column(
        children: [
          Obx(
            () => _CatalogTopBar(
              title: widget.title,
              hideCart: widget.hideCart,
              activeFilterCount: catalogController.activeFilterCount,
              onSearchTap: _goToSearchPage,
              onFilterTap: () => _openFilterSheet(catalogController),
              onCartTap: _goToCartPage,
              showBackButton: widget.showBackButton,
              onBackTap: Get.back,
            ),
          ),
          Expanded(
            child: Obx(
              () {
                final cat = catalogController;

                // Initial load skeleton
                if (cat.isLoading.value && cat.books.isEmpty) {
                  return SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      LuminaSpacing.marginMobile,
                      LuminaSpacing.md,
                      LuminaSpacing.marginMobile,
                      LuminaSpacing.xl,
                    ),
                    child: const LuminaCatalogBookGridSkeleton(count: 6),
                  );
                }

                // Full error state (no books at all)
                if (cat.errorMessage.value.isNotEmpty && cat.books.isEmpty) {
                  return _CatalogErrorState(
                    message: cat.errorMessage.value,
                    onRetry: cat.loadBooks,
                  );
                }

                final books = cat.filteredBooks;

                return RefreshIndicator(
                  onRefresh: cat.loadBooks,
                  color: LuminaColors.primary,
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      const SliverToBoxAdapter(
                        child: SizedBox(height: LuminaSpacing.md),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: LuminaSpacing.marginMobile,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: _CatalogBookGrid(
                            books: books,
                            favoriteBookIds: cat.favoriteBookIds.toSet(),
                            onBookTap: _handleBookTap,
                            onFavoriteTap: cat.toggleFavorite,
                          ),
                        ),
                      ),
                      // Bottom loading indicator
                      if (cat.isLoadingMore.value)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: LuminaSpacing.lg,
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: LuminaColors.primary,
                              ),
                            ),
                          ),
                        ),
                      // Load-more error with retry
                      if (cat.loadMoreError.value.isNotEmpty)
                        SliverToBoxAdapter(
                          child: _LoadMoreRetryButton(
                            message: cat.loadMoreError.value,
                            onRetry: cat.loadMoreBooks,
                          ),
                        ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: LuminaSpacing.xl),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _CatalogTopBar extends StatelessWidget {
  const _CatalogTopBar({
    required this.title,
    required this.hideCart,
    required this.showBackButton,
    required this.activeFilterCount,
    required this.onBackTap,
    required this.onSearchTap,
    required this.onFilterTap,
    required this.onCartTap,
  });

  final String title;
  final bool hideCart;
  final bool showBackButton;
  final int activeFilterCount;
  final VoidCallback onBackTap;
  final VoidCallback onSearchTap;
  final VoidCallback onFilterTap;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LuminaColors.surface,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: LuminaColors.outlineVariant.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: LuminaSpacing.marginMobile,
            vertical: LuminaSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showBackButton) ...[
                _TopBarIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: onBackTap,
                ),
                const SizedBox(width: LuminaSpacing.xs),
              ],
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LuminaTextStyles.headlineSm.copyWith(
                    color: LuminaColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(width: LuminaSpacing.sm),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TopBarIconButton(
                    icon: Icons.search_rounded,
                    onTap: onSearchTap,
                  ),
                  const SizedBox(width: 4),
                  _TopBarIconButton(
                    icon: Icons.tune_rounded,
                    badgeCount: activeFilterCount,
                    onTap: onFilterTap,
                    isActive: activeFilterCount > 0,
                  ),
                  if (!hideCart) ...[
                    const SizedBox(width: 4),
                    _TopBarIconButton(
                      icon: Icons.shopping_cart_outlined,
                      onTap: onCartTap,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBarIconButton extends StatelessWidget {
  const _TopBarIconButton({
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
    this.isActive = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive
          ? LuminaColors.primary.withOpacity(0.08)
          : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? LuminaColors.primary : LuminaColors.onSurface,
                size: 24,
              ),
              if (badgeCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: LuminaColors.secondary,
                      shape: badgeCount > 9
                          ? BoxShape.rectangle
                          : BoxShape.circle,
                      borderRadius:
                          badgeCount > 9 ? BorderRadius.circular(10) : null,
                      border: Border.all(
                        color: LuminaColors.surface,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        badgeCount > 9 ? '9+' : '$badgeCount',
                        style: LuminaTextStyles.labelMd.copyWith(
                          color: LuminaColors.onSecondary,
                          fontSize: 8,
                          height: 1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Filter bottom sheet ────────────────────────────────────────────────────────

class _CatalogFilterBottomSheet extends StatelessWidget {
  const _CatalogFilterBottomSheet({required this.controller});

  final LibraryCatalogController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: LuminaColors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(LuminaRadius.xl),
              ),
            ),
            child: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      LuminaSpacing.marginMobile,
                      LuminaSpacing.sm,
                      LuminaSpacing.marginMobile,
                      LuminaSpacing.md,
                    ),
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            width: 48,
                            height: 5,
                            margin: const EdgeInsets.only(
                              bottom: LuminaSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  LuminaColors.outlineVariant.withOpacity(0.5),
                              borderRadius:
                                  BorderRadius.circular(LuminaRadius.full),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Filter Katalog',
                              style: LuminaTextStyles.titleLg.copyWith(
                                color: LuminaColors.onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                controller.resetFilters();
                                // Apply reset immediately (server reload)
                                controller.applyFilters();
                                Get.back<void>();
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: LuminaColors.secondary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              child: Text(
                                'Reset',
                                style: LuminaTextStyles.titleSm.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: LuminaSpacing.marginMobile,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FilterSection<String>(
                            title: 'Urutkan Berdasarkan',
                            options: controller.sortOptions,
                            selectedValue: controller.selectedSortKey.value,
                            onChanged: controller.setSortFilter,
                          ),
                          const SizedBox(height: LuminaSpacing.xl),
                          _FilterSection<String>(
                            title: 'Kategori Buku',
                            options: controller.categoryOptions,
                            selectedValue: controller.selectedCategoryKey.value,
                            onChanged: controller.setCategoryFilter,
                          ),
                          const SizedBox(height: LuminaSpacing.xl),
                          _FilterSection<String>(
                            title: 'Status Ketersediaan',
                            options: controller.availabilityOptions,
                            selectedValue:
                                controller.selectedAvailabilityKey.value,
                            onChanged: controller.setAvailabilityFilter,
                          ),
                          const SizedBox(height: LuminaSpacing.xl),
                          _FilterSection<int?>(
                            title: 'Tahun Terbit',
                            options: controller.publishedYearOptions,
                            selectedValue: controller.selectedPublishedYear.value,
                            onChanged: controller.setPublishedYearFilter,
                          ),
                          const SizedBox(height: LuminaSpacing.xl),
                          _FilterSection<String>(
                            title: 'Jarak Perpustakaan',
                            options: controller.distanceOptions,
                            selectedValue: controller.selectedDistanceKey.value,
                            onChanged: controller.setDistanceFilter,
                          ),
                          const SizedBox(height: LuminaSpacing.xl),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(
                      LuminaSpacing.marginMobile,
                      LuminaSpacing.md,
                      LuminaSpacing.marginMobile,
                      LuminaSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: LuminaColors.surface,
                      border: Border(
                        top: BorderSide(
                          color: LuminaColors.outlineVariant.withOpacity(0.2),
                        ),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back<void>();
                          controller.applyFilters();
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: LuminaColors.primary,
                          foregroundColor: LuminaColors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(LuminaRadius.lg),
                          ),
                        ),
                        child: Text(
                          'Terapkan Filter',
                          style: LuminaTextStyles.titleMd.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterSection<T> extends StatelessWidget {
  const _FilterSection({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  final String title;
  final List<CatalogFilterOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: LuminaSpacing.sm, left: 4),
          child: Text(
            title,
            style: LuminaTextStyles.titleSm.copyWith(
              color: LuminaColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: LuminaColors.surface,
            borderRadius: BorderRadius.circular(LuminaRadius.lg),
            border: Border.all(
              color: LuminaColors.outlineVariant.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: List.generate(options.length, (index) {
              final option = options[index];
              final isLast = index == options.length - 1;
              return Column(
                children: [
                  _FilterOptionTile<T>(
                    label: option.label,
                    value: option.value,
                    selectedValue: selectedValue,
                    onChanged: onChanged,
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: LuminaColors.outlineVariant.withOpacity(0.2),
                      indent: LuminaSpacing.md,
                      endIndent: LuminaSpacing.md,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _FilterOptionTile<T> extends StatelessWidget {
  const _FilterOptionTile({
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.onChanged,
  });

  final String label;
  final T value;
  final T selectedValue;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedValue;

    return Material(
      color: isSelected
          ? LuminaColors.primary.withOpacity(0.04)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(LuminaRadius.lg),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LuminaSpacing.md,
            vertical: LuminaSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: LuminaTextStyles.bodyLg.copyWith(
                    color: isSelected
                        ? LuminaColors.primary
                        : LuminaColors.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: LuminaColors.primary,
                  size: 22,
                )
              else
                const Icon(
                  Icons.circle_outlined,
                  color: LuminaColors.outlineVariant,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Book grid ─────────────────────────────────────────────────────────────────

class _CatalogBookGrid extends StatelessWidget {
  const _CatalogBookGrid({
    required this.books,
    required this.favoriteBookIds,
    required this.onBookTap,
    required this.onFavoriteTap,
  });

  final List<BookModel> books;
  final Set<String> favoriteBookIds;
  final ValueChanged<BookModel> onBookTap;
  final ValueChanged<String> onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return const _CatalogEmptyState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        const spacing = LuminaSpacing.md;
        final cardWidth =
            (constraints.maxWidth - ((crossAxisCount - 1) * spacing)) /
                crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing + 8,
          children: List.generate(books.length, (index) {
            final book = books[index];
            return LibraryTrendingBookCard(
              width: cardWidth,
              title: book.title,
              author: book.author,
              rating: book.ratingLabel,
              imageUrl: book.coverUrl ?? '',
              isAvailable: book.isAvailable,
              libraryLocation: book.locationLabel,
              isFavorite: favoriteBookIds.contains(book.id),
              showRatingBadge: false,
              showInlineRating: true,
              showBorrowButton: false,
              showAvailabilityStatus: true,
              showFavoriteButton: true,
              dimUnavailableCover: false,
              onTap: () => onBookTap(book),
              onFavoriteTap: () => onFavoriteTap(book.id),
            );
          }),
        );
      },
    );
  }

  int _getCrossAxisCount(double width) {
    if (width >= 960) return 4;
    if (width >= 680) return 3;
    return 2;
  }
}

// ── Feedback widgets ──────────────────────────────────────────────────────────

class _CatalogErrorState extends StatelessWidget {
  const _CatalogErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LuminaSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: LuminaColors.onSurfaceVariant,
              size: 48,
            ),
            const SizedBox(height: LuminaSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: LuminaTextStyles.bodyMd.copyWith(
                color: LuminaColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: LuminaSpacing.lg),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: LuminaColors.primary,
                foregroundColor: LuminaColors.onPrimary,
                elevation: 0,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadMoreRetryButton extends StatelessWidget {
  const _LoadMoreRetryButton({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.marginMobile,
        vertical: LuminaSpacing.md,
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: LuminaTextStyles.bodySm.copyWith(
              color: LuminaColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: LuminaSpacing.sm),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Coba Lagi'),
            style: OutlinedButton.styleFrom(
              foregroundColor: LuminaColors.primary,
              side: const BorderSide(color: LuminaColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(LuminaRadius.lg),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogEmptyState extends StatelessWidget {
  const _CatalogEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: LuminaSpacing.xl),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: LuminaColors.surfaceContainerLowest,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.search_off_rounded,
                color: LuminaColors.primary.withOpacity(0.8),
                size: 48,
              ),
            ),
            const SizedBox(height: LuminaSpacing.xl),
            Text(
              'Buku Tidak Ditemukan',
              style: LuminaTextStyles.titleLg.copyWith(
                color: LuminaColors.onSurface,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: LuminaSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Coba ubah filter atau gunakan kata kunci pencarian yang lain.',
                textAlign: TextAlign.center,
                style: LuminaTextStyles.bodyMd.copyWith(
                  color: LuminaColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
