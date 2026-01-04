import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/player_model.dart';
// Import Logic
import '../../logic/squad_bloc.dart';
import '../../logic/squad_event.dart';

class PlayerListItem extends StatelessWidget {
  final Player player;
  final int index;

  const PlayerListItem({super.key, required this.player, required this.index});

  @override
  Widget build(BuildContext context) {
    Color roleColor;
    switch (player.position) {
      case 'FWD': roleColor = AppColors.hotPink; break;
      case 'MID': roleColor = AppColors.electricCyan; break;
      case 'DEF': roleColor = AppColors.neonYellow; break;
      default: roleColor = Colors.white;
    }

    // BUNGKUS DENGAN INKWELL AGAR BISA DIKLIK (HEAL)
    return InkWell(
      onTap: () {
        // Cek jika stamina berkurang
        if (player.stamina < 1.0) {
          context.read<SquadBloc>().add(HealPlayer(player));
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${player.name} rested and recovered!"),
              backgroundColor: Colors.green,
              duration: const Duration(milliseconds: 500),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF101025).withOpacity(0.9),
          border: Border(
            left: BorderSide(color: roleColor, width: 4),
            bottom: BorderSide(color: Colors.white10),
          ),
        ),
        child: Row(
          children: [
            Text(
              "${index + 1}",
              style: const TextStyle(color: Colors.white54, fontFamily: 'Rajdhani', fontSize: 18),
            ),
            const SizedBox(width: 16),
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.black,
              backgroundImage: AssetImage(player.imagePath),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Rajdhani'),
                  ),
                  Text(
                    player.position,
                    style: TextStyle(color: roleColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${player.rating}",
                  style: TextStyle(
                    color: player.rating > 85 ? AppColors.neonYellow : Colors.white,
                    fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Rajdhani',
                  ),
                ),
                const SizedBox(height: 4),
                // Stamina Bar
                SizedBox(
                  width: 60,
                  height: 4,
                  child: LinearProgressIndicator(
                    value: player.stamina,
                    backgroundColor: Colors.grey[800],
                    // Warna jadi merah jika stamina < 50%
                    valueColor: AlwaysStoppedAnimation<Color>(
                      player.stamina < 0.5 ? AppColors.hotPink : AppColors.electricCyan,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}