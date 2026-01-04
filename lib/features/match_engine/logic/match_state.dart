import '../data/match_card_model.dart';

class MatchState {
  final List<MatchCard> playerHand;
  final int playerScore;
  final int enemyScore;
  final String lastEvent; // Komentar (Goal/Miss)
  
  // --- BARU: WAKTU ---
  final int gameMinute;   // 0 sampai 90
  final bool isMatchOver; // True jika sudah peluit panjang

  MatchState({
    this.playerHand = const [],
    this.playerScore = 0,
    this.enemyScore = 0,
    this.lastEvent = "MATCH START!",
    this.gameMinute = 0,     // Default menit 0
    this.isMatchOver = false, // Default belum selesai
  });

  // Fitur CopyWith (Penting untuk update state parsial)
  MatchState copyWith({
    List<MatchCard>? playerHand,
    int? playerScore,
    int? enemyScore,
    String? lastEvent,
    int? gameMinute,
    bool? isMatchOver,
  }) {
    return MatchState(
      playerHand: playerHand ?? this.playerHand,
      playerScore: playerScore ?? this.playerScore,
      enemyScore: enemyScore ?? this.enemyScore,
      lastEvent: lastEvent ?? this.lastEvent,
      gameMinute: gameMinute ?? this.gameMinute,
      isMatchOver: isMatchOver ?? this.isMatchOver,
    );
  }
}