import 'package:flutter/material.dart';
import 'package:lumina_library/features/staff/presentation/models/rack_management_models.dart';

import '../../../../../core/theme/lumina_colors.dart';
import '../../../../../core/theme/lumina_radius.dart';
import '../../../../../core/theme/lumina_spacing.dart';
import '../../../../../core/theme/lumina_text_styles.dart';

class RackTopAppBar extends StatelessWidget {
  const RackTopAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon = Icons.arrow_back_rounded,
    this.trailingIcon,
    this.onLeadingTap,
    this.onTrailingTap,
    this.showSearch = false,
    this.searchController,
    this.searchHintText = 'Cari rak, kode, lantai, area...',
    this.onSearchChanged,
    this.onSearchClear,
  });

  final String title;
  final String? subtitle;
  final IconData leadingIcon;
  final IconData? trailingIcon;
  final VoidCallback? onLeadingTap;
  final VoidCallback? onTrailingTap;

  final bool showSearch;
  final TextEditingController? searchController;
  final String searchHintText;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LuminaColors.surface,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              LuminaSpacing.marginMobile,
              0,
              LuminaSpacing.marginMobile,
              LuminaSpacing.sm,
            ),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: LuminaColors.surfaceVariant,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 62,
                  child: Row(
                    children: [
                      _RackCircleButton(
                        icon: leadingIcon,
                        onTap: onLeadingTap,
                      ),
                      const SizedBox(width: LuminaSpacing.sm),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: LuminaTextStyles.headlineSm.copyWith(
                                color: LuminaColors.primary,
                                fontWeight: FontWeight.w900,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            if (subtitle != null &&
                                subtitle!.trim().isNotEmpty) ...[
                              const SizedBox(height: 1),
                              Text(
                                subtitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: LuminaTextStyles.labelMd.copyWith(
                                  color: LuminaColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (trailingIcon != null)
                        _RackCircleButton(
                          icon: trailingIcon!,
                          onTap: onTrailingTap,
                        )
                      else
                        const SizedBox(width: 40),
                    ],
                  ),
                ),

                if (showSearch) ...[
                  const SizedBox(height: 4),
                  RackAppBarSearchField(
                    controller: searchController,
                    hintText: searchHintText,
                    onChanged: onSearchChanged,
                    onClearTap: onSearchClear,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RackAppBarSearchField extends StatelessWidget {
  const RackAppBarSearchField({
    super.key,
    this.controller,
    required this.hintText,
    this.onChanged,
    this.onClearTap,
  });

  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClearTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        cursorColor: LuminaColors.primary,
        textAlignVertical: TextAlignVertical.center,
        style: LuminaTextStyles.bodyMd.copyWith(
          color: LuminaColors.onSurface,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.none,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: hintText,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: LuminaColors.onSurfaceVariant,
            size: 21,
          ),
          suffixIcon: controller == null
              ? null
              : ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller!,
                  builder: (context, value, _) {
                    if (value.text.trim().isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return IconButton(
                      onPressed: onClearTap,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: LuminaColors.onSurfaceVariant,
                        size: 20,
                      ),
                    );
                  },
                ),
          filled: true,
          fillColor: LuminaColors.surfaceContainerLow,
          hintStyle: LuminaTextStyles.bodyMd.copyWith(
            color: LuminaColors.outline,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: LuminaSpacing.sm,
            vertical: 0,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(LuminaRadius.full),
            borderSide: const BorderSide(
              color: LuminaColors.surfaceVariant,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(LuminaRadius.full),
            borderSide: const BorderSide(
              color: LuminaColors.primary,
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class SelectionAppBar extends StatelessWidget {
  const SelectionAppBar({
    super.key,
    required this.selectedCount,
    required this.onCloseTap,
    required this.onSelectAllTap,
  });

  final int selectedCount;
  final VoidCallback onCloseTap;
  final VoidCallback onSelectAllTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LuminaColors.primary,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(
            horizontal: LuminaSpacing.marginMobile,
          ),
          child: Row(
            children: [
              _RackCircleButton(
                icon: Icons.close_rounded,
                iconColor: LuminaColors.onPrimary,
                onTap: onCloseTap,
              ),
              const SizedBox(width: LuminaSpacing.sm),
              Expanded(
                child: Text(
                  '$selectedCount buku dipilih',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LuminaTextStyles.headlineSm.copyWith(
                    color: LuminaColors.onPrimary,
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              TextButton(
                onPressed: onSelectAllTap,
                child: Text(
                  'Pilih Semua',
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: LuminaColors.onPrimary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                    decoration: TextDecoration.none,
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

class _RackCircleButton extends StatelessWidget {
  const _RackCircleButton({
    required this.icon,
    this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final Color? iconColor;
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
            color: iconColor ?? LuminaColors.onSurfaceVariant,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class RackCard extends StatelessWidget {
  const RackCard({
    super.key,
    required this.rack,
    this.onTap,
  });

  final RackModel rack;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final progressColor = rack.isFull ? LuminaColors.error : LuminaColors.secondary;
    final statusBackground = rack.isFull
        ? LuminaColors.errorContainer
        : LuminaColors.secondary.withOpacity(0.10);
    final statusForeground = rack.isFull
        ? LuminaColors.onErrorContainer
        : LuminaColors.secondary;

    return Material(
      color: LuminaColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(LuminaSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: rack.isFull
                  ? LuminaColors.error.withOpacity(0.18)
                  : LuminaColors.outlineVariant.withOpacity(0.34),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RackCoverStack(
                covers: rack.previewCovers,
                isFull: rack.isFull,
              ),
              const SizedBox(width: LuminaSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: LuminaSpacing.xs,
                      runSpacing: LuminaSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        RackCodeBadge(
                          rackCode: rack.rackCode,
                          isBasement: rack.isBasement,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: LuminaSpacing.xs,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: statusBackground,
                            borderRadius: BorderRadius.circular(
                              LuminaRadius.full,
                            ),
                          ),
                          child: Text(
                            rack.capacityText,
                            style: LuminaTextStyles.labelMd.copyWith(
                              color: statusForeground,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: LuminaSpacing.sm),
                    Text(
                      rack.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LuminaTextStyles.titleLg.copyWith(
                        color: LuminaColors.primary,
                        fontWeight: FontWeight.w900,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      rack.sectionName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LuminaTextStyles.bodyMd.copyWith(
                        color: LuminaColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: LuminaSpacing.sm),
                    RackLocationInfo(
                      floorLabel: rack.floorLabel,
                      areaLabel: rack.areaLabel,
                      aisleCode: rack.aisleCode,
                      isBasement: rack.isBasement,
                    ),
                    const SizedBox(height: LuminaSpacing.sm),
                    RackCapacityBar(
                      value: rack.capacityPercentage,
                      color: progressColor,
                      label: '${rack.bookCount}/${rack.capacity} buku',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: LuminaSpacing.sm),
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: LuminaColors.outline,
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RackCodeBadge extends StatelessWidget {
  const RackCodeBadge({
    super.key,
    required this.rackCode,
    this.isBasement = false,
  });

  final String rackCode;
  final bool isBasement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.xs,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: isBasement
            ? LuminaColors.primary.withOpacity(0.08)
            : LuminaColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(LuminaRadius.full),
        border: Border.all(
          color: isBasement
              ? LuminaColors.primary.withOpacity(0.16)
              : LuminaColors.surfaceVariant,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isBasement ? Icons.layers_rounded : Icons.tag_rounded,
            color: LuminaColors.primary,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            rackCode,
            style: LuminaTextStyles.labelMd.copyWith(
              color: LuminaColors.primary,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

class RackLocationInfo extends StatelessWidget {
  const RackLocationInfo({
    super.key,
    required this.floorLabel,
    required this.areaLabel,
    required this.aisleCode,
    this.isBasement = false,
  });

  final String floorLabel;
  final String areaLabel;
  final String aisleCode;
  final bool isBasement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.sm),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLow.withOpacity(0.72),
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
        border: Border.all(
          color: LuminaColors.surfaceVariant,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isBasement
                  ? LuminaColors.primary.withOpacity(0.08)
                  : LuminaColors.secondary.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isBasement ? Icons.stairs_rounded : Icons.location_on_rounded,
              color: isBasement ? LuminaColors.primary : LuminaColors.secondary,
              size: 18,
            ),
          ),
          const SizedBox(width: LuminaSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$floorLabel • $aisleCode',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: LuminaColors.onSurface,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  areaLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: LuminaColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                    decoration: TextDecoration.none,
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

class RackCapacityBar extends StatelessWidget {
  const RackCapacityBar({
    super.key,
    required this.value,
    required this.color,
    required this.label,
  });

  final double value;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final safeValue = value < 0
        ? 0.0
        : value > 1
            ? 1.0
            : value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(LuminaRadius.full),
          child: LinearProgressIndicator(
            value: safeValue,
            minHeight: 6,
            backgroundColor: LuminaColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: LuminaTextStyles.labelMd.copyWith(
            color: LuminaColors.outline,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}

class RackCoverStack extends StatelessWidget {
  const RackCoverStack({
    super.key,
    required this.covers,
    this.isFull = false,
  });

  final List<String> covers;
  final bool isFull;

  @override
  Widget build(BuildContext context) {
    if (covers.isEmpty) {
      return Container(
        width: 76,
        height: 104,
        decoration: BoxDecoration(
          color: LuminaColors.surfaceContainer,
          borderRadius: BorderRadius.circular(LuminaRadius.lg),
          border: Border.all(
            color: LuminaColors.surfaceVariant,
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.inventory_2_outlined,
          color: LuminaColors.primary,
          size: 34,
        ),
      );
    }

    return SizedBox(
      width: 82,
      height: 104,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ...List.generate(covers.length.clamp(0, 3), (index) {
            final left = index * 11.0;
            final top = index * 5.0;

            return Positioned(
              left: left,
              top: top,
              child: Container(
                width: 54,
                height: 86,
                decoration: BoxDecoration(
                  color: LuminaColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(LuminaRadius.md),
                  border: Border.all(
                    color: LuminaColors.surfaceContainerLowest,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  covers[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return const Icon(
                      Icons.menu_book_rounded,
                      color: LuminaColors.primary,
                    );
                  },
                ),
              ),
            );
          }).reversed,
          if (isFull)
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: LuminaColors.error,
                  borderRadius: BorderRadius.circular(LuminaRadius.full),
                ),
                child: Text(
                  'FULL',
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: LuminaColors.onError,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 0,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LuminaSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                color: LuminaColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: LuminaColors.outline,
                size: 38,
              ),
            ),
            const SizedBox(height: LuminaSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: LuminaTextStyles.titleLg.copyWith(
                color: LuminaColors.primary,
                fontWeight: FontWeight.w900,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: LuminaSpacing.xs),
            Text(
              description,
              textAlign: TextAlign.center,
              style: LuminaTextStyles.bodyMd.copyWith(
                color: LuminaColors.onSurfaceVariant,
                height: 1.45,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.isSelectionMode,
    required this.isSelected,
    this.onTap,
    this.onLongPress,
  });

  final BookModel book;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? LuminaColors.primary
        : LuminaColors.outlineVariant.withOpacity(0.34);

    final backgroundColor = isSelected
        ? LuminaColors.primary.withOpacity(0.055)
        : LuminaColors.surfaceContainerLowest;

    final shadowColor = isSelected
        ? LuminaColors.primary.withOpacity(0.22)
        : Colors.black.withOpacity(0.04);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      opacity: isSelectionMode && !isSelected ? 0.62 : 1,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        scale: isSelected ? 0.965 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: isSelected ? 28 : 18,
                offset: Offset(0, isSelected ? 12 : 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(LuminaSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: LuminaColors.surfaceContainer,
                                  borderRadius: BorderRadius.circular(
                                    LuminaRadius.lg,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image.network(
                                  book.cover,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return const Center(
                                      child: Icon(
                                        Icons.menu_book_rounded,
                                        color: LuminaColors.primary,
                                      ),
                                    );
                                  },
                                ),
                              ),

                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 180),
                                opacity: isSelected ? 1 : 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: LuminaColors.primary.withOpacity(0.42),
                                    borderRadius: BorderRadius.circular(
                                      LuminaRadius.lg,
                                    ),
                                  ),
                                ),
                              ),

                              if (isSelected)
                                Center(
                                  child: Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: LuminaColors.surfaceContainerLowest,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.16),
                                          blurRadius: 18,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      color: LuminaColors.primary,
                                      size: 34,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: LuminaSpacing.sm),

                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: LuminaTextStyles.bodyMd.copyWith(
                            color: isSelected
                                ? LuminaColors.primary
                                : LuminaColors.onSurface,
                            fontWeight: FontWeight.w900,
                            height: 1.25,
                            decoration: TextDecoration.none,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          book.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: LuminaTextStyles.labelMd.copyWith(
                            color: LuminaColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                            decoration: TextDecoration.none,
                          ),
                        ),

                        if (book.catalogCode != null &&
                            book.catalogCode!.trim().isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.qr_code_2_rounded,
                                size: 14,
                                color: isSelected
                                    ? LuminaColors.primary
                                    : LuminaColors.outline,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  book.catalogCode!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: LuminaTextStyles.labelMd.copyWith(
                                    color: isSelected
                                        ? LuminaColors.primary
                                        : LuminaColors.outline,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  Positioned(
                    top: 10,
                    right: 10,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutBack,
                      scale: isSelectionMode ? 1 : 0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: isSelectionMode ? 1 : 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? LuminaColors.primary
                                : LuminaColors.surfaceContainerLowest,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? LuminaColors.primary
                                  : LuminaColors.outlineVariant,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            isSelected
                                ? Icons.check_rounded
                                : Icons.circle_outlined,
                            color: isSelected
                                ? LuminaColors.onPrimary
                                : LuminaColors.outline,
                            size: 19,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    left: 10,
                    top: 10,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: isSelected ? 1 : 0,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: LuminaColors.primary,
                            borderRadius: BorderRadius.circular(
                              LuminaRadius.full,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: LuminaColors.primary.withOpacity(0.24),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Text(
                            'DIPILIH',
                            style: LuminaTextStyles.labelMd.copyWith(
                              color: LuminaColors.onPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomFloatingButton extends StatelessWidget {
  const CustomFloatingButton({
    super.key,
    required this.visible,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final bool visible;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      scale: visible ? 1 : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: visible ? 1 : 0,
        child: FloatingActionButton.extended(
          onPressed: visible ? onTap : null,
          backgroundColor: LuminaColors.secondary,
          foregroundColor: LuminaColors.onSecondary,
          elevation: 8,
          icon: Icon(icon),
          label: Text(
            label,
            style: LuminaTextStyles.titleLg.copyWith(
              color: LuminaColors.onSecondary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class MoveRackTile extends StatelessWidget {
  const MoveRackTile({
    super.key,
    required this.rack,
    required this.isSelected,
    this.disabled = false,
    this.onTap,
  });

  final RackModel rack;
  final bool isSelected;
  final bool disabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: Material(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(LuminaRadius.xl),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(LuminaSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(LuminaRadius.xl),
              border: Border.all(
                color: isSelected
                    ? LuminaColors.primary
                    : LuminaColors.surfaceVariant,
                width: isSelected ? 1.6 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? LuminaColors.primary.withOpacity(0.12)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? LuminaColors.primary
                        : LuminaColors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSelected
                        ? Icons.check_rounded
                        : Icons.inventory_2_rounded,
                    color: isSelected
                        ? LuminaColors.onPrimary
                        : LuminaColors.primary,
                    size: 23,
                  ),
                ),
                const SizedBox(width: LuminaSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rack.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LuminaTextStyles.bodyLg.copyWith(
                          color: LuminaColors.onSurface,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rack.sectionName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LuminaTextStyles.labelMd.copyWith(
                          color: LuminaColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: rack.capacityPercentage,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(
                          LuminaRadius.full,
                        ),
                        backgroundColor: LuminaColors.surfaceVariant,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          LuminaColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: LuminaSpacing.sm),
                Text(
                  '${rack.availableSlot} slot',
                  style: LuminaTextStyles.labelMd.copyWith(
                    color: LuminaColors.secondary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.description,
    required this.confirmLabel,
    required this.cancelLabel,
    this.icon = Icons.swap_horiz_rounded,
  });

  final String title;
  final String description;
  final String confirmLabel;
  final String cancelLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: LuminaColors.surfaceContainerLowest,
      insetPadding: const EdgeInsets.all(LuminaSpacing.marginMobile),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LuminaRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(LuminaSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: LuminaColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: LuminaColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: LuminaSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: LuminaTextStyles.headlineSm.copyWith(
                color: LuminaColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: LuminaSpacing.xs),
            Text(
              description,
              textAlign: TextAlign.center,
              style: LuminaTextStyles.bodyMd.copyWith(
                color: LuminaColors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: LuminaSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(cancelLabel),
                    ),
                  ),
                ),
                const SizedBox(width: LuminaSpacing.sm),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: LuminaColors.primary,
                        foregroundColor: LuminaColors.onPrimary,
                      ),
                      child: Text(confirmLabel),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}