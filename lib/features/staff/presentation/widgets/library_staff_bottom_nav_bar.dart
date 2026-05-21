import 'package:flutter/material.dart';

import '../../../../shared/models/navigation/bottom_nav_item_model.dart';
import '../../../../shared/widgets/navigation/lumina_role_bottom_nav_bar.dart';

class LibraryStaffBottomNavBar extends StatelessWidget {
  const LibraryStaffBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  static const List<LuminaBottomNavItemModel> _items = [
    LuminaBottomNavItemModel(
      icon: Icons.dashboard_rounded,
      label: 'Management',
    ),
    LuminaBottomNavItemModel(
      icon: Icons.qr_code_scanner_rounded,
      label: 'Scan',
    ),
    LuminaBottomNavItemModel(
      icon: Icons.analytics_rounded,
      label: 'Reports',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LuminaRoleBottomNavBar(
      items: _items,
      currentIndex: currentIndex,
      onChanged: onChanged,
      centerActionIndex: 1,
      centerButtonIcon: Icons.qr_code_scanner_rounded,
    );
  }
}
