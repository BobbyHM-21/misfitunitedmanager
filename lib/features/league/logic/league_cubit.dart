import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/league_models.dart';
import 'league_state.dart';

class LeagueCubit extends Cubit<LeagueState> {
  LeagueCubit() : super(LeagueInitial());

  final Random _rng = Random();

  // Daftar 20 Tim untuk Liga Penuh
  final List<String> _teamNames = [
    "MISFIT UNITED", "CYBER FC", "NEON CITY", "TOKYO RAIDERS", "SOLARIS UNITED",
    "LUNAR ELITE", "VOID WANDERERS", "TITAN HEAVY", "ATLAS CORE", "ZENITH PRIME",
    "OMEGA SECTOR", "FLUX ACADEMY", "CRIMSON SYNDICATE", "AZURE KNIGHTS", "QUANTUM XI",
    "VELOCITY STAR", "ECHO RANGERS", "PHANTOM OPERATORS", "IRON LEGION", "NOVA UNION"
  ];

  // 1. Inisialisasi Liga (Awal Musim)
  void initLeague() {
    // Buat Model Tim
    List<TeamModel> initialTeams = _teamNames.map((name) {
      return TeamModel(name: name, isPlayerTeam: name == "MISFIT UNITED");
    }).toList();

    // Generate Jadwal (Round Robin - Home & Away)
    var schedule = _generateSchedule(_teamNames);

    emit(LeagueLoaded(
      teams: initialTeams,
      schedule: schedule,
      currentMatchday: 1, // Mulai dari Matchday 1
      topScorers: [],
      topAssists: [],
    ));
  }

  // 2. Fungsi Selesai Match (Play Next Matchday)
  void finishMatchday(int userGoals, int enemyGoals, List<String> userScorers) {
    if (state is LeagueLoaded) {
      final currentState = state as LeagueLoaded;
      int currentDayIndex = currentState.currentMatchday - 1; // Array index mulai 0
      
      // Jika musim sudah habis, reset
      if (currentDayIndex >= currentState.schedule.length) {
        initLeague(); // Reset Season
        return;
      }

      List<TeamModel> updatedTeams = List.from(currentState.teams);
      List<FixtureModel> currentFixtures = List.from(currentState.schedule[currentDayIndex]);
      List<FixtureModel> updatedFixtures = [];
      List<PlayerStatEntry> updatedScorers = List.from(currentState.topScorers);

      // A. Update Statistik Pencetak Gol User
      for (var scorerName in userScorers) {
        _updateTopStats(updatedScorers, scorerName, "MISFIT UNITED", 1);
      }

      // B. Simulasi Seluruh Pertandingan di Matchday Ini
      for (var fixture in currentFixtures) {
        String home = fixture.homeTeam;
        String away = fixture.awayTeam;
        int hScore = 0;
        int aScore = 0;

        // Cek mana match kita (Gunakan skor asli dari user)
        if (home == "MISFIT UNITED") {
          hScore = userGoals; aScore = enemyGoals;
        } else if (away == "MISFIT UNITED") {
          aScore = userGoals; hScore = enemyGoals;
        } else {
          // Simulasi AI vs AI (Skor Acak)
          // Beri sedikit keunggulan acak untuk variasi
          hScore = _rng.nextInt(4); // 0-3 gol
          aScore = _rng.nextInt(4);
          
          // Generate Random Scorer untuk AI (Agar Leaderboard hidup)
          if (hScore > 0) _generateAiScorers(updatedScorers, home, hScore);
          if (aScore > 0) _generateAiScorers(updatedScorers, away, aScore);
        }

        // Update Data Klasemen (Poin)
        _updateTeamStats(updatedTeams, home, hScore, aScore);
        _updateTeamStats(updatedTeams, away, aScore, hScore);

        // Simpan Hasil di Jadwal
        updatedFixtures.add(fixture.copyWith(
          homeScore: hScore, awayScore: aScore, isPlayed: true
        ));
      }

      // Update Jadwal Global
      List<List<FixtureModel>> fullSchedule = List.from(currentState.schedule);
      fullSchedule[currentDayIndex] = updatedFixtures;

      // Sorting Klasemen (Points > Goal Diff)
      updatedTeams.sort((a, b) {
        int pointCmp = b.points.compareTo(a.points);
        if (pointCmp != 0) return pointCmp;
        return (b.won - b.lost).compareTo(a.won - a.lost);
      });

      // Sorting Top Scorers
      updatedScorers.sort((a, b) => b.value.compareTo(a.value));

      // Emit State Baru (Matchday + 1)
      emit(LeagueLoaded(
        teams: updatedTeams,
        schedule: fullSchedule,
        currentMatchday: currentState.currentMatchday + 1,
        topScorers: updatedScorers.take(20).toList(), // Ambil Top 20
      ));
    }
  }

  // --- HELPER FUNCTIONS ---

  void _updateTeamStats(List<TeamModel> teams, String teamName, int goalsFor, int goalsAgainst) {
    int index = teams.indexWhere((t) => t.name == teamName);
    if (index != -1) {
      var t = teams[index];
      int pts = 0;
      if (goalsFor > goalsAgainst) pts = 3;
      else if (goalsFor == goalsAgainst) pts = 1;

      teams[index] = t.copyWith(
        played: t.played + 1,
        won: t.won + (goalsFor > goalsAgainst ? 1 : 0),
        drawn: t.drawn + (goalsFor == goalsAgainst ? 1 : 0),
        lost: t.lost + (goalsFor < goalsAgainst ? 1 : 0),
        points: t.points + pts
      );
    }
  }

  void _updateTopStats(List<PlayerStatEntry> list, String playerName, String team, int add) {
    int index = list.indexWhere((e) => e.name == playerName && e.teamName == team);
    if (index != -1) {
      list[index] = PlayerStatEntry(playerName, team, list[index].value + add);
    } else {
      list.add(PlayerStatEntry(playerName, team, add));
    }
  }

  void _generateAiScorers(List<PlayerStatEntry> list, String teamName, int goals) {
    // Simulasi nama pemain AI (e.g. "Striker Cyber")
    // Kita buat nama tetap untuk setiap tim agar bisa bersaing di top skor
    String starPlayer = "FW ${teamName.split(' ')[0]}"; 
    // Distribusikan gol
    for(int i=0; i<goals; i++) {
       // 70% chance gol dicetak star player
       if (_rng.nextDouble() > 0.3) {
         _updateTopStats(list, starPlayer, teamName, 1);
       } else {
         _updateTopStats(list, "MF ${teamName.split(' ')[0]}", teamName, 1);
       }
    }
  }

  // ALGORITMA ROUND ROBIN (Generate Jadwal)
  List<List<FixtureModel>> _generateSchedule(List<String> teams) {
    List<List<FixtureModel>> schedule = [];
    int totalRounds = (teams.length - 1) * 2; // Home & Away
    int matchesPerRound = teams.length ~/ 2;
    List<String> roundTeams = List.from(teams);

    for (int round = 0; round < totalRounds; round++) {
      List<FixtureModel> matchdayFixtures = [];
      for (int match = 0; match < matchesPerRound; match++) {
        int homeIdx = (round + match) % (teams.length - 1);
        int awayIdx = (teams.length - 1 - match + round) % (teams.length - 1);
        
        // Tim terakhir fix di posisi akhir array untuk rotasi
        if (match == 0) awayIdx = teams.length - 1;

        String home = roundTeams[homeIdx];
        String away = roundTeams[awayIdx];

        // Swap Home/Away setiap putaran kedua (Second Leg)
        if (round >= totalRounds / 2) {
          String temp = home; home = away; away = temp;
        }

        matchdayFixtures.add(FixtureModel(
          homeTeam: home, awayTeam: away, matchday: round + 1
        ));
      }
      schedule.add(matchdayFixtures);
    }
    return schedule;
  }
}