import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/lumina_colors.dart';
import '../../../../core/theme/lumina_radius.dart';
import '../../../../core/theme/lumina_spacing.dart';
import '../../../../core/theme/lumina_text_styles.dart';
import '../controllers/library_search_controller.dart';
import '../widgets/library_trending_book_card.dart';
import 'library_book_detail_page.dart';
import 'library_search_result_page.dart';

class LibrarySearchPage extends StatefulWidget {
  const LibrarySearchPage({super.key});

  @override
  State<LibrarySearchPage> createState() => _LibrarySearchPageState();
}

class _LibrarySearchPageState extends State<LibrarySearchPage> {
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
      text: controller.keyword.value,
    );

    _focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _goToBookDetail(LibrarySearchBook book) {
    controller.addRecentSearch(book.title);

    Get.to(
      () => const LibraryBookDetailPage(),
      transition: Transition.cupertino,
    );
  }

  void _goToSearchResult(String value) {
    final keyword = value.trim();

    if (keyword.isEmpty) return;

    controller.addRecentSearch(keyword);
    controller.setKeyword(keyword);

    Get.to(
      () => LibrarySearchResultPage(
        initialKeyword: keyword,
      ),
      transition: Transition.cupertino,
    );
  }

  void _selectKeyword(String value) {
    _textController.text = value;
    _textController.selection = TextSelection.collapsed(
      offset: _textController.text.length,
    );

    _goToSearchResult(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuminaColors.background,
      body: Column(
        children: [
          _SearchTopBar(
            controller: _textController,
            focusNode: _focusNode,
            onChanged: controller.setKeyword,
            onSubmitted: _goToSearchResult,
          ),
          Expanded(
            child: Obx(() {
              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  LuminaSpacing.marginMobile,
                  LuminaSpacing.lg,
                  LuminaSpacing.marginMobile,
                  LuminaSpacing.xl,
                ),
                children: [
                  _SearchHistorySection(
                    items: controller.recentSearches,
                    onTap: _selectKeyword,
                    onRemove: controller.removeRecentSearch,
                    onClear: controller.clearRecentSearches,
                  ),

                  if (controller.recentSearches.isNotEmpty)
                    const SizedBox(height: LuminaSpacing.xl),

                  _TrendingKeywordSection(
                    items: controller.filteredTrendingKeywords,
                    onTap: _selectKeyword,
                  ),

                  const SizedBox(height: LuminaSpacing.xl),

                  _HorizontalBookSection(
                    title: 'Buku Terakhir Dilihat',
                    books: controller.lastViewedBooks,
                    onBookTap: _goToBookDetail,
                  ),

                  const SizedBox(height: LuminaSpacing.xl),

                  _HorizontalBookSection(
                    title: 'Sedang Trending',
                    subtitle: 'Rekomendasi buku populer saat ini.',
                    books: controller.trendingBooks,
                    onBookTap: _goToBookDetail,
                    showTrendBadge: true,
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

class _SearchTopBar extends StatelessWidget {
  const _SearchTopBar({
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

class _SearchHistorySection extends StatelessWidget {
  const _SearchHistorySection({
    required this.items,
    required this.onTap,
    required this.onRemove,
    required this.onClear,
  });

  final List<String> items;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onRemove;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        _SectionHeader(
          title: 'History Search',
          actionLabel: 'Clear',
          onActionTap: onClear,
        ),

        const SizedBox(height: LuminaSpacing.sm),

        Column(
          children: List.generate(items.length, (index) {
            final item = items[index];

            return InkWell(
              onTap: () => onTap(item),
              borderRadius: BorderRadius.circular(LuminaRadius.lg),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: LuminaSpacing.xs,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.history_rounded,
                      color: LuminaColors.onSurfaceVariant,
                      size: 21,
                    ),
                    const SizedBox(width: LuminaSpacing.sm),
                    Expanded(
                      child: Text(
                        item,
                        style: LuminaTextStyles.bodyMd.copyWith(
                          color: LuminaColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => onRemove(item),
                      borderRadius: BorderRadius.circular(LuminaRadius.full),
                      child: const SizedBox(
                        width: 34,
                        height: 34,
                        child: Icon(
                          Icons.close_rounded,
                          color: LuminaColors.outline,
                          size: 19,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _TrendingKeywordSection extends StatelessWidget {
  const _TrendingKeywordSection({
    required this.items,
    required this.onTap,
  });

  final List<String> items;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Trending',
          subtitle: 'Pencarian yang sedang populer.',
        ),

        const SizedBox(height: LuminaSpacing.sm),

        Wrap(
          spacing: LuminaSpacing.sm,
          runSpacing: LuminaSpacing.sm,
          children: List.generate(items.length, (index) {
            final item = items[index];

            return _TrendingKeywordChip(
              label: item,
              rank: index + 1,
              onTap: () => onTap(item),
            );
          }),
        ),
      ],
    );
  }
}

class _TrendingKeywordChip extends StatelessWidget {
  const _TrendingKeywordChip({
    required this.label,
    required this.rank,
    required this.onTap,
  });

  final String label;
  final int rank;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isTopTrend = rank <= 3;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(LuminaRadius.full),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: LuminaSpacing.md,
          vertical: LuminaSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isTopTrend
              ? LuminaColors.secondary.withOpacity(0.10)
              : LuminaColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(LuminaRadius.full),
          border: Border.all(
            color: isTopTrend
                ? LuminaColors.secondary.withOpacity(0.28)
                : LuminaColors.outlineVariant,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isTopTrend
                  ? Icons.local_fire_department_rounded
                  : Icons.trending_up_rounded,
              color: isTopTrend
                  ? LuminaColors.secondary
                  : LuminaColors.onSurfaceVariant,
              size: 16,
            ),
            const SizedBox(width: LuminaSpacing.xs),
            Text(
              label,
              style: LuminaTextStyles.labelMd.copyWith(
                color: isTopTrend
                    ? LuminaColors.secondary
                    : LuminaColors.onSurfaceVariant,
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

class _HorizontalBookSection extends StatelessWidget {
  const _HorizontalBookSection({
    super.key,
    required this.title,
    required this.books,
    required this.onBookTap,
    this.subtitle,
    this.showTrendBadge = false,
  });

  final String title;
  final String? subtitle;
  final List<LibrarySearchBook> books;
  final ValueChanged<LibrarySearchBook> onBookTap;
  final bool showTrendBadge;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: title,
          subtitle: subtitle,
        ),
        
        const SizedBox(height: LuminaSpacing.md),

        // Menggunakan SingleChildScrollView + Row agar tinggi dinamis
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none, // Penting agar badge tidak terpotong saat di-scroll
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(books.length, (index) {
              final book = books[index];
              final isLast = index == books.length - 1;

              return Padding(
                // Menambahkan margin kanan sebagai pengganti separatorBuilder
                // Menambahkan margin atas sebesar 7 jika ada badge agar top: -7 tidak terpotong
                padding: EdgeInsets.only(
                  right: isLast ? 0 : LuminaSpacing.md,
                  top: showTrendBadge ? 7.0 : 0.0, 
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    LibraryTrendingBookCard(
                      width: 142,
                      title: book.title,
                      author: book.author,
                      rating: book.rating,
                      imageUrl: book.imageUrl,
                      isAvailable: book.isAvailable,
                      showBorrowButton: false,
                      showAvailabilityStatus: false,
                      showRatingBadge: true,
                      onTap: () => onBookTap(book),
                    ),
                    if (showTrendBadge)
                      Positioned(
                        top: -7,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: LuminaSpacing.xs,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: LuminaColors.secondary,
                            borderRadius: BorderRadius.circular(
                              LuminaRadius.full,
                            ),
                          ),
                          child: Text(
                            '#${index + 1} Trending',
                            style: LuminaTextStyles.labelMd.copyWith(
                              color: LuminaColors.onSecondary,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                              letterSpacing: 0,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          subtitle == null ? CrossAxisAlignment.center : CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: LuminaTextStyles.headlineSm.copyWith(
                  color: LuminaColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: LuminaTextStyles.bodyMd.copyWith(
                    color: LuminaColors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(
              actionLabel!,
              style: LuminaTextStyles.labelMd.copyWith(
                color: LuminaColors.secondary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
      ],
    );
  }
}
