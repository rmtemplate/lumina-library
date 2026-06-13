import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';

// ══════════════════════════════════════════════════════════════════════════════
// BASE — Animated shimmer box
// ══════════════════════════════════════════════════════════════════════════════

/// Widget dasar skeleton dengan animasi shimmer sweep kiri → kanan.
class LuminaSkeleton extends StatefulWidget {
  const LuminaSkeleton({
    super.key,
    this.width,
    this.height,
    this.radius = LuminaRadius.base,
    this.child,
  });

  final double? width;
  final double? height;
  final double radius;
  final Widget? child;

  @override
  State<LuminaSkeleton> createState() => _LuminaSkeletonState();
}

class _LuminaSkeletonState extends State<LuminaSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  static const Color _base = Color(0xFFE4E6E8);
  static const Color _highlight = Color(0xFFF2F3F5);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) {
        final v = _anim.value * 3 - 1.5;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(v - 0.8, 0),
              end: Alignment(v + 0.8, 0),
              colors: const [_base, _highlight, _base],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PRE-BUILT SKELETONS
// ══════════════════════════════════════════════════════════════════════════════

// ─── Banner ───────────────────────────────────────────────────────────────────

class LuminaBannerSkeleton extends StatelessWidget {
  const LuminaBannerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2 / 1,
      child: LuminaSkeleton(radius: LuminaRadius.xl),
    );
  }
}

// ─── Branch card ──────────────────────────────────────────────────────────────

/// Meniru `_NearbyLibraryCard`. Gunakan di dalam horizontal scroll.
class LuminaBranchCardSkeleton extends StatelessWidget {
  const LuminaBranchCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 304,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto header
          LuminaSkeleton(height: 138, radius: LuminaRadius.xl),
          const SizedBox(height: LuminaSpacing.md),

          // Nama perpustakaan
          LuminaSkeleton(height: 18, radius: LuminaRadius.sm),
          const SizedBox(height: 6),

          // Alamat
          LuminaSkeleton(width: 220, height: 13, radius: LuminaRadius.sm),
          const SizedBox(height: 4),
          LuminaSkeleton(width: 160, height: 13, radius: LuminaRadius.sm),
          const SizedBox(height: LuminaSpacing.sm),

          // Info pills
          Row(children: [
            LuminaSkeleton(width: 88, height: 28, radius: LuminaRadius.full),
            const SizedBox(width: LuminaSpacing.xs),
            LuminaSkeleton(width: 108, height: 28, radius: LuminaRadius.full),
          ]),
          const SizedBox(height: LuminaSpacing.sm),

          // Status + button
          Row(children: [
            LuminaSkeleton(width: 56, height: 16, radius: LuminaRadius.sm),
            const Spacer(),
            LuminaSkeleton(width: 68, height: 30, radius: LuminaRadius.full),
          ]),
        ],
      ),
    );
  }
}

// ─── Book card ────────────────────────────────────────────────────────────────

class LuminaBookCardSkeleton extends StatelessWidget {
  const LuminaBookCardSkeleton({super.key, this.width = 160});
  final double width;

  @override
  Widget build(BuildContext context) {
    final imageHeight = width / (2 / 3);

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LuminaSkeleton(height: imageHeight, radius: LuminaRadius.xl),
          const SizedBox(height: LuminaSpacing.xs),
          LuminaSkeleton(height: 14, radius: LuminaRadius.sm),
          const SizedBox(height: 5),
          LuminaSkeleton(width: width * 0.65, height: 12, radius: LuminaRadius.sm),
          const SizedBox(height: LuminaSpacing.sm),
          LuminaSkeleton(height: 34, radius: LuminaRadius.md),
        ],
      ),
    );
  }
}

// ─── Category item ────────────────────────────────────────────────────────────

class LuminaCategoryItemSkeleton extends StatelessWidget {
  const LuminaCategoryItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LuminaSkeleton(width: 56, height: 56, radius: LuminaRadius.full),
          const SizedBox(height: LuminaSpacing.xs),
          LuminaSkeleton(width: 52, height: 11, radius: LuminaRadius.sm),
        ],
      ),
    );
  }
}

// ─── My Book card ─────────────────────────────────────────────────────────────

/// Meniru `LibraryMyBookCard` — cover samping kiri, info di kanan, progress bar bawah.
class LuminaMyBookCardSkeleton extends StatelessWidget {
  const LuminaMyBookCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE4E6E8).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
      ),
      padding: const EdgeInsets.all(LuminaSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover
              LuminaSkeleton(
                width: 72,
                height: 104,
                radius: LuminaRadius.md,
              ),
              const SizedBox(width: LuminaSpacing.md),

              // Info
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge
                    LuminaSkeleton(
                      width: 72,
                      height: 22,
                      radius: LuminaRadius.full,
                    ),
                    const SizedBox(height: LuminaSpacing.xs),
                    // Title
                    LuminaSkeleton(height: 16, radius: LuminaRadius.sm),
                    const SizedBox(height: 5),
                    LuminaSkeleton(
                      width: 120,
                      height: 13,
                      radius: LuminaRadius.sm,
                    ),
                    const SizedBox(height: LuminaSpacing.sm),
                    // Library name
                    LuminaSkeleton(
                      width: 140,
                      height: 12,
                      radius: LuminaRadius.sm,
                    ),
                    const SizedBox(height: 4),
                    // Due date
                    LuminaSkeleton(
                      width: 100,
                      height: 12,
                      radius: LuminaRadius.sm,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: LuminaSpacing.md),
          // Progress bar
          LuminaSkeleton(height: 6, radius: LuminaRadius.full),
          const SizedBox(height: LuminaSpacing.sm),
          // Detail button
          LuminaSkeleton(height: 36, radius: LuminaRadius.md),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HORIZONTAL LIST HELPERS
// ══════════════════════════════════════════════════════════════════════════════

/// Horizontal list skeleton untuk branch cards.
/// Tinggi dinamis — tidak hardcoded, mengikuti konten card.
class LuminaBranchCardSkeletonList extends StatelessWidget {
  const LuminaBranchCardSkeletonList({super.key, this.count = 3});
  final int count;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: LuminaSpacing.marginMobile,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(count, (i) => Padding(
            padding: EdgeInsets.only(
              right: i < count - 1 ? LuminaSpacing.md : 0,
            ),
            child: const LuminaBranchCardSkeleton(),
          )),
        ),
      ),
    );
  }
}

/// Horizontal list skeleton untuk book cards.
class LuminaBookCardSkeletonList extends StatelessWidget {
  const LuminaBookCardSkeletonList({
    super.key,
    this.count = 4,
    this.cardWidth = 160,
  });
  final int count;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: LuminaSpacing.marginMobile,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(count, (i) => Padding(
            padding: EdgeInsets.only(
              right: i < count - 1 ? LuminaSpacing.md : 0,
            ),
            child: LuminaBookCardSkeleton(width: cardWidth),
          )),
        ),
      ),
    );
  }
}

/// Horizontal list skeleton untuk category items.
class LuminaCategoryItemSkeletonList extends StatelessWidget {
  const LuminaCategoryItemSkeletonList({super.key, this.count = 6});
  final int count;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: LuminaSpacing.marginMobile,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(count, (i) => Padding(
            padding: EdgeInsets.only(
              right: i < count - 1 ? LuminaSpacing.md : 0,
            ),
            child: const LuminaCategoryItemSkeleton(),
          )),
        ),
      ),
    );
  }
}

/// Vertical list skeleton untuk my books.
class LuminaMyBookCardSkeletonList extends StatelessWidget {
  const LuminaMyBookCardSkeletonList({super.key, this.count = 3});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) => Padding(
        padding: EdgeInsets.only(
          bottom: i < count - 1 ? LuminaSpacing.md : 0,
        ),
        child: const LuminaMyBookCardSkeleton(),
      )),
    );
  }
}

/// Skeleton untuk halaman Cart — satu item keranjang per baris.
class LuminaCartItemSkeleton extends StatelessWidget {
  const LuminaCartItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LuminaSkeleton(
            width: 48,
            height: 64,
            radius: LuminaRadius.md,
          ),
          const SizedBox(width: LuminaSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                LuminaSkeleton(width: double.infinity, height: 14, radius: LuminaRadius.sm),
                SizedBox(height: 6),
                LuminaSkeleton(width: 140, height: 12, radius: LuminaRadius.sm),
                SizedBox(height: 6),
                LuminaSkeleton(width: 100, height: 11, radius: LuminaRadius.sm),
              ],
            ),
          ),
          const SizedBox(width: LuminaSpacing.sm),
          const LuminaSkeleton(width: 28, height: 28, radius: LuminaRadius.sm),
        ],
      ),
    );
  }
}

/// Skeleton lengkap untuk halaman Cart (header grup + beberapa item).
class LuminaCartSkeleton extends StatelessWidget {
  const LuminaCartSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        LuminaSpacing.marginMobile,
        LuminaSpacing.md,
        LuminaSpacing.marginMobile,
        LuminaSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group card 1
          _CartGroupSkeleton(itemCount: 2),
          const SizedBox(height: LuminaSpacing.lg),
          // Group card 2
          _CartGroupSkeleton(itemCount: 1),
        ],
      ),
    );
  }
}

class _CartGroupSkeleton extends StatelessWidget {
  const _CartGroupSkeleton({required this.itemCount});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        border: Border.all(color: LuminaColors.surfaceVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(LuminaSpacing.sm),
            color: LuminaColors.surfaceContainerLow,
            child: Row(
              children: const [
                LuminaSkeleton(width: 24, height: 24, radius: LuminaRadius.sm),
                SizedBox(width: LuminaSpacing.sm),
                LuminaSkeleton(width: 38, height: 38, radius: LuminaRadius.md),
                SizedBox(width: LuminaSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LuminaSkeleton(width: double.infinity, height: 14, radius: LuminaRadius.sm),
                      SizedBox(height: 5),
                      LuminaSkeleton(width: 100, height: 11, radius: LuminaRadius.sm),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Items
          for (int i = 0; i < itemCount; i++) ...[
            if (i > 0) const Divider(height: 1, color: LuminaColors.surfaceVariant),
            const LuminaCartItemSkeleton(),
          ],
        ],
      ),
    );
  }
}

/// Skeleton grid untuk halaman Catalog — 2 kolom, mirip layout buku aslinya.
class LuminaCatalogBookGridSkeleton extends StatelessWidget {
  const LuminaCatalogBookGridSkeleton({super.key, this.count = 6});
  final int count;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 680 ? 3 : 2;
        const spacing = LuminaSpacing.md;
        final cardWidth =
            (constraints.maxWidth - ((crossAxisCount - 1) * spacing)) /
                crossAxisCount;
        final imageHeight = cardWidth / (2 / 3);

        return Wrap(
          spacing: spacing,
          runSpacing: spacing + 8,
          children: List.generate(count, (_) {
            return SizedBox(
              width: cardWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LuminaSkeleton(height: imageHeight, radius: LuminaRadius.xl),
                  const SizedBox(height: LuminaSpacing.xs),
                  LuminaSkeleton(height: 14, radius: LuminaRadius.sm),
                  const SizedBox(height: 5),
                  LuminaSkeleton(
                    width: cardWidth * 0.65,
                    height: 12,
                    radius: LuminaRadius.sm,
                  ),
                  const SizedBox(height: LuminaSpacing.xs),
                  LuminaSkeleton(
                    width: cardWidth * 0.45,
                    height: 11,
                    radius: LuminaRadius.sm,
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
