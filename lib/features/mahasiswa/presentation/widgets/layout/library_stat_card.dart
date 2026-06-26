
import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/shared/widgets/card/lumina_stat_card.dart';

class LibraryStatCard extends LuminaStatCard {
  const LibraryStatCard({
    super.key,
    required super.icon,
    required super.value,
    required super.label,
    super.iconBackgroundColor = LuminaColors.primaryFixed,
    super.iconColor = LuminaColors.onPrimaryFixed,
    super.valueColor = LuminaColors.primary,
    super.backgroundColor = LuminaColors.surfaceContainerLowest,
    super.labelColor = LuminaColors.onSurfaceVariant,
    super.onTap,
  });
}
