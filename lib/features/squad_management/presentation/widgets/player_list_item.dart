import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../data/player_model.dart';
import '../../logic/squad_bloc.dart';
import '../../logic/squad_event.dart';

class PlayerListItem extends StatelessWidget {
  final Player player;
  final bool isStarter;
  final VoidCallback? onTap;

  const PlayerListItem({
    super.key,
    required this.player,
    required this.isStarter,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white.withOpacity(0.05),
      leading: CircleAvatar(
        backgroundImage: const AssetImage(AppAssets.avatarManager),
      ),
      title: Text(player.name, style: const TextStyle(color: Colors.white, fontFamily: 'Rajdhani', fontWeight: FontWeight.bold)),
      subtitle: Text("${player.position} | RTG: ${player.rating}", style: const TextStyle(color: Colors.grey)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stamina Indicator
          Icon(Icons.battery_charging_full, color: player.stamina > 0.5 ? Colors.green : Colors.red, size: 16),
          const SizedBox(width: 10),
          
          // Tombol Recover (Quick Action)
          IconButton(
            icon: const Icon(Icons.medical_services, size: 20, color: AppColors.hotPink),
            onPressed: () {
              // FIX: Menggunakan Event yang Benar
              context.read<SquadBloc>().add(RecoverStamina(player));
            },
          )
        ],
      ),
      onTap: onTap,
    );
  }
}