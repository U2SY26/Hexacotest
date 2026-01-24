import 'package:flutter/material.dart';

class AppColors {
  static const darkBg = Color(0xFF0F0F23);
  static const darkCard = Color(0xFF1A1A2E);
  static const darkBorder = Color(0xFF2D2D44);

  static const purple400 = Color(0xFFC084FC);
  static const purple500 = Color(0xFF8B5CF6);
  static const purple600 = Color(0xFF7C3AED);
  static const pink500 = Color(0xFFEC4899);
  static const pink600 = Color(0xFFDB2777);
  static const red500 = Color(0xFFEF4444);

  static const orange500 = Color(0xFFF97316);
  static const amber500 = Color(0xFFF59E0B);
  static const emerald500 = Color(0xFF10B981);
  static const green500 = Color(0xFF22C55E);
  static const blue500 = Color(0xFF3B82F6);
  static const cyan500 = Color(0xFF06B6D4);

  static const gray400 = Color(0xFF9CA3AF);
  static const gray500 = Color(0xFF6B7280);
  static const gray700 = Color(0xFF374151);
}

class AppGradients {
  static const background = LinearGradient(
    colors: [
      Color(0xFF0F0F23),
      Color(0xFF1A1A2E),
      Color(0xFF16213E),
      Color(0xFF0F3460),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const primaryButton = LinearGradient(
    colors: [
      AppColors.purple600,
      AppColors.pink600,
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const textGradient = LinearGradient(
    colors: [
      AppColors.purple400,
      AppColors.pink500,
      AppColors.red500,
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

class AppRadii {
  static const double xl = 24;
  static const double lg = 16;
  static const double md = 12;
  static const double sm = 8;
}
