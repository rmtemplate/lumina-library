import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/theme/lumina_theme.dart';
import 'features/splash/presentation/pages/splash_screen_page.dart';

class LuminaApp extends StatelessWidget {
  const LuminaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Lumina Digital Library',
      debugShowCheckedModeBanner: false,
      theme: LuminaTheme.light(),
      home: const SplashScreenPage(),
    );
  }
}
