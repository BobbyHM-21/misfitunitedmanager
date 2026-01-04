import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../game/the_pitch_game.dart';
import '../../../../core/theme/app_colors.dart';

// Import Logic Match
import '../../logic/match_bloc.dart';
import '../../logic/match_event.dart';
import '../../logic/match_state.dart';

// Import Logic Squad (UNTUK STAMINA)
import '../../../squad_management/logic/squad_bloc.dart';
import '../../../squad_management/logic/squad_event.dart';

import '../widgets/hand_deck_widget.dart';

class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MatchBloc()..add(StartMatch()),
      // BUNGKUS DENGAN LISTENER
      child: BlocListener<MatchBloc, MatchState>(
        listener: (context, state) {
          // JIKA MATCH SELESAI (FULL TIME)
          if (state.isMatchOver) {
            // Panggil SquadBloc untuk kurangi stamina
            context.read<SquadBloc>().add(ReduceStaminaForStarters());
            
            // Tampilkan Info
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("MATCH ENDED! Starters lost energy (-10%)"),
                backgroundColor: AppColors.hotPink,
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              // LAYER 1: GAME
              GameWidget(game: ThePitchGame()),

              // LAYER 2: UI
              SafeArea(
                child: Column(
                  children: [
                    // Scoreboard
                    BlocBuilder<MatchBloc, MatchState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            _buildScoreBoard(state),
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
                    // Tombol Keluar (Hanya muncul jika selesai)
                    BlocBuilder<MatchBloc, MatchState>(
                      builder: (context, state) {
                        if (state.isMatchOver) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.electricCyan),
                              onPressed: () => Navigator.pop(context),
                              child: const Text("RETURN TO CLUB", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            ),
                          );
                        }
                        return const HandDeckWidget(); // Kartu main
                      },
                    ),
                  ],
                ),
              ),
              
              // Tombol Back (Pojok Kiri)
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
      ),
    );
  }

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