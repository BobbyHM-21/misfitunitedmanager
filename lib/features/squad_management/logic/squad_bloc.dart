import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/player_model.dart';
import 'squad_event.dart';
import 'squad_state.dart';

class SquadBloc extends Bloc<SquadEvent, SquadState> {
  List<Player> _currentSquad = [];

  SquadBloc() : super(SquadInitial()) {
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

    // [BARU] LOGIKA DRAG & DROP
    on<ReorderSquad>((event, emit) {
      if (state is SquadLoaded) {
        int newIndex = event.newIndex;
        if (newIndex > event.oldIndex) {
          newIndex -= 1;
        }
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

    // [BARU] LOGIKA HEAL ALL
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
            final newStamina = (p.stamina - 0.15).clamp(0.0, 1.0);
            _currentSquad[i] = p.copyWith(stamina: newStamina);
          }
        }
        emit(SquadLoaded(List.from(_currentSquad)));
      }
    });
  }
}