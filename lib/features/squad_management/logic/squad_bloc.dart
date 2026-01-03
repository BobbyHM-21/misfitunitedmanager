import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:misfitunited/features/squad_management/data/player_model.dart';
import 'squad_event.dart';
import 'squad_state.dart';

class SquadBloc extends Bloc<SquadEvent, SquadState> {
  SquadBloc() : super(SquadInitial()) {
    
    // 1. Saat Event LoadSquad Dijalankan
    on<LoadSquad>((event, emit) async {
      // Simulasi loading sebentar
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Ambil data dummy dari Model (atau nanti dari Database)
      // Kita pakai data statis yang sudah Anda buat sebelumnya
      final initialPlayers = Player.dummySquad; 
      
      emit(SquadLoaded(players: initialPlayers));
    });

    // Logika Menambah Pemain
    on<AddPlayerToSquad>((event, emit) {
      if (state is SquadLoaded) {
        // Ambil list lama
        final currentList = (state as SquadLoaded).players;
        
        // Buat list baru (List lama + Pemain baru)
        final newList = List<Player>.from(currentList)..add(event.newPlayer);
        
        // Update State
        emit(SquadLoaded(players: newList));
      }
    });
    on<SwapPlayers>((event, emit) {
      if (state is SquadLoaded) {
        final currentList = List<Player>.from((state as SquadLoaded).players);
        
        // Cek range agar tidak error
        if (event.index1 < currentList.length && event.index2 < currentList.length) {
          // Lakukan Swap
          final temp = currentList[event.index1];
          currentList[event.index1] = currentList[event.index2];
          currentList[event.index2] = temp;
          
          emit(SquadLoaded(players: currentList));
        }
      }
    });
  }
}