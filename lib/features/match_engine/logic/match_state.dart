import '../data/match_card_model.dart';
import '../data/goal_model.dart';

// ENUM STATUS PERTANDINGAN
enum MatchContext { 
  neutral,   // Bola di tengah
  attacking, // KITA SEDANG MENYERANG (Peluang)
  defending  // KITA SEDANG DISERANG (Bahaya)
}

class MatchState {
  final List<MatchCard> playerHand;
  final int playerScore;
  final int enemyScore;
  final String lastEvent;
  final int gameMinute;
  final bool isMatchOver;
  final List<String> squadNames;
  final List<GoalModel> matchGoals;
  
  // STATUS BARU
  final MatchContext matchContext; // Menggantikan 'eventType' string
  final bool isEventTriggered;     // True = Game Pause

  MatchState({
    this.playerHand = const [],
    this.playerScore = 0,
    this.enemyScore = 0,
    this.lastEvent = "Menunggu Kick-off...",
    this.gameMinute = 0,
    this.isMatchOver = false,
    this.squadNames = const [],
    this.matchGoals = const [],
    this.matchContext = MatchContext.neutral,
    this.isEventTriggered = false,
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
    MatchContext? matchContext,
    bool? isEventTriggered,
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
      matchContext: matchContext ?? this.matchContext,
      isEventTriggered: isEventTriggered ?? this.isEventTriggered,
    );
  }
}