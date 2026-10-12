import 'package:flutter/material.dart';

import 'app_color.dart';

class AppTheme {
  AppTheme._();

  static ThemeData _build({required Color background, required Color surface}) {
    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.dark(
        primary: AppColors.kPrimaryColor,
        surface: surface,
        secondary: AppColors.kBorderColor,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        elevation: 0,
        titleSpacing: 0,
        backgroundColor: background,
        iconTheme: const IconThemeData(color: AppColors.kWhiteColor),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: surface,
      ),
      cardTheme: CardThemeData(color: surface),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.kWhiteColor.withAlpha(200),
        ),
      ),
    );
  }

  /// Existing app appearance remains the first-install default.
  static final ThemeData dark = _build(
    background: AppColors.kPrimaryColor,
    surface: AppColors.kPrimaryColor,
  );

  /// Optional pure-black scaffold and surfaces for AMOLED displays.
  static final ThemeData amoled = _build(
    background: Colors.black,
    surface: Colors.black,
  );
}
