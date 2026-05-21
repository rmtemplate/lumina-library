import '../../../../shared/widgets/layout/lumina_section_header.dart';

class LibrarySectionHeader extends LuminaSectionHeader {
  const LibrarySectionHeader({
    super.key,
    required super.title,
    super.subtitle,
    super.actionLabel = 'Lihat Semua',
    super.showAction = true,
    super.onActionTap,
  });
}
