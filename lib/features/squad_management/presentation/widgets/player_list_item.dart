import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
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
  
  // [BARU] Tambahan parameter untuk fitur Tap Selection
  final bool isSelected;
  final VoidCallback onTap;

  const PlayerListItem({
    super.key,
    required this.player,
    required this.isStarter,
    required this.index,
    // [BARU] Wajib diisi dari screen
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = isStarter ? AppColors.electricCyan : Colors.grey;
    double stamina = player.stamina;
    double targetXp = (player.xpToNextLevel > 0) ? player.xpToNextLevel.toDouble() : 1000.0;
    double xpProgress = (player.currentXp / targetXp).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap, 
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.electricCyan.withValues(alpha: 0.3) 
              : (isStarter ? Colors.blueGrey.withValues(alpha: 0.1) : Colors.black),
          border: Border(
            left: BorderSide(color: statusColor, width: 4),
            top: isSelected ? const BorderSide(color: AppColors.electricCyan, width: 2) : BorderSide.none,
            bottom: isSelected ? const BorderSide(color: AppColors.electricCyan, width: 2) : const BorderSide(color: Colors.white12),
            right: isSelected ? const BorderSide(color: AppColors.electricCyan, width: 2) : BorderSide.none,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.drag_handle, 
                color: isSelected ? AppColors.electricCyan : Colors.white24
              ),
              const SizedBox(width: 10),
              Container(
                width: 25,
                alignment: Alignment.center,
                child: Text(
                  "${index + 1}", 
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 16)
                ),
              ),
            ],
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      player.name, 
                      style: const TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold, 
                        fontFamily: 'Rajdhani', 
                        fontSize: 16
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (player.seasonGoals > 0) 
                    Container(
                      margin: const EdgeInsets.only(left: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.neonYellow), 
                        borderRadius: BorderRadius.circular(3)
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.sports_soccer, size: 10, color: AppColors.neonYellow),
                          const SizedBox(width: 2),
                          Text(
                            "${player.seasonGoals}", 
                            style: const TextStyle(color: AppColors.neonYellow, fontSize: 10, fontWeight: FontWeight.bold)
                          ),
                        ],
                      ),
                    )
                ],
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(3)),
                    child: Text(
                      player.position, 
                      style: const TextStyle(color: AppColors.neonYellow, fontWeight: FontWeight.bold, fontSize: 10)
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text("RTG: ${player.rating}", style: const TextStyle(color: Colors.white, fontSize: 11)),
                  const SizedBox(width: 8),
                  Text("APPS: ${player.seasonAppearances}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text("STM", style: TextStyle(color: Colors.grey, fontSize: 9)),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(2)),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft, 
                        widthFactor: stamina, 
                        child: Container(color: stamina > 0.5 ? Colors.green : Colors.red)
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Text("EXP", style: TextStyle(color: AppColors.neonYellow, fontSize: 9, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(2)),
                        ),
                        FractionallySizedBox(
                          widthFactor: xpProgress,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(color: AppColors.neonYellow, borderRadius: BorderRadius.circular(2)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text("${player.currentXp}/${player.xpToNextLevel}", style: const TextStyle(color: Colors.grey, fontSize: 9)),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.settings, color: Colors.white24, size: 24),
            onPressed: () => _showActionMenu(context, player),
          ),
        ),
      ),
    );
  }

  void _showActionMenu(BuildContext context, Player player) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.electricCyan, width: 2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Manage ${player.name}", 
                style: const TextStyle(color: Colors.white, fontSize: 22, fontFamily: 'Rajdhani', fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 5),
              Text(
                "Rating: ${player.rating} | XP: ${player.currentXp}", 
                style: const TextStyle(color: Colors.grey, fontSize: 12)
              ),
              const Divider(color: Colors.white24, height: 30),
              
              ListTile(
                leading: const Icon(Icons.local_hospital, color: Colors.green),
                title: const Text("Heal Player", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text("Cost: \$50 to restore full stamina", style: TextStyle(color: Colors.grey)),
                onTap: () {
                  if (player.stamina < 1.0) {
                    final managerBloc = context.read<ManagerBloc>();
                    int money = (managerBloc.state is ManagerLoaded) ? (managerBloc.state as ManagerLoaded).money : 0;
                    
                    if (money >= 50) {
                      managerBloc.add(const ModifyMoney(-50));
                      context.read<SquadBloc>().add(RecoverStamina(player));
                      Navigator.pop(context);
                      // [FIX] Hapus const
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Player Recovered!"), backgroundColor: Colors.green));
                    } else {
                      Navigator.pop(context);
                      // [FIX] Hapus const
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Not enough money!"), backgroundColor: Colors.red));
                    }
                  } else {
                    Navigator.pop(context);
                    // [FIX] Hapus const
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Player is already fit!")));
                  }
                },
              ),

              const SizedBox(height: 10),

              ListTile(
                leading: const Icon(Icons.monetization_on, color: Colors.amber),
                title: const Text("Sell Player", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text("Get \$200 immediately", style: TextStyle(color: Colors.grey)),
                onTap: () {
                  context.read<ManagerBloc>().add(const ModifyMoney(200));
                  context.read<SquadBloc>().add(SellPlayer(player));
                  Navigator.pop(context);
                  // [FIX] Hapus const dan escape dollar (\$)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Player Sold! +\$200"), backgroundColor: AppColors.neonYellow)
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    );
  }
}