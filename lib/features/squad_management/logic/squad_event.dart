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

class RecoverStamina extends SquadEvent {
  final Player player;
  const RecoverStamina(this.player);
  @override
  List<Object> get props => [player];
}

class RecoverAllStamina extends SquadEvent {}

class ReduceStaminaForStarters extends SquadEvent {}

class SellPlayer extends SquadEvent {
  final Player player;
  const SellPlayer(this.player);
  @override
  List<Object> get props => [player];
}

class ReorderSquad extends SquadEvent {
  final int oldIndex;
  final int newIndex;
  const ReorderSquad(this.oldIndex, this.newIndex);
  @override
  List<Object> get props => [oldIndex, newIndex];
}

// [BARU] Event untuk Update Statistik Pasca-Match
class UpdatePlayerMatchStats extends SquadEvent {
  final Map<String, int> goalScorers; // Nama: Jumlah Gol
  final Map<String, int> assistMakers; // Nama: Jumlah Assist
  final Map<String, double> matchRatings; // Nama: Rating Match Ini
  
  const UpdatePlayerMatchStats({
    required this.goalScorers,
    required this.assistMakers,
    required this.matchRatings,
  });

  @override
  List<Object> get props => [goalScorers, assistMakers, matchRatings];
}