import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../game/the_pitch_game.dart'; 
import '../../../../core/theme/app_colors.dart';
import '../../data/goal_model.dart'; // Import Goal Model agar State valid

import '../../logic/match_bloc.dart';
import '../../logic/match_event.dart';
import '../../logic/match_state.dart';

import '../../../squad_management/logic/squad_bloc.dart';
import '../../../squad_management/logic/squad_event.dart';
import '../../../squad_management/logic/squad_state.dart';
import '../../../squad_management/data/player_model.dart';

import '../widgets/hand_deck_widget.dart';

class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Ambil Nama Pemain
    final squadState = context.read<SquadBloc>().state;
    List<String> starterNames = [];
    if (squadState is SquadLoaded && squadState.players.isNotEmpty) {
      starterNames = squadState.players.take(11).map((p) => p.name).toList();
    } else {
      starterNames = Player.dummySquad.take(11).map((p) => p.name).toList();
    }

    return BlocProvider(
      create: (context) => MatchBloc()..add(StartMatch(starterNames)),
      
      child: BlocListener<MatchBloc, MatchState>(
        listener: (context, state) {
          // POPUP HASIL AKHIR
          if (state.isMatchOver) {
            context.read<SquadBloc>().add(ReduceStaminaForStarters());
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => _buildMatchResultDialog(context, state),
            );
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              // LAYER 1: GAME FLAME (Background Statis)
              ColorFiltered(
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                child: GameWidget(game: ThePitchGame(playerNames: starterNames)),
              ),
              
              // LAYER 2: UI UTAMA
              SafeArea(
                child: Column(
                  children: [
                    // A. SCOREBOARD
                    _buildScoreBoard(context),
                    
                    const Spacer(),

                    // B. KOMENTATOR / EVENT BOX
                    BlocBuilder<MatchBloc, MatchState>(
                      builder: (context, state) {
                        // Tentukan Warna Border berdasarkan Konteks
                        Color borderColor = Colors.white12;
                        String titleText = "";
                        
                        // LOGIKA PENGGANTI 'eventType' string
                        if (state.isEventTriggered) {
                           if (state.matchContext == MatchContext.attacking) {
                             borderColor = AppColors.electricCyan;
                             titleText = "PELUANG EMAS!";
                           } else if (state.matchContext == MatchContext.defending) {
                             borderColor = Colors.red;
                             titleText = "BAHAYA! DISERANG!";
                           }
                        }

                        return Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: state.isEventTriggered ? 3 : 1),
                            boxShadow: [
                              BoxShadow(color: borderColor.withOpacity(0.5), blurRadius: 20)
                            ]
                          ),
                          child: Column(
                            children: [
                              if (state.isEventTriggered)
                                Text(
                                  titleText,
                                  style: TextStyle(
                                    color: borderColor,
                                    fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'Rajdhani'
                                  ),
                                ),
                              const SizedBox(height: 10),
                              Text(
                                state.lastEvent,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // C. KARTU TANGAN (HANYA MUNCUL SAAT EVENT PAUSE)
                    BlocBuilder<MatchBloc, MatchState>(
                      builder: (context, state) {
                        if (!state.isEventTriggered) {
                          return const Padding(
                            padding: EdgeInsets.only(bottom: 20.0),
                            child: Text("Simulating...", style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic)),
                          );
                        }
                        
                        return Column(
                          children: [
                            Text(
                              state.matchContext == MatchContext.attacking 
                                  ? "PILIH FINISHING:" 
                                  : "PILIH CARA BERTAHAN:", 
                              style: const TextStyle(color: AppColors.neonYellow, fontWeight: FontWeight.bold)
                            ),
                            const SizedBox(height: 10),
                            const HandDeckWidget(),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
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
        ),
      ),
    );
  }

  Widget _buildScoreBoard(BuildContext context) {
    return BlocBuilder<MatchBloc, MatchState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
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
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Rajdhani'),
                  ),
                ],
              ),
              const Text("CORPO", style: TextStyle(color: AppColors.hotPink, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMatchResultDialog(BuildContext context, MatchState state) {
     return AlertDialog(
      backgroundColor: Colors.black.withOpacity(0.95),
      title: const Center(child: Text("FULL TIME", style: TextStyle(color: Colors.white, fontFamily: 'Rajdhani', fontSize: 24, fontWeight: FontWeight.bold))),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text("${state.playerScore} - ${state.enemyScore}", style: const TextStyle(color: AppColors.neonYellow, fontSize: 50, fontWeight: FontWeight.bold)),
             const Divider(color: Colors.white24),
             const SizedBox(height: 10),
             if (state.matchGoals.isEmpty)
               const Text("No Goals", style: TextStyle(color: Colors.grey)),
             
             Flexible(
               child: ListView(
                 shrinkWrap: true,
                 children: state.matchGoals.map((g) => Padding(
                   padding: const EdgeInsets.symmetric(vertical: 4),
                   child: Row(
                     mainAxisAlignment: g.isEnemyGoal ? MainAxisAlignment.end : MainAxisAlignment.start,
                     children: [
                       Text(
                         "${g.minute}' ${g.scorerName}", 
                         style: TextStyle(color: g.isEnemyGoal ? AppColors.hotPink : AppColors.electricCyan, fontWeight: FontWeight.bold)
                        ),
                     ],
                   ),
                 )).toList(),
               ),
             ),
          ],
        ),
      ),
      actions: [
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.electricCyan),
            onPressed: () { Navigator.pop(context); Navigator.pop(context); }, 
            child: const Text("RETURN TO CLUB", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
          )
        )
      ],
    );
  }
}