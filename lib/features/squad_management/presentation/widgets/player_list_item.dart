import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../data/player_model.dart';
import '../../logic/squad_bloc.dart';
import '../../logic/squad_event.dart';

import '../../../manager_cockpit/logic/manager_bloc.dart';
import '../../../manager_cockpit/logic/manager_event.dart';
import '../../../manager_cockpit/logic/manager_state.dart';

class PlayerListItem extends StatelessWidget {
  final Player player;
  final bool isStarter;
  final int index;

  const PlayerListItem({
    super.key,
    required this.player,
    required this.isStarter,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = isStarter ? AppColors.electricCyan : Colors.grey;
    double stamina = player.stamina;

    return Container(
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
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.drag_handle, color: Colors.white24),
            const SizedBox(width: 10),
            Container(
              width: 25,
              alignment: Alignment.center,
              child: Text("${index + 1}", style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(player.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Rajdhani'), overflow: TextOverflow.ellipsis),
            ),
            if (player.seasonGoals > 0 || player.seasonAssists > 0)
              Container(
                margin: const EdgeInsets.only(left: 5),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.white24)),
                child: Row(
                  children: [
                    if(player.seasonGoals > 0) ...[const Icon(Icons.sports_soccer, size: 10, color: AppColors.neonYellow), const SizedBox(width: 2), Text("${player.seasonGoals}", style: const TextStyle(color: AppColors.neonYellow, fontSize: 10)), const SizedBox(width: 4)],
                    if(player.seasonAssists > 0) ...[const Icon(Icons.group_add, size: 10, color: AppColors.hotPink), const SizedBox(width: 2), Text("${player.seasonAssists}", style: const TextStyle(color: AppColors.hotPink, fontSize: 10))],
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
            Container(
              height: 4, width: 100,
              decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(2)),
              child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: stamina, child: Container(color: stamina > 0.5 ? Colors.green : Colors.red)),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.settings, color: Colors.white54),
          onPressed: () => _showPlayerOptions(context, player),
        ),
      ),
    );
  }

  void _showPlayerOptions(BuildContext context, Player player) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        double xpProgress = player.currentXp / player.xpToNextLevel;
        if (xpProgress > 1.0) xpProgress = 1.0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.electricCyan, width: 2))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(player.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Rajdhani')),
              Text("${player.position} | Rating ${player.rating}", style: const TextStyle(color: AppColors.electricCyan, fontWeight: FontWeight.bold)),
              
              const SizedBox(height: 20),

              // [BARU] XP PROGRESS BAR
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("LEVEL PROGRESS", style: TextStyle(color: Colors.grey, fontSize: 10)),
                      Text("${player.currentXp} / ${player.xpToNextLevel} XP", style: const TextStyle(color: AppColors.neonYellow, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: xpProgress,
                      backgroundColor: Colors.grey[800],
                      color: AppColors.neonYellow,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text("Earn XP from matches to increase Rating!", style: TextStyle(color: Colors.white24, fontSize: 10, fontStyle: FontStyle.italic)),
                ],
              ),

              const SizedBox(height: 20),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem("GOALS", "${player.seasonGoals}", AppColors.neonYellow),
                    _buildStatItem("ASSISTS", "${player.seasonAssists}", AppColors.hotPink),
                    _buildStatItem("APPS", "${player.seasonAppearances}", Colors.white),
                    _buildStatItem("AVG RTG", "${player.averageRating}", Colors.blueAccent),
                  ],
                ),
              ),
              
              const Divider(color: Colors.white24, height: 30),

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
                      managerBloc.add(const ModifyMoney(-50));
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

              ListTile(
                leading: const Icon(Icons.monetization_on, color: Colors.amber),
                title: const Text("Sell Player", style: TextStyle(color: Colors.white)),
                subtitle: const Text("Get \$200", style: TextStyle(color: Colors.grey)),
                onTap: () {
                  context.read<ManagerBloc>().add(const ModifyMoney(200));
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