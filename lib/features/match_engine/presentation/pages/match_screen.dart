import 'dart:math'; // Diperlukan untuk perhitungan rating/assist acak
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../game/the_pitch_game.dart'; 
import '../../../../core/theme/app_colors.dart';
import '../../data/goal_model.dart'; 

// Logic Match
import '../../logic/match_bloc.dart';
import '../../logic/match_event.dart';
import '../../logic/match_state.dart';

// Logic Squad
import '../../../squad_management/logic/squad_bloc.dart';
import '../../../squad_management/logic/squad_event.dart';
import '../../../squad_management/logic/squad_state.dart';
import '../../../squad_management/data/player_model.dart';

// Logic Manager
import '../../../manager_cockpit/logic/manager_bloc.dart';
import '../../../manager_cockpit/logic/manager_event.dart';

// [BARU] Logic League (Untuk Update Klasemen)
import '../../../league/logic/league_cubit.dart';

// Widget UI
import '../widgets/hand_deck_widget.dart';

class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. AMBIL STARTER DARI SQUAD (Fitur Lama: Agar yang main adalah skuad asli)
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
          // --- LOGIKA SAAT MATCH BERAKHIR ---
          if (state.isMatchOver) {
            
            // A. [Fitur Lama] Kurangi Stamina Starter
            context.read<SquadBloc>().add(ReduceStaminaForStarters());
            
            // B. [Fitur Lama] Hitung Uang
            int reward = 0;
            String resultStatus = "";

            if (state.playerScore > state.enemyScore) {
              reward = 1000; 
              resultStatus = "WIN";
            } else if (state.playerScore == state.enemyScore) {
              reward = 500; 
              resultStatus = "DRAW";
            } else {
              reward = 100; 
              resultStatus = "LOSS";
            }

            int goalBonus = state.playerScore * 50;
            int totalEarnings = reward + goalBonus;

            // C. [Fitur Lama] Update Uang Manager
            context.read<ManagerBloc>().add(ModifyMoney(totalEarnings));

            // ============================================================
            // [FITUR BARU PHASE 4: UPDATE STATISTIK & KLASEMEN]
            // ============================================================
            
            // 1. Ambil nama pencetak gol tim kita
            List<String> myScorersList = state.matchGoals
                .where((g) => !g.isEnemyGoal)
                .map((g) => g.scorerName)
                .toList();

            // 2. Update Klasemen Liga (LeagueCubit)
            // (Pastikan Anda sudah update main.dart agar LeagueCubit tersedia)
            context.read<LeagueCubit>().finishMatchday(
              state.playerScore, 
              state.enemyScore, 
              myScorersList
            );

            // 3. Hitung Statistik Detail (Gol, Assist, Rating) untuk Skuad
            Map<String, int> goalMap = {};
            Map<String, int> assistMap = {};
            Map<String, double> ratingMap = {};
            final random = Random();

            // 3a. Hitung Gol
            for (var scorer in myScorersList) {
              goalMap[scorer] = (goalMap[scorer] ?? 0) + 1;
              
              // 3b. Simulasi Assist (Pilih starter lain secara acak selain pencetak gol)
              if (starterNames.length > 1) {
                String assister = starterNames[random.nextInt(starterNames.length)];
                int attempts = 0;
                while (assister == scorer && attempts < 5) {
                  assister = starterNames[random.nextInt(starterNames.length)];
                  attempts++;
                }
                assistMap[assister] = (assistMap[assister] ?? 0) + 1;
              }
            }

            // 3c. Hitung Rating Match (6.0 - 10.0)
            for (var player in starterNames) {
              double baseRating = 6.0;
              // Tambah rating jika cetak gol/assist
              if (goalMap.containsKey(player)) baseRating += (goalMap[player]! * 1.0);
              if (assistMap.containsKey(player)) baseRating += (assistMap[player]! * 0.5);
              
              // Variasi Random +/- 0.5
              double variance = (random.nextDouble() - 0.5); 
              
              // Bonus jika Menang
              if (state.playerScore > state.enemyScore) baseRating += 0.5;
              
              double finalRating = baseRating + variance;
              if (finalRating > 10.0) finalRating = 10.0;
              if (finalRating < 3.0) finalRating = 3.0;

              ratingMap[player] = double.parse(finalRating.toStringAsFixed(1));
            }

            // 4. Kirim Statistik ke SquadBloc (agar tersimpan di profil pemain)
            context.read<SquadBloc>().add(UpdatePlayerMatchStats(
              goalScorers: goalMap,
              assistMakers: assistMap,
              matchRatings: ratingMap,
            ));
            // ============================================================

            // D. [Fitur Lama] Tampilkan Dialog Hasil
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => _buildMatchResultDialog(context, state, totalEarnings, resultStatus),
            );
          }
        },
        child: Scaffold(
          // [Fitur Lama] Stack berisi Game Engine & UI Overlay
          body: Stack(
            children: [
              // LAYER 1: GAME FLAME (VISUAL)
              ColorFiltered(
                colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.4), BlendMode.darken),
                child: GameWidget(game: ThePitchGame(playerNames: starterNames)),
              ),
              
              // LAYER 2: UI UTAMA
              SafeArea(
                child: Column(
                  children: [
                    // A. SCOREBOARD
                    _buildScoreBoard(context),
                    
                    const Spacer(),

                    // B. EVENT BOX / KOMENTATOR
                    BlocBuilder<MatchBloc, MatchState>(
                      builder: (context, state) {
                        Color borderColor = Colors.white12;
                        String titleText = "";
                        
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
                            color: Colors.black.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: state.isEventTriggered ? 3 : 1),
                            boxShadow: [
                              BoxShadow(color: borderColor.withValues(alpha: 0.5), blurRadius: 20)
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

                    // C. KARTU TANGAN (HAND DECK)
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

              // Tombol Kembali (Pojok Kiri Atas)
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

  // --- WIDGET HELPER (TETAP SAMA) ---

  Widget _buildScoreBoard(BuildContext context) {
    return BlocBuilder<MatchBloc, MatchState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.9),
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

  Widget _buildMatchResultDialog(BuildContext context, MatchState state, int earnings, String status) {
     return AlertDialog(
      backgroundColor: Colors.black.withValues(alpha: 0.95),
      shape: RoundedRectangleBorder(side: const BorderSide(color: AppColors.electricCyan), borderRadius: BorderRadius.circular(12)),
      
      title: Center(
        child: Text(
          status, 
          style: TextStyle(
            color: status == "WIN" ? AppColors.electricCyan : (status == "LOSS" ? Colors.red : Colors.white), 
            fontFamily: 'Rajdhani', fontSize: 32, fontWeight: FontWeight.bold
          )
        )
      ),
      
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text(
               "${state.playerScore} - ${state.enemyScore}", 
               style: const TextStyle(color: AppColors.neonYellow, fontSize: 50, fontWeight: FontWeight.bold)
             ),
             const SizedBox(height: 20),
             
             // Info Gaji
             Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
               child: Column(
                 children: [
                   const Text("MATCH EARNINGS", style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2)),
                   const SizedBox(height: 5),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       const Icon(Icons.monetization_on, color: Colors.amber),
                       const SizedBox(width: 8),
                       Text("+\$$earnings", style: const TextStyle(color: Colors.amber, fontSize: 28, fontWeight: FontWeight.bold)),
                     ],
                   )
                 ],
               ),
             ),
             
             const Divider(color: Colors.white24, height: 30),
             
             // Log Gol
             if (state.matchGoals.isEmpty)
               const Text("No Goals Scored", style: TextStyle(color: Colors.grey)),
             
             Flexible(
               child: ListView(
                 shrinkWrap: true,
                 children: state.matchGoals.map((g) => Padding(
                   padding: const EdgeInsets.symmetric(vertical: 2),
                   child: Row(
                     mainAxisAlignment: g.isEnemyGoal ? MainAxisAlignment.end : MainAxisAlignment.start,
                     children: [
                       Text(
                         "${g.minute}' ${g.scorerName}", 
                         style: TextStyle(color: g.isEnemyGoal ? Colors.redAccent : Colors.cyanAccent, fontSize: 12)
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricCyan, 
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)
            ),
            onPressed: () { 
              Navigator.pop(context); // Tutup Dialog
              Navigator.pop(context); // Kembali ke Menu
            }, 
            child: const Text("COLLECT & RETURN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
          )
        )
      ],
    );
  }
}