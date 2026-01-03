import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart'; // Import daftar aset tadi
import '../widgets/neon_menu_button.dart';
import '../../../../features/squad_management/presentation/pages/squad_screen.dart';


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
                const SizedBox(height: 40),
                
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
                        onTap: () => print("Taktik Clicked"),
                      ),
                      // TOMBOL 3: TRANSFER
                      NeonMenuButton(
                        label: "TRANSFER",
                        imagePath: AppAssets.iconTransfer,
                        glowColor: AppColors.hotPink,
                        delay: 300,
                        onTap: () => print("Transfer Clicked"),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5), // Semi transparan
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: AppColors.electricCyan, width: 4),
        ),
      ),
      child: Row(
        children: [
          // Avatar Image (Jika ada, kalau tidak pakai Icon default)
          CircleAvatar(
            backgroundColor: AppColors.electricCyan,
            radius: 25,
            // Cek kalau file avatar ada, pakai gambar. Kalau tidak, icon.
            backgroundImage: AssetImage(AppAssets.avatarManager), 
            onBackgroundImageError: (_, __) => const Icon(Icons.person),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "MANAGER: USER",
                style: TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                  fontFamily: 'Rajdhani',
                ),
              ),
              Text(
                "DIVISI: 10 (ROOKIE)",
                style: TextStyle(
                  color: AppColors.neonYellow, 
                  fontSize: 12,
                  fontFamily: 'Rajdhani',
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}