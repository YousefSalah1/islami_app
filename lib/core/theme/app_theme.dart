import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.transparent,
    primaryColor: AppColors.primary,
    fontFamily: AppFonts.janna,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.white, fontFamily: AppFonts.janna),
      bodyMedium: TextStyle(color: AppColors.white, fontFamily: AppFonts.janna),
      titleLarge: TextStyle(color: AppColors.primary, fontFamily: AppFonts.janna, fontWeight: FontWeight.bold),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.primary),
      titleTextStyle: TextStyle(
        color: AppColors.primary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: AppFonts.janna,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.primary,
      selectedItemColor: AppColors.white,
      unselectedItemColor: AppColors.black,
      showUnselectedLabels: false,
      elevation: 0,
    ),
  );
}
