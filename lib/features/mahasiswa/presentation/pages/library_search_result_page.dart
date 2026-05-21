import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/lumina_colors.dart';
import '../../../../core/theme/lumina_radius.dart';
import '../../../../core/theme/lumina_spacing.dart';
import '../../../../core/theme/lumina_text_styles.dart';
import '../controllers/library_search_controller.dart';
import '../widgets/library_trending_book_card.dart';
import 'library_book_detail_page.dart';

class LibrarySearchResultPage extends StatefulWidget {
  const LibrarySearchResultPage({
    super.key,
    required this.initialKeyword,
  });

  final String initialKeyword;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuminaColors.background,
      body: Column(
        children: [
          _SearchResultTopBar(
            controller: _textController,
            focusNode: _focusNode,
            onChanged: controller.setKeyword,
            onSubmitted: _runSearch,
          ),

          Expanded(
            child: Obx(() {
              final keyword = controller.keyword.value.trim();
              final results = controller.getSearchResults(keyword);

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
                  ),

                  const SizedBox(height: LuminaSpacing.md),

                  if (results.isEmpty)
                    _ResultFallbackSection(
                      keyword: keyword,
                      trendingBooks: controller.trendingBooks,
                      onBookTap: _goToBookDetail,
                    )
                  else
                    _SearchResultGrid(
                      books: results,
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
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
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
                      hintText: 'Cari buku, author, kategori...',
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
  });

  final String keyword;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            keyword.isEmpty ? 'Search Result' : 'Search "$keyword"',
            maxLines: 1,
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
    required this.onBookTap,
  });

  final List<LibrarySearchBook> books;
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
            return LibraryTrendingBookCard(
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
              onTap: () => onBookTap(book),
            );
          }).toList(),
        );
      },
    );
  }
}


class _ResultFallbackSection extends StatelessWidget {
  const _ResultFallbackSection({
    super.key,
    required this.keyword,
    required this.trendingBooks,
    required this.onBookTap,
  });

  final String keyword;
  final List<LibrarySearchBook> trendingBooks;
  final ValueChanged<LibrarySearchBook> onBookTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- BAGIAN EMPTY STATE (ILUSTRASI & TEKS) ---
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: LuminaSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ilustrasi Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: LuminaColors.surfaceContainerHighest.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 40,
                  color: LuminaColors.outline, // Gunakan warna redup
                ),
              ),
              const SizedBox(height: LuminaSpacing.lg),
              
              // Teks Judul
              Text(
                'Belum ada hasil untuk "$keyword"',
                textAlign: TextAlign.center,
                style: LuminaTextStyles.titleLg.copyWith(
                  color: LuminaColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: LuminaSpacing.xs),
              
              // Teks Deskripsi
              Text(
                'Coba kata kunci lain atau lihat\nbuku yang sedang trending di bawah ini.',
                textAlign: TextAlign.center,
                style: LuminaTextStyles.bodyMd.copyWith(
                  color: LuminaColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: LuminaSpacing.lg),

        // --- BAGIAN TRENDING BOOKS ---
        Text(
          'Trending Books',
          style: LuminaTextStyles.headlineSm.copyWith(
            color: LuminaColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: LuminaSpacing.md),
        _SearchResultGrid(
          books: trendingBooks,
          onBookTap: onBookTap,
        ),
      ],
    );
  }
}
