import 'package:equatable/equatable.dart';
import '../data/league_models.dart';

abstract class LeagueState extends Equatable {
  const LeagueState();
  @override
  List<Object> get props => [];
}

class LeagueInitial extends LeagueState {}

class LeagueLoaded extends LeagueState {
  final List<TeamModel> teams; // Klasemen
  final List<List<FixtureModel>> schedule; // Jadwal [Week 1, Week 2...]
  final int currentMatchday; // 1 - 38
  
  // Statistik Liga
  final List<PlayerStatEntry> topScorers;
  final List<PlayerStatEntry> topAssists;

  const LeagueLoaded({
    required this.teams,
    required this.schedule,
    required this.currentMatchday,
    this.topScorers = const [],
    this.topAssists = const [],
  });

  // Helper: Ambil lawan tim kita di matchday saat ini
  String getNextOpponent() {
    if (currentMatchday > schedule.length) return "Season Finished";
    
    // Cari fixture dimana salah satu timnya adalah "MISFIT UNITED"
    final currentFixtures = schedule[currentMatchday - 1];
    final myFixture = currentFixtures.firstWhere(
      (f) => f.homeTeam == "MISFIT UNITED" || f.awayTeam == "MISFIT UNITED",
      orElse: () => FixtureModel(homeTeam: "-", awayTeam: "-", matchday: 0),
    );

    if (myFixture.homeTeam == "MISFIT UNITED") return myFixture.awayTeam;
    return myFixture.homeTeam;
  }

  @override
  List<Object> get props => [teams, schedule, currentMatchday, topScorers, topAssists];
}