import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart'; // Import daftar aset tadi
import '../widgets/neon_menu_button.dart';
import '../../../../features/squad_management/presentation/pages/squad_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/manager_bloc.dart';
import '../../logic/manager_state.dart';
import '../../../../features/squad_management/presentation/pages/tactics_screen.dart';
import '../../../transfer_market/presentation/pages/transfer_screen.dart';
import '../../../match_engine/presentation/pages/match_screen.dart';

class CockpitScreen extends StatelessWidget {
  const CockpitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- BACKGROUND IMAGE FULL SCREEN ---
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.bgCity), // Panggil Background Kota
            fit: BoxFit.cover, // Penuhi layar
            colorFilter: ColorFilter.mode(
              // Gelapkan gambar sedikit agar teks terbaca (Overlay Hitam)
              Colors.black.withOpacity(0.7), 
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricCyan,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MatchScreen()),
                  );
                },
                child: const Text(
                  "PLAY NEXT MATCH",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
                // GRID MENU
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.85,
                    children: [
                      // TOMBOL 1: TIM
                      NeonMenuButton(
                        label: "TIM",
                        imagePath: AppAssets.iconTeam,
                        glowColor: AppColors.electricCyan,
                        delay: 100,
                        onTap: () {
                          // NAVIGASI KE SQUAD SCREEN
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SquadScreen()), // Error merah? Hover -> Quick Fix -> Import squad_screen.dart
                          );
                        },
                      ),
                      // TOMBOL 2: TAKTIK
                      NeonMenuButton(
                      label: "TAKTIK",
                      imagePath: AppAssets.iconTactics,
                      glowColor: AppColors.neonYellow,
                      delay: 200,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TacticsScreen()), // Import dulu
                        );
                      },
                    ),
                      // TOMBOL 3: TRANSFER
                      NeonMenuButton(
                        label: "TRANSFER",
                        imagePath: AppAssets.iconTransfer,
                        glowColor: AppColors.hotPink,
                        delay: 300,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TransferScreen()), 
                          );
                        },
                      ),
                      // TOMBOL 4: KLUB
                      NeonMenuButton(
                        label: "KLUB",
                        imagePath: AppAssets.iconClub,
                        glowColor: Colors.white,
                        delay: 400,
                        onTap: () => print("Klub Clicked"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    // GUNAKAN BLOC BUILDER DI SINI
    return BlocBuilder<ManagerBloc, ManagerState>(
      builder: (context, state) {
        // Default values jika data belum siap
        String name = "LOADING...";
        String club = "...";
        int money = 0;
        String avatar = AppAssets.avatarManager; // Default

        // Jika data sudah loaded, ambil isinya
        if (state is ManagerLoaded) {
          name = state.name;
          club = state.clubName;
          money = state.money;
          // avatar = state.avatarPath; // Jika mau dinamis
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(color: AppColors.electricCyan, width: 4),
            ),
          ),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                backgroundColor: AppColors.electricCyan,
                radius: 25,
                backgroundImage: AssetImage(avatar),
              ),
              const SizedBox(width: 16),
              
              // Info Text (Expanded agar tidak overflow)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "MANAGER: $name", // Data dari BLoC
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Rajdhani',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "CLUB: $club",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        // Tampilan Uang ($)
                        Text(
                          "\$ $money", 
                          style: const TextStyle(
                            color: AppColors.neonYellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}