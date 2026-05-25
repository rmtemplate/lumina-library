import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/library_location/library_location_detail_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/pages/catalog/library_book_detail_page.dart';
import 'package:lumina_library/features/mahasiswa/presentation/pages/library_location/library_route_map_page.dart';
import 'package:lumina_library/features/mahasiswa/presentation/pages/search/library_search_page.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/catalog/library_trending_book_card.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/library_location/library_nearby_library_slider.dart';
import 'package:lumina_library/shared/models/book/library_book_model.dart';
import 'package:lumina_library/shared/models/library/library_branch_model.dart';

class LibraryNearbyLibraryDetailPage extends StatelessWidget {
  const LibraryNearbyLibraryDetailPage({
    super.key,
    this.library,
  });

  final LibraryNearbyLibraryData? library;

  static const LibraryNearbyLibraryData _fallbackLibrary = LibraryNearbyLibraryData(
    id: 'lib-central',
    name: 'Lumina Library - Central',
    address: 'Jl. Pendidikan No. 12, Kampus Utama',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCPTii7cXy7313wcdGk7zQc8SXQW_4UegxfseSNmuDmT_7vqsMzl_Gb9Cxc2jJ3J4KYzQcDHxGrj5PxA7nmprxz-4f16T7QFbuOzIE0VwzNoeP56AkQEX7I22BO4kr1u5O2FsZhAK1y_ldu2TNq4_n1SKLtlxh4ebYI7COsL9ckLsmOB2BapfzPVdqIU2X4DWzq-5MEF1ClBxqT0D3mFdnDTYVMA1KnQkz2JxHSU4b3dDyMfcS32niApylAvKNcj5mfIB6uNCE7WVBv',
    distanceText: '350 m',
    durationText: '5 min',
    scheduleText: '08.00 - 20.00',
    openStatusText: 'Buka Sekarang',
    isOpen: true,
    latitude: -6.200000,
    longitude: 106.816666,
  );

  static const List<LibraryBookModel> _books = [
    LibraryBookModel(
      title: 'The Design of Everyday Things',
      author: 'Don Norman',
      rating: '4.8',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDMX4YVcC_-UVaul5kGV68fPcdv03_iB8G9MwL03eMXwbXzpo-ewRHxZPlp6j2Vo_CbfgSFj_SmTLS-0DkDN5ckEeM0V6BAJGcSk6yIomAcKS_6mOdD9qoSAtOD_Zdf7V5BXPsNWo3N8x7ThhdsdgijBQ4UnD855facLmSD3_fcyEthbA5og9aqWPV-xwr43zlGNA9sztcElcZmOBDfsnqt7vKbl-2dWLzUf0MXluMVG5vduUadipe5c_JaHy7rUugHUBWEscfarqIA',
      isAvailable: true,
      stockText: 'Tersedia: 3',
    ),
    LibraryBookModel(
      title: 'Introduction to Algorithms',
      author: 'Thomas H. Cormen',
      rating: '4.7',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAoj4Z8IoRSbMHxcHtyF5zv-vftPDK9cEmIt5CWpIbIFF8FfnDsdsfP2nupFnCUXvVFO0sGmQMrS54Pl5r3bcrbX99lI6PlUkykcO4_Oy5osY70WvrPRu1-n4mm-8QPO8-_-MryX6sBF6WTpzN2CKv2qRPml7NF3AHYHAo8ztQeeI3blkxqWgZbKDPMbJHL5Oo6VagMzspuZHBK5eRcUxU9ec9PvU7LyrOKGPxx6enE-rZYQlaFdH3n9XA22wcQT2t2PuZLIT8TtLIU',
      isAvailable: false,
      stockText: 'Dipinjam',
    ),
    LibraryBookModel(
      title: 'Clean Architecture',
      author: 'Robert C. Martin',
      rating: '4.9',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAuLblMAj5-Sc853TMVBkmebmIs-PlqkXA2dmSvr6np_PuAApRlgf0J9jxiwcJG-BsSUs9oKsn9ksyb3dfmzQtUydS6lc_1Emw_aOukz22O2jzIOC5ET0JGAZPFPxzTDSKEO6OxtFcm8Y1QzTh_5wPP2qQnP16DxscNnWv0X2BEi3lbQy24UysKZ_Nlcp3o9laV40glwhEHh3O_B_WOOlWdZaJyeJ0CcHF3IAk6jCbHn4pSCtzT110s7C5aIff8AVMeosutYK3qGFaj',
      isAvailable: true,
      stockText: 'Tersedia: 5',
    ),
    LibraryBookModel(
      title: 'Sapiens',
      author: 'Yuval Noah Harari',
      rating: '4.9',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAOGdF3QY5G89jhgdZoszYTVtgwR3oxR_MjOcbuc9zoWw-ykYzpq2GdDFwhRsEmV6I6fcwVxAKt3mlKBT8EzWVNGGm3Oa33rYDpFZstTXu_npFRx8Nu7h8b_mqoxj66VbH6Jf8JfD6LCfAdFF0nR8LonDJqbUPoGhwdZhDjlXMbFuZqCvC6KZy6AtDhrCu-vgkdYnqpqsXXy4gAgNc54k6dPS7OsMAZuIdjGaslY26YvCIMaaWv4nK6tkq3NoRi6meFwbrhSHY_t2w8',
      isAvailable: true,
      stockText: 'Tersedia: 2',
    ),
  ];

  LibraryLocationDetailController get controller => Get.isRegistered<LibraryLocationDetailController>()
      ? Get.find<LibraryLocationDetailController>()
      : Get.put(LibraryLocationDetailController(), permanent: true);

  LibraryNearbyLibraryData get currentLibrary => library ?? _fallbackLibrary;

  void _goToBookDetail() {
    Get.to(
      () => const LibraryBookDetailPage(),
      transition: Transition.cupertino,
    );
  }

  void _goToSearchPage(LibraryNearbyLibraryData selectedLibrary) {
    Get.to(
      () => LibrarySearchPage(
        scopedLibrary: selectedLibrary,
        initialSearchInCurrentLibrary: true,
      ),
      transition: Transition.cupertino,
    );
  }

  void _goToRouteMapPage(LibraryNearbyLibraryData selectedLibrary) {
    final latitude = selectedLibrary.latitude;
    final longitude = selectedLibrary.longitude;

    if (latitude == null || longitude == null) {
      Get.snackbar(
        'Lokasi tidak tersedia',
        'Koordinat perpustakaan belum tersedia.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(LuminaSpacing.marginMobile),
        backgroundColor: LuminaColors.errorContainer,
        colorText: LuminaColors.onErrorContainer,
      );
      return;
    }

    Get.to(
      () => LibraryRouteMapPage(
        destinationName: selectedLibrary.name,
        destinationAddress: selectedLibrary.address,
        destinationLatitude: latitude,
        destinationLongitude: longitude,
      ),
      transition: Transition.cupertino,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedLibrary = currentLibrary;
    final detailController = controller;

    return Obx(
      () => Scaffold(
        backgroundColor: LuminaColors.background,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _LibraryDetailAppBar(
              library: selectedLibrary,
              onBackTap: () => Navigator.of(context).maybePop(),
              onSearchTap: () => _goToSearchPage(selectedLibrary),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                LuminaSpacing.marginMobile,
                LuminaSpacing.lg,
                LuminaSpacing.marginMobile,
                LuminaSpacing.xl,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _LibraryMainInfoCard(
                      library: selectedLibrary,
                      isFavorite: detailController.isFavorite.value,
                      onDirectionTap: () => _goToRouteMapPage(selectedLibrary),
                      onFavoriteTap: detailController.toggleFavorite,
                    ),
                    const SizedBox(height: LuminaSpacing.lg),
                    const _LibraryInfoGrid(),
                    const SizedBox(height: LuminaSpacing.xl),
                    _LibraryBookSectionHeader(
                      totalBooks: _books.length,
                      onSearchTap: () => _goToSearchPage(selectedLibrary),
                    ),
                    const SizedBox(height: LuminaSpacing.md),
                    _LibraryBookGrid(
                      books: _books,
                      onBookTap: _goToBookDetail,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryDetailAppBar extends StatelessWidget {
  const _LibraryDetailAppBar({
    required this.library,
    required this.onBackTap,
    required this.onSearchTap,
  });

  final LibraryNearbyLibraryData library;
  final VoidCallback onBackTap;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: 330,
      backgroundColor: LuminaColors.surface,
      elevation: 0,
      leading: _CircleIconButton(
        icon: Icons.arrow_back_rounded,
        onTap: onBackTap,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: LuminaSpacing.sm),
          child: _CircleIconButton(
            icon: Icons.search_rounded,
            onTap: onSearchTap,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              library.imageUrl,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;

                return Container(
                  color: LuminaColors.surfaceContainer,
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: LuminaColors.secondary,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: LuminaColors.surfaceContainer,
                  child: const Center(
                    child: Icon(
                      Icons.local_library_rounded,
                      color: LuminaColors.primary,
                      size: 48,
                    ),
                  ),
                );
              },
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.08),
                    Colors.black.withOpacity(0.18),
                    Colors.black.withOpacity(0.72),
                  ],
                ),
              ),
            ),
            Positioned(
              left: LuminaSpacing.marginMobile,
              right: LuminaSpacing.marginMobile,
              bottom: LuminaSpacing.lg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OpenStatusChip(
                    isOpen: library.isOpen,
                    label: library.openStatusText,
                  ),
                  const SizedBox(height: LuminaSpacing.sm),
                  Text(
                    library.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: LuminaTextStyles.displayLgMobile.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: LuminaSpacing.xs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          library.address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: LuminaTextStyles.bodyMd.copyWith(
                            color: Colors.white.withOpacity(0.90),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: LuminaColors.surfaceContainerLowest.withOpacity(0.88),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              icon,
              color: LuminaColors.primary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _OpenStatusChip extends StatelessWidget {
  const _OpenStatusChip({
    required this.isOpen,
    required this.label,
  });

  final bool isOpen;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? LuminaColors.secondary : LuminaColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.sm,
        vertical: LuminaSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(LuminaRadius.full),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.22),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        label,
        style: LuminaTextStyles.labelMd.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _LibraryMainInfoCard extends StatelessWidget {
  const _LibraryMainInfoCard({
    required this.library,
    required this.isFavorite,
    required this.onDirectionTap,
    required this.onFavoriteTap,
  });

  final LibraryNearbyLibraryData library;
  final bool isFavorite;
  final VoidCallback onDirectionTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(
          color: LuminaColors.surfaceVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _MetricTile(
                icon: Icons.near_me_rounded,
                label: 'Jarak',
                value: library.distanceText,
              ),
              _MetricDivider(),
              _MetricTile(
                icon: Icons.directions_walk_rounded,
                label: 'Estimasi',
                value: library.durationText,
              ),
              _MetricDivider(),
              _MetricTile(
                icon: Icons.schedule_rounded,
                label: 'Hari Ini',
                value: library.scheduleText,
              ),
            ],
          ),
          const SizedBox(height: LuminaSpacing.md),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onDirectionTap,
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
                        const Icon(Icons.directions_rounded, size: 20),
                        const SizedBox(width: LuminaSpacing.xs),
                        Text(
                          'Petunjuk Arah',
                          style: LuminaTextStyles.titleLg.copyWith(
                            color: LuminaColors.onPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: LuminaSpacing.sm),
              Material(
                color: isFavorite
                    ? LuminaColors.secondary.withOpacity(0.10)
                    : LuminaColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(LuminaRadius.lg),
                child: InkWell(
                  onTap: onFavoriteTap,
                  borderRadius: BorderRadius.circular(LuminaRadius.lg),
                  child: SizedBox(
                    width: 54,
                    height: 48,
                    child: Icon(
                      isFavorite
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: isFavorite
                          ? LuminaColors.secondary
                          : LuminaColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: LuminaColors.primary, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: LuminaTextStyles.labelMd.copyWith(
              color: LuminaColors.onSurfaceVariant,
              letterSpacing: 0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: LuminaTextStyles.bodyMd.copyWith(
              color: LuminaColors.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 46,
      color: LuminaColors.surfaceVariant,
    );
  }
}

class _LibraryInfoGrid extends StatelessWidget {
  const _LibraryInfoGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _OperationalHoursCard(),
        SizedBox(height: LuminaSpacing.md),
        _FacilitiesCard(),
      ],
    );
  }
}

class _OperationalHoursCard extends StatelessWidget {
  const _OperationalHoursCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.schedule_rounded,
      title: 'Jam Operasional',
      child: Column(
        children: const [
          _OperationalHourRow(
            day: 'Senin - Jumat',
            time: '08:00 - 20:00',
          ),
          SizedBox(height: LuminaSpacing.xs),
          _OperationalHourRow(
            day: 'Sabtu',
            time: '09:00 - 15:00',
          ),
          SizedBox(height: LuminaSpacing.xs),
          _OperationalHourRow(
            day: 'Minggu',
            time: 'Tutup',
            isClosed: true,
          ),
        ],
      ),
    );
  }
}

class _OperationalHourRow extends StatelessWidget {
  const _OperationalHourRow({
    required this.day,
    required this.time,
    this.isClosed = false,
  });

  final String day;
  final String time;
  final bool isClosed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            day,
            style: LuminaTextStyles.bodyMd.copyWith(
              color: isClosed
                  ? LuminaColors.error
                  : LuminaColors.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          time,
          style: LuminaTextStyles.bodyMd.copyWith(
            color: isClosed ? LuminaColors.error : LuminaColors.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _FacilitiesCard extends StatelessWidget {
  const _FacilitiesCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.local_cafe_rounded,
      title: 'Fasilitas',
      child: Wrap(
        spacing: LuminaSpacing.xs,
        runSpacing: LuminaSpacing.xs,
        children: const [
          _FacilityChip(icon: Icons.wifi_rounded, label: 'Free Wi-Fi'),
          _FacilityChip(icon: Icons.volume_off_rounded, label: 'Quiet Zone'),
          _FacilityChip(icon: Icons.power_rounded, label: 'Charging'),
          _FacilityChip(icon: Icons.print_rounded, label: 'Printing'),
          _FacilityChip(icon: Icons.desktop_windows_rounded, label: 'Komputer'),
          _FacilityChip(icon: Icons.local_cafe_rounded, label: 'Cafe Area'),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(
          color: LuminaColors.surfaceVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: LuminaColors.primary, size: 22),
              const SizedBox(width: LuminaSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: LuminaTextStyles.titleLg.copyWith(
                    color: LuminaColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: LuminaSpacing.sm),
          const Divider(color: LuminaColors.surfaceVariant, height: 1),
          const SizedBox(height: LuminaSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _FacilityChip extends StatelessWidget {
  const _FacilityChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.sm,
        vertical: LuminaSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(LuminaRadius.full),
        border: Border.all(color: LuminaColors.surfaceVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: LuminaColors.onSurfaceVariant, size: 16),
          const SizedBox(width: 5),
          Text(
            label,
            style: LuminaTextStyles.labelMd.copyWith(
              color: LuminaColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryBookSectionHeader extends StatelessWidget {
  const _LibraryBookSectionHeader({
    required this.totalBooks,
    required this.onSearchTap,
  });

  final int totalBooks;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Koleksi di Perpustakaan Ini',
            style: LuminaTextStyles.headlineSm.copyWith(
              color: LuminaColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          '$totalBooks buku',
          style: LuminaTextStyles.labelMd.copyWith(
            color: LuminaColors.onSurfaceVariant,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(width: LuminaSpacing.xs),
        Material(
          color: LuminaColors.surfaceContainerLowest,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onSearchTap,
            customBorder: const CircleBorder(),
            child: const SizedBox(
              width: 38,
              height: 38,
              child: Icon(
                Icons.search_rounded,
                color: LuminaColors.primary,
                size: 21,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LibraryBookGrid extends StatelessWidget {
  const _LibraryBookGrid({
    required this.books,
    required this.onBookTap,
  });

  final List<LibraryBookModel> books;
  final VoidCallback onBookTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = LuminaSpacing.md;
        final crossAxisCount = constraints.maxWidth >= 720 ? 3 : 2;
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
              dimUnavailableCover: true,
              availableStatusLabel: book.stockText,
              unavailableStatusLabel: book.stockText,
              onTap: onBookTap,
            );
          }).toList(),
        );
      },
    );
  }
}

