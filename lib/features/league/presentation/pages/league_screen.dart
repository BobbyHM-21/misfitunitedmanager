import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../logic/league_cubit.dart';
import '../../logic/league_state.dart';
import '../../data/team_model.dart';

class LeagueScreen extends StatelessWidget {
  const LeagueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("CYBER LEAGUE STANDINGS", style: TextStyle(fontFamily: 'Rajdhani', fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<LeagueCubit, LeagueState>(
        builder: (context, state) {
          if (state is LeagueLoaded) {
            return Column(
              children: [
                // HEADER TABEL
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  color: Colors.white10,
                  child: const Row(
                    children: [
                      SizedBox(width: 30, child: Text("#", style: TextStyle(color: Colors.grey))),
                      Expanded(child: Text("CLUB", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                      SizedBox(width: 30, child: Text("P", style: TextStyle(color: Colors.grey), textAlign: TextAlign.center)),
                      SizedBox(width: 30, child: Text("W", style: TextStyle(color: Colors.grey), textAlign: TextAlign.center)),
                      SizedBox(width: 30, child: Text("D", style: TextStyle(color: Colors.grey), textAlign: TextAlign.center)),
                      SizedBox(width: 30, child: Text("L", style: TextStyle(color: Colors.grey), textAlign: TextAlign.center)),
                      SizedBox(width: 40, child: Text("PTS", style: TextStyle(color: AppColors.electricCyan, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                    ],
                  ),
                ),
                
                // LIST TIM
                Expanded(
                  child: ListView.builder(
                    itemCount: state.teams.length,
                    itemBuilder: (context, index) {
                      final team = state.teams[index];
                      return _buildTeamRow(team, index + 1);
                    },
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildTeamRow(TeamModel team, int rank) {
    // Highlight tim kita
    Color bgColor = team.isPlayerTeam ? AppColors.electricCyan.withOpacity(0.15) : Colors.transparent;
    Color textColor = team.isPlayerTeam ? AppColors.electricCyan : Colors.white;
    FontWeight weight = team.isPlayerTeam ? FontWeight.bold : FontWeight.normal;

    // Warna Peringkat (1-3 Emas/Kuning, 9-10 Merah/Degradasi)
    Color rankColor = Colors.grey;
    if (rank <= 3) rankColor = AppColors.neonYellow; 
    if (rank >= 9) rankColor = Colors.red;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text("$rank", style: TextStyle(color: rankColor, fontWeight: FontWeight.bold))),
          Expanded(child: Text(team.name, style: TextStyle(color: textColor, fontWeight: weight, fontFamily: 'Rajdhani'))),
          SizedBox(width: 30, child: Text("${team.played}", style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center)),
          SizedBox(width: 30, child: Text("${team.won}", style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center)),
          SizedBox(width: 30, child: Text("${team.drawn}", style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center)),
          SizedBox(width: 30, child: Text("${team.lost}", style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center)),
          SizedBox(width: 40, child: Text("${team.points}", style: const TextStyle(color: AppColors.neonYellow, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}