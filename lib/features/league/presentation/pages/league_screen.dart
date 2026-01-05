import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../logic/league_cubit.dart';
import '../../logic/league_state.dart';
import '../../data/league_models.dart';

import '../../../manager_cockpit/logic/manager_bloc.dart';
import '../../../manager_cockpit/logic/manager_event.dart';
import '../../../squad_management/logic/squad_bloc.dart';
import '../../../squad_management/logic/squad_event.dart';
import '../../../match_engine/presentation/pages/match_screen.dart';

class LeagueScreen extends StatelessWidget {
  const LeagueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("LEAGUE CENTER", style: TextStyle(fontFamily: 'Rajdhani', fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: AppColors.electricCyan,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.electricCyan,
            tabs: [
              Tab(text: "TABLE"),
              Tab(text: "FIXTURES"),
              Tab(text: "STATS"),
            ],
          ),
        ),
        body: BlocBuilder<LeagueCubit, LeagueState>(
          builder: (context, state) {
            // [FIX] Cek class LeagueLoading sekarang aman
            if (state is LeagueLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.electricCyan));
            }
            
            if (state is LeagueLoaded) {
              return Column(
                children: [
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildLeagueTable(state.teams),
                        _buildFixturesList(state.schedule, state.currentMatchday),
                        _buildTopScorers(state.topScorers),
                      ],
                    ),
                  ),
                  _buildBottomAction(context, state),
                ],
              );
            }
            
            // State Initial atau Error
            return const Center(child: Text("League Data Unavailable", style: TextStyle(color: Colors.white)));
          },
        ),
      ),
    );
  }

  Widget _buildLeagueTable(List<TeamModel> teams) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          // [FIX] WidgetStateProperty.all (Pengganti MaterialStateProperty)
          headingRowColor: WidgetStateProperty.all(Colors.white10),
          columns: const [
            DataColumn(label: Text("POS", style: TextStyle(color: Colors.grey, fontSize: 12))),
            DataColumn(label: Text("TEAM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text("P", style: TextStyle(color: Colors.grey))),
            DataColumn(label: Text("W", style: TextStyle(color: Colors.grey))),
            DataColumn(label: Text("D", style: TextStyle(color: Colors.grey))),
            DataColumn(label: Text("L", style: TextStyle(color: Colors.grey))),
            DataColumn(label: Text("PTS", style: TextStyle(color: AppColors.electricCyan, fontWeight: FontWeight.bold))),
          ],
          rows: teams.asMap().entries.map((entry) {
            int index = entry.key + 1;
            TeamModel team = entry.value;
            bool isUser = team.isPlayerTeam;
            
            return DataRow(
              // [FIX] WidgetStateProperty.all & withValues (Sesuai Flutter Terbaru)
              color: isUser 
                  ? WidgetStateProperty.all(AppColors.electricCyan.withValues(alpha: 0.2)) 
                  : null,
              cells: [
                DataCell(Text("$index", style: TextStyle(color: index <= 4 ? Colors.green : (index >= 18 ? Colors.red : Colors.white)))),
                DataCell(Text(team.name, style: TextStyle(color: isUser ? AppColors.electricCyan : Colors.white, fontWeight: isUser ? FontWeight.bold : FontWeight.normal))),
                DataCell(Text("${team.played}", style: const TextStyle(color: Colors.white70))),
                DataCell(Text("${team.won}", style: const TextStyle(color: Colors.white70))),
                DataCell(Text("${team.drawn}", style: const TextStyle(color: Colors.white70))),
                DataCell(Text("${team.lost}", style: const TextStyle(color: Colors.white70))),
                DataCell(Text("${team.points}", style: const TextStyle(color: AppColors.electricCyan, fontWeight: FontWeight.bold))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFixturesList(List<List<FixtureModel>> schedule, int currentMatchday) {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: schedule.length,
      itemBuilder: (context, index) {
        int matchday = index + 1;
        List<FixtureModel> fixtures = schedule[index];
        bool isNext = matchday == currentMatchday;
        
        return Card(
          // [FIX] withValues
          color: isNext ? AppColors.electricCyan.withValues(alpha: 0.1) : Colors.black,
          shape: isNext ? RoundedRectangleBorder(side: const BorderSide(color: AppColors.electricCyan), borderRadius: BorderRadius.circular(8)) : null,
          margin: const EdgeInsets.only(bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("MATCHDAY $matchday ${isNext ? '(UPCOMING)' : ''}", 
                  style: TextStyle(color: isNext ? AppColors.electricCyan : Colors.grey, fontWeight: FontWeight.bold)),
              ),
              const Divider(color: Colors.white24, height: 1),
              ...fixtures.map((f) => Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: Row(
                  children: [
                    Expanded(child: Text(f.homeTeam, textAlign: TextAlign.right, style: TextStyle(color: f.homeTeam == "MISFIT UNITED" ? AppColors.electricCyan : Colors.white))),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        f.isPlayed ? "${f.homeScore} - ${f.awayScore}" : "VS",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    Expanded(child: Text(f.awayTeam, textAlign: TextAlign.left, style: TextStyle(color: f.awayTeam == "MISFIT UNITED" ? AppColors.electricCyan : Colors.white))),
                  ],
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopScorers(List<PlayerStatEntry> scorers) {
    if (scorers.isEmpty) return const Center(child: Text("No stats yet.", style: TextStyle(color: Colors.grey)));

    return ListView.builder(
      itemCount: scorers.length,
      itemBuilder: (context, index) {
        final p = scorers[index];
        return ListTile(
          leading: Text("${index + 1}", style: const TextStyle(color: Colors.grey, fontSize: 16)),
          title: Text(p.name, style: const TextStyle(color: Colors.white)),
          subtitle: Text(p.teamName, style: const TextStyle(color: Colors.white30, fontSize: 10)),
          trailing: Text("${p.value} Goals", style: const TextStyle(color: AppColors.neonYellow, fontWeight: FontWeight.bold)),
        );
      },
    );
  }

  Widget _buildBottomAction(BuildContext context, LeagueLoaded state) {
    bool seasonEnded = state.currentMatchday > 38;

    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: AppColors.electricCyan, width: 2)),
      ),
      child: seasonEnded 
          ? ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonYellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.emoji_events),
              label: const Text("FINISH SEASON & CLAIM PRIZE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              onPressed: () => _showEndSeasonDialog(context),
            )
          : ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electricCyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.sports_soccer),
              label: Text("PLAY MATCHDAY ${state.currentMatchday}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MatchScreen()));
              },
            ),
    );
  }

  void _showEndSeasonDialog(BuildContext context) {
    final leagueCubit = context.read<LeagueCubit>();
    final prize = leagueCubit.getSeasonPrize();
    
    // Safety check jika state belum loaded
    final state = leagueCubit.state;
    int pos = 0;
    if (state is LeagueLoaded) {
      pos = state.teams.indexWhere((t) => t.isPlayerTeam) + 1;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.neonYellow, width: 2),
            borderRadius: BorderRadius.circular(16)),
        title: const Center(
            child: Text("SEASON COMPLETED!", 
                style: TextStyle(color: Colors.white, fontFamily: 'Rajdhani', fontWeight: FontWeight.bold))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 60, color: AppColors.neonYellow),
            const SizedBox(height: 20),
            Text("You finished in position:", style: TextStyle(color: Colors.grey[400])),
            Text("#$pos", style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text("PRIZE MONEY:", style: TextStyle(color: Colors.grey)),
            Text("\$ $prize", style: const TextStyle(color: Colors.greenAccent, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Player Goals/Assists will be reset.", 
                textAlign: TextAlign.center, style: TextStyle(color: Colors.redAccent, fontSize: 12)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.electricCyan),
            onPressed: () {
              context.read<ManagerBloc>().add(ModifyMoney(prize));
              context.read<SquadBloc>().add(ResetSeasonStats());
              leagueCubit.startNewSeason();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("New Season Started! Good Luck!"), backgroundColor: Colors.green),
              );
            },
            child: const Text("CLAIM & START NEW SEASON", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}