import 'dart:async'; // Wajib import ini untuk StreamSubscription
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/match_card_model.dart';
import 'match_event.dart';
import 'match_state.dart';

class MatchBloc extends Bloc<MatchEvent, MatchState> {
  final Random _rng = Random();
  StreamSubscription<int>? _tickerSubscription; // Variable Timer

  MatchBloc() : super(MatchState()) {
    
    // 1. SAAT MATCH DIMULAI -> JALANKAN TIMER
    on<StartMatch>((event, emit) {
      // Reset State Awal
      final starterHand = List.generate(3, (_) => _generateRandomCard());
      emit(MatchState(playerHand: starterHand, lastEvent: "KICK OFF!"));

      // Mulai Timer: Nambah 1 menit setiap 1 detik (Bisa dipercepat nanti)
      _tickerSubscription?.cancel();
      _tickerSubscription = Stream.periodic(const Duration(seconds: 1), (x) => x + 1).listen((tick) {
        add(TimerTicked(tick)); // Panggil event TimerTicked
      });
    });

    // 2. LOGIKA SETIAP DETIK (TIMER TICKED)
    on<TimerTicked>((event, emit) {
      if (state.isMatchOver) return; // Stop jika sudah kelar

      if (event.minute >= 90) {
        // FULL TIME!
        _tickerSubscription?.cancel();
        emit(state.copyWith(
          gameMinute: 90,
          isMatchOver: true,
          lastEvent: "FULL TIME! WHISTLE BLOWN!",
        ));
      } else {
        // Lanjut jalan
        emit(state.copyWith(gameMinute: event.minute));
      }
    });

    // 3. LOGIKA MAIN KARTU (Sama seperti sebelumnya, tapi pakai copyWith)
    on<PlayCard>((event, emit) {
      if (state.isMatchOver) return; // Gak bisa main kartu kalau sudah bubar

      final playerCard = event.card;
      final enemyCard = _generateRandomCard();

      String resultText = "";
      int pScore = state.playerScore;
      int eScore = state.enemyScore;

      // Logika Duel (Simpel)
      if (playerCard.type == enemyCard.type) {
         // Seri
         resultText = "DRAW! (${playerCard.power} vs ${enemyCard.power})";
      } else if (playerCard.winsAgainst(enemyCard)) {
        resultText = "GOAL! ${playerCard.name} beats ${enemyCard.name}";
        pScore++;
      } else {
        resultText = "BLOCKED! ${enemyCard.name} stops attack";
        // eScore++; // Opsional
      }

      // Hapus & Draw Kartu Baru
      final newHand = List<MatchCard>.from(state.playerHand);
      newHand.remove(playerCard);
      newHand.add(_generateRandomCard());

      emit(state.copyWith(
        playerHand: newHand,
        playerScore: pScore,
        enemyScore: eScore,
        lastEvent: resultText,
      ));
    });
  }

  // Wajib tutup timer saat Bloc dihancurkan agar tidak memori leak
  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  MatchCard _generateRandomCard() {
    final type = CardType.values[_rng.nextInt(3)];
    final power = 50 + _rng.nextInt(51);
    String name = "Action";
    if (type == CardType.attack) name = ["Power Shot", "Volley", "Header"][_rng.nextInt(3)];
    if (type == CardType.skill) name = ["Through Pass", "Dribble", "Rabona"][_rng.nextInt(3)];
    if (type == CardType.defend) name = ["Tackle", "Block", "Intercept"][_rng.nextInt(3)];
    return MatchCard(name: name, type: type, power: power);
  }
}