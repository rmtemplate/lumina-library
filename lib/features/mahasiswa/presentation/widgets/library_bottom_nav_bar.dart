import 'package:flutter/material.dart';

import '../../../../shared/models/navigation/bottom_nav_item_model.dart';
import '../../../../shared/widgets/navigation/lumina_role_bottom_nav_bar.dart';

class LibraryBottomNavBar extends StatelessWidget {
  const LibraryBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  static const List<LuminaBottomNavItemModel> _items = [
    LuminaBottomNavItemModel(
      icon: Icons.home_rounded,
      label: 'Home',
    ),
    LuminaBottomNavItemModel(
      icon: Icons.import_contacts_rounded,
      label: 'Catalog',
    ),
    LuminaBottomNavItemModel(
      icon: Icons.book_rounded,
      label: 'My Books',
    ),
    LuminaBottomNavItemModel(
      icon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LuminaRoleBottomNavBar(
      items: _items,
      currentIndex: currentIndex,
      onChanged: onChanged,
      height: 64,
    );
  }
}
