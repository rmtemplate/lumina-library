import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'lumina_colors.dart';
import 'lumina_radius.dart';
import 'lumina_spacing.dart';
import 'lumina_text_styles.dart';

class LuminaTheme {
  const LuminaTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: LuminaColors.primary,
      brightness: Brightness.light,
      primary: LuminaColors.primary,
      onPrimary: LuminaColors.onPrimary,
      secondary: LuminaColors.secondary,
      onSecondary: LuminaColors.onSecondary,
      tertiary: LuminaColors.tertiary,
      error: LuminaColors.error,
      onError: LuminaColors.onError,
      surface: LuminaColors.surface,
      onSurface: LuminaColors.onSurface,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: LuminaColors.background,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: LuminaTextStyles.displayLg,
        headlineMedium: LuminaTextStyles.headlineMd,
        headlineSmall: LuminaTextStyles.headlineSm,
        titleLarge: LuminaTextStyles.titleLg,
        bodyLarge: LuminaTextStyles.bodyLg,
        bodyMedium: LuminaTextStyles.bodyMd,
        labelMedium: LuminaTextStyles.labelMd,
      ),
      cardTheme: CardThemeData(
        color: LuminaColors.surfaceContainerLowest,
        elevation: 0,
        margin: LuminaSpacing.cardMargin,
        shape: RoundedRectangleBorder(
          borderRadius: LuminaRadius.card,
          side: const BorderSide(
            color: LuminaColors.outlineVariant,
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LuminaColors.surfaceContainerLowest,
        contentPadding: LuminaSpacing.inputPadding,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: LuminaTextStyles.bodyMd.copyWith(
          color: LuminaColors.onSurfaceVariant,
        ),
        floatingLabelStyle: LuminaTextStyles.labelMd.copyWith(
          color: LuminaColors.primary,
        ),
        hintStyle: LuminaTextStyles.bodyMd.copyWith(
          color: LuminaColors.outline,
        ),
        border: OutlineInputBorder(
          borderRadius: LuminaRadius.input,
          borderSide: const BorderSide(
            color: LuminaColors.outlineVariant,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: LuminaRadius.input,
          borderSide: const BorderSide(
            color: LuminaColors.outlineVariant,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: LuminaRadius.input,
          borderSide: const BorderSide(
            color: LuminaColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: LuminaRadius.input,
          borderSide: const BorderSide(
            color: LuminaColors.error,
            width: 1,
          ),
        ),
      ),
    );
  }
}
