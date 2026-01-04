import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/team_model.dart';
import 'league_state.dart';

class LeagueCubit extends Cubit<LeagueState> {
  LeagueCubit() : super(LeagueInitial());

  final Random _rng = Random();

  // 1. Inisialisasi Liga (Data Awal Musim)
  void initLeague() {
    List<TeamModel> initialTeams = [
      TeamModel(name: "MISFIT UNITED", isPlayerTeam: true), // Tim Kita
      TeamModel(name: "CYBER FC"),
      TeamModel(name: "NEON CITY"),
      TeamModel(name: "TOKYO RAIDERS"),
      TeamModel(name: "SOLARIS UNITED"),
      TeamModel(name: "LUNAR ELITE"),
      TeamModel(name: "VOID WANDERERS"),
      TeamModel(name: "TITAN HEAVY"),
      TeamModel(name: "ATLAS CORE"),
      TeamModel(name: "ZENITH PRIME"),
    ];
    
    emit(LeagueLoaded(initialTeams));
  }

  // 2. Update Klasemen Setelah Match Selesai
  void updateLeagueAfterMatch(int myScore, int enemyScore) {
    if (state is LeagueLoaded) {
      List<TeamModel> currentTeams = (state as LeagueLoaded).teams;
      List<TeamModel> updatedTeams = [];

      for (var team in currentTeams) {
        if (team.isPlayerTeam) {
          // UPDATE TIM KITA (Berdasarkan Skor Asli)
          int pts = team.points;
          int w = team.won;
          int d = team.drawn;
          int l = team.lost;

          if (myScore > enemyScore) {
            pts += 3; 
            w++; 
          } else if (myScore == enemyScore) {
            pts += 1; 
            d++; 
          } else {
            l++; 
          }

          updatedTeams.add(team.copyWith(
            played: team.played + 1,
            won: w, drawn: d, lost: l,
            points: pts
          ));
        } else {
          // SIMULASI TIM LAIN (RNG Match)
          // Tim AI juga "bertanding" agar poinnya berubah
          int outcome = _rng.nextInt(3); // 0: Kalah, 1: Seri, 2: Menang
          
          int pts = team.points;
          int w = team.won;
          int d = team.drawn;
          int l = team.lost;

          if (outcome == 2) { 
            pts += 3; 
            w++; 
          } else if (outcome == 1) { 
            pts += 1; 
            d++; 
          } else { 
            l++; 
          }

          updatedTeams.add(team.copyWith(
            played: team.played + 1,
            won: w, drawn: d, lost: l,
            points: pts
          ));
        }
      }

      // SORTING: Urutkan berdasarkan Poin Tertinggi -> Terendah
      updatedTeams.sort((a, b) => b.points.compareTo(a.points));

      emit(LeagueLoaded(updatedTeams));
    }
  }
}