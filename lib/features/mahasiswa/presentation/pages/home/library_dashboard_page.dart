import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/home/library_dashboard_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/pages/cart/library_cart_page.dart';
import 'package:lumina_library/features/mahasiswa/presentation/pages/catalog/library_book_detail_page.dart';
import 'package:lumina_library/features/mahasiswa/presentation/pages/catalog/library_catalog_page.dart';
import 'package:lumina_library/features/mahasiswa/presentation/pages/library_location/library_nearby_library_detail_page.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/catalog/library_trending_book_card.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/home/library_category_icon_item.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/home/library_featured_banner.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/home/library_home_top_bar.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/home/library_promo_banner_card.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/home/library_reminder_banner.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/layout/library_section_header.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/library_location/library_nearby_library_slider.dart';
import 'package:lumina_library/shared/models/banner/library_banner_model.dart';

class LibraryDashboardPage extends StatelessWidget {
  const LibraryDashboardPage({super.key});

  LibraryDashboardController get controller => Get.isRegistered<LibraryDashboardController>()
      ? Get.find<LibraryDashboardController>()
      : Get.put(LibraryDashboardController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    final dashboardController = controller;

    return Obx(
      () => ColoredBox(
        color: LuminaColors.background,
        child: Column(
          children: [
            LibraryHomeTopBar(
              onCartTap: () {
                Get.to(() => LibraryCartPage());
              },
              onNotificationTap: () {},
            ),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  top: LuminaSpacing.lg,
                  bottom: LuminaSpacing.md,
                ),
                children: [
                  if (dashboardController.showReminder.value) ...[
                    _PaddedSection(
                      child: LibraryReminderBanner(
                        title: "Kembalikan buku 'Modern UX Design'",
                        description: 'Tersisa 2 hari lagi sebelum denda berlaku.',
                        onExtend: () {},
                        onDismiss: dashboardController.dismissReminder,
                      ),
                    ),
                    const SizedBox(height: LuminaSpacing.md),
                  ],

                  const _PaddedSection(
                    child: LibraryFeaturedBanner(
                      banners: [
                        LibraryBannerData(
                          title: 'Featured Banner',
                          subtitle: 'Area promosi utama perpustakaan digital.',
                          icon: Icons.image_rounded,
                        ),
                        LibraryBannerData(
                          title: 'Buku Baru',
                          subtitle: 'Koleksi rilis terbaru bulan ini.',
                          icon: Icons.menu_book_rounded,
                        ),
                        LibraryBannerData(
                          title: 'Tips Membaca',
                          subtitle: 'Tingkatkan fokus dengan teknik pomodoro.',
                          icon: Icons.timer_rounded,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: LuminaSpacing.xl),

                  LibraryNearbyLibrarySlider(
                    items: dashboardController.nearbyLibraries,
                    onTap: (library) {
                      Get.to(
                        () => LibraryNearbyLibraryDetailPage(library: library),
                      );
                    },
                    onDirectionTap: (library) {
                      debugPrint(
                        'Open route to ${library.name}: ${library.latitude}, ${library.longitude}',
                      );
                    },
                  ),

                  const SizedBox(height: LuminaSpacing.xl),

                  const _PaddedSection(
                    child: LibrarySectionHeader(
                      title: 'Kategori',
                      showAction: false,
                    ),
                  ),

                  const SizedBox(height: LuminaSpacing.md),

                  const _FullBleedCategorySlider(),

                  const SizedBox(height: LuminaSpacing.xl),

                  _PaddedSection(
                    child: LibrarySectionHeader(
                      title: 'Sedang Tren',
                      actionLabel: 'Lihat Semua',
                      onActionTap: () {},
                    ),
                  ),

                  const SizedBox(height: LuminaSpacing.md),

                  const _FullBleedTrendingBookSlider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaddedSection extends StatelessWidget {
  const _PaddedSection({
    required this.child,
  });

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


class _FullBleedCategorySlider extends StatelessWidget {
  const _FullBleedCategorySlider();

  void _openCatalogByCategory({
    required String title,
    required String categoryKey,
  }) {
    Get.to(
      () =>  LibraryCatalogPage(
        title: title,
        initialCategoryKey: categoryKey,
        hideCart: true,
        showBackButton: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(width: LuminaSpacing.marginMobile),

          _CategoryCatalogItem(
            icon: Icons.import_contacts_rounded,
            label: 'Novel',
            onTap: () => _openCatalogByCategory(
              title: 'Novel',
              categoryKey: 'novel',
            ),
          ),
          _CategoryCatalogItem(
            icon: Icons.memory_rounded,
            label: 'Teknologi',
            onTap: () => _openCatalogByCategory(
              title: 'Teknologi',
              categoryKey: 'technology',
            ),
          ),
          _CategoryCatalogItem(
            icon: Icons.school_rounded,
            label: 'Pendidikan',
            onTap: () => _openCatalogByCategory(
              title: 'Pendidikan',
              categoryKey: 'education',
            ),
          ),
          _CategoryCatalogItem(
            icon: Icons.science_rounded,
            label: 'Sains',
            onTap: () => _openCatalogByCategory(
              title: 'Sains',
              categoryKey: 'science',
            ),
          ),
          _CategoryCatalogItem(
            icon: Icons.history_rounded,
            label: 'Sejarah',
            onTap: () => _openCatalogByCategory(
              title: 'Sejarah',
              categoryKey: 'history',
            ),
          ),
          _CategoryCatalogItem(
            icon: Icons.business_center_rounded,
            label: 'Bisnis',
            onTap: () => _openCatalogByCategory(
              title: 'Bisnis',
              categoryKey: 'business',
            ),
          ),

          const SizedBox(width: LuminaSpacing.marginMobile),
        ],
      ),
    );
  }
}

class _CategoryCatalogItem extends StatelessWidget {
  const _CategoryCatalogItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: LibraryCategoryIconItem(
        icon: icon,
        label: label,
      ),
    );
  }
}

class _FullBleedTrendingBookSlider extends StatelessWidget {
  const _FullBleedTrendingBookSlider();

  @override
  Widget build(BuildContext context) {
    // Menggunakan SingleChildScrollView + Row agar tinggi otomatis (auto)
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      // Gunakan padding di sini jika ingin memberikan jarak keseluruhan, 
      // atau biarkan di dalam Row seperti sebelumnya.
      child: Row(
        // crossAxisAlignment.start agar item rata atas jika tingginya berbeda-beda
        crossAxisAlignment: CrossAxisAlignment.start, 
        children:  [
          SizedBox(width: LuminaSpacing.marginMobile),

          LibraryTrendingBookCard(
            title: 'Clean Architecture',
            author: 'Robert C. Martin',
            rating: '4.8',
            imageUrl:
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAuLblMAj5-Sc853TMVBkmebmIs-PlqkXA2dmSvr6np_PuAApRlgf0J9jxiwcJG-BsSUs9oKsn9ksyb3dfmzQtUydS6lc_1Emw_aOukz22O2jzIOC5ET0JGAZPFPxzTDSKEO6OxtFcm8Y1QzTh_5wPP2qQnP16DxscNnWv0X2BEi3lbQy24UysKZ_Nlcp3o9laV40glwhEHh3O_B_WOOlWdZaJyeJ0CcHF3IAk6jCbHn4pSCtzT110s7C5aIff8AVMeosutYK3qGFaj',
            isAvailable: true,
            onTap: () => {
              Get.to(
                () => LibraryBookDetailPage(),
              )
            },
            onBorrowTap: () => {
              Get.to(
                () => LibraryBookDetailPage(),
              )
            },

          ),

          SizedBox(width: LuminaSpacing.md),

          LibraryTrendingBookCard(
            title: 'Design of Everyday Things',
            author: 'Don Norman',
            rating: '4.6',
            imageUrl:
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAzpmqkX7zqHxIffZ3d25pq1X0JZ36S4TdlP5S_lziXjjh2fnLIBwyAtQgksQ_Nwm-Hfa8PcMVjqFuezchn1dMKEXAzbWz0TVhFj08xJ02GyhWZHLO9HRed1fqWekOtGU82Z0xC6Tr6YKrUiyJ3AGUYHUyr_j0zzjlevLyx3quxeacgbENLWHPvVLMZbuP31umrxALb9UNCd3NNlBdPr4Kd8YLauEHyyO0UEkY6YstIZXHoPsGzbF_ILS2AOoJfRyn-IOncMLCHvV7K',
            isAvailable: true,
            onTap: () => {
              Get.to(
                () => LibraryBookDetailPage(),
              )
            },
            onBorrowTap: () => {
              Get.to(
                () => LibraryBookDetailPage(),
              )
            },

          ),

          SizedBox(width: LuminaSpacing.md),

          LibraryTrendingBookCard(
            title: 'Sapiens',
            author: 'Yuval Noah Harari',
            rating: '4.9',
            imageUrl:
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAOGdF3QY5G89jhgdZoszYTVtgwR3oxR_MjOcbuc9zoWw-ykYzpq2GdDFwhRsEmV6I6fcwVxAKt3mlKBT8EzWVNGGm3Oa33rYDpFZstTXu_npFRx8Nu7h8b_mqoxj66VbH6Jf8JfD6LCfAdFF0nR8LonDJqbUPoGhwdZhDjlXMbFuZqCvC6KZy6AtDhrCu-vgkdYnqpqsXXy4gAgNc54k6dPS7OsMAZuIdjGaslY26YvCIMaaWv4nK6tkq3NoRi6meFwbrhSHY_t2w8',
            isAvailable: false,
            onTap: () => {
              Get.to(
                () => LibraryBookDetailPage(),
              )
            },
            onBorrowTap: () => {
              Get.to(
                () => LibraryBookDetailPage(),
              )
            },
          ),

          SizedBox(width: LuminaSpacing.marginMobile),
        ],
      ),
    );
  }
}
