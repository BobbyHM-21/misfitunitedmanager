import 'package:equatable/equatable.dart';
import 'package:misfitunited/features/squad_management/data/player_model.dart';

abstract class SquadEvent extends Equatable {
  const SquadEvent();

  @override
  List<Object> get props => [];
}

// 1. Perintah untuk memuat data pemain saat aplikasi buka
class LoadSquad extends SquadEvent {}

// 2. (Nanti) Perintah untuk memulihkan stamina dengan membayar
class HealPlayer extends SquadEvent {
  final String playerId;
  const HealPlayer(this.playerId);

  @override
  List<Object> get props => [playerId];
}
// Event saat berhasil beli pemain
class AddPlayerToSquad extends SquadEvent {
  final Player newPlayer;
  const AddPlayerToSquad(this.newPlayer);

  @override
  List<Object> get props => [newPlayer];
}
// Event Tukar Posisi (Misal: Cadangan masuk ke Inti)
class SwapPlayers extends SquadEvent {
  final int index1;
  final int index2;

  const SwapPlayers(this.index1, this.index2);

  @override
  List<Object> get props => [index1, index2];
}