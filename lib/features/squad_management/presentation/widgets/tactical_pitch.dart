import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/player_model.dart';

class TacticalPitch extends StatelessWidget {
  final List<Player> startingEleven;

  const TacticalPitch({super.key, required this.startingEleven});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2 / 3, // Pindahkan rasio ke sini
      child: Container(
        margin: const EdgeInsets.all(16),
        // Hapus baris 'aspectRatio: 2 / 3,' dari dalam Container ini
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          border: Border.all(color: AppColors.electricCyan.withOpacity(0.5), width: 2),
          borderRadius: BorderRadius.circular(16),
          image: const DecorationImage(
            image: AssetImage("assets/images/bg_city.png"),
            fit: BoxFit.cover,
            opacity: 0.2,
          ),
        ),
        child: Stack(
          children: [
          // 1. GARIS TENGAH (Visual)
          Center(child: Container(height: 2, color: AppColors.electricCyan.withOpacity(0.3))),
          Center(
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.electricCyan.withOpacity(0.3), width: 2),
              ),
            ),
          ),

          // 2. POSISI PEMAIN (4-3-3)
          // Kita map manual koordinatnya (0.0 - 1.0)
          
          // GK (Kiper)
          _buildPlayerNode(startingEleven[0], 0.5, 0.9), 
          
          // DEF (Bek) - 4 Orang
          _buildPlayerNode(startingEleven[1], 0.2, 0.75), // LB
          _buildPlayerNode(startingEleven[2], 0.4, 0.75), // CB
          _buildPlayerNode(startingEleven[3], 0.6, 0.75), // CB
          _buildPlayerNode(startingEleven[4], 0.8, 0.75), // RB
          
          // MID (Gelandang) - 3 Orang
          _buildPlayerNode(startingEleven[5], 0.3, 0.5), // LCM
          _buildPlayerNode(startingEleven[6], 0.5, 0.55), // CDM
          _buildPlayerNode(startingEleven[7], 0.7, 0.5), // RCM

          // FWD (Penyerang) - 3 Orang
          _buildPlayerNode(startingEleven[8], 0.2, 0.25), // LW
          _buildPlayerNode(startingEleven[9], 0.5, 0.2),  // ST
          _buildPlayerNode(startingEleven[10], 0.8, 0.25), // RW
        ],
      ),
      ),
    );
  }

  // Widget Node Pemain (Lingkaran Wajah)
  Widget _buildPlayerNode(Player player, double alignX, double alignY) {
    // Konversi koordinat (0..1) ke Alignment (-1..1)
    final x = (alignX * 2) - 1;
    final y = (alignY * 2) - 1;

    return Align(
      alignment: Alignment(x, y),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.electricCyan, width: 2),
              boxShadow: AppColors.glow(AppColors.electricCyan),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(player.imagePath),
              backgroundColor: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          // Nama & Rating
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            color: Colors.black87,
            child: Text(
              "${player.rating} ${player.name}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}