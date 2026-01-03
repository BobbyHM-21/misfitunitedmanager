import 'package:equatable/equatable.dart';
import 'package:misfitunited/features/squad_management/data/player_model.dart';

abstract class SquadState extends Equatable {
  const SquadState();
  
  @override
  List<Object> get props => [];
}

// Kondisi Awal (Kosong/Loading)
class SquadInitial extends SquadState {}

// Kondisi Data Siap
class SquadLoaded extends SquadState {
  final List<Player> players;

  const SquadLoaded({required this.players});

  // Fitur copyWith (Penting untuk update list nanti)
  SquadLoaded copyWith({List<Player>? players}) {
    return SquadLoaded(
      players: players ?? this.players,
    );
  }

  @override
  List<Object> get props => [players];
}