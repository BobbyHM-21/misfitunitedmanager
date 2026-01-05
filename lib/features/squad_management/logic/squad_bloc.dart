import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/save_service.dart';
import '../data/player_model.dart';
import 'squad_event.dart';
import 'squad_state.dart';

class SquadBloc extends Bloc<SquadEvent, SquadState> {
  List<Player> _currentSquad = [];

  SquadBloc() : super(SquadInitial()) {
    
    // 1. Load Data Saat Aplikasi Mulai
    on<LoadSquad>((event, emit) async {
      final savedPlayers = await SaveService.loadSquad();

      if (savedPlayers != null && savedPlayers.isNotEmpty) {
        _currentSquad = List.from(savedPlayers);
      } else {
        _currentSquad = List.from(Player.dummySquad);
        SaveService.saveSquad(_currentSquad);
      }
      emit(SquadLoaded(List.from(_currentSquad)));
    });

    on<AddPlayerToSquad>((event, emit) {
      if (state is SquadLoaded) {
        _currentSquad.add(event.player);
        SaveService.saveSquad(_currentSquad);
        emit(SquadLoaded(List.from(_currentSquad)));
      }
    });

    on<ReorderSquad>((event, emit) {
      if (state is SquadLoaded) {
        int newIndex = event.newIndex;
        if (newIndex > event.oldIndex) newIndex -= 1;
        final Player item = _currentSquad.removeAt(event.oldIndex);
        _currentSquad.insert(newIndex, item);
        SaveService.saveSquad(_currentSquad);
        emit(SquadLoaded(List.from(_currentSquad)));
      }
    });

    on<SellPlayer>((event, emit) {
      if (state is SquadLoaded) {
        _currentSquad.removeWhere((p) => p.name == event.player.name);
        SaveService.saveSquad(_currentSquad);
        emit(SquadLoaded(List.from(_currentSquad)));
      }
    });

    on<RecoverStamina>((event, emit) {
      if (state is SquadLoaded) {
        final index = _currentSquad.indexWhere((p) => p.name == event.player.name);
        if (index != -1) {
          _currentSquad[index] = _currentSquad[index].copyWith(stamina: 1.0);
          SaveService.saveSquad(_currentSquad);
          emit(SquadLoaded(List.from(_currentSquad)));
        }
      }
    });

    on<RecoverAllStamina>((event, emit) {
      if (state is SquadLoaded) {
        for (int i = 0; i < _currentSquad.length; i++) {
          _currentSquad[i] = _currentSquad[i].copyWith(stamina: 1.0);
        }
        SaveService.saveSquad(_currentSquad);
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
        SaveService.saveSquad(_currentSquad);
        emit(SquadLoaded(List.from(_currentSquad)));
      }
    });

    on<UpdatePlayerMatchStats>((event, emit) {
      if (state is SquadLoaded) {
        for (int i = 0; i < _currentSquad.length; i++) {
          if (i < 11) { // Hanya Starter
            Player p = _currentSquad[i];
            String name = p.name;

            // Update Statistik
            int newApps = p.seasonAppearances + 1;
            int goalsToAdd = event.goalScorers[name] ?? 0;
            int newGoals = p.seasonGoals + goalsToAdd;
            int assistsToAdd = event.assistMakers[name] ?? 0;
            int newAssists = p.seasonAssists + assistsToAdd;

            double matchRating = event.matchRatings[name] ?? 6.0;
            double totalRatingScore = (p.averageRating * p.seasonAppearances) + matchRating;
            if (p.seasonAppearances == 0) totalRatingScore = matchRating;
            double newAvgRating = double.parse((totalRatingScore / newApps).toStringAsFixed(1));

            // Hitung XP
            int gainedXp = (matchRating * 20).toInt(); 
            gainedXp += (goalsToAdd * 100);
            gainedXp += (assistsToAdd * 50);
            
            int finalXp = p.currentXp + gainedXp;
            int finalRating = p.rating;
            int finalTargetXp = p.xpToNextLevel;

            // Level Up Check
            if (finalXp >= p.xpToNextLevel) {
               finalXp = finalXp - p.xpToNextLevel;
               finalRating += 1;
               finalTargetXp += 200;
            }

            // Simpan perubahan ke List Memory
            _currentSquad[i] = p.copyWith(
              seasonAppearances: newApps,
              seasonGoals: newGoals,
              seasonAssists: newAssists,
              averageRating: newAvgRating,
              rating: finalRating,
              currentXp: finalXp,
              xpToNextLevel: finalTargetXp,
            );
          }
        }
        
        SaveService.saveSquad(_currentSquad); 
        emit(SquadLoaded(List.from(_currentSquad)));
      }
    });

    // [BARU] LOGIC RESET MUSIM (STATISTIK KEMBALI 0, XP TETAP)
    on<ResetSeasonStats>((event, emit) {
      if (state is SquadLoaded) {
        // Reset statistik setiap pemain
        List<Player> resetSquad = _currentSquad.map((p) {
          return p.copyWith(
            seasonGoals: 0,
            seasonAssists: 0,
            seasonYellowCards: 0,
            seasonRedCards: 0,
            seasonAppearances: 0,
            averageRating: 6.0, // Reset rating rata-rata ke default
            // XP, Level, Stamina TIDAK DIUBAH (Progression aman)
          );
        }).toList();

        _currentSquad = resetSquad;
        
        // Simpan squad yang sudah di-reset
        SaveService.saveSquad(_currentSquad);
        
        emit(SquadLoaded(List.from(_currentSquad)));
      }
    });
  }
}