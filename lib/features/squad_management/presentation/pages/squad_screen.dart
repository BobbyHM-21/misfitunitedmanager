import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';

// Logic Squad
import '../../logic/squad_bloc.dart';
import '../../logic/squad_event.dart';
import '../../logic/squad_state.dart';
import '../../data/player_model.dart';

// Logic Manager
import '../../../manager_cockpit/logic/manager_bloc.dart';
import '../../../manager_cockpit/logic/manager_event.dart';
import '../../../manager_cockpit/logic/manager_state.dart';

class SquadScreen extends StatelessWidget {
  const SquadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger Load saat dibuka
    context.read<SquadBloc>().add(LoadSquad());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("TACTICAL SQUAD", style: TextStyle(fontFamily: 'Rajdhani', fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // [FITUR LAMA] TOMBOL HEAL ALL TEAM
          IconButton(
            icon: const Icon(Icons.local_hospital, color: Colors.greenAccent),
            tooltip: "Heal All Players",
            onPressed: () => _showHealAllDialog(context),
          ),
          const SizedBox(width: 10),
          
          // [FITUR LAMA] MONEY DISPLAY
          BlocBuilder<ManagerBloc, ManagerState>(
            builder: (context, state) {
              int money = 0;
              if (state is ManagerLoaded) money = state.money;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.neonYellow),
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: Text("\$ $money", style: const TextStyle(color: AppColors.neonYellow, fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // [FITUR LAMA] INSTRUKSI
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.white10,
            child: const Text(
              "DRAG & DROP players to arrange Starting XI.\nPositions 1-11 are Starters.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          
          // [FITUR LAMA] DRAG & DROP LIST
          Expanded(
            child: BlocBuilder<SquadBloc, SquadState>(
              builder: (context, state) {
                if (state is SquadLoaded) {
                  return ReorderableListView.builder(
                    padding: const EdgeInsets.only(bottom: 50),
                    itemCount: state.players.length,
                    onReorder: (oldIndex, newIndex) {
                      context.read<SquadBloc>().add(ReorderSquad(oldIndex, newIndex));
                    },
                    itemBuilder: (context, index) {
                      final player = state.players[index];
                      final isStarter = index < 11; // 11 Teratas adalah Starter
                      
                      // WIDGET ITEM (Key wajib ada untuk reorder)
                      return _buildDraggablePlayerItem(context, player, isStarter, index + 1, ValueKey(player.name));
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggablePlayerItem(BuildContext context, Player player, bool isStarter, int number, Key key) {
    Color statusColor = isStarter ? AppColors.electricCyan : Colors.grey;
    double stamina = player.stamina;

    return Container(
      key: key, // Penting untuk ReorderableListView
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: isStarter ? Colors.blueGrey.withValues(alpha: 0.1) : Colors.black,
        border: Border(
          left: BorderSide(color: statusColor, width: 4),
          bottom: const BorderSide(color: Colors.white12),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        
        // HANDLE DRAG DI KIRI
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.drag_handle, color: Colors.white24),
            const SizedBox(width: 10),
            Container(
              width: 25,
              alignment: Alignment.center,
              child: Text("$number", style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
        
        // [UPDATE PHASE 4] INFO PEMAIN + STATISTIK
        title: Row(
          children: [
            Expanded(
              child: Text(
                player.name, 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Rajdhani'),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Indikator Statistik (Hanya muncul jika > 0)
            if (player.seasonGoals > 0 || player.seasonAssists > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.white24)),
                child: Row(
                  children: [
                    if(player.seasonGoals > 0) ...[
                      const Icon(Icons.sports_soccer, size: 12, color: AppColors.neonYellow),
                      const SizedBox(width: 4),
                      Text("${player.seasonGoals}", style: const TextStyle(color: AppColors.neonYellow, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                    ],
                    if(player.seasonAssists > 0) ...[
                      const Icon(Icons.group_add, size: 12, color: AppColors.hotPink),
                      const SizedBox(width: 4),
                      Text("${player.seasonAssists}", style: const TextStyle(color: AppColors.hotPink, fontSize: 10, fontWeight: FontWeight.bold)),
                    ]
                  ],
                ),
              )
          ],
        ),
        
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(player.position, style: const TextStyle(color: AppColors.neonYellow, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(width: 10),
                Text("RTG: ${player.rating}", style: const TextStyle(color: Colors.white54, fontSize: 10)),
                const SizedBox(width: 10),
                Text("APPS: ${player.seasonAppearances}", style: const TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
            const SizedBox(height: 4),
            // Stamina Bar Kecil
            Container(
              height: 4,
              width: 100,
              decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(2)),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: stamina,
                child: Container(color: stamina > 0.5 ? Colors.green : Colors.red),
              ),
            ),
          ],
        ),

        // TOMBOL PROFIL / MANAGE (KANAN)
        trailing: IconButton(
          icon: const Icon(Icons.settings, color: Colors.white54),
          onPressed: () => _showPlayerOptions(context, player),
        ),
      ),
    );
  }

  // --- LOGIKA HEAL ALL TEAM ---
  void _showHealAllDialog(BuildContext context) {
    final state = context.read<SquadBloc>().state;
    if (state is SquadLoaded) {
      // Hitung total biaya (Misal $20 per pemain yang lelah)
      int injuredCount = state.players.where((p) => p.stamina < 1.0).length;
      int cost = injuredCount * 20;

      if (injuredCount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Team is fully fit!")));
        return;
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.green), borderRadius: BorderRadius.circular(12)),
          title: const Text("TEAM RECOVERY", style: TextStyle(color: Colors.white, fontFamily: 'Rajdhani', fontWeight: FontWeight.bold)),
          content: Text("Heal $injuredCount players for \$$cost?", style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                final managerBloc = context.read<ManagerBloc>();
                int money = 0;
                if (managerBloc.state is ManagerLoaded) money = (managerBloc.state as ManagerLoaded).money;

                if (money >= cost) {
                  managerBloc.add(ModifyMoney(-cost));
                  context.read<SquadBloc>().add(RecoverAllStamina());
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Team Fully Recovered!"), backgroundColor: Colors.green));
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Insufficient Funds!"), backgroundColor: Colors.red));
                }
              }, 
              child: const Text("PAY & HEAL", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
            )
          ],
        )
      );
    }
  }

  // --- LOGIKA OPSI INDIVIDUAL ---
  void _showPlayerOptions(BuildContext context, Player player) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.electricCyan, width: 2))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(player.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Rajdhani')),
              Text("${player.position} | Rating ${player.rating}", style: const TextStyle(color: Colors.grey)),
              
              const SizedBox(height: 20),
              
              // [UPDATE PHASE 4] DETAIL STATISTIK
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem("GOALS", "${player.seasonGoals}", AppColors.neonYellow),
                    _buildStatItem("ASSISTS", "${player.seasonAssists}", AppColors.hotPink),
                    _buildStatItem("APPS", "${player.seasonAppearances}", Colors.white),
                    _buildStatItem("CARDS", "${player.seasonYellowCards}", Colors.yellow),
                  ],
                ),
              ),
              
              const Divider(color: Colors.white24, height: 30),

              // OPSI HEAL SINGLE
              ListTile(
                leading: const Icon(Icons.local_hospital, color: Colors.green),
                title: const Text("Heal Player", style: TextStyle(color: Colors.white)),
                subtitle: const Text("Cost: \$50", style: TextStyle(color: Colors.grey)),
                trailing: player.stamina >= 1.0 ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  if (player.stamina < 1.0) {
                    final managerBloc = context.read<ManagerBloc>();
                    int money = 0;
                    if (managerBloc.state is ManagerLoaded) money = (managerBloc.state as ManagerLoaded).money;

                    if (money >= 50) {
                      managerBloc.add(ModifyMoney(-50));
                      context.read<SquadBloc>().add(RecoverStamina(player));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Player Healed!"), backgroundColor: Colors.green));
                    } else {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Not enough money!"), backgroundColor: Colors.red));
                    }
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),

              // OPSI JUAL
              ListTile(
                leading: const Icon(Icons.monetization_on, color: Colors.amber),
                title: const Text("Sell Player", style: TextStyle(color: Colors.white)),
                subtitle: const Text("Get \$200", style: TextStyle(color: Colors.grey)),
                onTap: () {
                  context.read<ManagerBloc>().add(ModifyMoney(200));
                  context.read<SquadBloc>().add(SellPlayer(player));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Player Sold!"), backgroundColor: AppColors.neonYellow));
                },
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Rajdhani')),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }
}