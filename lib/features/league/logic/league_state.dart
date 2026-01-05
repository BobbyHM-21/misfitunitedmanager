import 'package:equatable/equatable.dart';
import '../data/league_models.dart';

abstract class LeagueState extends Equatable {
  const LeagueState();
  @override
  List<Object> get props => [];
}

// State Awal
class LeagueInitial extends LeagueState {}

// [WAJIB ADA] Agar tidak error "undefined name 'LeagueLoading'"
class LeagueLoading extends LeagueState {}

// State Data Loaded
class LeagueLoaded extends LeagueState {
  final List<TeamModel> teams; // Klasemen
  final List<List<FixtureModel>> schedule; // Jadwal
  final int currentMatchday;
  
  // Statistik
  final List<PlayerStatEntry> topScorers;
  final List<PlayerStatEntry> topAssists;

  const LeagueLoaded({
    required this.teams,
    required this.schedule,
    required this.currentMatchday,
    this.topScorers = const [],
    this.topAssists = const [],
  });

  // [FITUR ANDA: DIPERTAHANKAN]
  // Helper: Ambil lawan tim kita di matchday saat ini
  String getNextOpponent() {
    if (currentMatchday > schedule.length) return "Season Finished";
    
    // Safety check: pastikan index valid
    if (currentMatchday - 1 < 0 || currentMatchday - 1 >= schedule.length) return "-";

    final currentFixtures = schedule[currentMatchday - 1];
    
    try {
      final myFixture = currentFixtures.firstWhere(
        (f) => f.homeTeam == "MISFIT UNITED" || f.awayTeam == "MISFIT UNITED",
        orElse: () => FixtureModel(homeTeam: "-", awayTeam: "-", matchday: 0),
      );

      if (myFixture.homeTeam == "MISFIT UNITED") return myFixture.awayTeam;
      return myFixture.homeTeam;
    } catch (e) {
      return "-";
    }
  }

  @override
  List<Object> get props => [teams, schedule, currentMatchday, topScorers, topAssists];
}