import 'package:flutter/material.dart';

import '../../../../core/theme/lumina_colors.dart';
import '../widgets/library_bottom_nav_bar.dart';
import 'library_catalog_page.dart';
import 'library_dashboard_page.dart';
import 'library_my_books_page.dart';
import 'library_profile_page.dart';

class LibraryHomePage extends StatefulWidget {
  const LibraryHomePage({super.key});

  @override
  State<LibraryHomePage> createState() => _LibraryHomePageState();
}

class _LibraryHomePageState extends State<LibraryHomePage> {
  int _selectedNavIndex = 0;

  static const List<Widget> _pages = [
    LibraryDashboardPage(),
    LibraryCatalogPage(),
    LibraryMyBooksPage(),
    LibraryProfilePage(),
  ];

  void _onNavigationChanged(int index) {
    if (_selectedNavIndex == index) return;

    setState(() {
      _selectedNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuminaColors.background,
      body: IndexedStack(
        index: _selectedNavIndex,
        children: _pages,
      ),
      bottomNavigationBar: LibraryBottomNavBar(
        currentIndex: _selectedNavIndex,
        onChanged: _onNavigationChanged,
      ),
    );
  }
}
