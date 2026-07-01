import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/catalog/library_book_detail_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/search/library_search_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/pages/catalog/library_book_detail_page.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/catalog/library_trending_book_card.dart';
import 'package:lumina_library/shared/models/book/book_model.dart';

/// Backend-driven search results: keyword + optional branch scope, availability
/// filter, sorting, and infinite scroll — all served by the same catalog/branch
/// endpoints. No client-side filtering.
///
/// Refactor note:
/// - Obx dihapus dari page ini.
/// - Semua rebuild memakai GetBuilder karena controller sudah memanggil update().
/// - Ini menghindari error:
///   "[Get] the improper use of a GetX has been detected".
class LibrarySearchResultPage extends StatefulWidget {
  const LibrarySearchResultPage({
    super.key,
    required this.initialKeyword,
    this.searchInCurrentLibrary = false,
    this.libraryId,
    this.libraryName,
  });

  final String initialKeyword;
  final bool searchInCurrentLibrary;
  final String? libraryId;
  final String? libraryName;

  @override
  State<LibrarySearchResultPage> createState() =>
      _LibrarySearchResultPageState();
}

class _LibrarySearchResultPageState extends State<LibrarySearchResultPage> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  late final ScrollController _scrollController;

  final LibrarySearchController controller =
      Get.isRegistered<LibrarySearchController>()
          ? Get.find<LibrarySearchController>()
          : Get.put(
              LibrarySearchController(),
              permanent: true,
            );

  bool get _isScopedSearch {
    return widget.searchInCurrentLibrary &&
        widget.libraryId != null &&
        widget.libraryId!.trim().isNotEmpty;
  }

  String? get _scopeBranchId {
    return _isScopedSearch ? widget.libraryId : null;
  }

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController(text: widget.initialKeyword);
    _focusNode = FocusNode();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final keyword = widget.initialKeyword.trim();
      if (keyword.isEmpty) return;

      controller.setKeyword(keyword);
      controller.addRecentSearch(keyword);
      controller.runSearch(
        keyword,
        branchId: _scopeBranchId,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final max = position.maxScrollExtent;

    if (max <= 0) return;

    if (position.pixels >= max * 0.8) {
      controller.loadMore();
    }
  }

  void _runSearch(String value) {
    final keyword = value.trim();
    if (keyword.isEmpty) return;

    controller.setKeyword(keyword);
    controller.addRecentSearch(keyword);
    controller.runSearch(
      keyword,
      branchId: _scopeBranchId,
    );

    _textController.selection = TextSelection.collapsed(
      offset: _textController.text.length,
    );
  }

  void _openBook(BookModel book) {
    controller.addRecentSearch(book.title);

    final ctrl = Get.isRegistered<LibraryBookDetailController>()
        ? Get.find<LibraryBookDetailController>()
        : Get.put(
            LibraryBookDetailController(),
            permanent: true,
          );

    ctrl.openBook(book);

    Get.to(
      () => const LibraryBookDetailPage(),
      transition: Transition.cupertino,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hintText = _isScopedSearch
        ? 'Cari lagi di ${widget.libraryName ?? 'cabang ini'}...'
        : 'Cari lagi di semua perpustakaan...';

    return Scaffold(
      backgroundColor: LuminaColors.background,
      body: Column(
        children: [
          _SearchResultTopBar(
            controller: _textController,
            focusNode: _focusNode,
            hintText: hintText,
            onChanged: controller.setKeyword,
            onSubmitted: _runSearch,
          ),
          _FilterBar(controller: controller),
          Expanded(
            child: GetBuilder<LibrarySearchController>(
              init: controller,
              autoRemove: false,
              builder: (controller) {
                if (controller.isSearching.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: LuminaColors.secondary,
                    ),
                  );
                }

                final errorMessage = controller.searchError.value.trim();
                if (errorMessage.isNotEmpty) {
                  return _ResultMessageState(
                    icon: Icons.cloud_off_rounded,
                    title: 'Gagal memuat hasil',
                    description: errorMessage,
                  );
                }

                final results = controller.results.toList(growable: false);
                final keyword = controller.keyword.value.trim();

                if (results.isEmpty) {
                  return _ResultMessageState(
                    icon: Icons.search_off_rounded,
                    title: keyword.isEmpty
                        ? 'Belum ada hasil pencarian'
                        : 'Belum ada hasil untuk "$keyword"',
                    description: _isScopedSearch
                        ? 'Buku ini belum tersedia di ${widget.libraryName ?? 'cabang ini'}. Coba kata kunci lain atau cari di semua perpustakaan.'
                        : 'Coba kata kunci lain atau ubah filter.',
                  );
                }

                return CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        LuminaSpacing.marginMobile,
                        LuminaSpacing.md,
                        LuminaSpacing.marginMobile,
                        LuminaSpacing.sm,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _ResultHeader(
                          keyword: keyword,
                          loaded: results.length,
                          hasMore: controller.hasMore.value,
                          isScopedSearch: _isScopedSearch,
                          libraryName: widget.libraryName,
                        ),
                      ),
                    ),

                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: LuminaSpacing.marginMobile,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final availableWidth = constraints.maxWidth;
                            const spacing = LuminaSpacing.md;
                            const minCardWidth = 162.0;
                            const maxColumnCount = 3;

                            final calculatedColumnCount =
                                ((availableWidth + spacing) / (minCardWidth + spacing))
                                    .floor();

                            final columnCount = calculatedColumnCount.clamp(
                              1,
                              maxColumnCount,
                            );

                            final cardWidth =
                                (availableWidth - ((columnCount - 1) * spacing)) /
                                    columnCount;

                            return Wrap(
                              spacing: spacing,
                              runSpacing: spacing,
                              children: List.generate(results.length, (index) {
                                final book = results[index];

                                return SizedBox(
                                  width: cardWidth,
                                  child: LibraryTrendingBookCard(
                                    width: cardWidth,
                                    title: book.title,
                                    author: book.author,
                                    rating: book.ratingLabel,
                                    imageUrl: book.coverUrl ?? '',
                                    isAvailable: book.isAvailable,
                                    categoryLabel: book.category?.name,
                                    libraryLocation: book.locationLabel,
                                    showRatingBadge: false,
                                    showInlineRating: true,
                                    showBorrowButton: false,
                                    showAvailabilityStatus: true,
                                    onTap: () => _openBook(book),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: _LoadMoreFooter(
                        isLoadingMore: controller.isLoadingMore.value,
                        hasMore: controller.hasMore.value,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Availability + sort controls.
/// Refactor:
/// - Tidak memakai Obx.
/// - Rebuild lewat GetBuilder karena controller.applyStatus/applySort
///   akan memanggil runSearch(), dan runSearch() memanggil update().
class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.controller,
  });

  final LibrarySearchController controller;

  static const _sorts = [
    ('trending', 'Terpopuler'),
    ('rating', 'Rating'),
    ('newest', 'Terbaru'),
    ('title', 'Judul'),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LibrarySearchController>(
      init: controller,
      autoRemove: false,
      builder: (controller) {
        return Container(
          color: LuminaColors.surface,
          padding: const EdgeInsets.fromLTRB(
            LuminaSpacing.marginMobile,
            0,
            LuminaSpacing.marginMobile,
            LuminaSpacing.sm,
          ),
          child: Row(
            children: [
              _FilterChip(
                label: 'Tersedia',
                selected: controller.activeStatus == 'available',
                onTap: () {
                  controller.applyStatus(
                    controller.activeStatus == 'available'
                        ? null
                        : 'available',
                  );
                },
              ),
              const SizedBox(width: LuminaSpacing.sm),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: DropdownButton<String>(
                    value: controller.activeSort,
                    isDense: true,
                    underline: const SizedBox.shrink(),
                    icon: const Icon(
                      Icons.sort_rounded,
                      size: 18,
                    ),
                    borderRadius: BorderRadius.circular(LuminaRadius.md),
                    style: LuminaTextStyles.labelMd.copyWith(
                      color: LuminaColors.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                    items: _sorts.map((sort) {
                      return DropdownMenuItem<String>(
                        value: sort.$1,
                        child: Text(sort.$2),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      controller.applySort(value);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? LuminaColors.secondary
        : LuminaColors.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(LuminaRadius.full),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: LuminaSpacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: selected
              ? LuminaColors.secondary.withOpacity(0.10)
              : LuminaColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(LuminaRadius.full),
          border: Border.all(
            color: selected
                ? LuminaColors.secondary.withOpacity(0.28)
                : LuminaColors.outlineVariant,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.check_circle_outline_rounded,
              size: 15,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: LuminaTextStyles.labelMd.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({
    required this.isLoadingMore,
    required this.hasMore,
  });

  final bool isLoadingMore;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(
          vertical: LuminaSpacing.lg,
        ),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: LuminaColors.secondary,
            ),
          ),
        ),
      );
    }

    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: LuminaSpacing.lg,
        ),
        child: Center(
          child: Text(
            'Semua hasil sudah ditampilkan',
            style: LuminaTextStyles.labelMd.copyWith(
              color: LuminaColors.outline,
              letterSpacing: 0,
            ),
          ),
        ),
      );
    }

    return const SizedBox(height: LuminaSpacing.xl);
  }
}

class _SearchResultTopBar extends StatelessWidget {
  const _SearchResultTopBar({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LuminaColors.surface,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            LuminaSpacing.marginMobile,
            LuminaSpacing.sm,
            LuminaSpacing.marginMobile,
            LuminaSpacing.sm,
          ),
          child: Row(
            children: [
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: Get.back,
                  customBorder: const CircleBorder(),
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: LuminaColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: LuminaSpacing.xs),
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: LuminaColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(LuminaRadius.lg),
                    border: Border.all(
                      color: LuminaColors.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: onChanged,
                    onSubmitted: onSubmitted,
                    textInputAction: TextInputAction.search,
                    style: LuminaTextStyles.bodyMd.copyWith(
                      color: LuminaColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: LuminaColors.onSurfaceVariant,
                        size: 22,
                      ),
                      hintText: hintText,
                      hintStyle: LuminaTextStyles.bodyMd.copyWith(
                        color: LuminaColors.outline,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: LuminaSpacing.md,
                        vertical: 12,
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

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({
    required this.keyword,
    required this.loaded,
    required this.hasMore,
    required this.isScopedSearch,
    this.libraryName,
  });

  final String keyword;
  final int loaded;
  final bool hasMore;
  final bool isScopedSearch;
  final String? libraryName;

  @override
  Widget build(BuildContext context) {
    final title = keyword.isEmpty
        ? 'Hasil Pencarian'
        : isScopedSearch
            ? 'Hasil "$keyword" di ${libraryName ?? 'cabang ini'}'
            : 'Hasil "$keyword"';

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: LuminaTextStyles.headlineSm.copyWith(
              color: LuminaColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: LuminaSpacing.sm,
            vertical: LuminaSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: LuminaColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(LuminaRadius.full),
            border: Border.all(
              color: LuminaColors.outlineVariant,
              width: 1,
            ),
          ),
          child: Text(
            hasMore ? '$loaded+' : '$loaded hasil',
            style: LuminaTextStyles.labelMd.copyWith(
              color: LuminaColors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultMessageState extends StatelessWidget {
  const _ResultMessageState({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LuminaSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: LuminaColors.surfaceContainerHighest.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: LuminaColors.outline,
              ),
            ),
            const SizedBox(height: LuminaSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: LuminaTextStyles.titleLg.copyWith(
                color: LuminaColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: LuminaSpacing.xs),
            Text(
              description,
              textAlign: TextAlign.center,
              style: LuminaTextStyles.bodyMd.copyWith(
                color: LuminaColors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}