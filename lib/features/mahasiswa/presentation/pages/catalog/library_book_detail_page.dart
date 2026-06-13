import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/catalog/library_book_detail_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/pages/cart/library_cart_page.dart';
import 'package:lumina_library/shared/models/book/book_model.dart';
import 'package:lumina_library/shared/widgets/feedback/lumina_toast.dart';
import 'package:lumina_library/shared/widgets/skeleton/lumina_skeleton.dart';

class LibraryBookDetailPage extends StatelessWidget {
  const LibraryBookDetailPage({super.key});

  LibraryBookDetailController get controller =>
      Get.isRegistered<LibraryBookDetailController>()
          ? Get.find<LibraryBookDetailController>()
          : Get.put(LibraryBookDetailController(), permanent: true);

  void _showBookOptionsSheet(BuildContext context, BookModel? book) {
    if (book == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookOptionsSheet(book: book),
    );
  }

  void _showAddedToCartSheet(BuildContext context, BookModel? book) {
    if (book == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      builder: (_) => _AddedToCartSheet(bookTitle: book.title),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = controller;

    return Obx(
      () {
        final book = ctrl.currentBook.value;

        return Scaffold(
          backgroundColor: LuminaColors.surface,
          bottomNavigationBar: _BookDetailActionBar(
            isBookmarked: ctrl.isBookmarked.value,
            isInCart: ctrl.isInCart.value,
            isCartLoading: ctrl.isCartLoading.value,
            onBookmarkTap: ctrl.toggleBookmark,
            onCartTap: ctrl.toggleCart,
            onBorrowTap: () async {
              if (ctrl.isInCart.value) {
                // Sudah di keranjang → navigasi langsung
                Get.to(() => LibraryCartPage(), transition: Transition.cupertino);
                return;
              }
              final justAdded = await ctrl.handleBorrowBook();
              if (justAdded && context.mounted) {
                _showAddedToCartSheet(context, ctrl.currentBook.value);
              }
            },
          ),
          body: Column(
            children: [
              _BookDetailTopBar(
                onMoreTap: () => _showBookOptionsSheet(context, ctrl.currentBook.value),
              ),
              Expanded(
                child: ctrl.isLoading.value
                    ? const _BookDetailSkeleton()
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          LuminaSpacing.marginMobile,
                          LuminaSpacing.lg,
                          LuminaSpacing.marginMobile,
                          LuminaSpacing.xl,
                        ),
                        children: [
                          _BookHeroSection(book: book),
                          const SizedBox(height: LuminaSpacing.xl),
                          _BookInfoGrid(book: book),
                          const SizedBox(height: LuminaSpacing.xl),
                          _SynopsisSection(
                            synopsis: book?.description,
                            isExpanded: ctrl.isSynopsisExpanded.value,
                            onToggle: ctrl.toggleSynopsis,
                          ),
                          const SizedBox(height: LuminaSpacing.xl),
                          const _SimilarBooksSection(),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BookDetailSkeleton extends StatelessWidget {
  const _BookDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        LuminaSpacing.marginMobile,
        LuminaSpacing.lg,
        LuminaSpacing.marginMobile,
        LuminaSpacing.xl,
      ),
      children: [
        // Cover placeholder
        Center(
          child: LuminaSkeleton(
            width: 192,
            height: 288,
            radius: LuminaRadius.lg,
          ),
        ),
        const SizedBox(height: LuminaSpacing.lg),
        // Title
        Center(child: LuminaSkeleton(width: 240, height: 24, radius: LuminaRadius.sm)),
        const SizedBox(height: LuminaSpacing.xs),
        Center(child: LuminaSkeleton(width: 160, height: 18, radius: LuminaRadius.sm)),
        const SizedBox(height: LuminaSpacing.md),
        // Rating
        Center(child: LuminaSkeleton(width: 140, height: 20, radius: LuminaRadius.sm)),
        const SizedBox(height: LuminaSpacing.lg),
        // Availability badge
        Center(child: LuminaSkeleton(width: 120, height: 32, radius: LuminaRadius.full)),
        const SizedBox(height: LuminaSpacing.xl),
        // Info grid
        LayoutBuilder(
          builder: (context, constraints) {
            const crossAxisCount = 2;
            const spacing = LuminaSpacing.md;
            final itemWidth = (constraints.maxWidth - spacing) / crossAxisCount;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: List.generate(6, (_) => SizedBox(
                width: itemWidth,
                child: const LuminaSkeleton(height: 72, radius: LuminaRadius.xl),
              )),
            );
          },
        ),
        const SizedBox(height: LuminaSpacing.xl),
        // Synopsis
        const LuminaSkeleton(width: 100, height: 20, radius: LuminaRadius.sm),
        const SizedBox(height: LuminaSpacing.sm),
        const LuminaSkeleton(height: 14, radius: LuminaRadius.sm),
        const SizedBox(height: 6),
        const LuminaSkeleton(height: 14, radius: LuminaRadius.sm),
        const SizedBox(height: 6),
        const LuminaSkeleton(width: 260, height: 14, radius: LuminaRadius.sm),
      ],
    );
  }
}

class _BookDetailTopBar extends StatelessWidget {
  const _BookDetailTopBar({this.onMoreTap});

  final VoidCallback? onMoreTap;

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
                onTap: onMoreTap,
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
  const _BookHeroSection({this.book});

  final BookModel? book;

  @override
  Widget build(BuildContext context) {
    final coverUrl = book?.coverUrl;
    final title = book?.title ?? 'Judul Buku';
    final author = book?.author ?? '';
    final rating = book?.ratingLabel ?? '-';
    final ratingCount = book?.ratingCount ?? 0;
    final isAvailable = book?.isAvailable ?? false;
    final availableCount = book?.availability.availableItems ?? 0;

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
                child: coverUrl != null && coverUrl.isNotEmpty
                    ? Image.network(
                        coverUrl,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const _BookCoverPlaceholder(showLoading: true);
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const _BookCoverPlaceholder(),
                      )
                    : const _BookCoverPlaceholder(),
              ),
            ),
          ],
        ),

        const SizedBox(height: LuminaSpacing.lg),

        Text(
          title,
          textAlign: TextAlign.center,
          style: LuminaTextStyles.displayLgMobile.copyWith(
            color: LuminaColors.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.56,
          ),
        ),

        const SizedBox(height: LuminaSpacing.xs),

        Text(
          author,
          textAlign: TextAlign.center,
          style: LuminaTextStyles.titleLg.copyWith(
            color: LuminaColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: LuminaSpacing.md),

        _BookRatingRow(rating: rating, ratingCount: ratingCount),

        const SizedBox(height: LuminaSpacing.lg),

        _AvailabilityBadge(
          isAvailable: isAvailable,
          availableCount: availableCount,
        ),
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
  const _BookRatingRow({
    required this.rating,
    required this.ratingCount,
  });

  final String rating;
  final int ratingCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Row(
          children: [
            Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 21),
            Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 21),
            Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 21),
            Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 21),
            Icon(Icons.star_half_rounded, color: Color(0xFFF59E0B), size: 21),
          ],
        ),

        const SizedBox(width: LuminaSpacing.sm),

        Text(
          rating,
          style: LuminaTextStyles.bodyMd.copyWith(
            color: LuminaColors.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(width: LuminaSpacing.xs),

        Text(
          ratingCount > 0 ? '($ratingCount Reviews)' : '',
          style: LuminaTextStyles.bodyMd.copyWith(
            color: LuminaColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({
    required this.isAvailable,
    required this.availableCount,
  });

  final bool isAvailable;
  final int availableCount;

  @override
  Widget build(BuildContext context) {
    final color = isAvailable ? LuminaColors.secondary : LuminaColors.error;
    final label = isAvailable
        ? (availableCount > 0 ? 'Tersedia ($availableCount)' : 'Tersedia')
        : 'Dipinjam';
    final icon = isAvailable
        ? Icons.check_circle_outline_rounded
        : Icons.cancel_outlined;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.sm,
        vertical: LuminaSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(LuminaRadius.full),
        border: Border.all(
          color: color.withOpacity(0.20),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: LuminaSpacing.base),
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
    );
  }
}

class _BookInfoGrid extends StatelessWidget {
  const _BookInfoGrid({this.book});

  final BookModel? book;

  @override
  Widget build(BuildContext context) {
    final rackCode = book?.availability.racks.isNotEmpty == true
        ? book!.availability.racks.first.code
        : '-';

    final items = [
      _InfoItem(
        label: 'Year',
        value: book?.publishYear?.toString() ?? '-',
        isStrongValue: true,
      ),
      _InfoItem(
        label: 'Category',
        value: book?.category?.name ?? '-',
        isStrongValue: true,
      ),
      _InfoItem(
        label: 'ISBN',
        value: book?.isbn ?? '-',
      ),
      _InfoItem(
        label: 'Publisher',
        value: book?.publisher ?? '-',
      ),
      _InfoItem(
        label: 'Language',
        value: book?.language ?? '-',
      ),
      _InfoItem(
        label: 'Rack No.',
        value: rackCode,
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

class _InfoItem {
  const _InfoItem({
    required this.label,
    required this.value,
    this.isStrongValue = false,
  });

  final String label;
  final String value;
  final bool isStrongValue;
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
    this.synopsis,
    required this.isExpanded,
    required this.onToggle,
  });

  final String? synopsis;
  final bool isExpanded;
  final VoidCallback onToggle;

  static const String _fallbackSynopsis =
      'Deskripsi buku belum tersedia.';

  @override
  Widget build(BuildContext context) {
    final text = (synopsis?.isNotEmpty == true) ? synopsis! : _fallbackSynopsis;

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
              text,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _SimilarBookItem(
                title: 'Thinking, Fast and Slow',
                author: 'Daniel Kahneman',
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuA5MSIL9UMEUDxdEOPOh8AeFdZTzd5pn7-vWnH5-TWDIpC89I-W4DmPzL_2zFCa2jl2LTZqDiU5-l9hWTXO1_bRH62mNsI7WM_sJolEUvesxr-bF-qUqVdaPThjAUqckhc1Q7qSlaJiAFEIkP1ZiSMqV1_TlXOpfFECKAZtvq1K-y7AVM2ldJ8G-LJOOIdaZ5IuuXvwdaFlieS8xsBaHuUdpC05EaZ6NRhVUPZAgzpxtqme3UNNq2dXIv2x4By5aVKzSUShjj6aVjqJ',
              ),

              SizedBox(width: LuminaSpacing.md),

              _SimilarBookItem(
                title: 'Sapiens: A Brief History of Humankind',
                author: 'Yuval Noah Harari',
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAFEWu1BfcyY2SOmgrOjhQEaA8xik_NCxRJ_7_uyQ-1QWdBpc1hErB_-Z_cC9YUhLTmP5oI48ialhp0G2_o7JNGf7UiukjKQmnRl0Qtm3dkczUqd4xj1tsyLSWk6XpCvUUJdDCGuWfFi7VVxYbE28_R9TAuuYG4HPg1ZH-zvlhA_YtkdQ0V-foUIThZvrpT7wmi_q7z21Jx3NMAfAAnwjXz5ZyK-5ZGcITjedCt-WA',
              ),

              SizedBox(width: LuminaSpacing.md),

              _SimilarBookItem(
                title: 'Quiet',
                author: 'Susan Cain',
                imageUrl: '',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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
      width: 128,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(LuminaRadius.md),
              child: imageUrl.isNotEmpty
                  ? Image.network(
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
                    )
                  : Container(
                      color: LuminaColors.surfaceContainer,
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: LuminaColors.primary,
                        size: 40,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: LuminaSpacing.sm),

          Text(
            title,
            style: LuminaTextStyles.bodyMd.copyWith(
              color: LuminaColors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 2),

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
    required this.isCartLoading,
    required this.onBookmarkTap,
    required this.onCartTap,
    required this.onBorrowTap,
  });

  final bool isBookmarked;
  final bool isInCart;
  final bool isCartLoading;
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
                    onPressed: isCartLoading ? null : onBorrowTap,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: LuminaColors.primary,
                      disabledBackgroundColor: LuminaColors.primary.withOpacity(0.6),
                      foregroundColor: LuminaColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(LuminaRadius.lg),
                      ),
                    ),
                    child: isCartLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: LuminaColors.onPrimary,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isInCart
                                    ? Icons.shopping_cart_rounded
                                    : Icons.import_contacts_rounded,
                                size: 21,
                              ),
                              const SizedBox(width: LuminaSpacing.xs),
                              Text(
                                isInCart ? 'Lihat Keranjang' : 'Pinjam Buku',
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

// ─── Book Options Bottom Sheet ────────────────────────────────────────────────

class _BookOptionsSheet extends StatelessWidget {
  const _BookOptionsSheet({required this.book});

  final BookModel book;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        LuminaSpacing.marginMobile,
        LuminaSpacing.md,
        LuminaSpacing.marginMobile,
        LuminaSpacing.marginMobile,
      ),
      decoration: const BoxDecoration(
        color: LuminaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: LuminaColors.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: LuminaSpacing.lg),
            _OptionTile(
              icon: Icons.copy_rounded,
              label: 'Salin Info Buku',
              subtitle: '${book.title} · ${book.author}',
              onTap: () {
                Clipboard.setData(
                  ClipboardData(text: '${book.title} — ${book.author}'),
                );
                Get.back<void>();
                LuminaToast.success('Info buku disalin ke clipboard.');
              },
            ),
            const SizedBox(height: LuminaSpacing.xs),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LuminaColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(LuminaRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LuminaSpacing.md,
            vertical: LuminaSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: LuminaColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(LuminaRadius.lg),
                ),
                child: Icon(icon, color: LuminaColors.primary, size: 22),
              ),
              const SizedBox(width: LuminaSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: LuminaTextStyles.bodyLg.copyWith(
                        color: LuminaColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LuminaTextStyles.labelMd.copyWith(
                          color: LuminaColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
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

// ─── Bottom Icon Action ───────────────────────────────────────────────────────

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
    final color =
        isActive ? LuminaColors.secondary : LuminaColors.onSurfaceVariant;

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

// ─── Bottom Sheet Konfirmasi Tambah ke Keranjang ──────────────────────────────

class _AddedToCartSheet extends StatelessWidget {
  const _AddedToCartSheet({required this.bookTitle});

  final String bookTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(LuminaRadius.xl),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        LuminaSpacing.marginMobile,
        LuminaSpacing.md,
        LuminaSpacing.marginMobile,
        LuminaSpacing.marginMobile + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: LuminaColors.surfaceVariant,
                borderRadius: BorderRadius.circular(LuminaRadius.full),
              ),
            ),
          ),

          const SizedBox(height: LuminaSpacing.lg),

          // Icon sukses
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: LuminaColors.secondary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: LuminaColors.secondary,
              size: 36,
            ),
          ),

          const SizedBox(height: LuminaSpacing.md),

          // Judul
          Text(
            'Buku berhasil ditambahkan',
            textAlign: TextAlign.center,
            style: LuminaTextStyles.titleLg.copyWith(
              color: LuminaColors.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: LuminaSpacing.xs),

          // Deskripsi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.sm),
            child: Text(
              '"$bookTitle" telah ditambahkan ke keranjang peminjaman kamu.',
              textAlign: TextAlign.center,
              style: LuminaTextStyles.bodyMd.copyWith(
                color: LuminaColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: LuminaSpacing.xl),

          // Tombol Lihat Keranjang
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Get.back();
                Get.to(
                  () => LibraryCartPage(),
                  transition: Transition.cupertino,
                );
              },
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
                  const Icon(Icons.shopping_cart_rounded, size: 20),
                  const SizedBox(width: LuminaSpacing.xs),
                  Text(
                    'Lihat Keranjang',
                    style: LuminaTextStyles.titleMd.copyWith(
                      color: LuminaColors.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: LuminaSpacing.sm),

          // Tombol Tutup
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: Get.back,
              style: OutlinedButton.styleFrom(
                foregroundColor: LuminaColors.onSurface,
                side: const BorderSide(color: LuminaColors.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(LuminaRadius.lg),
                ),
              ),
              child: Text(
                'Tutup',
                style: LuminaTextStyles.titleMd.copyWith(
                  color: LuminaColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(height: LuminaSpacing.sm),
        ],
      ),
    );
  }
}
