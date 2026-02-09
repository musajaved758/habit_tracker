import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF0F172A);
  static const secondary = Color(0xFF1E293B);
  static const brightPrimary = Color(0xFF3B82F6);
  static const cardBackground = Color(0xFF1E293B);
  static const border = Color(0xFF334155);
  static const selectedBorder = Color(0xFF60A5FA);
  static const glowingGreen = Color(
    0xFF60A5FA,
  ); // Renamed internally but keeping name for compatibility if used elsewhere
  static const iconSelected = Color(0xFF60A5FA);
  static const iconPrimary = Color(0xFF94A3B8);
  static const textPrimaryWhite = Color(0xFFF8FAFC);
  static const textColorGrey = Color(0xFF94A3B8);
  static const white = Color.fromRGBO(255, 255, 255, 0.1);
  static const cardBgUpColor = Color(0xFF334155);
  static const textPrimaryBlack = Color(0xFF0F172A);

  // --- Habit Screen New Colors (Blueish Scheme) ---
  static const habitBg = Color(0xFF0F172A);
  static const habitSurface = Color(0xFF1E293B);
  static const habitPrimary = Color(0xFF2563EB); // Vibrant Blue
  static const habitCategoryBlue = Color(0xFF3B82F6);
  static const habitCategoryText = Colors.white;
  static const habitIconGrey = Color(0xFF64748B);
  static const habitBorder = Color(0xFF334155);

  static const lowPriorityColor = Color(0xFF10B981); // Emerald
  static const mediumPriorityColor = Color(0xFFF59E0B); // Amber
  static const highPriorityColor = Color(0xFFEF4444); // Red
}

class AppGradient {
  static const cardGradient = LinearGradient(
    colors: [AppColors.white, AppColors.cardBackground, AppColors.glowingGreen],
    stops: [1, 2, 3],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
