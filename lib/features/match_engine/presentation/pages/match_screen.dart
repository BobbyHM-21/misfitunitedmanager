import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../game/the_pitch_game.dart';
import '../../../../core/theme/app_colors.dart';

class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // LAYER 1: GAME ENGINE (Flame)
          GameWidget(
            game: ThePitchGame(),
          ),

          // LAYER 2: UI OVERLAY (Skor & Tombol Keluar)
          SafeArea(
            child: Column(
              children: [
                // Scoreboard Atas
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  color: Colors.black.withOpacity(0.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTeamName("MISFITS", AppColors.electricCyan),
                      const Text(
                        "0 - 0",
                        style: TextStyle(
                          fontSize: 32, 
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Rajdhani'
                        ),
                      ),
                      _buildTeamName("CORPO FC", AppColors.hotPink),
                    ],
                  ),
                ),
                
                const Spacer(),

                // Tombol Keluar Sementara
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("ABORT MATCH"),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamName(String name, Color color) {
    return Text(
      name,
      style: TextStyle(
        color: color, 
        fontWeight: FontWeight.bold, 
        fontSize: 18,
        shadows: AppColors.glow(color),
      ),
    );
  }
}