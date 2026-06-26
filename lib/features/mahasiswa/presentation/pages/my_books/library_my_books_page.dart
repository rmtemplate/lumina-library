import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/my_books/library_my_books_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/pages/my_books/library_my_book_detail_page.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/layout/library_app_top_bar.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/layout/library_stat_card.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/my_books/library_my_book_card.dart';
import 'package:lumina_library/shared/models/book/library_my_book_item_model.dart';
import 'package:lumina_library/shared/widgets/skeleton/lumina_skeleton.dart';

class LibraryMyBooksPage extends StatefulWidget {
  const LibraryMyBooksPage({super.key});

  @override
  State<LibraryMyBooksPage> createState() => _LibraryMyBooksPageState();
}

class _LibraryMyBooksPageState extends State<LibraryMyBooksPage> {
  late final ScrollController _scrollController;

  LibraryMyBooksController get controller =>
      Get.isRegistered<LibraryMyBooksController>()
          ? Get.find<LibraryMyBooksController>()
          : Get.put(LibraryMyBooksController());

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Trigger load more ketika user scroll ≥80% dari total konten.
  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent * 0.8) {
      controller.loadMore();
    }
  }

  void _goToDetail(LibraryMyBookItemModel book) {
    Get.to(
      () => LibraryMyBookDetailPage(book: book),
      transition: Transition.cupertino,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return ColoredBox(
      color: LuminaColors.background,
      child: Column(
        children: [
          const LibraryAppTopBar(
            title: 'My Books',
            subtitle: 'Track your active book loans',
            avatarUrl:
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCOUvcuhrVPW6TDnxzNftePyL0xi1fH6OHV95Beg7esW1M8wRZHjjluoHNyTYsyVEx3LlwkFgVb2suvjzCHdemAv58quy6z7cc8uMRhTRevRE0rbj51KvFcN4ZZd6xWa6Odx4WumnhYO5FLvVYdMGKtO1ykNBXlGxV2SbT-j2Nyx2hVUPL-oJby1mBJ-CHLEdb1cX2ggVN9SzR2BOY9CbuOGWrA3pS8SbSbQwjNBXDXFtHRwypfMetx7orjLK5lNqtleuJlOU45Ggqa',
            showNotificationDot: true,
          ),

          Expanded(
            child: Obx(() {
              // ── Initial loading — tampilkan skeleton penuh ─────────────
              if (c.isInitialLoading.value) {
                return const _MyBooksSkeleton();
              }

              // ── Refresh + data ─────────────────────────────────────────
              return RefreshIndicator(
                color: LuminaColors.secondary,
                backgroundColor: LuminaColors.surfaceContainerLowest,
                onRefresh: c.refresh,
                child: Obx(() {
                  final books = c.filteredBooks;
                  final reminderBook = c.priorityReminderBook;

                  return ListView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(
                      LuminaSpacing.marginMobile,
                      LuminaSpacing.lg,
                      LuminaSpacing.marginMobile,
                      LuminaSpacing.lg,
                    ),
                    children: [
                      // Stats
                      _MyBooksStats(
                        activeCount: c.activeCount,
                        dueSoonCount: c.dueSoonCount,
                        overdueCount: c.overdueCount,
                      ),

                      // Reminder card
                      if (reminderBook != null) ...[
                        const SizedBox(height: LuminaSpacing.lg),
                        _MyBooksReminderCard(
                          book: reminderBook,
                          onTap: () => _goToDetail(reminderBook),
                        ),
                      ],

                      const SizedBox(height: LuminaSpacing.lg),

                      // Filter bar
                      _MyBooksFilterBar(
                        filters: c.filters,
                        selectedIndex: c.selectedFilterIndex.value,
                        onChanged: c.setFilterIndex,
                      ),

                      const SizedBox(height: LuminaSpacing.md),

                      // Book list
                      if (books.isEmpty && !c.isLoadingMore.value && !c.isRefreshing.value)
                        const _MyBooksEmptyState()
                      else
                        ...books.asMap().entries.map((e) {
                          final index = e.key;
                          final book = e.value;
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == books.length - 1 &&
                                      !c.isLoadingMore.value &&
                                      !c.hasMore.value
                                  ? 0
                                  : LuminaSpacing.md,
                            ),
                            child: LibraryMyBookCard(
                              book: book,
                              onTap: () => _goToDetail(book),
                              onDetailTap: () => _goToDetail(book),
                            ),
                          );
                        }),

                      // Load more skeleton
                      if (c.isLoadingMore.value) ...[
                        const SizedBox(height: LuminaSpacing.md),
                        const LuminaMyBookCardSkeleton(),
                      ],

                      // End of list indicator
                      if (!c.hasMore.value && books.isNotEmpty)
                        const _EndOfListLabel(),
                    ],
                  );
                }),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Full skeleton on initial load ───────────────────────────────────────────

class _MyBooksSkeleton extends StatelessWidget {
  const _MyBooksSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        LuminaSpacing.marginMobile,
        LuminaSpacing.lg,
        LuminaSpacing.marginMobile,
        LuminaSpacing.lg,
      ),
      children: [
        // Stats row skeleton
        Row(
          children: List.generate(3, (i) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < 2 ? LuminaSpacing.md : 0),
              child: const LuminaSkeleton(height: 76, radius: LuminaRadius.xl),
            ),
          )),
        ),
        const SizedBox(height: LuminaSpacing.lg),

        // Filter bar skeleton
        Row(
          children: List.generate(5, (i) => Padding(
            padding: EdgeInsets.only(right: i < 4 ? LuminaSpacing.sm : 0),
            child: const LuminaSkeleton(
              width: 64,
              height: 36,
              radius: LuminaRadius.full,
            ),
          )),
        ),
        const SizedBox(height: LuminaSpacing.md),

        // Book card skeletons
        const LuminaMyBookCardSkeletonList(count: 3),
      ],
    );
  }
}

// ─── Stats ────────────────────────────────────────────────────────────────────

class _MyBooksStats extends StatelessWidget {
  const _MyBooksStats({
    required this.activeCount,
    required this.dueSoonCount,
    required this.overdueCount,
  });

  final int activeCount;
  final int dueSoonCount;
  final int overdueCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LibraryStatCard(
            icon: Icons.book_rounded,
            value: '$activeCount',
            label: 'Active',
            iconBackgroundColor: LuminaColors.secondaryContainer,
            iconColor: LuminaColors.onSecondaryContainer,
          ),
        ),
        const SizedBox(width: LuminaSpacing.md),
        Expanded(
          child: LibraryStatCard(
            icon: Icons.schedule_rounded,
            value: '$dueSoonCount',
            label: 'Due Soon',
            iconBackgroundColor: LuminaColors.tertiaryFixed,
            iconColor: LuminaColors.onTertiaryFixedVariant,
          ),
        ),
        const SizedBox(width: LuminaSpacing.md),
        Expanded(
          child: LibraryStatCard(
            icon: Icons.warning_rounded,
            value: '$overdueCount',
            label: 'Overdue',
            iconBackgroundColor: LuminaColors.errorContainer,
            iconColor: LuminaColors.error,
          ),
        ),
      ],
    );
  }
}

// ─── Reminder card ────────────────────────────────────────────────────────────

class _MyBooksReminderCard extends StatelessWidget {
  const _MyBooksReminderCard({required this.book, this.onTap});

  final LibraryMyBookItemModel book;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isOverdue = book.status == LibraryMyBookStatus.overdue;

    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: isOverdue
            ? LuminaColors.errorContainer
            : LuminaColors.tertiaryContainer,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (isOverdue ? LuminaColors.error : LuminaColors.onTertiary)
                  .withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOverdue
                  ? Icons.warning_amber_rounded
                  : Icons.notifications_active_rounded,
              color: isOverdue
                  ? LuminaColors.error
                  : LuminaColors.inversePrimary,
            ),
          ),
          const SizedBox(width: LuminaSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOverdue ? 'Overdue Loan' : 'Return Reminder',
                  style: LuminaTextStyles.bodyMd.copyWith(
                    color: isOverdue
                        ? LuminaColors.onErrorContainer
                        : LuminaColors.onTertiary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isOverdue
                      ? "'${book.title}' is ${book.overdueDays} days overdue. Fine: ${book.fineAmountText}."
                      : "'${book.title}' is due in ${book.remainingDays} days.",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: isOverdue
                        ? LuminaColors.onErrorContainer
                        : LuminaColors.inversePrimary,
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
              backgroundColor:
                  isOverdue ? LuminaColors.error : LuminaColors.onTertiary,
              foregroundColor: isOverdue
                  ? LuminaColors.onError
                  : LuminaColors.tertiaryContainer,
              padding: const EdgeInsets.symmetric(
                horizontal: LuminaSpacing.md,
                vertical: LuminaSpacing.xs,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(LuminaRadius.full),
              ),
            ),
            child: Text(
              'Details',
              style: LuminaTextStyles.labelMd.copyWith(
                color: isOverdue
                    ? LuminaColors.onError
                    : LuminaColors.tertiaryContainer,
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

// ─── Filter bar ───────────────────────────────────────────────────────────────

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
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: LuminaSpacing.sm),
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

// ─── Empty state ──────────────────────────────────────────────────────────────

class _MyBooksEmptyState extends StatelessWidget {
  const _MyBooksEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.xl),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(color: LuminaColors.surfaceVariant),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: LuminaColors.primary.withValues(alpha: 0.08),
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
            'No Books Found',
            style: LuminaTextStyles.titleLg.copyWith(
              color: LuminaColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: LuminaSpacing.xs),
          Text(
            'There are no loans in this category yet.',
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

// ─── End of list ──────────────────────────────────────────────────────────────

class _EndOfListLabel extends StatelessWidget {
  const _EndOfListLabel();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LuminaSpacing.md),
      child: Center(
        child: Text(
          '— Semua data sudah ditampilkan —',
          style: LuminaTextStyles.labelMd.copyWith(
            color: LuminaColors.outline,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
