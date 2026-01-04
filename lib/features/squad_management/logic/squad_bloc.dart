import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/player_model.dart';
import 'squad_event.dart';
import 'squad_state.dart';

class SquadBloc extends Bloc<SquadEvent, SquadState> {
  List<Player> _currentSquad = [];

  SquadBloc() : super(SquadInitial()) {
    // Init Data
    _currentSquad = List.from(Player.dummySquad);
    
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

    // [BARU] LOGIC UPDATE STATISTIK
    on<UpdatePlayerMatchStats>((event, emit) {
      if (state is SquadLoaded) {
        // Hanya update 11 pemain pertama (Starter) karena cuma mereka yang main
        for (int i = 0; i < _currentSquad.length; i++) {
          // Cek apakah dia Starter (Index 0-10)
          if (i < 11) {
            Player p = _currentSquad[i];
            String name = p.name;

            // 1. Tambah Jumlah Main (Apps)
            int newApps = p.seasonAppearances + 1;

            // 2. Tambah Gol
            int goalsToAdd = event.goalScorers[name] ?? 0;
            int newGoals = p.seasonGoals + goalsToAdd;

            // 3. Tambah Assist
            int assistsToAdd = event.assistMakers[name] ?? 0;
            int newAssists = p.seasonAssists + assistsToAdd;

            // 4. Hitung Rata-rata Rating Baru
            double matchRating = event.matchRatings[name] ?? 6.0;
            // Rumus Running Average: ((OldAvg * OldApps) + NewRating) / NewApps
            double totalRatingScore = (p.averageRating * p.seasonAppearances) + matchRating;
            // Jika ini match pertama, averageRating awal (6.0) tidak dihitung, langsung pakai matchRating
            if (p.seasonAppearances == 0) totalRatingScore = matchRating;
            
            double newAvgRating = double.parse((totalRatingScore / newApps).toStringAsFixed(1));

            // Simpan Update
            _currentSquad[i] = p.copyWith(
              seasonAppearances: newApps,
              seasonGoals: newGoals,
              seasonAssists: newAssists,
              averageRating: newAvgRating,
            );
          }
        }
        emit(SquadLoaded(List.from(_currentSquad)));
      }
    });
  }
}