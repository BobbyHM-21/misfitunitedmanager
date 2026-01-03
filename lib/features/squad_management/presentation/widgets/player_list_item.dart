import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/player_model.dart';

class PlayerListItem extends StatelessWidget {
  final Player player;
  final int index;

  const PlayerListItem({super.key, required this.player, required this.index});

  @override
  Widget build(BuildContext context) {
    // Tentukan warna posisi
    Color roleColor;
    switch (player.position) {
      case 'FWD': roleColor = AppColors.hotPink; break;
      case 'MID': roleColor = AppColors.electricCyan; break;
      case 'DEF': roleColor = AppColors.neonYellow; break;
      default: roleColor = Colors.white;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF101025).withOpacity(0.9), // Background Gelap
        border: Border(
          left: BorderSide(color: roleColor, width: 4), // Garis Warna Posisi
          bottom: BorderSide(color: Colors.white10),
        ),
      ),
      child: Row(
        children: [
          // 1. NOMOR PUNGGUNG
          Text(
            "${index + 1}",
            style: const TextStyle(
              color: Colors.white54,
              fontFamily: 'Rajdhani',
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 16),

          // 2. AVATAR (Foto)
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.black,
            backgroundImage: AssetImage(player.imagePath),
          ),
          const SizedBox(width: 16),

          // 3. INFO UTAMA (Nama & Posisi)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'Rajdhani',
                  ),
                ),
                Text(
                  player.position,
                  style: TextStyle(color: roleColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // 4. STATISTIK (Rating & Stamina)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Rating Besar
              Text(
                "${player.rating}",
                style: TextStyle(
                  color: player.rating > 85 ? AppColors.neonYellow : Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Rajdhani',
                ),
              ),
              const SizedBox(height: 4),
              // Stamina Bar Kecil
              SizedBox(
                width: 60,
                height: 4,
                child: LinearProgressIndicator(
                  value: player.stamina,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    player.stamina < 0.5 ? AppColors.hotPink : AppColors.electricCyan,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}