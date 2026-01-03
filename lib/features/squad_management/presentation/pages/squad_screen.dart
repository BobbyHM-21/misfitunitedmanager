import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../data/player_model.dart';
import '../widgets/player_list_item.dart';

class SquadScreen extends StatelessWidget {
  const SquadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil data dummy
    final squad = Player.dummySquad;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("SQUAD MANAGEMENT", style: TextStyle(color: AppColors.electricCyan, fontFamily: 'Rajdhani', fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.electricCyan),
      ),
      extendBodyBehindAppBar: true, // Agar background full sampai atas
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.bgCity),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.darken),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100), // Spasi untuk AppBar

            // --- AREA FORMASI (PITCH PREVIEW) ---
            Container(
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.electricCyan.withOpacity(0.5)),
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  // Nanti ganti dengan gambar lapangan neon
                  image: AssetImage(AppAssets.bgCity), 
                  opacity: 0.2, 
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.hub, color: AppColors.electricCyan, size: 40),
                    SizedBox(height: 8),
                    Text("FORMATION: 4-3-3", style: TextStyle(color: Colors.white, fontFamily: 'Rajdhani')),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- DAFTAR PEMAIN (LIST) ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: squad.length,
                itemBuilder: (context, index) {
                  return PlayerListItem(player: squad[index], index: index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}