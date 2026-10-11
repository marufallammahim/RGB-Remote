import 'package:flutter/material.dart';

import 'app_color.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData dark = ThemeData.dark().copyWith(
    colorScheme: const ColorScheme.dark(
      primary: AppColors.kPrimaryColor,
      surface: AppColors.kPrimaryColor,
    ),
    scaffoldBackgroundColor: AppColors.kPrimaryColor,
    appBarTheme: AppBarTheme(
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: AppColors.kPrimaryColor,
      iconTheme: const IconThemeData(color: AppColors.kWhiteColor),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.kPrimaryColor,
      surfaceTintColor: AppColors.kPrimaryColor,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.kWhiteColor.withAlpha(200),
      ),
    ),
  );
}
