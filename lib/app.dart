import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/bindings/lumina_initial_binding.dart';
import 'package:lumina_library/core/theme/lumina_theme.dart';
import 'package:lumina_library/features/splash/presentation/pages/splash_screen_page.dart';

class LuminaApp extends StatelessWidget {
  const LuminaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Lumina Digital Library',
      debugShowCheckedModeBanner: false,
      theme: LuminaTheme.light(),
      initialBinding: LuminaInitialBinding(),
      home: const SplashScreenPage(),
    );
  }
}
