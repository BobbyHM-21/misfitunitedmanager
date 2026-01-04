import 'package:equatable/equatable.dart';
import '../data/team_model.dart';

abstract class LeagueState extends Equatable {
  const LeagueState();
  @override
  List<Object> get props => [];
}

class LeagueInitial extends LeagueState {}

class LeagueLoaded extends LeagueState {
  final List<TeamModel> teams; // Daftar tim terurut

  const LeagueLoaded(this.teams);

  @override
  List<Object> get props => [teams];
}