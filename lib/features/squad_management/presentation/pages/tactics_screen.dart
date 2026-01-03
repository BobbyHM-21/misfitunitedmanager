import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../logic/squad_bloc.dart';
import '../../logic/squad_event.dart'; // Import Event Swap
import '../../logic/squad_state.dart';
import '../../data/player_model.dart'; // Import Model
import '../widgets/tactical_pitch.dart';
import '../widgets/player_list_item.dart'; // Reuse list item

class TacticsScreen extends StatefulWidget {
  const TacticsScreen({super.key});

  @override
  State<TacticsScreen> createState() => _TacticsScreenState();
}

class _TacticsScreenState extends State<TacticsScreen> {
  // Variabel untuk menyimpan index pemain yang sedang dipilih
  int? selectedPlayerIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("TACTICAL BOARD", style: TextStyle(color: AppColors.neonYellow, fontFamily: 'Rajdhani', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black.withOpacity(0.5),
        iconTheme: const IconThemeData(color: AppColors.neonYellow),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.bgCity),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.9), BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<SquadBloc, SquadState>(
            builder: (context, state) {
              if (state is SquadLoaded) {
                final allPlayers = state.players;
                // Ambil 11 pemain inti
                final startingXI = allPlayers.take(11).toList();
                // Sisanya cadangan
                final bench = allPlayers.skip(11).toList();

                return Column(
                  children: [
                    // 1. INFO STATUS
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        selectedPlayerIndex == null 
                            ? "TAP PLAYER TO SWAP" 
                            : "SELECT TARGET TO SWAP",
                        style: TextStyle(
                          color: selectedPlayerIndex == null ? Colors.white54 : AppColors.electricCyan, 
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),

                    // 2. LAPANGAN (Inti - Index 0-10)
                    Expanded(
                      flex: 4,
                      child: GestureDetector(
                        // Nanti kita bisa bikin TacticalPitch interaktif juga, 
                        // tapi sekarang kita fokus swap via List di bawah dulu biar mudah.
                        child: TacticalPitch(startingEleven: startingXI),
                      ),
                    ),

                    const Divider(color: AppColors.electricCyan),

                    // 3. DAFTAR PEMAIN (Gabungan Inti & Cadangan untuk Kontrol Mudah)
                    Expanded(
                      flex: 5,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: allPlayers.length,
                        itemBuilder: (context, index) {
                          final player = allPlayers[index];
                          final isSelected = selectedPlayerIndex == index;
                          final isStarter = index < 11;

                          return GestureDetector(
                            onTap: () => _handlePlayerTap(index),
                            child: Container(
                              color: isSelected ? AppColors.electricCyan.withOpacity(0.2) : null,
                              child: Row(
                                children: [
                                  // Indikator Posisi (Inti/Bench)
                                  Container(
                                    width: 4,
                                    height: 60,
                                    color: isStarter ? AppColors.neonYellow : Colors.grey,
                                  ),
                                  // Widget Item Pemain
                                  Expanded(
                                    child: PlayerListItem(player: player, index: index),
                                  ),
                                  // Icon Penanda
                                  if (isSelected)
                                    const Icon(Icons.swap_vert, color: AppColors.electricCyan)
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  void _handlePlayerTap(int index) {
    setState(() {
      if (selectedPlayerIndex == null) {
        // 1. Belum ada yang dipilih -> Pilih pemain ini
        selectedPlayerIndex = index;
      } else if (selectedPlayerIndex == index) {
        // 2. Klik pemain yang sama -> Batalkan pilihan
        selectedPlayerIndex = null;
      } else {
        // 3. Klik pemain berbeda -> LAKUKAN SWAP!
        
        // Panggil BLoC untuk tukar data
        context.read<SquadBloc>().add(SwapPlayers(selectedPlayerIndex!, index));
        
        // Reset pilihan
        selectedPlayerIndex = null;
        
        // Feedback visual
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("POSITION SWAPPED!"),
            duration: Duration(milliseconds: 500),
            backgroundColor: AppColors.neonYellow,
          ),
        );
      }
    });
  }
}