import 'package:flutter/material.dart';

import '../../../../../core/theme/lumina_colors.dart';
import '../../../../../core/theme/lumina_spacing.dart';
import '../../../../../core/theme/lumina_text_styles.dart';
import '../../../data/models/staff_dashboard_summary_model.dart';

class StaffRackOverviewSection extends StatelessWidget {
  const StaffRackOverviewSection({super.key, required this.racks});

  final List<StaffRackOverviewModel> racks;

  @override
  Widget build(BuildContext context) {
    if (racks.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.marginMobile),
      child: Container(
        decoration: BoxDecoration(
          color: LuminaColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: LuminaColors.outlineVariant.withOpacity(0.30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: List.generate(racks.length, (i) {
            return Container(
              decoration: i == 0
                  ? null
                  : BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: LuminaColors.outlineVariant.withOpacity(0.20),
                          width: 1,
                        ),
                      ),
                    ),
              child: StaffRackOverviewTile(rack: racks[i]),
            );
          }),
        ),
      ),
    );
  }
}

class StaffRackOverviewTile extends StatelessWidget {
  const StaffRackOverviewTile({super.key, required this.rack});

  final StaffRackOverviewModel rack;

  @override
  Widget build(BuildContext context) {
    final ratio = rack.occupancyRatio;
    final Color progressColor = ratio >= 0.9
        ? LuminaColors.error
        : ratio >= 0.7
            ? LuminaColors.onTertiaryContainer
            : LuminaColors.secondary;

    return Padding(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      child: Row(
        children: [
          // Rack icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: LuminaColors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shelves,
              size: 20,
              color: LuminaColors.onPrimaryContainer,
            ),
          ),

          const SizedBox(width: LuminaSpacing.md),

          // Info + progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        rack.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LuminaTextStyles.bodyMd.copyWith(
                          color: LuminaColors.onBackground,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: LuminaSpacing.xs),
                    Text(
                      rack.rackCode,
                      style: LuminaTextStyles.labelMd.copyWith(
                        color: LuminaColors.onSurfaceVariant,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
                if (rack.floorLabel != null && rack.floorLabel!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    rack.floorLabel!,
                    style: LuminaTextStyles.labelMd.copyWith(
                      color: LuminaColors.onSurfaceVariant,
                      letterSpacing: 0,
                      fontSize: 11,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                    backgroundColor: LuminaColors.surfaceContainer,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${rack.totalBooks}/${rack.capacity} buku',
                      style: LuminaTextStyles.labelMd.copyWith(
                        color: LuminaColors.onSurfaceVariant,
                        letterSpacing: 0,
                        fontSize: 10,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${rack.freeSlots} slot kosong',
                      style: LuminaTextStyles.labelMd.copyWith(
                        color: LuminaColors.onSurfaceVariant,
                        letterSpacing: 0,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
