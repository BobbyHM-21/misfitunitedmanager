import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/player_model.dart';
import 'squad_event.dart';
import 'squad_state.dart';

class SquadBloc extends Bloc<SquadEvent, SquadState> {
  List<Player> _currentSquad = [];

  SquadBloc() : super(SquadInitial()) {
    _currentSquad = List.from(Player.dummySquad);
    
    // ... (Event lain seperti LoadSquad, AddPlayer, Reorder tetap sama, tidak perlu dihapus) ...
    // LANGSUNG SAJA TIMPA BAGIAN INI:

    on<LoadSquad>((event, emit) {
      emit(SquadLoaded(List.from(_currentSquad)));
    });

    on<AddPlayerToSquad>((event, emit) {
      if (state is SquadLoaded) {
        _currentSquad.add(event.player);
        emit(SquadLoaded(List.from(_currentSquad)));
      }
    });

    on<ReorderSquad>((event, emit) {
      if (state is SquadLoaded) {
        int newIndex = event.newIndex;
        if (newIndex > event.oldIndex) newIndex -= 1;
        final Player item = _currentSquad.removeAt(event.oldIndex);
        _currentSquad.insert(newIndex, item);
        emit(SquadLoaded(List.from(_currentSquad)));
      }
    });

    on<SellPlayer>((event, emit) {
      if (state is SquadLoaded) {
        _currentSquad.removeWhere((p) => p.name == event.player.name);
        emit(SquadLoaded(List.from(_currentSquad)));
      }
    });

    on<RecoverStamina>((event, emit) {
      if (state is SquadLoaded) {
        final index = _currentSquad.indexWhere((p) => p.name == event.player.name);
        if (index != -1) {
          _currentSquad[index] = _currentSquad[index].copyWith(stamina: 1.0);
          emit(SquadLoaded(List.from(_currentSquad)));
        }
      }
    });

    on<RecoverAllStamina>((event, emit) {
      if (state is SquadLoaded) {
        for (int i = 0; i < _currentSquad.length; i++) {
          _currentSquad[i] = _currentSquad[i].copyWith(stamina: 1.0);
        }
        emit(SquadLoaded(List.from(_currentSquad)));
      }
    });

    on<ReduceStaminaForStarters>((event, emit) {
      if (state is SquadLoaded) {
        for (int i = 0; i < _currentSquad.length; i++) {
          if (i < 11) { 
            final p = _currentSquad[i];
            final newStamina = (p.stamina - 0.1).clamp(0.0, 1.0);
            _currentSquad[i] = p.copyWith(stamina: newStamina);
          }
        }
        emit(SquadLoaded(List.from(_currentSquad)));
      }
    });

    // [BAGIAN PENTING: LOGIC UPDATE STATISTIK & XP]
    on<UpdatePlayerMatchStats>((event, emit) {
      if (state is SquadLoaded) {
        for (int i = 0; i < _currentSquad.length; i++) {
          // Hanya starter (index 0-10) yang dapat update
          if (i < 11) {
            Player p = _currentSquad[i];
            String name = p.name;

            // 1. Update Statistik
            int newApps = p.seasonAppearances + 1;
            int goalsToAdd = event.goalScorers[name] ?? 0;
            int newGoals = p.seasonGoals + goalsToAdd;
            int assistsToAdd = event.assistMakers[name] ?? 0;
            int newAssists = p.seasonAssists + assistsToAdd;

            double matchRating = event.matchRatings[name] ?? 6.0;
            double totalRatingScore = (p.averageRating * p.seasonAppearances) + matchRating;
            if (p.seasonAppearances == 0) totalRatingScore = matchRating;
            double newAvgRating = double.parse((totalRatingScore / newApps).toStringAsFixed(1));

            // 2. [BARU] Hitung XP
            // Rumus: (Rating x 20) + (Gol x 100) + (Assist x 50)
            int gainedXp = (matchRating * 20).toInt(); 
            gainedXp += (goalsToAdd * 100);
            gainedXp += (assistsToAdd * 50);
            
            int finalXp = p.currentXp + gainedXp;
            int finalRating = p.rating;
            int finalTargetXp = p.xpToNextLevel;

            // 3. [BARU] Cek Level Up
            if (finalXp >= p.xpToNextLevel) {
               finalXp = finalXp - p.xpToNextLevel; // Sisa XP
               finalRating += 1; // Rating Naik!
               finalTargetXp += 200; // Target selanjutnya makin sulit
            }

            // Simpan
            _currentSquad[i] = p.copyWith(
              seasonAppearances: newApps,
              seasonGoals: newGoals,
              seasonAssists: newAssists,
              averageRating: newAvgRating,
              // Update RPG Data
              rating: finalRating,
              currentXp: finalXp,
              xpToNextLevel: finalTargetXp,
            );
          }
        }
        emit(SquadLoaded(List.from(_currentSquad)));
      }
    });
  }
}