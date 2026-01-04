import 'package:flutter/material.dart';

// ENUM KATEGORI (Untuk Konteks Situasi)
enum CardCategory { shooting, defending, passing, neutral }

// ENUM TIPE (Untuk Logika Menang/Kalah)
enum CardType { attack, skill, defend }

class MatchCard {
  final String name;
  final CardType type; 
  final CardCategory category; // Field Baru
  final int power;
  
  // Visual
  final Color? color; 
  final IconData? icon;

  MatchCard({
    required this.name,
    required this.type,
    required this.category,
    required this.power,
    this.color,
    this.icon,
  });

  // Logika Batu-Gunting-Kertas (Attack > Skill > Defend > Attack)
  bool winsAgainst(MatchCard other) {
    if (type == CardType.attack && other.type == CardType.skill) return true;
    if (type == CardType.skill && other.type == CardType.defend) return true;
    if (type == CardType.defend && other.type == CardType.attack) return true;
    return false;
  }
}