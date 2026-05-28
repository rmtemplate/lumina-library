import 'package:flutter/material.dart';
import 'package:lumina_library/features/profile/presentasion/pages/lumina_profile_page.dart';

import '../../../../../shared/models/profile/lumina_profile_models.dart';

class LibraryProfilePage extends StatelessWidget {
  const LibraryProfilePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const LuminaProfilePage(
      role: LuminaProfileRole.user,
    );
  }
}