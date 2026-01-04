import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../widgets/neon_menu_button.dart';

// Logic Manager
import '../../logic/manager_bloc.dart';
import '../../logic/manager_state.dart';

// Import Halaman Lain (Pastikan path import ini sesuai folder Anda)
import '../../../../features/squad_management/presentation/pages/squad_screen.dart';
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
            fit: BoxFit.cover, 
            colorFilter: ColorFilter.mode(
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
                _buildHeader(), // HEADER (Saldo, Nama, dll)
                
                const SizedBox(height: 20),
                
                // TOMBOL BIG MATCH
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SquadScreen()),
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
                            MaterialPageRoute(builder: (context) => const TacticsScreen()),
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
    // GUNAKAN BLOC BUILDER (Cek Status ManagerLoaded)
    return BlocBuilder<ManagerBloc, ManagerState>(
      builder: (context, state) {
        // Default values
        String name = "LOADING...";
        String club = "...";
        int money = 0;
        String avatar = AppAssets.avatarManager;

        // JIKA DATA SUDAH LOADED (Sesuai struktur Anda)
        if (state is ManagerLoaded) {
          name = state.name;
          club = state.clubName;
          money = state.money;
          // avatar = state.avatarPath; // Jika mau custom
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
              
              // Info Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "MANAGER: $name",
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
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const Spacer(),
                        // TAMPILAN UANG ($)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.neonYellow)
                          ),
                          child: Text(
                            "\$ $money", 
                            style: const TextStyle(
                              color: AppColors.neonYellow,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
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