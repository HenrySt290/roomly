import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8F85FF);
  static const Color primaryDark = Color(0xFF4B42D4);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF00D9A0);
  static const Color secondaryLight = Color(0xFF4DE8C1);
  static const Color secondaryDark = Color(0xFF00B382);
  
  // Accent Colors
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentLight = Color(0xFFFF8E8E);
  
  // Background Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textHint = Color(0xFFADB5BD);
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color success = Color(0xFF28C76F);
  static const Color error = Color(0xFFEA5455);
  static const Color warning = Color(0xFFFF9F43);
  static const Color info = Color(0xFF00CFE8);
  
  // Border Colors
  static const Color border = Color(0xFFE9ECEF);
  static const Color divider = Color(0xFFDEE2E6);
  
  // Shadow
  static const Color shadow = Color(0x1A000000);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
