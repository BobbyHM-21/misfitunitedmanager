import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/match_card_model.dart';
import '../data/goal_model.dart'; // Pastikan Anda sudah membuat file ini di langkah 1
import 'match_event.dart';
import 'match_state.dart';

class MatchBloc extends Bloc<MatchEvent, MatchState> {
  final Random _rng = Random();
  StreamSubscription<int>? _tickerSubscription;

  MatchBloc() : super(MatchState()) {
    
    // 1. EVENT MATCH START
    on<StartMatch>((event, emit) {
      // Generate 3 kartu awal untuk musuh (Smart AI default skor 0)
      final starterHand = List.generate(3, (_) => _generateSmartEnemyCard(0));
      
      emit(MatchState(
        playerHand: starterHand, 
        lastEvent: "KICK OFF!",
        squadNames: event.squadNames, // Simpan nama pemain
        matchGoals: [], // Reset daftar gol
      ));

      // Reset dan Jalankan Timer (1 detik = tambah 1 menit secara pasif)
      _tickerSubscription?.cancel();
      _tickerSubscription = Stream.periodic(const Duration(seconds: 1), (x) => x + 1).listen((tick) {
        add(TimerTicked(state.gameMinute + 1)); 
      });
    });

    // 2. EVENT TIMER TICKED
    on<TimerTicked>((event, emit) {
      if (state.isMatchOver) return;

      // Cek apakah waktu habis (90 menit)
      if (event.minute >= 90) {
        _finishMatch(emit);
      } else {
        emit(state.copyWith(gameMinute: event.minute));
      }
    });

    // 3. EVENT PLAY CARD (INTI PERMAINAN)
    on<PlayCard>((event, emit) {
      if (state.isMatchOver) return;

      // --- A. LOGIKA LOMPAT WAKTU (Time Skip) ---
      // Setiap kartu memakan waktu 10-15 menit agar game cepat selesai
      int timeConsumed = 10 + _rng.nextInt(6); 
      int newMinute = state.gameMinute + timeConsumed;

      // Jika waktu tembus 90, game berakhir
      if (newMinute >= 90) {
        _finishMatch(emit);
        return; // Stop eksekusi agar tidak ada gol di masa injury time yang lewat
      }

      // --- B. LOGIKA DUEL KARTU ---
      final playerCard = event.card;
      
      // AI Musuh Berpikir berdasarkan selisih skor
      final scoreDiff = state.enemyScore - state.playerScore;
      final enemyCard = _generateSmartEnemyCard(scoreDiff);

      String resultText = "";
      int pScore = state.playerScore;
      int eScore = state.enemyScore;
      
      // Salin daftar gol saat ini agar bisa ditambah
      List<GoalModel> currentGoals = List.from(state.matchGoals);

      if (playerCard.type == enemyCard.type) {
         // SERI (Draw)
         resultText = "DRAW! Duel at $newMinute'";
      } else if (playerCard.winsAgainst(enemyCard)) {
        // --- GOAL PEMAIN ---
        // Pilih nama pencetak gol secara acak dari Skuad
        String scorer = "Unknown Player";
        if (state.squadNames.isNotEmpty) {
          scorer = state.squadNames[_rng.nextInt(state.squadNames.length)];
        }
        
        resultText = "GOAL! $scorer scores!";
        pScore++;
        
        // Catat ke Statistik
        currentGoals.add(GoalModel(
          scorerName: scorer, 
          minute: newMinute, 
          isEnemyGoal: false
        ));

      } else {
        // --- BLOK / GOL MUSUH ---
        resultText = "SAVED! Enemy blocks at $newMinute'";
        
        // (Opsional: Aktifkan kode di bawah jika ingin musuh bisa mencetak gol juga)
        /*
        eScore++;
        resultText = "GOAL CONCEDED! Enemy scores!";
        currentGoals.add(GoalModel(
          scorerName: "Opponent", 
          minute: newMinute, 
          isEnemyGoal: true
        ));
        */
      }

      // --- C. UPDATE STATE ---
      // Hapus kartu yang dipakai
      final newHand = List<MatchCard>.from(state.playerHand);
      newHand.remove(playerCard);
      
      // Ambil kartu baru (Random/Smart AI Netral)
      newHand.add(_generateSmartEnemyCard(0)); 

      emit(state.copyWith(
        gameMinute: newMinute, // Update waktu yang sudah melompat
        playerHand: newHand,
        playerScore: pScore,
        enemyScore: eScore,
        lastEvent: resultText,
        matchGoals: currentGoals, // Update daftar gol
      ));
    });
  }

  // Helper untuk mengakhiri pertandingan
  void _finishMatch(Emitter<MatchState> emit) {
    _tickerSubscription?.cancel();
    emit(state.copyWith(
      gameMinute: 90,
      isMatchOver: true,
      lastEvent: "FULL TIME! WHISTLE BLOWN!",
    ));
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  // --- LOGIKA AI CERDAS (SMART ENEMY) ---
  MatchCard _generateSmartEnemyCard(int scoreDiff) {
    int roll = _rng.nextInt(100);
    CardType selectedType;

    if (scoreDiff < 0) { 
      // Musuh Kalah -> Panik Menyerang (Agresif)
      if (roll < 60) {
        selectedType = CardType.attack;      
      } else if (roll < 90) {
        selectedType = CardType.skill;  
      } else {
        selectedType = CardType.defend;                
      }
    } else if (scoreDiff > 0) { 
      // Musuh Menang -> Parkir Bus (Defensif)
      if (roll < 60) {
        selectedType = CardType.defend;      
      } else if (roll < 90) {
        selectedType = CardType.skill;
      } else {
        selectedType = CardType.attack;
      }
    } else { 
      // Seri -> Seimbang
      if (roll < 33) {
        selectedType = CardType.attack;
      } else if (roll < 66) {
        selectedType = CardType.defend;
      } else {
        selectedType = CardType.skill;
      }
    }

    // Power dan Nama Kartu
    final power = 50 + _rng.nextInt(51); // 50-100
    String name = "Action";
    
    if (selectedType == CardType.attack) {
      name = ["Power Shot", "Volley", "Header", "Counter"][_rng.nextInt(4)];
    }
    if (selectedType == CardType.skill) {
      name = ["Through Pass", "Dribble", "Rabona", "Tiki-Taka"][_rng.nextInt(4)];
    }
    if (selectedType == CardType.defend) {
      name = ["Tackle", "Block", "Intercept", "Offside Trap"][_rng.nextInt(4)];
    }

    return MatchCard(name: name, type: selectedType, power: power);
  }
}