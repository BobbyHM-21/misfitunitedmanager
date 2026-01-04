import '../data/match_card_model.dart';
import '../data/goal_model.dart'; // Import model baru

class MatchState {
  final List<MatchCard> playerHand;
  final int playerScore;
  final int enemyScore;
  final String lastEvent;
  final int gameMinute;
  final bool isMatchOver;
  final List<String> squadNames;
  
  // BARU: Daftar Pencetak Gol
  final List<GoalModel> matchGoals; 

  MatchState({
    this.playerHand = const [],
    this.playerScore = 0,
    this.enemyScore = 0,
    this.lastEvent = "MATCH START!",
    this.gameMinute = 0,
    this.isMatchOver = false,
    this.squadNames = const [],
    this.matchGoals = const [], // Default kosong
  });

  MatchState copyWith({
    List<MatchCard>? playerHand,
    int? playerScore,
    int? enemyScore,
    String? lastEvent,
    int? gameMinute,
    bool? isMatchOver,
    List<String>? squadNames,
    List<GoalModel>? matchGoals,
  }) {
    return MatchState(
      playerHand: playerHand ?? this.playerHand,
      playerScore: playerScore ?? this.playerScore,
      enemyScore: enemyScore ?? this.enemyScore,
      lastEvent: lastEvent ?? this.lastEvent,
      gameMinute: gameMinute ?? this.gameMinute,
      isMatchOver: isMatchOver ?? this.isMatchOver,
      squadNames: squadNames ?? this.squadNames,
      matchGoals: matchGoals ?? this.matchGoals,
    );
  }
}