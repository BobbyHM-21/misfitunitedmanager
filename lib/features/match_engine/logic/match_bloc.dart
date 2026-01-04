import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/match_card_model.dart';
import '../data/goal_model.dart';
import 'match_event.dart';
import 'match_state.dart';

class MatchBloc extends Bloc<MatchEvent, MatchState> {
  final Random _rng = Random();
  StreamSubscription<int>? _tickerSubscription;

  MatchBloc() : super(MatchState()) {
    
    // 1. START MATCH
    on<StartMatch>((event, emit) {
      emit(MatchState(
        lastEvent: "KICK OFF! Pertandingan dimulai!",
        squadNames: event.squadNames,
        matchContext: MatchContext.neutral,
      ));
      _startTimer();
    });

    // 2. TIMER (Jalan Cepat & Trigger Event)
    on<TimerTicked>((event, emit) {
      // Jika game selesai atau sedang PAUSE (Event), timer stop update
      if (state.isMatchOver || state.isEventTriggered) return;

      int newMinute = state.gameMinute + 1;
      if (newMinute >= 90) { _finishMatch(emit); return; }

      // RNG: 15% Kemungkinan terjadi EVENT PENTING setiap menit
      int roll = _rng.nextInt(100);

      if (roll < 15) {
        // --- EVENT TERJADI ---
        bool isMyChance = _rng.nextBool(); // 50:50 Antara Nyerang atau Diserang
        
        MatchContext context = isMyChance ? MatchContext.attacking : MatchContext.defending;
        
        // GENERATE KARTU KHUSUS (Shooting vs Defending)
        List<MatchCard> contextCards = _generateContextHand(context);

        emit(state.copyWith(
          gameMinute: newMinute,
          isEventTriggered: true, // PAUSE GAME
          matchContext: context,
          playerHand: contextCards, // Kartu baru di tangan
          lastEvent: isMyChance 
              ? "PELUANG! Striker kita lolos dari kawalan!" 
              : "BAHAYA! Musuh melakukan serangan balik cepat!",
        ));
      } else {
        // Filler Text (Komentator biasa)
        if (newMinute % 4 == 0) {
           emit(state.copyWith(gameMinute: newMinute, lastEvent: _getFillerCommentary()));
        } else {
           emit(state.copyWith(gameMinute: newMinute));
        }
      }
    });

    // 3. MAIN KARTU (RESOLUSI DUEL)
    on<PlayCard>((event, emit) {
      if (!state.isEventTriggered) return;

      final playerCard = event.card;
      final enemyCard = _generateEnemyCard(); // Musuh counter

      String commentary = "";
      int pScore = state.playerScore;
      int eScore = state.enemyScore;
      List<GoalModel> currentGoals = List.from(state.matchGoals);
      
      String heroName = state.squadNames.isNotEmpty 
          ? state.squadNames[_rng.nextInt(state.squadNames.length)] 
          : "Pemain Kita";

      // LOGIKA MENANG/KALAH
      bool playerWin = playerCard.winsAgainst(enemyCard);
      bool draw = (playerCard.type == enemyCard.type);

      // A. JIKA KITA MENYERANG (Shooting Context)
      if (state.matchContext == MatchContext.attacking) {
        if (playerWin) {
          pScore++;
          commentary = "GOAL!!! ${playerCard.name} dari $heroName merobek jala gawang!";
          currentGoals.add(GoalModel(scorerName: heroName, minute: state.gameMinute, isEnemyGoal: false));
        } else if (draw) {
          commentary = "TIANG GAWANG! ${playerCard.name} nyaris masuk!";
        } else {
          commentary = "DITEPS! Kiper lawan membaca arah bola dengan baik.";
        }
      } 
      // B. JIKA KITA BERTAHAN (Defending Context)
      else if (state.matchContext == MatchContext.defending) {
        if (playerWin) {
          commentary = "BERHASIL! ${playerCard.name} mematahkan serangan musuh.";
        } else if (draw) {
          commentary = "SAPU BERSIH! Bola dibuang jauh ke depan.";
        } else {
          // KALAH DUEL BERTAHAN -> RISIKO
          if (playerCard.name == "Slide Tackle") {
             // RISIKO PENALTI (30% Chance kalau tackle gagal)
             if (_rng.nextInt(100) < 30) {
               eScore++;
               commentary = "PRUIT! PENALTI! Tackle terlambat. Gol untuk lawan.";
               currentGoals.add(GoalModel(scorerName: "Lawan (Pen)", minute: state.gameMinute, isEnemyGoal: true));
             } else {
               eScore++;
               commentary = "LOLOS! Tackle gagal, musuh mencetak gol mudah.";
               currentGoals.add(GoalModel(scorerName: "Lawan", minute: state.gameMinute, isEnemyGoal: true));
             }
          } else {
            // Intercept/Offside trap gagal
            eScore++;
            commentary = "GAGAL! ${playerCard.name} tidak berhasil. Gol untuk musuh.";
            currentGoals.add(GoalModel(scorerName: "Lawan", minute: state.gameMinute, isEnemyGoal: true));
          }
        }
      }

      // RESUME GAME (Kembali Neutral)
      emit(state.copyWith(
        isEventTriggered: false,
        matchContext: MatchContext.neutral,
        playerScore: pScore,
        enemyScore: eScore,
        lastEvent: commentary,
        matchGoals: currentGoals,
      ));
    });
  }

  // GENERATOR KARTU SPESIFIK
  List<MatchCard> _generateContextHand(MatchContext context) {
    List<MatchCard> hand = [];
    
    if (context == MatchContext.attacking) {
      // OPSI MENYERANG
      hand.add(MatchCard(name: "Power Shot", type: CardType.attack, category: CardCategory.shooting, power: 80, color: Colors.red, icon: Icons.sports_soccer));
      hand.add(MatchCard(name: "Chip Shot", type: CardType.skill, category: CardCategory.shooting, power: 75, color: Colors.amber, icon: Icons.upload));
      hand.add(MatchCard(name: "Place Shot", type: CardType.defend, category: CardCategory.shooting, power: 70, color: Colors.blue, icon: Icons.gps_fixed)); 
    } else {
      // OPSI BERTAHAN
      hand.add(MatchCard(name: "Slide Tackle", type: CardType.attack, category: CardCategory.defending, power: 85, color: Colors.red, icon: Icons.warning));
      hand.add(MatchCard(name: "Offside Trap", type: CardType.skill, category: CardCategory.defending, power: 70, color: Colors.amber, icon: Icons.flag));
      hand.add(MatchCard(name: "Intercept", type: CardType.defend, category: CardCategory.defending, power: 75, color: Colors.blue, icon: Icons.shield));
    }
    return hand;
  }

  MatchCard _generateEnemyCard() {
    int r = _rng.nextInt(3);
    if (r == 0) return MatchCard(name: "Block", type: CardType.defend, category: CardCategory.neutral, power: 70);
    if (r == 1) return MatchCard(name: "Dribble", type: CardType.skill, category: CardCategory.neutral, power: 70);
    return MatchCard(name: "Shoot", type: CardType.attack, category: CardCategory.neutral, power: 70);
  }

  void _startTimer() {
    _tickerSubscription?.cancel();
    // Speed: 600ms = 1 menit game
    _tickerSubscription = Stream.periodic(const Duration(milliseconds: 600), (x) => x).listen((_) {
      add(TimerTicked(0));
    });
  }

  void _finishMatch(Emitter<MatchState> emit) {
    _tickerSubscription?.cancel();
    emit(state.copyWith(gameMinute: 90, isMatchOver: true, isEventTriggered: false, lastEvent: "FULL TIME!"));
  }
  
  String _getFillerCommentary() {
    List<String> t = ["Bola bergulir di lini tengah.", "Kedua tim bermain hati-hati.", "Sorakan penonton terdengar riuh.", "Pelatih memberi instruksi dari pinggir lapangan.", "Operan pendek yang rapi diperagakan."];
    return t[_rng.nextInt(t.length)];
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }
}