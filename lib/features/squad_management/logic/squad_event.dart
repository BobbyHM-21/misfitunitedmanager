import 'package:equatable/equatable.dart';
import '../data/player_model.dart';

abstract class SquadEvent extends Equatable {
  const SquadEvent();
  @override
  List<Object> get props => [];
}

class LoadSquad extends SquadEvent {}

class AddPlayerToSquad extends SquadEvent {
  final Player player;
  const AddPlayerToSquad(this.player);
  @override
  List<Object> get props => [player];
}

// Event untuk menyembuhkan satu pemain
class RecoverStamina extends SquadEvent {
  final Player player;
  const RecoverStamina(this.player);
  @override
  List<Object> get props => [player];
}

// [BARU] Event untuk menyembuhkan SEMUA pemain
class RecoverAllStamina extends SquadEvent {}

class ReduceStaminaForStarters extends SquadEvent {}

class SellPlayer extends SquadEvent {
  final Player player;
  const SellPlayer(this.player);
  @override
  List<Object> get props => [player];
}

// [BARU] Event Drag & Drop (Geser Posisi)
class ReorderSquad extends SquadEvent {
  final int oldIndex;
  final int newIndex;
  const ReorderSquad(this.oldIndex, this.newIndex);
  
  @override
  List<Object> get props => [oldIndex, newIndex];
}