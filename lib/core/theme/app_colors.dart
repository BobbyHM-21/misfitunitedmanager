import 'package:flutter/material.dart';

class AppColors {
  // Background Gelap (Dystopian City)
  static const Color background = Color(0xFF050510);
  
  // Palet Neon Utama
  static const Color electricCyan = Color(0xFF00FFFF); // Menu Utama
  static const Color hotPink = Color(0xFFFF69B4);      // Attack/Danger
  static const Color neonYellow = Color(0xFFFFFF00);   // Warning/Info
  
  // Warna Teks
  static const Color textPrimary = Colors.white;
  static const Color textDim = Colors.white54;

  static List<BoxShadow> glow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.6),
      blurRadius: 10,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: color.withOpacity(0.2),
      blurRadius: 20,
      spreadRadius: 4,
    ),
  ];
}
