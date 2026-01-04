import 'package:equatable/equatable.dart';
import 'package:misfitunited/features/squad_management/data/player_model.dart';

abstract class SquadEvent extends Equatable {
  const SquadEvent();

  @override
  List<Object> get props => [];
}

// 1. Load Data
class LoadSquad extends SquadEvent {}

// 2. Tambah Pemain (Beli)
class AddPlayerToSquad extends SquadEvent {
  final Player newPlayer;
  const AddPlayerToSquad(this.newPlayer);

  @override
  List<Object> get props => [newPlayer];
}

// 3. Tukar Posisi
class SwapPlayers extends SquadEvent {
  final int index1;
  final int index2;
  const SwapPlayers(this.index1, this.index2);

  @override
  List<Object> get props => [index1, index2];
}

// 4. BARU: Kurangi Stamina Pemain Inti
class ReduceStaminaForStarters extends SquadEvent {}

// 5. BARU: Sembuhkan Pemain (Heal)
class HealPlayer extends SquadEvent {
  final Player player; 
  const HealPlayer(this.player);

  @override
  List<Object> get props => [player];
}