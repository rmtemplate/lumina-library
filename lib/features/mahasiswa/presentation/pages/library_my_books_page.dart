import 'package:flutter/material.dart';

import '../../../../core/theme/lumina_colors.dart';
import '../../../../core/theme/lumina_radius.dart';
import '../../../../core/theme/lumina_spacing.dart';
import '../../../../core/theme/lumina_text_styles.dart';
import '../widgets/library_app_top_bar.dart';
import '../widgets/library_my_book_card.dart';
import '../widgets/library_stat_card.dart';

class LibraryMyBooksPage extends StatefulWidget {
  const LibraryMyBooksPage({super.key});

  @override
  State<LibraryMyBooksPage> createState() => _LibraryMyBooksPageState();
}

class _LibraryMyBooksPageState extends State<LibraryMyBooksPage> {
  int _selectedFilterIndex = 0;

  final List<String> _filters = const [
    'Semua',
    'Aktif',
    'Segera Kembali',
    'Selesai',
  ];

  final List<_MyBookItem> _books = const [
    _MyBookItem(
      title: 'Modern UX Design',
      author: 'Alicia Hart',
      dueDate: 'Jatuh tempo: 2 hari lagi',
      progress: 0.82,
      status: LibraryMyBookStatus.dueSoon,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAzpmqkX7zqHxIffZ3d25pq1X0JZ36S4TdlP5S_lziXjjh2fnLIBwyAtQgksQ_Nwm-Hfa8PcMVjqFuezchn1dMKEXAzbWz0TVhFj08xJ02GyhWZHLO9HRed1fqWekOtGU82Z0xC6Tr6YKrUiyJ3AGUYHUyr_j0zzjlevLyx3quxeacgbENLWHPvVLMZbuP31umrxALb9UNCd3NNlBdPr4Kd8YLauEHyyO0UEkY6YstIZXHoPsGzbF_ILS2AOoJfRyn-IOncMLCHvV7K',
    ),
    _MyBookItem(
      title: 'Clean Architecture',
      author: 'Robert C. Martin',
      dueDate: 'Jatuh tempo: 8 hari lagi',
      progress: 0.48,
      status: LibraryMyBookStatus.active,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAuLblMAj5-Sc853TMVBkmebmIs-PlqkXA2dmSvr6np_PuAApRlgf0J9jxiwcJG-BsSUs9oKsn9ksyb3dfmzQtUydS6lc_1Emw_aOukz22O2jzIOC5ET0JGAZPFPxzTDSKEO6OxtFcm8Y1QzTh_5wPP2qQnP16DxscNnWv0X2BEi3lbQy24UysKZ_Nlcp3o9laV40glwhEHh3O_B_WOOlWdZaJyeJ0CcHF3IAk6jCbHn4pSCtzT110s7C5aIff8AVMeosutYK3qGFaj',
    ),
    _MyBookItem(
      title: 'Sapiens',
      author: 'Yuval Noah Harari',
      dueDate: 'Selesai dibaca',
      progress: 1,
      status: LibraryMyBookStatus.finished,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAOGdF3QY5G89jhgdZoszYTVtgwR3oxR_MjOcbuc9zoWw-ykYzpq2GdDFwhRsEmV6I6fcwVxAKt3mlKBT8EzWVNGGm3Oa33rYDpFZstTXu_npFRx8Nu7h8b_mqoxj66VbH6Jf8JfD6LCfAdFF0nR8LonDJqbUPoGhwdZhDjlXMbFuZqCvC6KZy6AtDhrCu-vgkdYnqpqsXXy4gAgNc54k6dPS7OsMAZuIdjGaslY26YvCIMaaWv4nK6tkq3NoRi6meFwbrhSHY_t2w8',
    ),
  ];

  List<_MyBookItem> get _filteredBooks {
    final selectedFilter = _filters[_selectedFilterIndex];

    if (selectedFilter == 'Semua') return _books;

    return _books.where((book) {
      switch (selectedFilter) {
        case 'Aktif':
          return book.status == LibraryMyBookStatus.active;
        case 'Segera Kembali':
          return book.status == LibraryMyBookStatus.dueSoon ||
              book.status == LibraryMyBookStatus.overdue;
        case 'Selesai':
          return book.status == LibraryMyBookStatus.finished;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final books = _filteredBooks;

    return ColoredBox(
      color: LuminaColors.background,
      child: Column(
        children: [
          const LibraryAppTopBar(
            title: 'My Books',
            subtitle: 'Koleksi pinjaman aktif',
            avatarUrl:
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCOUvcuhrVPW6TDnxzNftePyL0xi1fH6OHV95Beg7esW1M8wRZHjjluoHNyTYsyVEx3LlwkFgVb2suvjzCHdemAv58quy6z7cc8uMRhTRevRE0rbj51KvFcN4ZZd6xWa6Odx4WumnhYO5FLvVYdMGKtO1ykNBXlGxV2SbT-j2Nyx2hVUPL-oJby1mBJ-CHLEdb1cX2ggVN9SzR2BOY9CbuOGWrA3pS8SbSbQwjNBXDXFtHRwypfMetx7orjLK5lNqtleuJlOU45Ggqa',
            showNotificationDot: true,
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                LuminaSpacing.marginMobile,
                LuminaSpacing.lg,
                LuminaSpacing.marginMobile,
                LuminaSpacing.lg,
              ),
              children: [
                const SizedBox(height: LuminaSpacing.lg),
                _MyBooksReminderCard(
                  onTap: () {},
                ),
                const SizedBox(height: LuminaSpacing.lg),
                _MyBooksFilterBar(
                  filters: _filters,
                  selectedIndex: _selectedFilterIndex,
                  onChanged: (index) {
                    setState(() => _selectedFilterIndex = index);
                  },
                ),
                const SizedBox(height: LuminaSpacing.md),
                if (books.isEmpty)
                  const _MyBooksEmptyState()
                else
                  ...List.generate(books.length, (index) {
                    final item = books[index];

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == books.length - 1 ? 0 : LuminaSpacing.md,
                      ),
                      child: LibraryMyBookCard(
                        title: item.title,
                        author: item.author,
                        imageUrl: item.imageUrl,
                        dueDate: item.dueDate,
                        progress: item.progress,
                        status: item.status,
                        onTap: () {},
                        onReadTap: () {},
                        onRenewTap: () {},
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MyBooksStats extends StatelessWidget {
  const _MyBooksStats();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: LibraryStatCard(
            icon: Icons.book_online_rounded,
            value: '3',
            label: 'Aktif',
            iconBackgroundColor: LuminaColors.secondaryContainer,
            iconColor: LuminaColors.onSecondaryContainer,
          ),
        ),
        SizedBox(width: LuminaSpacing.md),
        Expanded(
          child: LibraryStatCard(
            icon: Icons.schedule_rounded,
            value: '1',
            label: 'Segera Kembali',
            iconBackgroundColor: LuminaColors.tertiaryFixed,
            iconColor: LuminaColors.onTertiaryFixedVariant,
          ),
        ),
        SizedBox(width: LuminaSpacing.md),
        Expanded(
          child: LibraryStatCard(
            icon: Icons.done_all_rounded,
            value: '12',
            label: 'Selesai',
            iconBackgroundColor: LuminaColors.primaryFixed,
            iconColor: LuminaColors.onPrimaryFixed,
          ),
        ),
      ],
    );
  }
}

class _MyBooksReminderCard extends StatelessWidget {
  const _MyBooksReminderCard({
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.tertiaryContainer,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        boxShadow: [
          BoxShadow(
            color: LuminaColors.tertiaryContainer.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: LuminaColors.onTertiary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: LuminaColors.inversePrimary,
            ),
          ),
          const SizedBox(width: LuminaSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengingat Pengembalian',
                  style: LuminaTextStyles.bodyMd.copyWith(
                    color: LuminaColors.onTertiary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Buku 'Modern UX Design' harus dikembalikan dalam 2 hari.",
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: LuminaColors.inversePrimary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: LuminaSpacing.sm),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              backgroundColor: LuminaColors.onTertiary,
              foregroundColor: LuminaColors.tertiaryContainer,
              padding: const EdgeInsets.symmetric(
                horizontal: LuminaSpacing.md,
                vertical: LuminaSpacing.xs,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(LuminaRadius.full),
              ),
            ),
            child: Text(
              'Detail',
              style: LuminaTextStyles.labelMd.copyWith(
                color: LuminaColors.tertiaryContainer,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyBooksFilterBar extends StatelessWidget {
  const _MyBooksFilterBar({
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
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: LuminaSpacing.sm),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;

          return InkWell(
            onTap: () => onChanged(index),
            borderRadius: BorderRadius.circular(LuminaRadius.full),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
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
              child: Center(
                child: Text(
                  filters[index],
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: isSelected
                        ? LuminaColors.onPrimary
                        : LuminaColors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MyBooksEmptyState extends StatelessWidget {
  const _MyBooksEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Icons.library_books_rounded,
              color: LuminaColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: LuminaSpacing.md),
          Text(
            'Tidak ada buku',
            style: LuminaTextStyles.titleLg.copyWith(
              color: LuminaColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: LuminaSpacing.xs),
          Text(
            'Belum ada buku dalam kategori ini.',
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

class _MyBookItem {
  const _MyBookItem({
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.dueDate,
    required this.progress,
    required this.status,
  });

  final String title;
  final String author;
  final String imageUrl;
  final String dueDate;
  final double progress;
  final LibraryMyBookStatus status;
}
