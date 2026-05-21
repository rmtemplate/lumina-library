import 'package:flutter/material.dart';

import '../../../../core/theme/lumina_colors.dart';
import '../../../../core/theme/lumina_radius.dart';
import '../../../../core/theme/lumina_spacing.dart';
import '../../../../core/theme/lumina_text_styles.dart';
import '../widgets/library_trending_book_card.dart';

class LibraryBookDetailPage extends StatefulWidget {
  const LibraryBookDetailPage({
    super.key,
  });

  @override
  State<LibraryBookDetailPage> createState() => _LibraryBookDetailPageState();
}

class _LibraryBookDetailPageState extends State<LibraryBookDetailPage> {
  bool _isExpanded = false;
  bool _isBookmarked = false;
  bool _isInCart = false;

  void _toggleSynopsis() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
  }

  void _toggleCart() {
    setState(() {
      _isInCart = !_isInCart;
    });
  }

  void _handleBorrowBook() {
    debugPrint('Borrow book tapped');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuminaColors.surface,
      bottomNavigationBar: _BookDetailActionBar(
        isBookmarked: _isBookmarked,
        isInCart: _isInCart,
        onBookmarkTap: _toggleBookmark,
        onCartTap: _toggleCart,
        onBorrowTap: _handleBorrowBook,
      ),
      body: Column(
        children: [
          const _BookDetailTopBar(),

          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                LuminaSpacing.marginMobile,
                LuminaSpacing.lg,
                LuminaSpacing.marginMobile,
                LuminaSpacing.xl,
              ),
              children: [
                const _BookHeroSection(),

                const SizedBox(height: LuminaSpacing.xl),

                const _BookInfoGrid(),

                const SizedBox(height: LuminaSpacing.xl),

                _SynopsisSection(
                  isExpanded: _isExpanded,
                  onToggle: _toggleSynopsis,
                ),

                const SizedBox(height: LuminaSpacing.xl),

                const _SimilarBooksSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookDetailTopBar extends StatelessWidget {
  const _BookDetailTopBar();

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
          child: Row(
            children: [
              _TopBarIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: () {
                  Navigator.of(context).maybePop();
                },
              ),

              Expanded(
                child: Text(
                  'Lumina Library',
                  textAlign: TextAlign.center,
                  style: LuminaTextStyles.headlineSm.copyWith(
                    color: LuminaColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              _TopBarIconButton(
                icon: Icons.more_vert_rounded,
                onTap: () {},
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
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            color: LuminaColors.onSurfaceVariant,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _BookHeroSection extends StatelessWidget {
  const _BookHeroSection();

  static const String _coverUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBuM61nMe96JO0Jup1sSitAZz_vi4AIvlbaVkBG0pgBM3SW3pbVd7xfb0Xv0_PIM3WOb4vbCLflnG4lWfEKhVCwvhNFu1Md5tJC3PouRQfdH5UCqcb1NmSy68c0ULuPl-znPqIfM8BRNG-cwaAH0sRHxX2clqDSuWbv_CVP8eSmSv4V1GeuyWyh7SniuoNa95ZnJLQu1JEt7cIYiJHEZ5PC1hCDYcg-5FXo4zgvnsm5ZwswmVzh3xC69rtQhQjazQKlCta8b_DUnZWN';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: LuminaColors.secondary.withOpacity(0.06),
                    boxShadow: [
                      BoxShadow(
                        color: LuminaColors.secondary.withOpacity(0.10),
                        blurRadius: 80,
                        spreadRadius: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Container(
              width: 192,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(LuminaRadius.lg),
                border: Border.all(
                  color: LuminaColors.surfaceVariant.withOpacity(0.50),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: Image.network(
                  _coverUrl,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    return const _BookCoverPlaceholder(
                      showLoading: true,
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const _BookCoverPlaceholder();
                  },
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: LuminaSpacing.lg),

        Text(
          'The Architecture of Happiness',
          textAlign: TextAlign.center,
          style: LuminaTextStyles.displayLgMobile.copyWith(
            color: LuminaColors.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.56,
          ),
        ),

        const SizedBox(height: LuminaSpacing.xs),

        Text(
          'Alain de Botton',
          textAlign: TextAlign.center,
          style: LuminaTextStyles.titleLg.copyWith(
            color: LuminaColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: LuminaSpacing.md),

        const _BookRatingRow(),

        const SizedBox(height: LuminaSpacing.lg),

        const _AvailabilityBadge(),
      ],
    );
  }
}

class _BookCoverPlaceholder extends StatelessWidget {
  const _BookCoverPlaceholder({
    this.showLoading = false,
  });

  final bool showLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LuminaColors.surfaceContainer,
      child: Center(
        child: showLoading
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: LuminaColors.secondary,
                ),
              )
            : const Icon(
                Icons.menu_book_rounded,
                color: LuminaColors.primary,
                size: 42,
              ),
      ),
    );
  }
}

class _BookRatingRow extends StatelessWidget {
  const _BookRatingRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Row(
          children: [
            Icon(
              Icons.star_rounded,
              color: Color(0xFFF59E0B),
              size: 21,
            ),
            Icon(
              Icons.star_rounded,
              color: Color(0xFFF59E0B),
              size: 21,
            ),
            Icon(
              Icons.star_rounded,
              color: Color(0xFFF59E0B),
              size: 21,
            ),
            Icon(
              Icons.star_rounded,
              color: Color(0xFFF59E0B),
              size: 21,
            ),
            Icon(
              Icons.star_half_rounded,
              color: Color(0xFFF59E0B),
              size: 21,
            ),
          ],
        ),

        const SizedBox(width: LuminaSpacing.sm),

        Text(
          '4.8',
          style: LuminaTextStyles.bodyMd.copyWith(
            color: LuminaColors.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(width: LuminaSpacing.xs),

        Text(
          '(124 Reviews)',
          style: LuminaTextStyles.bodyMd.copyWith(
            color: LuminaColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.sm,
        vertical: LuminaSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: LuminaColors.secondary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(LuminaRadius.full),
        border: Border.all(
          color: LuminaColors.secondary.withOpacity(0.20),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: LuminaColors.secondary,
            size: 17,
          ),
          const SizedBox(width: LuminaSpacing.base),
          Text(
            'Tersedia',
            style: LuminaTextStyles.labelMd.copyWith(
              color: LuminaColors.secondary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookInfoGrid extends StatelessWidget {
  const _BookInfoGrid();

  @override
  Widget build(BuildContext context) {
    const items = [
      _BookInfoItem(
        label: 'Pages',
        value: '280',
        isStrongValue: true,
      ),
      _BookInfoItem(
        label: 'Year',
        value: '2006',
        isStrongValue: true,
      ),
      _BookInfoItem(
        label: 'Category',
        value: 'Philosophy',
        isStrongValue: true,
      ),
      _BookInfoItem(
        label: 'ISBN',
        value: '978-0307277244',
      ),
      _BookInfoItem(
        label: 'Publisher',
        value: 'Vintage',
      ),
      _BookInfoItem(
        label: 'Rack No.',
        value: 'A-42',
        isStrongValue: true,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 560 ? 3 : 2;
        const spacing = LuminaSpacing.md;
        final itemWidth =
            (constraints.maxWidth - ((crossAxisCount - 1) * spacing)) /
                crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items.map((item) {
            return SizedBox(
              width: itemWidth,
              child: _BookInfoTile(
                label: item.label,
                value: item.value,
                isStrongValue: item.isStrongValue,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _BookInfoTile extends StatelessWidget {
  const _BookInfoTile({
    required this.label,
    required this.value,
    required this.isStrongValue,
  });

  final String label;
  final String value;
  final bool isStrongValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(
          color: LuminaColors.surfaceVariant.withOpacity(0.30),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            spreadRadius: 4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: LuminaTextStyles.labelMd.copyWith(
              color: LuminaColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),

          const SizedBox(height: LuminaSpacing.base),

          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: isStrongValue
                ? LuminaTextStyles.titleLg.copyWith(
                    color: LuminaColors.primary,
                    fontWeight: FontWeight.w800,
                  )
                : LuminaTextStyles.bodyMd.copyWith(
                    color: LuminaColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
          ),
        ],
      ),
    );
  }
}

class _SynopsisSection extends StatelessWidget {
  const _SynopsisSection({
    required this.isExpanded,
    required this.onToggle,
  });

  final bool isExpanded;
  final VoidCallback onToggle;

  static const String _synopsis =
      'In The Architecture of Happiness, Alain de Botton explores the hidden links between buildings and our well-being. Arguing that the places we live and work in profoundly shape our moods and identities, he takes readers on a fascinating journey through the history of architecture. From Palladian villas to modernist masterpieces, de Botton examines how different styles embody different values and ideas about what makes a good life. He suggests that our desire for beauty in our surroundings is fundamentally a desire for a particular kind of psychological harmony.';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Synopsis',
          style: LuminaTextStyles.headlineSm.copyWith(
            color: LuminaColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: LuminaSpacing.sm),

        Stack(
          children: [
            Text(
              _synopsis,
              maxLines: isExpanded ? null : 4,
              overflow:
                  isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: LuminaTextStyles.bodyLg.copyWith(
                color: LuminaColors.onSurfaceVariant,
                height: 1.55,
              ),
            ),

            if (!isExpanded)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 42,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          LuminaColors.surface.withOpacity(0),
                          LuminaColors.surface,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: LuminaSpacing.sm),

        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(LuminaRadius.full),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 2,
              vertical: LuminaSpacing.base,
            ),
            child: Text(
              isExpanded ? 'Show less' : 'Read more',
              style: LuminaTextStyles.labelMd.copyWith(
                color: LuminaColors.secondary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SimilarBooksSection extends StatelessWidget {
  const _SimilarBooksSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                'Similar Books',
                style: LuminaTextStyles.headlineSm.copyWith(
                  color: LuminaColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View all',
                style: LuminaTextStyles.labelMd.copyWith(
                  color: LuminaColors.secondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: LuminaSpacing.md),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Penting agar rata atas saat text wrap berbeda baris
            children: const [
              _SimilarBookItem(
                title: 'Thinking, Fast and Slow',
                author: 'Daniel Kahneman',
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuA5MSIL9UMEUDxdEOPOh8AeFdZTzd5pn7-vWnH5-TWDIpC89I-W4DmPzL_2zFCa2jl2LTZqDiU5-l9hWTXO1_bRH62mNsI7WM_sJolEUvesxr-bF-qUqVdaPThjAUqckhc1Q7qSlaJiAFEIkP1ZiSMqV1_TlXOpfFECKAZtvq1K-y7AVM2ldJ8G-LJOOIdaZ5IuuXvwdaFlieS8xsBaHuUdpC05EaZ6NRhVUPZAgzpxtqme3UNNq2dXIv2x4By5aVKzSUShjj6aVjqJ',
              ),

              SizedBox(width: LuminaSpacing.md),

              _SimilarBookItem(
                title: 'Sapiens: A Brief History of Humankind', // Contoh teks panjang agar wrap
                author: 'Yuval Noah Harari',
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAFEWu1BfcyY2SOmgrOjhQEaA8xik_NCxRJ_7_uyQ-1QWdBpc1hErB_-Z_cC9YUhLTmP5oI48ialhp0G2_o7JNGf7UiukjKQmnRl0Qtm3dkczUqd4xj1tsyLSWk6XpCvUUJdDCGuWfFi7VVxYbE28_R9TAuuYG4HPg1ZH-zvlhA_YtkdQ0V-foUIThZvrpT7wmi_q7z21Jx3NMAfAAnwjXz5ZyK-5ZGcITjedCt-yQkoIpGZoUjNbaXfYw3-RQbvXX-wXOJzI0ja2p-',
              ),

              SizedBox(width: LuminaSpacing.md),

              _SimilarBookItem(
                title: 'Quiet',
                author: 'Susan Cain',
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuB-2DpyskGkjMHoH4bIdp0JJPYjHtAKA6uvsI9skUMMZjC71Oidp-ju9gNsDh30fp9RFC1jx41fl-nQcEgE5P9QuCrqVm4m1ICHdyNFwQlS2AOQ6VKyrAgR3mx56jH44Rfr9iII5eNnN25Em7VQiHlEzas_Zc4dP323dusgpJHpPV30lRDmlJ6pUTEbQCREFelHXIc4tdPhVb32m_3pivDY34gWX5R1rfHt-XUTJvfbIqZ6k8R6PIuP5UWv1qV1ipNuCnBPuV5ZlxRC',
              ),

              SizedBox(width: LuminaSpacing.md),

              _SimilarBookItem(
                title: 'Outliers',
                author: 'Malcolm Gladwell',
                imageUrl: '',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Widget khusus untuk list item buku tanpa style Card dan mengizinkan text wrap
class _SimilarBookItem extends StatelessWidget {
  const _SimilarBookItem({
    required this.title,
    required this.author,
    required this.imageUrl,
  });

  final String title;
  final String author;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128, // Lebar tetap membatasi text agar melakukan wrap
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Biarkan tinggi menyesuaikan otomatis
        children: [
          // Gambar dengan rounded corners (tanpa border luar card)
          AspectRatio(
            aspectRatio: 2 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(LuminaRadius.md),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: LuminaColors.surfaceContainer,
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: LuminaColors.secondary,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: LuminaColors.surfaceContainer,
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: LuminaColors.primary,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: LuminaSpacing.sm),

          // Teks Judul (Tanpa maxLines dan overflow agar wrap)
          Text(
            title,
            style: LuminaTextStyles.bodyMd.copyWith(
              color: LuminaColors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 2),

          // Teks Author (Tanpa maxLines dan overflow agar wrap)
          Text(
            author,
            style: LuminaTextStyles.labelMd.copyWith(
              color: LuminaColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}


class _BookDetailActionBar extends StatelessWidget {
  const _BookDetailActionBar({
    required this.isBookmarked,
    required this.isInCart,
    required this.onBookmarkTap,
    required this.onCartTap,
    required this.onBorrowTap,
  });

  final bool isBookmarked;
  final bool isInCart;
  final VoidCallback onBookmarkTap;
  final VoidCallback onCartTap;
  final VoidCallback onBorrowTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LuminaColors.surface.withOpacity(0.94),
        border: Border(
          top: BorderSide(
            color: LuminaColors.surfaceVariant.withOpacity(0.30),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            LuminaSpacing.marginMobile,
            LuminaSpacing.sm,
            LuminaSpacing.marginMobile,
            LuminaSpacing.sm,
          ),
          child: Row(
            children: [
              _BottomIconAction(
                icon: isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                isActive: isBookmarked,
                onTap: onBookmarkTap,
              ),

              const SizedBox(width: LuminaSpacing.md),

              _BottomIconAction(
                icon: isInCart
                    ? Icons.shopping_cart_rounded
                    : Icons.shopping_cart_outlined,
                isActive: isInCart,
                onTap: onCartTap,
              ),

              const SizedBox(width: LuminaSpacing.md),

              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onBorrowTap,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: LuminaColors.primary,
                      foregroundColor: LuminaColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(LuminaRadius.lg),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.import_contacts_rounded,
                          size: 21,
                        ),
                        const SizedBox(width: LuminaSpacing.xs),
                        Text(
                          'Pinjam Buku',
                          style: LuminaTextStyles.titleLg.copyWith(
                            color: LuminaColors.onPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
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

class _BottomIconAction extends StatelessWidget {
  const _BottomIconAction({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? LuminaColors.secondary : LuminaColors.onSurfaceVariant;

    return Material(
      color: LuminaColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(LuminaRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LuminaRadius.lg),
            border: Border.all(
              color: isActive
                  ? LuminaColors.secondary.withOpacity(0.30)
                  : LuminaColors.surfaceVariant,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _BookInfoItem {
  const _BookInfoItem({
    required this.label,
    required this.value,
    this.isStrongValue = false,
  });

  final String label;
  final String value;
  final bool isStrongValue;
}
