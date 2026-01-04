import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:misfitunited/features/squad_management/data/player_model.dart';
import 'squad_event.dart';
import 'squad_state.dart';

class SquadBloc extends Bloc<SquadEvent, SquadState> {
  SquadBloc() : super(SquadInitial()) {
    
    // 1. LOAD DATA
    on<LoadSquad>((event, emit) async {
      await Future.delayed(const Duration(milliseconds: 500));
      final initialPlayers = Player.dummySquad; 
      emit(SquadLoaded(players: initialPlayers));
    });

    // 2. TAMBAH PEMAIN
    on<AddPlayerToSquad>((event, emit) {
      if (state is SquadLoaded) {
        final currentList = (state as SquadLoaded).players;
        final newList = List<Player>.from(currentList)..add(event.newPlayer);
        emit(SquadLoaded(players: newList));
      }
    });

    // 3. SWAP POSISI
    on<SwapPlayers>((event, emit) {
      if (state is SquadLoaded) {
        final currentList = List<Player>.from((state as SquadLoaded).players);
        if (event.index1 < currentList.length && event.index2 < currentList.length) {
          final temp = currentList[event.index1];
          currentList[event.index1] = currentList[event.index2];
          currentList[event.index2] = temp;
          emit(SquadLoaded(players: currentList));
        }
      }
    });

    // 4. BARU: KURANGI STAMINA (11 Pemain Inti)
    on<ReduceStaminaForStarters>((event, emit) {
      if (state is SquadLoaded) {
        final currentList = (state as SquadLoaded).players;
        List<Player> updatedList = [];

        for (int i = 0; i < currentList.length; i++) {
          Player p = currentList[i];
          // Hanya 11 pemain pertama yang capek
          if (i < 11) {
            // Kurangi 0.1 (10%), limit minimal 0.0
            double newStamina = (p.stamina - 0.1).clamp(0.0, 1.0);
            updatedList.add(p.copyWith(stamina: newStamina));
          } else {
            // Cadangan tetap segar
            updatedList.add(p);
          }
        }
        emit(SquadLoaded(players: updatedList));
      }
    });

    // 5. BARU: HEAL PLAYER
    on<HealPlayer>((event, emit) {
      if (state is SquadLoaded) {
        final currentList = (state as SquadLoaded).players;
        final updatedList = currentList.map((p) {
          // Jika nama pemain sama, reset stamina ke 1.0
          if (p.name == event.player.name) { 
             return p.copyWith(stamina: 1.0);
          }
          return p;
        }).toList();

        emit(SquadLoaded(players: updatedList));
      }
    });
  }
}