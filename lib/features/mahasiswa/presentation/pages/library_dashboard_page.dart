import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'library_book_detail_page.dart';
import 'library_cart_page.dart';

import '../../../../core/theme/lumina_colors.dart';
import '../../../../core/theme/lumina_spacing.dart';
import '../widgets/library_category_filter_bar.dart';
import '../widgets/library_category_icon_item.dart';
import '../widgets/library_featured_banner.dart';
import '../widgets/library_home_top_bar.dart';
import '../widgets/library_promo_banner_card.dart';
import '../widgets/library_reminder_banner.dart';
import '../widgets/library_search_bar.dart';
import '../widgets/library_section_header.dart';
import '../widgets/library_trending_book_card.dart';

class LibraryDashboardPage extends StatefulWidget {
  const LibraryDashboardPage({super.key});

  @override
  State<LibraryDashboardPage> createState() => _LibraryDashboardPageState();
}

class _LibraryDashboardPageState extends State<LibraryDashboardPage> {
  int _selectedCategoryIndex = 0;
  bool _showReminder = true;

  final List<String> _filters = const [
    'Semua',
    'Novel',
    'Teknologi',
    'Sains',
    'Sejarah',
    'Jurnal',
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: LuminaColors.background,
      child: Column(
        children: [
          LibraryHomeTopBar(
            onCartTap: () => {
              Get.to(
                () => LibraryCartPage(),
              ),
            },
            onNotificationTap: () => {},

          ),

          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                top: LuminaSpacing.lg,
                bottom: LuminaSpacing.md,
              ),
              children: [

                if (_showReminder) ...[
                  _PaddedSection(
                    child: LibraryReminderBanner(
                      title: "Kembalikan buku 'Modern UX Design'",
                      description:
                          'Tersisa 2 hari lagi sebelum denda berlaku.',
                      onExtend: () {},
                      onDismiss: () {
                        setState(() => _showReminder = false);
                      },
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
                          icon: Icons.image_rounded, // Optional
                        ),
                        LibraryBannerData(
                          title: 'Buku Baru',
                          subtitle: 'Koleksi rilis terbaru bulan ini.',
                          icon: Icons.menu_book_rounded, // Optional
                        ),
                        LibraryBannerData(
                          title: 'Tips Membaca',
                          subtitle: 'Tingkatkan fokus dengan teknik pomodoro.',
                          icon: Icons.timer_rounded, // Optional
                        ),
                      ],
                    ),
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

class _FullBleedPromoSlider extends StatelessWidget {
  const _FullBleedPromoSlider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 178,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: const [
          SizedBox(width: LuminaSpacing.marginMobile),

          LibraryPromoBannerCard(
            label: 'Baru',
            title: 'Koleksi Terbaru Bulan Ini',
            description:
                'Jelajahi ratusan buku dan jurnal terbaru yang baru saja ditambahkan.',
            buttonLabel: 'Lihat Koleksi',
            icon: Icons.local_library_rounded,
            variant: LibraryPromoVariant.navy,
          ),

          SizedBox(width: LuminaSpacing.md),

          LibraryPromoBannerCard(
            label: 'Promo',
            title: 'Diskon Denda Akhir Semester',
            description:
                'Potongan 50% untuk semua denda keterlambatan hingga akhir bulan ini.',
            buttonLabel: 'Klaim Sekarang',
            icon: Icons.campaign_rounded,
            variant: LibraryPromoVariant.green,
          ),

          SizedBox(width: LuminaSpacing.marginMobile),
        ],
      ),
    );
  }
}

class _FullBleedCategorySlider extends StatelessWidget {
  const _FullBleedCategorySlider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: const [
          SizedBox(width: LuminaSpacing.marginMobile),

          LibraryCategoryIconItem(
            icon: Icons.import_contacts_rounded,
            label: 'Novel',
          ),
          LibraryCategoryIconItem(
            icon: Icons.memory_rounded,
            label: 'Teknologi',
          ),
          LibraryCategoryIconItem(
            icon: Icons.school_rounded,
            label: 'Pendidikan',
          ),
          LibraryCategoryIconItem(
            icon: Icons.science_rounded,
            label: 'Sains',
          ),
          LibraryCategoryIconItem(
            icon: Icons.history_rounded,
            label: 'Sejarah',
          ),
          LibraryCategoryIconItem(
            icon: Icons.business_center_rounded,
            label: 'Bisnis',
          ),

          SizedBox(width: LuminaSpacing.marginMobile),
        ],
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
