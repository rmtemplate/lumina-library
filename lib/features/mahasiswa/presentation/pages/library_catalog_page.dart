import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'library_book_detail_page.dart';
import 'library_cart_page.dart';
import 'library_search_page.dart';

import '../../../../core/theme/lumina_colors.dart';
import '../../../../core/theme/lumina_radius.dart';
import '../../../../core/theme/lumina_spacing.dart';
import '../../../../core/theme/lumina_text_styles.dart';
import '../widgets/library_trending_book_card.dart';

class LibraryCatalogPage extends StatefulWidget {
  const LibraryCatalogPage({super.key});

  @override
  State<LibraryCatalogPage> createState() => _LibraryCatalogPageState();
}

class _LibraryCatalogPageState extends State<LibraryCatalogPage> {
  int _selectedFilterIndex = 0;

  final List<String> _filters = const [
    'All',
    'Popular',
    'Newest',
    'Novel',
    'Tech',
  ];

  final Set<int> _favoriteIndexes = {
    2,
  };

  final List<_CatalogBook> _books = const [
    _CatalogBook(
      title: 'The Design of Everyday Things',
      author: 'Don Norman',
      rating: '4.8',
      isAvailable: true,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDFtPY08koMch_TVNgxI6NG7PM-FzVmki-eENqsbHPdiuTqJu53S19Rzzuewotosw7fpA0BOHSo8u7rp6esH0z9z5YDAxVCXI_bzCry3t2jfErzsR1AiXaPQXuNq7LbPqn66Y4Etk5eNNFqTyLivYkxyOLMgrY-vZHr9t0bgMIxjpV4YYwLIEArvxee0cMXce9RbIcVXWbU2212IwPLDheL0tnZ9PaKoLvCmeYiUVIvp8QyzcMe0klsbfG_WcUMaUflq3inhdk7qVmg',
    ),
    _CatalogBook(
      title: 'Clean Code',
      author: 'Robert C. Martin',
      rating: '4.9',
      isAvailable: false,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCO34Y508de6iKw_qzLC6_2khlv2bRyBx7h4XorhVHnkzkfFsZrBK2DSPcgTd44O7j5m5-RkYK8pzR8LEimeUNuEwz1stpZtQih_LSmdcghLYsPq2SQ9qjWWab5_2CnsV6Zqq3xuxpo2Oq24iCXn2k0i0lsSg-QZ6iYM_UMoNAFOsE5t6pdyclTmaKDagds72W3NKb4tDwSuaAiebME6HzI6wZi5Wjo71jnzKrk2tUmrhhNjaH8xS2LmGL6n-eW3WasselkmOJZo1N9',
    ),
    _CatalogBook(
      title: 'Sapiens',
      author: 'Yuval Noah Harari',
      rating: '4.7',
      isAvailable: true,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDEqwKBnH8vr-PuYXSy-6DZAa4WouAOjyZyx_VITYRgXX4O-V6P91OszSCt6POwHB-N3EqTfV_FxrGpEBPDYWt7aQHuepWAppe-0kAkpYVcV4rW0Xo5oflqor5X0LsySQdvSBetLpMUj--CtpaPsIY0NWRunpbDxpAimtXprYZ9FpWPwVo8A5FkIq0Z2YnX9fno3vayr12fwde3Ls9uIsVOzW54MWruq8G3QgkgleR4gHF4sQFr27d0d-0GU-mILt1lXSU5qQDyErXJ',
    ),
    _CatalogBook(
      title: 'Thinking, Fast and Slow',
      author: 'Daniel Kahneman',
      rating: '4.8',
      isAvailable: true,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCKFM0hqygsbsRpvlKPieR5QZ3wUJdUwrrBHNvQ1Xpl_v3ZyA2CmnI00VaWHwip_nSReK2A1rJCVl7vEvj_6GHlAQoJfDpPgTYJqnBXKHXfeIo_c1DzD7QiEgTpXf1ZPg8h8dNHYVz5tcnG1DXoK7rFK6crYXvhdhmP-hrqmjuHxC6QpDXSz83Cw4kbbm66191LxJ0-LCs-MsA7ku1zhR_2-LvjOu3JhVwrvQe_02XnkIyhOq8GzSZroYhnNcYXyffs4Yw7EA2DwGBg',
    ),
  ];

  void _toggleFavorite(int index) {
    setState(() {
      if (_favoriteIndexes.contains(index)) {
        _favoriteIndexes.remove(index);
      } else {
        _favoriteIndexes.add(index);
      }
    });
  }

  void _handleBookTap(_CatalogBook book) {
    Get.to(
      () => const LibraryBookDetailPage(),
      transition: Transition.cupertino,
    );
  }

  void _handleBorrowTap(_CatalogBook book) {
    debugPrint('Borrow tapped: ${book.title}');
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

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: LuminaColors.background,
      child: Column(
        children: [
          _CatalogTopBar(
            onSearchTap: _goToSearchPage,
            onCartTap: _goToCartPage,
          ),

          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(
                  child: SizedBox(height: LuminaSpacing.md),
                ),

                SliverToBoxAdapter(
                  child: _CatalogFilterChips(
                    filters: _filters,
                    selectedIndex: _selectedFilterIndex,
                    onChanged: (index) {
                      setState(() {
                        _selectedFilterIndex = index;
                      });
                    },
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: LuminaSpacing.lg),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    LuminaSpacing.marginMobile,
                    0,
                    LuminaSpacing.marginMobile,
                    LuminaSpacing.xl,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _CatalogBookGrid(
                      books: _books,
                      favoriteIndexes: _favoriteIndexes,
                      onBookTap: _handleBookTap,
                      onFavoriteTap: _toggleFavorite,
                      onBorrowTap: _handleBorrowTap,
                    ),
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


class _CatalogTopBar extends StatelessWidget {
  const _CatalogTopBar({
    super.key,
    required this.onSearchTap,
    required this.onCartTap,
  });

  final VoidCallback onSearchTap;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LuminaColors.surface,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LuminaSpacing.marginMobile,
            vertical: LuminaSpacing.sm,
          ),
          // Menggunakan Stack agar elemen bisa ditumpuk secara independen
          child: Stack(
            alignment: Alignment.center, // Memastikan anak di dalamnya rata tengah
            children: [
              // Judul (Teks) akan selalu berada presisi di tengah layar
              Text(
                'Lumina Library',
                textAlign: TextAlign.center,
                style: LuminaTextStyles.headlineSm.copyWith(
                  color: LuminaColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),

              // Bagian Ikon didorong ke pojok kanan
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TopBarIconButton(
                      icon: Icons.search_rounded,
                      onTap: onSearchTap,
                    ),
                    const SizedBox(width: 2),
                    _TopBarIconButton(
                      icon: Icons.shopping_cart_outlined,
                      onTap: onCartTap,
                    ),
                  ],
                ),
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
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(LuminaRadius.full),
      child: SizedBox(
        width: 38,
        height: 40,
        child: Icon(
          icon,
          color: LuminaColors.primary,
          size: 24,
        ),
      ),
    );
  }
}

class _CatalogFilterChips extends StatelessWidget {
  const _CatalogFilterChips({
    required this.filters,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> filters;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: LuminaSpacing.marginMobile,
        ),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: LuminaSpacing.sm),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          final label = filters[index];
          final showClose = label == 'Novel';

          return InkWell(
            onTap: () => onChanged(index),
            borderRadius: BorderRadius.circular(LuminaRadius.full),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(
                horizontal: LuminaSpacing.md,
                vertical: LuminaSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? LuminaColors.primary
                    : LuminaColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(LuminaRadius.full),
                border: Border.all(
                  color: isSelected
                      ? LuminaColors.primary
                      : LuminaColors.outlineVariant,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: LuminaTextStyles.labelMd.copyWith(
                      color: isSelected
                          ? LuminaColors.onPrimary
                          : LuminaColors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (showClose) ...[
                    const SizedBox(width: LuminaSpacing.xs),
                    Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: isSelected
                          ? LuminaColors.onPrimary
                          : LuminaColors.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CatalogBookGrid extends StatelessWidget {
  const _CatalogBookGrid({
    required this.books,
    required this.favoriteIndexes,
    required this.onBookTap,
    required this.onFavoriteTap,
    required this.onBorrowTap,
  });

  final List<_CatalogBook> books;
  final Set<int> favoriteIndexes;
  final ValueChanged<_CatalogBook> onBookTap;
  final ValueChanged<int> onFavoriteTap;
  final ValueChanged<_CatalogBook> onBorrowTap;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return const _CatalogEmptyState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        final spacing = LuminaSpacing.md;
        final cardWidth =
            (constraints.maxWidth - ((crossAxisCount - 1) * spacing)) /
                crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(books.length, (index) {
            final book = books[index];

            return LibraryTrendingBookCard(
              width: cardWidth,
              title: book.title,
              author: book.author,
              rating: book.rating,
              imageUrl: book.imageUrl,
              isAvailable: book.isAvailable,
              isFavorite: favoriteIndexes.contains(index),
              showRatingBadge: false,
              showInlineRating: true,
              showBorrowButton: false,
              showAvailabilityStatus: true,
              showFavoriteButton: true,
              dimUnavailableCover: true,
              onTap: () => onBookTap(book),
              onFavoriteTap: () => onFavoriteTap(index),
              onBorrowTap: () => onBorrowTap(book),
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

class _CatalogEmptyState extends StatelessWidget {
  const _CatalogEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(LuminaSpacing.xl),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(
          color: LuminaColors.surfaceVariant,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: LuminaColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: LuminaColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: LuminaSpacing.md),
          Text(
            'Buku tidak ditemukan',
            style: LuminaTextStyles.titleLg.copyWith(
              color: LuminaColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: LuminaSpacing.xs),
          Text(
            'Coba gunakan kata kunci lain untuk mencari katalog.',
            textAlign: TextAlign.center,
            style: LuminaTextStyles.bodyMd.copyWith(
              color: LuminaColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogBook {
  const _CatalogBook({
    required this.title,
    required this.author,
    required this.rating,
    required this.isAvailable,
    required this.imageUrl,
  });

  final String title;
  final String author;
  final String rating;
  final bool isAvailable;
  final String imageUrl;
}
