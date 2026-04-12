import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Modern green
  static const Color primary = Color(0xFF10B981);
  static const Color primaryDark = Color(0xFF059669);
  static const Color primaryLight = Color(0x3310B981);
  static const Color primaryLighter = Color(0x1A10B981);
  static const Color primarySurface = Color(0xFFECFDF5);

  // Purple/AI Colors
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0x1A8B5CF6);
  static const Color purpleBorder = Color(0x338B5CF6);
  static const Color purpleSurface = Color(0xFFF5F3FF);

  // Background Colors
  static const Color background = Color(0xFFF8FAFB);
  static const Color backgroundLight = Color(0xCCF6F8F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color white = Color(0xFFFFFFFF);
  static const Color whiteTransparent = Color(0xE3FFFFFF);

  // Text Colors
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMedium = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);

  // Border Colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // Shadow Colors
  static const Color shadow = Color(0x0A000000);
  static const Color shadowMedium = Color(0x14000000);
  static const Color shadowGreen = Color(0x3310B981);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF10B981), Color(0xFF059669), Color(0xFF047857)],
  );
}
