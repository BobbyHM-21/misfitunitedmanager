import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../game/the_pitch_game.dart';
import '../../../../core/theme/app_colors.dart';

// --- BAGIAN PENTING: IMPORT SEMUA FILE LOGIC ---
import '../../logic/match_bloc.dart';
import '../../logic/match_event.dart'; // <-- Agar kenal 'StartMatch', 'TimerTicked'
import '../../logic/match_state.dart'; // <-- Agar kenal 'MatchState'
// -----------------------------------------------

import '../widgets/hand_deck_widget.dart';

class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MatchBloc()..add(StartMatch()), // Error 'StartMatch' hilang
      child: Scaffold(
        body: Stack(
          children: [
            GameWidget(game: ThePitchGame()),
            SafeArea(
              child: Column(
                children: [
                  // SCOREBOARD
                  BlocBuilder<MatchBloc, MatchState>( // Error 'MatchState' hilang
                    builder: (context, state) {
                      return Column(
                        children: [
                          _buildScoreBoard(state), // Kita kirim seluruh state
                          const SizedBox(height: 10),
                          Text(
                            state.lastEvent,
                            style: TextStyle(
                              color: state.isMatchOver ? Colors.red : AppColors.neonYellow,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const Spacer(),
                  const HandDeckWidget(),
                ],
              ),
            ),
            // Tombol Back
             Positioned(
              top: 40, left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Helper Scoreboard (Saya update parameternya biar tidak error nullable)
  Widget _buildScoreBoard(MatchState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.electricCyan),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("MISFITS", style: TextStyle(color: AppColors.electricCyan, fontWeight: FontWeight.bold)),
          Column(
            children: [
              Text(
                "${state.gameMinute}'",
                style: const TextStyle(color: AppColors.neonYellow, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                "${state.playerScore} - ${state.enemyScore}",
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const Text("CORPO", style: TextStyle(color: AppColors.hotPink, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}