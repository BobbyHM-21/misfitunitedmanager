import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum CardType { attack, defend, skill }

class MatchCard {
  final String name;
  final CardType type;
  final int power; // Kekuatan tambahan (misal: +10)
  
  const MatchCard({
    required this.name, 
    required this.type, 
    required this.power
  });

  // Helper: Ambil warna berdasarkan tipe
  Color get color {
    switch (type) {
      case CardType.attack: return AppColors.hotPink;
      case CardType.skill: return AppColors.electricCyan; // Variasi skill
      case CardType.defend: return AppColors.neonYellow;  // Variasi defend
    }
  }

  // Helper: Ambil icon berdasarkan tipe
  IconData get icon {
    switch (type) {
      case CardType.attack: return Icons.flash_on;
      case CardType.skill: return Icons.auto_awesome;
      case CardType.defend: return Icons.shield;
    }
  }

  // --- LOGIKA BATU-GUNTING-KERTAS ---
  // Mengembalikan TRUE jika kartu ini menang lawan kartu musuh
  bool winsAgainst(MatchCard other) {
    if (type == CardType.attack && other.type == CardType.skill) return true;
    if (type == CardType.skill && other.type == CardType.defend) return true;
    if (type == CardType.defend && other.type == CardType.attack) return true;
    return false; // Kalah atau Seri
  }
}