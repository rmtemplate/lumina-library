import 'package:flutter/material.dart';

import 'package:lumina_library/shared/widgets/feedback/lumina_empty_state.dart';

class StaffProfilePage extends StatelessWidget {
  const StaffProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LuminaEmptyState(
      icon: Icons.admin_panel_settings_rounded,
      title: 'Profil Staff',
      description: 'Informasi petugas akan ditampilkan di sini.',
    );
  }
}
