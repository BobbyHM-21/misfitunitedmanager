import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/match_card_model.dart';
import 'match_event.dart';
import 'match_state.dart';

class MatchBloc extends Bloc<MatchEvent, MatchState> {
  final Random _rng = Random();
  StreamSubscription<int>? _tickerSubscription;

  MatchBloc() : super(MatchState()) {
    
    // 1. MATCH START
    on<StartMatch>((event, emit) {
      final starterHand = List.generate(3, (_) => _generateSmartEnemyCard(0)); // Awal game netral
      emit(MatchState(playerHand: starterHand, lastEvent: "KICK OFF!"));

      _tickerSubscription?.cancel();
      _tickerSubscription = Stream.periodic(const Duration(seconds: 1), (x) => x + 1).listen((tick) {
        add(TimerTicked(tick));
      });
    });

    // 2. TIMER LOGIC
    on<TimerTicked>((event, emit) {
      if (state.isMatchOver) return;

      if (event.minute >= 90) {
        _tickerSubscription?.cancel();
        emit(state.copyWith(
          gameMinute: 90,
          isMatchOver: true,
          lastEvent: "FULL TIME! WHISTLE BLOWN!",
        ));
      } else {
        emit(state.copyWith(gameMinute: event.minute));
      }
    });

    // 3. LOGIKA MAIN KARTU (DENGAN SMART AI)
    on<PlayCard>((event, emit) {
      if (state.isMatchOver) return;

      final playerCard = event.card;
      
      // --- PERUBAHAN DI SINI (AI PINTAR) ---
      // Hitung selisih skor (Musuh - Player)
      final scoreDiff = state.enemyScore - state.playerScore;
      
      // Musuh berpikir berdasarkan selisih skor tersebut
      final enemyCard = _generateSmartEnemyCard(scoreDiff);
      // -------------------------------------

      String resultText = "";
      int pScore = state.playerScore;
      int eScore = state.enemyScore;

      // Logika Duel
      if (playerCard.type == enemyCard.type) {
         resultText = "DRAW! (${playerCard.power} vs ${enemyCard.power})";
      } else if (playerCard.winsAgainst(enemyCard)) {
        resultText = "GOAL! ${playerCard.name} beats ${enemyCard.name}";
        pScore++;
      } else {
        resultText = "BLOCKED! ${enemyCard.name} stops attack";
        // eScore++; // Opsional: Musuh bisa cetak gol kalau mau dipersulit
      }

      final newHand = List<MatchCard>.from(state.playerHand);
      newHand.remove(playerCard);
      // Player draw kartu baru (bisa dibuat smart juga nanti, tapi random dulu ok)
      newHand.add(_generateSmartEnemyCard(0)); 

      emit(state.copyWith(
        playerHand: newHand,
        playerScore: pScore,
        enemyScore: eScore,
        lastEvent: resultText,
      ));
    });
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  // --- LOGIKA AI BARU ---
  // Menggantikan _generateRandomCard yang lama
  MatchCard _generateSmartEnemyCard(int scoreDiff) {
    int roll = _rng.nextInt(100);
    CardType selectedType;

    // LOGIKA:
    // scoreDiff < 0 : Musuh Kalah -> Panik Menyerang (Attack)
    // scoreDiff > 0 : Musuh Menang -> Bertahan (Defend)
    // scoreDiff == 0 : Seri -> Seimbang

    if (scoreDiff < 0) { // Musuh Tertinggal
      if (roll < 60) selectedType = CardType.attack;      // 60% Attack
      else if (roll < 90) selectedType = CardType.skill;  // 30% Skill
      else selectedType = CardType.defend;                // 10% Defend
    } else if (scoreDiff > 0) { // Musuh Unggul
      if (roll < 60) selectedType = CardType.defend;      // 60% Defend (Parkir Bus)
      else if (roll < 90) selectedType = CardType.skill;
      else selectedType = CardType.attack;
    } else { // Seri
      if (roll < 33) selectedType = CardType.attack;
      else if (roll < 66) selectedType = CardType.defend;
      else selectedType = CardType.skill;
    }

    // Power acak 50-100
    final power = 50 + _rng.nextInt(51);
    
    // Nama Keren
    String name = "Action";
    if (selectedType == CardType.attack) name = ["Power Shot", "Volley", "Header", "Counter"][_rng.nextInt(4)];
    if (selectedType == CardType.skill) name = ["Through Pass", "Dribble", "Rabona", "Tiki-Taka"][_rng.nextInt(4)];
    if (selectedType == CardType.defend) name = ["Slide Tackle", "Block", "Intercept", "Offside Trap"][_rng.nextInt(4)];

    return MatchCard(name: name, type: selectedType, power: power);
  }
}