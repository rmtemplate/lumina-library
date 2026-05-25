import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/home/library_home_controller.dart';
import 'package:lumina_library/features/mahasiswa/presentation/pages/catalog/library_catalog_page.dart';
import 'package:lumina_library/features/mahasiswa/presentation/pages/home/library_dashboard_page.dart';
import 'package:lumina_library/features/mahasiswa/presentation/pages/my_books/library_my_books_page.dart';
import 'package:lumina_library/features/mahasiswa/presentation/pages/profile/library_profile_page.dart';
import 'package:lumina_library/features/mahasiswa/presentation/widgets/navigation/library_bottom_nav_bar.dart';

class LibraryHomePage extends StatelessWidget {
  const LibraryHomePage({super.key});

  static const List<Widget> _pages = [
    LibraryDashboardPage(),
    LibraryCatalogPage(),
    LibraryMyBooksPage(),
    LibraryProfilePage(),
  ];

  LibraryHomeController get controller => Get.isRegistered<LibraryHomeController>()
      ? Get.find<LibraryHomeController>()
      : Get.put(LibraryHomeController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    final homeController = controller;

    return Obx(
      () => Scaffold(
        backgroundColor: LuminaColors.background,
        body: IndexedStack(
          index: homeController.selectedNavIndex.value,
          children: _pages,
        ),
        bottomNavigationBar: LibraryBottomNavBar(
          currentIndex: homeController.selectedNavIndex.value,
          onChanged: homeController.changeNavIndex,
        ),
      ),
    );
  }
}
