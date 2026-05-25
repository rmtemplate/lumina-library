import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/search/library_search_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/catalog/library_trending_book_card.dart';
import 'package:lumina_library/features/mahasiswa/presentation/pages/catalog/library_book_detail_page.dart';
import 'package:lumina_library/shared/models/search/library_search_book_model.dart';

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
        widget.libraryId!.trim().isNotEmpty &&
        widget.libraryName != null &&
        widget.libraryName!.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController(
      text: widget.initialKeyword,
    );

    _focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setKeyword(widget.initialKeyword);
      controller.addRecentSearch(widget.initialKeyword);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _runSearch(String value) {
    final keyword = value.trim();

    if (keyword.isEmpty) return;

    controller.setKeyword(keyword);
    controller.addRecentSearch(keyword);

    _textController.text = keyword;
    _textController.selection = TextSelection.collapsed(
      offset: _textController.text.length,
    );
  }

  void _goToBookDetail(LibrarySearchBook book) {
    controller.addRecentSearch(book.title);

    Get.to(
      () => const LibraryBookDetailPage(),
      transition: Transition.cupertino,
    );
  }

  List<LibrarySearchBook> _getGlobalRelevantBooks(String keyword) {
    final cleanKeyword = keyword.trim().toLowerCase();

    if (cleanKeyword.isEmpty) {
      return controller.trendingBooks.take(4).toList(growable: false);
    }

    final keywordParts = cleanKeyword
        .split(RegExp(r'\s+'))
        .where((item) => item.trim().isNotEmpty)
        .toList(growable: false);

    final relevantBooks = controller.trendingBooks.where((book) {
      final title = book.title.toLowerCase();
      final author = book.author.toLowerCase();

      return keywordParts.any((part) {
        return title.contains(part) || author.contains(part);
      });
    }).toList(growable: false);

    if (relevantBooks.isNotEmpty) {
      return relevantBooks;
    }

    return controller.trendingBooks.take(4).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final hintText = _isScopedSearch
        ? 'Cari lagi di ${widget.libraryName}...'
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
          Expanded(
            child: Obx(() {
              final keyword = controller.keyword.value.trim();

              final results = controller.getSearchResults(
                keyword,
                libraryId: _isScopedSearch ? widget.libraryId : null,
              );

              final relevantBooks = _isScopedSearch
                  ? <LibrarySearchBook>[]
                  : _getGlobalRelevantBooks(keyword);

              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  LuminaSpacing.marginMobile,
                  LuminaSpacing.lg,
                  LuminaSpacing.marginMobile,
                  LuminaSpacing.xl,
                ),
                children: [
                  _ResultHeader(
                    keyword: keyword,
                    total: results.length,
                    isScopedSearch: _isScopedSearch,
                    libraryName: widget.libraryName,
                  ),

                  const SizedBox(height: LuminaSpacing.md),

                  if (results.isEmpty)
                    _ResultFallbackSection(
                      keyword: keyword,
                      isScopedSearch: _isScopedSearch,
                      libraryName: widget.libraryName,
                      relevantBooks: relevantBooks,
                      onBookTap: _goToBookDetail,
                    )
                  else
                    _SearchResultGrid(
                      books: results,
                      isScopedSearch: _isScopedSearch,
                      onBookTap: _goToBookDetail,
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
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
    required this.total,
    required this.isScopedSearch,
    this.libraryName,
  });

  final String keyword;
  final int total;
  final bool isScopedSearch;
  final String? libraryName;

  @override
  Widget build(BuildContext context) {
    final title = keyword.isEmpty
        ? 'Search Result'
        : isScopedSearch
            ? 'Search "$keyword" di ${libraryName ?? 'cabang ini'}'
            : 'Search "$keyword"';

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
            '$total Result',
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

class _SearchResultGrid extends StatelessWidget {
  const _SearchResultGrid({
    required this.books,
    required this.isScopedSearch,
    required this.onBookTap,
  });

  final List<LibrarySearchBook> books;
  final bool isScopedSearch;
  final ValueChanged<LibrarySearchBook> onBookTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = LuminaSpacing.md;
        final crossAxisCount = constraints.maxWidth >= 680 ? 3 : 2;
        final cardWidth =
            (constraints.maxWidth - ((crossAxisCount - 1) * spacing)) /
                crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: books.map((book) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                LibraryTrendingBookCard(
                  width: cardWidth,
                  title: book.title,
                  author: book.author,
                  rating: book.rating,
                  imageUrl: book.imageUrl,
                  isAvailable: book.isAvailable,
                  showRatingBadge: false,
                  showInlineRating: true,
                  showBorrowButton: false,
                  showAvailabilityStatus: true,
                  availableStatusLabel:
                      isScopedSearch ? 'Ada di cabang ini' : 'Available',
                  unavailableStatusLabel: isScopedSearch
                      ? 'Tidak tersedia di cabang ini'
                      : 'Borrowed',
                  onTap: () => onBookTap(book),
                ),

                Positioned(
                  top: 8,
                  left: 8,
                  child: _ScopeMiniBadge(
                    isScopedSearch: isScopedSearch,
                  ),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}

class _ScopeMiniBadge extends StatelessWidget {
  const _ScopeMiniBadge({
    required this.isScopedSearch,
  });

  final bool isScopedSearch;

  @override
  Widget build(BuildContext context) {
    final color = isScopedSearch ? LuminaColors.secondary : LuminaColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.94),
        borderRadius: BorderRadius.circular(LuminaRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isScopedSearch ? Icons.local_library_rounded : Icons.public_rounded,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 3),
          Text(
            isScopedSearch ? 'Cabang' : 'Global',
            style: LuminaTextStyles.labelMd.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 0,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultFallbackSection extends StatelessWidget {
  const _ResultFallbackSection({
    required this.keyword,
    required this.isScopedSearch,
    required this.relevantBooks,
    required this.onBookTap,
    this.libraryName,
  });

  final String keyword;
  final bool isScopedSearch;
  final String? libraryName;
  final List<LibrarySearchBook> relevantBooks;
  final ValueChanged<LibrarySearchBook> onBookTap;

  @override
  Widget build(BuildContext context) {
    if (isScopedSearch) {
      return _ResultEmptyState(
        icon: Icons.local_library_outlined,
        title: 'Belum ada hasil di ${libraryName ?? 'cabang ini'}',
        description:
            'Buku "$keyword" belum tersedia di perpustakaan ini. Coba kata kunci lain atau cari di semua perpustakaan.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ResultEmptyState(
          icon: Icons.search_off_rounded,
          title: 'Belum ada hasil untuk "$keyword"',
          description:
              'Kami belum menemukan hasil yang cocok. Berikut beberapa buku yang mungkin masih relevan untuk Anda.',
        ),

        if (relevantBooks.isNotEmpty) ...[
          const SizedBox(height: LuminaSpacing.xl),
          Text(
            'Mungkin Relevan',
            style: LuminaTextStyles.headlineSm.copyWith(
              color: LuminaColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: LuminaSpacing.md),
          _SearchResultGrid(
            books: relevantBooks,
            isScopedSearch: false,
            onBookTap: onBookTap,
          ),
        ],
      ],
    );
  }
}

class _ResultEmptyState extends StatelessWidget {
  const _ResultEmptyState({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: LuminaSpacing.xl,
        horizontal: LuminaSpacing.md,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
}
