import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryPurple = Color(0xFF6C63FF);
  static const Color primaryPink = Color(0xFFFF6B9D);
  static const Color primaryOrange = Color(0xFFFF9F43);
  static const Color primaryBlue = Color(0xFF4FACFE);
  static const Color primaryGreen = Color(0xFF00F2C3);

  static const Color darkBg = Color(0xFF0A0E27);
  static const Color darkCard = Color(0xFF1B1E3C);

  static const Color socialMedia = Color(0xFFE91E63);
  static const Color banking = Color(0xFF4CAF50);
  static const Color email = Color(0xFFFF5722);
  static const Color shopping = Color(0xFFFF9800);
  static const Color work = Color(0xFF9C27B0);
  static const Color entertainment = Color(0xFF2196F3);
  static const Color other = Color(0xFF607D8B);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPurple, primaryPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1B1E3C), Color(0xFF2A2D4A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00F2C3), Color(0xFF00D4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
