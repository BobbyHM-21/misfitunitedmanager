import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../logic/league_cubit.dart';
import '../../logic/league_state.dart';
import '../../data/league_models.dart';

class LeagueScreen extends StatelessWidget {
  const LeagueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Table, Fixtures, Stats
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("LEAGUE CENTER", style: TextStyle(fontFamily: 'Rajdhani', fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: AppColors.electricCyan,
            labelColor: AppColors.electricCyan,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontFamily: 'Rajdhani', fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: "TABLE"),
              Tab(text: "FIXTURES"),
              Tab(text: "STATS"),
            ],
          ),
        ),
        body: BlocBuilder<LeagueCubit, LeagueState>(
          builder: (context, state) {
            if (state is LeagueLoaded) {
              return TabBarView(
                children: [
                  _buildTableTab(state),
                  _buildFixturesTab(state),
                  _buildStatsTab(state),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  // TAB 1: KLASEMEN
  Widget _buildTableTab(LeagueLoaded state) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          color: Colors.white10,
          child: const Row(
            children: [
              SizedBox(width: 30, child: Text("#", style: TextStyle(color: Colors.grey))),
              Expanded(child: Text("CLUB", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
              SizedBox(width: 30, child: Text("P", style: TextStyle(color: Colors.grey))),
              SizedBox(width: 30, child: Text("W", style: TextStyle(color: Colors.grey))),
              SizedBox(width: 30, child: Text("D", style: TextStyle(color: Colors.grey))),
              SizedBox(width: 30, child: Text("L", style: TextStyle(color: Colors.grey))),
              SizedBox(width: 40, child: Text("PTS", style: TextStyle(color: AppColors.electricCyan, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: state.teams.length,
            itemBuilder: (context, index) => _buildTeamRow(state.teams[index], index + 1),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamRow(TeamModel team, int rank) {
    Color textColor = team.isPlayerTeam ? AppColors.electricCyan : Colors.white;
    Color rankColor = rank <= 4 ? AppColors.neonYellow : (rank >= 18 ? Colors.red : Colors.grey);

    return Container(
      color: team.isPlayerTeam ? AppColors.electricCyan.withValues(alpha: 0.1) : Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text("$rank", style: TextStyle(color: rankColor, fontWeight: FontWeight.bold))),
          Expanded(child: Text(team.name, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontFamily: 'Rajdhani'))),
          SizedBox(width: 30, child: Text("${team.played}", style: const TextStyle(color: Colors.white70))),
          SizedBox(width: 30, child: Text("${team.won}", style: const TextStyle(color: Colors.white70))),
          SizedBox(width: 30, child: Text("${team.drawn}", style: const TextStyle(color: Colors.white70))),
          SizedBox(width: 30, child: Text("${team.lost}", style: const TextStyle(color: Colors.white70))),
          SizedBox(width: 40, child: Text("${team.points}", style: const TextStyle(color: AppColors.neonYellow, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  // TAB 2: JADWAL (FIXTURES)
  Widget _buildFixturesTab(LeagueLoaded state) {
    // Tampilkan Matchday saat ini di atas, lalu matchday sebelumnya
    return ListView.builder(
      itemCount: state.schedule.length,
      itemBuilder: (context, index) {
        final matchday = index + 1;
        final fixtures = state.schedule[index];
        final isCurrent = matchday == state.currentMatchday;
        final isPast = matchday < state.currentMatchday;

        return ExpansionTile(
          initiallyExpanded: isCurrent,
          title: Text(
            "MATCHDAY $matchday ${isCurrent ? "(CURRENT)" : ""}",
            style: TextStyle(
              color: isCurrent ? AppColors.neonYellow : (isPast ? Colors.grey : Colors.white),
              fontFamily: 'Rajdhani',
              fontWeight: FontWeight.bold
            ),
          ),
          children: fixtures.map((f) => Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(f.homeTeam, textAlign: TextAlign.right, style: TextStyle(color: f.homeTeam == "MISFIT UNITED" ? AppColors.electricCyan : Colors.white))),
                Container(
                  width: 60,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    f.isPlayed ? "${f.homeScore} - ${f.awayScore}" : "VS",
                    style: TextStyle(fontWeight: FontWeight.bold, color: f.isPlayed ? AppColors.neonYellow : Colors.grey)
                  ),
                ),
                Expanded(child: Text(f.awayTeam, style: TextStyle(color: f.awayTeam == "MISFIT UNITED" ? AppColors.electricCyan : Colors.white))),
              ],
            ),
          )).toList(),
        );
      },
    );
  }

  // TAB 3: STATISTIK (TOP SCORER)
  Widget _buildStatsTab(LeagueLoaded state) {
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("TOP SCORERS", style: TextStyle(color: AppColors.hotPink, fontSize: 20, fontFamily: 'Rajdhani', fontWeight: FontWeight.bold)),
        ),
        if (state.topScorers.isEmpty)
          const Padding(padding: EdgeInsets.all(16), child: Text("No stats available yet.", style: TextStyle(color: Colors.grey))),
        
        ...state.topScorers.map((p) => ListTile(
          leading: CircleAvatar(backgroundColor: Colors.white10, child: Text("${state.topScorers.indexOf(p)+1}")),
          title: Text(p.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(p.teamName, style: const TextStyle(color: Colors.grey)),
          trailing: Text("${p.value} Goals", style: const TextStyle(color: AppColors.neonYellow, fontWeight: FontWeight.bold, fontSize: 16)),
        )),
      ],
    );
  }
}