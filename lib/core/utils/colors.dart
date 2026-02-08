import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color.fromRGBO(16, 33, 19, 1);
  static const secondary = Color.fromRGBO(26, 44, 29, 1);
  static const brightPrimary = Color.fromRGBO(16, 56, 24, 1);
  static const cardBackground = Color.fromRGBO(26, 46, 31, 1);
  static const border = Color.fromRGBO(49, 66, 53, 1);
  static const selectedBorder = Color.fromRGBO(19, 236, 55, 1);
  static const glowingGreen = Color.fromRGBO(19, 236, 55, 1);
  static const iconSelected = Color.fromRGBO(19, 236, 55, 1);
  static const iconPrimary = Color.fromRGBO(148, 163, 184, 1);
  static const textPrimaryWhite = Color.fromRGBO(255, 255, 255, 1);
  static const textColorGrey = Colors.grey;
  static const white = Color.fromRGBO(255, 255, 255, 0.1);
  static const cardBgUpColor = Color.fromRGBO(37, 56, 41, 1);
  static const textPrimaryBlack = Color(0xff000000);

  // --- Habit Screen New Colors ---
  static const habitBg = Color(0xFF0B0D14);
  static const habitSurface = Color(0xFF151921);
  static const habitPrimary = Color(0xFF244EFB);
  static const habitCategoryBlue = Color(0xFF1A35FF);
  static const habitCategoryText = Colors.white;
  static const habitIconGrey = Color(0xFF94A3B8);
  static const habitBorder = Color(0xFF2D3748);

  static const easyColor = Color(0xFF10B981);
  static const mediumColor = Color(0xFFF59E0B);
  static const hardColor = Color(0xFFEF4444);
}

class AppGradient {
  static const cardGradient = LinearGradient(
    colors: [AppColors.white, AppColors.cardBackground, AppColors.glowingGreen],
    stops: [1, 2, 3],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
