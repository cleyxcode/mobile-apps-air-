import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        const TextTheme(
          headlineSmall: TextStyle(
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
          headlineMedium: TextStyle(
            color: AppColors.textDark,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          headlineLarge: TextStyle(
            color: AppColors.textDark,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          bodySmall: TextStyle(
            color: AppColors.textLight,
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
          bodyMedium: TextStyle(
            color: AppColors.textMedium,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          bodyLarge: TextStyle(
            color: AppColors.textMedium,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          labelSmall: TextStyle(
            color: AppColors.textMedium,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          labelMedium: TextStyle(
            color: AppColors.textMedium,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.textLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primaryLight;
          return AppColors.border;
        }),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        color: AppColors.white,
      ),
    );
  }
}
