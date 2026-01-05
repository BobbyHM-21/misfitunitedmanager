import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/save_service.dart';
import '../data/league_models.dart';
import 'league_state.dart';

class LeagueCubit extends Cubit<LeagueState> {
  LeagueCubit() : super(LeagueInitial());

  final Random _rng = Random();

  final List<String> _teamNames = [
    "MISFIT UNITED", "CYBER FC", "NEON CITY", "TOKYO RAIDERS", "SOLARIS UNITED",
    "LUNAR ELITE", "VOID WANDERERS", "TITAN HEAVY", "ATLAS CORE", "ZENITH PRIME",
    "OMEGA SECTOR", "FLUX ACADEMY", "CRIMSON SYNDICATE", "AZURE KNIGHTS", "QUANTUM XI",
    "VELOCITY STAR", "ECHO RANGERS", "PHANTOM OPERATORS", "IRON LEGION", "NOVA UNION"
  ];

  // --- 1. INISIALISASI LIGA (LOAD / NEW) ---
  void initLeague() async {
    // Tampilkan Loading State agar UI tahu
    emit(LeagueLoading());

    // Coba Load Data dari HP
    Map<String, dynamic>? savedData = await SaveService.loadLeague();

    if (savedData != null) {
      // [LOAD GAME]
      try {
        List<TeamModel> loadedTeams = (savedData['teams'] as List)
            .map((e) => TeamModel.fromJson(e)).toList();
        
        List<List<FixtureModel>> loadedSchedule = (savedData['schedule'] as List)
            .map((round) => (round as List).map((f) => FixtureModel.fromJson(f)).toList())
            .toList();

        List<PlayerStatEntry> loadedScorers = (savedData['topScorers'] as List)
            .map((e) => PlayerStatEntry.fromJson(e)).toList();

        emit(LeagueLoaded(
          teams: loadedTeams,
          schedule: loadedSchedule,
          currentMatchday: savedData['currentMatchday'],
          topScorers: loadedScorers,
          topAssists: [],
        ));
      } catch (e) {
        // Jika data corrupt, buat baru
        print("Error loading data: $e");
        startNewSeason(); 
      }
    } else {
      // [NEW GAME]
      startNewSeason();
    }
  }

  // --- 2. LOGIKA SELESAI MATCH ---
  void finishMatchday(int userGoals, int enemyGoals, List<String> userScorers) {
    if (state is LeagueLoaded) {
      final currentState = state as LeagueLoaded;
      int currentDayIndex = currentState.currentMatchday - 1; 
      
      // Cek apakah musim sudah selesai
      if (currentDayIndex >= currentState.schedule.length) {
        return;
      }

      List<TeamModel> updatedTeams = List.from(currentState.teams);
      List<FixtureModel> currentFixtures = List.from(currentState.schedule[currentDayIndex]);
      List<FixtureModel> updatedFixtures = [];
      List<PlayerStatEntry> updatedScorers = List.from(currentState.topScorers);

      // A. Update Statistik User (Pemain Kita)
      for (var scorerName in userScorers) {
        _updateTopStats(updatedScorers, scorerName, "MISFIT UNITED", 1);
      }

      // B. Simulasi Match Lain (AI vs AI)
      for (var fixture in currentFixtures) {
        String home = fixture.homeTeam;
        String away = fixture.awayTeam;
        int hScore = 0;
        int aScore = 0;

        // Jika ini match kita, pakai skor asli dari parameter
        if (home == "MISFIT UNITED") {
          hScore = userGoals; aScore = enemyGoals;
        } else if (away == "MISFIT UNITED") {
          aScore = userGoals; hScore = enemyGoals;
        } else {
          // Simulasi Random
          hScore = _rng.nextInt(4); 
          aScore = _rng.nextInt(4);
          
          if (hScore > 0) _generateAiScorers(updatedScorers, home, hScore);
          if (aScore > 0) _generateAiScorers(updatedScorers, away, aScore);
        }

        // Update Poin & Gol Tim
        _updateTeamStats(updatedTeams, home, hScore, aScore);
        _updateTeamStats(updatedTeams, away, aScore, hScore);

        updatedFixtures.add(fixture.copyWith(
          homeScore: hScore, awayScore: aScore, isPlayed: true
        ));
      }

      // Update Jadwal
      List<List<FixtureModel>> fullSchedule = List.from(currentState.schedule);
      fullSchedule[currentDayIndex] = updatedFixtures;

      // Sort Klasemen (Poin -> Selisih Gol -> Menang)
      updatedTeams.sort((a, b) {
        int pointCmp = b.points.compareTo(a.points);
        if (pointCmp != 0) return pointCmp;
        return (b.won - b.lost).compareTo(a.won - a.lost);
      });

      // Sort Top Skor
      updatedScorers.sort((a, b) => b.value.compareTo(a.value));

      int nextMatchday = currentState.currentMatchday + 1;

      // Simpan Data Terbaru
      _saveCurrentState(updatedTeams, fullSchedule, nextMatchday, updatedScorers);

      emit(LeagueLoaded(
        teams: updatedTeams,
        schedule: fullSchedule,
        currentMatchday: nextMatchday,
        topScorers: updatedScorers.take(20).toList(),
        topAssists: [],
      ));
    }
  }

  // --- 3. FITUR AKHIR MUSIM ---

  // Hitung Hadiah Uang (Prize Money)
  int getSeasonPrize() {
    if (state is LeagueLoaded) {
      final teams = (state as LeagueLoaded).teams;
      int position = teams.indexWhere((t) => t.isPlayerTeam) + 1;
      if (position == 0) return 0;
      
      // Juara 1 = $5000, Posisi 20 = $250
      return 250 + ((21 - position) * 250);
    }
    return 0;
  }

  // Mulai Musim Baru (Reset Liga)
  void startNewSeason() {
    emit(LeagueLoading());

    // Reset Statistik Tim
    List<TeamModel> newTeams = _teamNames.map((name) {
      return TeamModel(name: name, isPlayerTeam: name == "MISFIT UNITED");
    }).toList();

    // Generate Jadwal Baru
    var newSchedule = _generateSchedule(_teamNames);
    int newMatchday = 1;
    List<PlayerStatEntry> emptyScorers = [];

    // Simpan Kondisi Awal Musim Baru
    _saveCurrentState(newTeams, newSchedule, newMatchday, emptyScorers);

    emit(LeagueLoaded(
      teams: newTeams,
      schedule: newSchedule,
      currentMatchday: newMatchday,
      topScorers: emptyScorers,
      topAssists: [],
    ));
  }

  // --- HELPER FUNCTIONS ---

  void _saveCurrentState(List<TeamModel> teams, List<List<FixtureModel>> schedule, int matchday, List<PlayerStatEntry> scorers) {
    SaveService.saveLeague({
      'teams': teams.map((e) => e.toJson()).toList(),
      'schedule': schedule.map((round) => round.map((f) => f.toJson()).toList()).toList(),
      'currentMatchday': matchday,
      'topScorers': scorers.map((e) => e.toJson()).toList(),
    });
  }

  void _updateTeamStats(List<TeamModel> teams, String teamName, int goalsFor, int goalsAgainst) {
    int index = teams.indexWhere((t) => t.name == teamName);
    if (index != -1) {
      var t = teams[index];
      int pts = 0;
      if (goalsFor > goalsAgainst) {
        pts = 3;
      } else if (goalsFor == goalsAgainst) {
        pts = 1;
      }

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
    String starPlayer = "FW ${teamName.split(' ')[0]}"; 
    for(int i=0; i<goals; i++) {
       if (_rng.nextDouble() > 0.3) {
         _updateTopStats(list, starPlayer, teamName, 1);
       } else {
         _updateTopStats(list, "MF ${teamName.split(' ')[0]}", teamName, 1);
       }
    }
  }

  List<List<FixtureModel>> _generateSchedule(List<String> teams) {
    List<String> shuffledTeams = List.from(teams);
    // Pastikan user tetap di posisi awal agar mudah di-track, tapi lawan diacak
    shuffledTeams.remove("MISFIT UNITED");
    shuffledTeams.shuffle();
    shuffledTeams.insert(0, "MISFIT UNITED");

    List<List<FixtureModel>> schedule = [];
    int totalRounds = (shuffledTeams.length - 1) * 2; 
    int matchesPerRound = shuffledTeams.length ~/ 2;
    List<String> roundTeams = List.from(shuffledTeams);

    for (int round = 0; round < totalRounds; round++) {
      List<FixtureModel> matchdayFixtures = [];
      for (int match = 0; match < matchesPerRound; match++) {
        int homeIdx = (round + match) % (shuffledTeams.length - 1);
        int awayIdx = (shuffledTeams.length - 1 - match + round) % (shuffledTeams.length - 1);
        
        if (match == 0) awayIdx = shuffledTeams.length - 1;

        String home = roundTeams[homeIdx];
        String away = roundTeams[awayIdx];

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