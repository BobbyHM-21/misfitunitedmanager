import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../game/the_pitch_game.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/goal_model.dart';

import '../../logic/match_bloc.dart';
import '../../logic/match_event.dart';
import '../../logic/match_state.dart';

import '../../../squad_management/logic/squad_bloc.dart';
import '../../../squad_management/logic/squad_event.dart';
import '../../../squad_management/logic/squad_state.dart';
import '../../../squad_management/data/player_model.dart';

import '../widgets/hand_deck_widget.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  // Referensi ke Game Engine agar bisa Resume
  ThePitchGame? _activeGame;
  
  // Status Duel (Apakah sedang Pause & Pilih Kartu?)
  bool _isDuelActive = false; 

  @override
  Widget build(BuildContext context) {
    final squadState = context.read<SquadBloc>().state;
    List<String> starterNames = [];
    if (squadState is SquadLoaded && squadState.players.isNotEmpty) {
      starterNames = squadState.players.take(11).map((p) => p.name).toList();
    } else {
      starterNames = Player.dummySquad.take(11).map((p) => p.name).toList();
    }

    return BlocProvider(
      create: (context) => MatchBloc()..add(StartMatch(starterNames)),
      
      child: BlocConsumer<MatchBloc, MatchState>(
        listener: (context, state) {
          // A. LOGIKA RESUME SETELAH KARTU DIPILIH
          // Jika event berubah (ada GOAL/SAVED/DRAW), berarti duel selesai
          if (state.lastEvent.contains("GOAL") || state.lastEvent.contains("SAVED") || state.lastEvent.contains("DRAW")) {
            
            if (_isDuelActive) {
              setState(() { _isDuelActive = false; }); // Sembunyikan Overlay
              
              // RESUME GAME ENGINE!
              bool homeWon = state.lastEvent.contains("GOAL") || state.lastEvent.contains("DRAW");
              _activeGame?.resumeMatchAfterDuel(homeWon: homeWon);
            }
          }

          // B. LOGIKA FULL TIME
          if (state.isMatchOver) {
            context.read<SquadBloc>().add(ReduceStaminaForStarters());
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => _buildMatchResultDialog(context, state),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: Stack(
              children: [
                // LAYER 1: GAME ENGINE
                GameWidget(
                  game: _activeGame ??= ThePitchGame(
                    playerNames: starterNames,
                    onDuelTriggered: () {
                      // CALLBACK DARI GAME: KETIKA PEMAIN BERTMU -> STOP GAME
                      setState(() {
                        _isDuelActive = true; 
                      });
                    },
                  ),
                ),
                
                // LAYER 2: UI OVERLAY
                SafeArea(
                  child: Column(
                    children: [
                      _buildScoreBoard(state),
                      const SizedBox(height: 12),
                      
                      // LOG EVENT (Sembunyikan saat Duel biar bersih)
                      AnimatedOpacity(
                        opacity: _isDuelActive ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            state.lastEvent,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: state.lastEvent.contains("GOAL") ? AppColors.electricCyan : AppColors.neonYellow,
                              fontWeight: FontWeight.bold, fontFamily: 'Rajdhani', fontSize: 16
                            ),
                          ),
                        ),
                      ),
                      
                      const Spacer(),

                      // LAYER 3: KARTU TANGAN (HANYA MUNCUL SAAT DUEL / KICKOFF)
                      // Kita paksa user memilih kartu SAAT DUEL terjadi
                      if (_isDuelActive || state.gameMinute == 0) 
                        Column(
                          children: [
                            const Text(
                              "TACTICAL DUEL!", 
                              style: TextStyle(
                                color: Colors.redAccent, fontSize: 28, fontWeight: FontWeight.bold, 
                                letterSpacing: 2, fontFamily: 'Rajdhani',
                                shadows: [Shadow(blurRadius: 10, color: Colors.black)]
                              )
                            ),
                            const Text(
                              "Choose your move...", 
                              style: TextStyle(color: Colors.white70, fontSize: 14)
                            ),
                            const SizedBox(height: 10),
                            const HandDeckWidget(), // Widget Kartu
                          ],
                        )
                    ],
                  ),
                ),

                // Back Button
                Positioned(
                  top: 40, left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Widget Helper (Scoreboard & Dialog) ---
  Widget _buildScoreBoard(MatchState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.electricCyan, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("MISFITS", style: TextStyle(color: AppColors.electricCyan, fontWeight: FontWeight.bold, fontSize: 16)),
          Column(
            children: [
              Text(
                "${state.gameMinute}'",
                style: const TextStyle(color: AppColors.neonYellow, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                "${state.playerScore} - ${state.enemyScore}",
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Rajdhani'),
              ),
            ],
          ),
          const Text("CORPO", style: TextStyle(color: AppColors.hotPink, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildMatchResultDialog(BuildContext context, MatchState state) {
     return AlertDialog(
      backgroundColor: Colors.black.withOpacity(0.9),
      title: const Center(child: Text("FULL TIME", style: TextStyle(color: Colors.white, fontFamily: 'Rajdhani'))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           Text("${state.playerScore} - ${state.enemyScore}", style: const TextStyle(color: AppColors.neonYellow, fontSize: 40)),
           const SizedBox(height: 10),
           ...state.matchGoals.map((g) => Text("${g.minute}' ${g.scorerName}", style: TextStyle(color: g.isEnemyGoal ? Colors.red : Colors.cyan))),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () { Navigator.pop(context); Navigator.pop(context); }, 
          child: const Text("CLOSE")
        )
      ],
    );
  }
}