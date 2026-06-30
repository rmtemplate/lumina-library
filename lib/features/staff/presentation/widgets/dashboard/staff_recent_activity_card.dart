import 'package:flutter/material.dart';

import '../../../../../core/theme/lumina_colors.dart';
import '../../../../../core/theme/lumina_spacing.dart';
import '../../../../../core/theme/lumina_text_styles.dart';
import '../../../data/models/staff_dashboard_summary_model.dart';

class StaffRecentActivitySection extends StatelessWidget {
  const StaffRecentActivitySection({super.key, required this.activities, this.onTap});

  final List<StaffRecentActivityModel> activities;
  final void Function(StaffRecentActivityModel activity)? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.marginMobile),
      child: Column(
        children: [
          if (activities.isEmpty)
            Container(
              padding: const EdgeInsets.all(LuminaSpacing.lg),
              decoration: BoxDecoration(
                color: LuminaColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: LuminaColors.outlineVariant.withOpacity(0.30)),
              ),
              child: Center(
                child: Text(
                  'Belum ada aktivitas terbaru.',
                  style: LuminaTextStyles.bodyMd.copyWith(color: LuminaColors.onSurfaceVariant),
                ),
              ),
            )
          else
            Container(
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
                children: List.generate(activities.length, (i) {
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
                    child: StaffActivityTile(
                      activity: activities[i],
                      onTap: onTap != null ? () => onTap!(activities[i]) : null,
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

class StaffActivityTile extends StatelessWidget {
  const StaffActivityTile({super.key, required this.activity, this.onTap});

  final StaffRecentActivityModel activity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = _colorForStatus(activity.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(LuminaSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Member avatar
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: LuminaColors.surfaceContainerLow,
                ),
                clipBehavior: Clip.antiAlias,
                child: activity.memberAvatarUrl != null
                    ? Image.network(
                        activity.memberAvatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallbackAvatar(color),
                      )
                    : _fallbackAvatar(color),
              ),

              const SizedBox(width: LuminaSpacing.md),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.memberName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LuminaTextStyles.bodyMd.copyWith(
                        color: LuminaColors.onBackground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (activity.bookTitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        activity.bookTitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LuminaTextStyles.bodySm.copyWith(
                          color: LuminaColors.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 3),
                    Text(
                      '${activity.itemsCount} buku · ${activity.borrowingCode}',
                      style: LuminaTextStyles.labelMd.copyWith(
                        color: LuminaColors.onSurfaceVariant,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: LuminaSpacing.sm),

              // Status badge
              _statusBadge(activity.status),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackAvatar(Color color) {
    return Container(
      color: color.withOpacity(0.12),
      child: Icon(Icons.person_rounded, color: color, size: 22),
    );
  }
}

Widget _statusBadge(String status) {
  final (label, bg, fg) = switch (status) {
    'awaiting_pickup' => ('Menunggu', const Color(0xFFE8F0FE), const Color(0xFF1A73E8)),
    'active' => ('Dipinjam', LuminaColors.primaryContainer, LuminaColors.onPrimaryContainer),
    'overdue' => ('Terlambat', LuminaColors.errorContainer, LuminaColors.onErrorContainer),
    'waiting_payment' => ('Bayar', LuminaColors.errorContainer, LuminaColors.onErrorContainer),
    'returned' || 'returned_with_fine' => (
        'Kembali',
        LuminaColors.secondaryContainer,
        LuminaColors.onSecondaryContainer,
      ),
    _ => (status, LuminaColors.surfaceContainer, LuminaColors.onSurfaceVariant),
  };

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: fg,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    ),
  );
}

Color _colorForStatus(String status) => switch (status) {
      'overdue' || 'waiting_payment' => LuminaColors.error,
      'returned' || 'returned_with_fine' => LuminaColors.secondary,
      _ => LuminaColors.primary,
    };
