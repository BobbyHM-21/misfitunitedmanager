import 'package:equatable/equatable.dart';
import '../data/player_model.dart';

abstract class SquadState extends Equatable {
  const SquadState();
  @override
  List<Object> get props => [];
}

class SquadInitial extends SquadState {}

class SquadLoaded extends SquadState {
  final List<Player> players;

  // Positional Argument (agar tidak error 'missing named argument')
  const SquadLoaded(this.players);

  @override
  List<Object> get props => [players];
}