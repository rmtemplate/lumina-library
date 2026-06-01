import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/home/library_dashboard_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/pages/cart/library_cart_page.dart';
import 'package:lumina_library/features/mahasiswa/presentation/pages/catalog/library_book_detail_page.dart';
import 'package:lumina_library/features/mahasiswa/presentation/pages/catalog/library_catalog_page.dart';
import 'package:lumina_library/features/mahasiswa/presentation/pages/library_location/library_nearby_library_detail_page.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/catalog/library_trending_book_card.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/home/library_category_icon_item.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/home/library_featured_banner.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/home/library_home_top_bar.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/home/library_reminder_banner.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/layout/library_section_header.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/library_location/library_nearby_library_slider.dart';
import 'package:lumina_library/shared/models/book/book_model.dart';
import 'package:lumina_library/shared/models/category/category_model.dart';
import 'package:lumina_library/shared/widgets/skeleton/lumina_skeleton.dart';

class LibraryDashboardPage extends StatelessWidget {
  const LibraryDashboardPage({super.key});

  LibraryDashboardController get controller =>
      Get.isRegistered<LibraryDashboardController>()
          ? Get.find<LibraryDashboardController>()
          : Get.put(LibraryDashboardController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return ColoredBox(
      color: LuminaColors.background,
      child: Column(
        children: [
          // ── Top bar ────────────────────────────────────────────────────
          Obx(() => LibraryHomeTopBar(
                userName: c.userName.value.isNotEmpty ? c.userName.value : 'Halo',
                avatarUrl: c.userAvatarUrl.value ?? '',
                onCartTap: () => Get.to(() => LibraryCartPage()),
                onNotificationTap: () {},
              )),

          // ── Body ───────────────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              color: LuminaColors.secondary,
              backgroundColor: LuminaColors.surfaceContainerLowest,
              onRefresh: c.refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.only(
                  top: LuminaSpacing.lg,
                  bottom: LuminaSpacing.xl,
                ),
                children: [
                  // ── Reminder ───────────────────────────────────────────
                  Obx(() {
                    if (!c.showReminder.value) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: LuminaSpacing.marginMobile,
                        right: LuminaSpacing.marginMobile,
                        bottom: LuminaSpacing.md,
                      ),
                      child: LibraryReminderBanner(
                        title: 'Kembalikan buku sebelum denda berlaku',
                        description: 'Tersisa 2 hari lagi sebelum denda berlaku.',
                        onExtend: () {},
                        onDismiss: c.dismissReminder,
                      ),
                    );
                  }),

                  // ── Banner ─────────────────────────────────────────────
                  Obx(() {
                    if (c.bannersLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: LuminaSpacing.marginMobile,
                        ),
                        child: LuminaBannerSkeleton(),
                      );
                    }
                    if (c.banners.isEmpty) return const SizedBox.shrink();
                    return _PaddedSection(
                      child: LibraryFeaturedBanner(
                        banners: c.banners
                            .map((b) => b.toLibraryBannerData())
                            .toList(),
                      ),
                    );
                  }),

                  const SizedBox(height: LuminaSpacing.xl),

                  // ── Perpustakaan Terdekat ──────────────────────────────
                  const _PaddedSection(
                    child: LibrarySectionHeader(
                      title: 'Perpustakaan Terdekat',
                      showAction: false,
                    ),
                  ),
                  const SizedBox(height: LuminaSpacing.md),

                  Obx(() {
                    if (c.branchesLoading.value) {
                      return const LuminaBranchCardSkeletonList();
                    }
                    if (c.nearbyBranches.isEmpty) {
                      return const _PaddedSection(
                        child: _EmptySection(
                          icon: Icons.location_off_rounded,
                          label: 'Data perpustakaan belum tersedia.',
                        ),
                      );
                    }
                    return LibraryNearbyLibrarySlider(
                      items: c.nearbyBranches
                          .map((b) => b.toNearbyLibraryData())
                          .toList(),
                      onTap: (data) {
                        final branch = c.nearbyBranches.firstWhere(
                          (b) => b.id == data.id,
                          orElse: () => c.nearbyBranches.first,
                        );
                        Get.to(() => LibraryNearbyLibraryDetailPage(
                              library: branch.toNearbyLibraryData(),
                            ));
                      },
                      onDirectionTap: (_) {},
                    );
                  }),

                  const SizedBox(height: LuminaSpacing.xl),

                  // ── Kategori ──────────────────────────────────────────
                  const _PaddedSection(
                    child: LibrarySectionHeader(
                      title: 'Kategori',
                      showAction: false,
                    ),
                  ),
                  const SizedBox(height: LuminaSpacing.md),

                  Obx(() {
                    if (c.categoriesLoading.value) {
                      return const LuminaCategoryItemSkeletonList();
                    }
                    if (c.categories.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return _CategorySlider(categories: c.categories);
                  }),

                  const SizedBox(height: LuminaSpacing.xl),

                  // ── Sedang Tren ────────────────────────────────────────
                  _PaddedSection(
                    child: LibrarySectionHeader(
                      title: 'Sedang Tren',
                      actionLabel: 'Lihat Semua',
                      onActionTap: () {},
                    ),
                  ),
                  const SizedBox(height: LuminaSpacing.md),

                  Obx(() {
                    if (c.booksLoading.value) {
                      return const LuminaBookCardSkeletonList();
                    }
                    if (c.trendingBooks.isEmpty) {
                      return const _PaddedSection(
                        child: _EmptySection(
                          icon: Icons.menu_book_rounded,
                          label: 'Belum ada buku trending.',
                        ),
                      );
                    }
                    return _TrendingBookSlider(books: c.trendingBooks);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category Slider ──────────────────────────────────────────────────────────


class _CategorySlider extends StatelessWidget {
  const _CategorySlider({required this.categories});
  final List<CategoryModel> categories;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      // IntrinsicHeight → tinggi row otomatis ikut item tertinggi (label 2 baris)
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: LuminaSpacing.marginMobile),
            ...categories.map(
              (cat) => LibraryCategoryIconItem(
                label: cat.name,
                imageUrl: cat.icon?.imageUrl,
                icon: cat.icon?.imageUrl == null ? Icons.category_rounded : null,
                onTap: () => Get.to(
                  () => LibraryCatalogPage(
                    title: cat.name,
                    initialCategoryKey: cat.slug,
                    hideCart: true,
                    showBackButton: true,
                  ),
                ),
              ),
            ),
            const SizedBox(width: LuminaSpacing.marginMobile),
          ],
        ),
      ),
    );
  }
}

// ─── Trending Book Slider ─────────────────────────────────────────────────────

class _TrendingBookSlider extends StatelessWidget {
  const _TrendingBookSlider({required this.books});
  final List<BookModel> books;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: LuminaSpacing.marginMobile),
          ...books.asMap().entries.map((entry) {
            final book = entry.value;
            final isLast = entry.key == books.length - 1;
            return Padding(
              padding: EdgeInsets.only(
                right: isLast ? LuminaSpacing.marginMobile : LuminaSpacing.md,
              ),
              child: LibraryTrendingBookCard(
                title: book.title,
                author: book.author,
                rating: book.ratingLabel,
                imageUrl: book.coverUrl ?? '',
                isAvailable: book.isAvailable,
                libraryLocation: book.locationLabel,
                onTap: () => Get.to(() => LibraryBookDetailPage()),
                onBorrowTap: () => Get.to(() => LibraryBookDetailPage()),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Layout helpers ───────────────────────────────────────────────────────────

class _PaddedSection extends StatelessWidget {
  const _PaddedSection({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.marginMobile,
      ),
      child: child,
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: LuminaColors.outline, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: LuminaTextStyles.bodyMd.copyWith(
              color: LuminaColors.outline,
            ),
          ),
        ],
      ),
    );
  }
}
