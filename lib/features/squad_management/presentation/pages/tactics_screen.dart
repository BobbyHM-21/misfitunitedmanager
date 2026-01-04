import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../logic/squad_bloc.dart';
import '../../logic/squad_state.dart';

class TacticsScreen extends StatefulWidget {
  const TacticsScreen({super.key});

  @override
  State<TacticsScreen> createState() => _TacticsScreenState();
}

class _TacticsScreenState extends State<TacticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("TACTICAL BOARD", style: TextStyle(fontFamily: 'Rajdhani', color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<SquadBloc, SquadState>(
        builder: (context, state) {
          if (state is SquadLoaded) {
            // Ambil 11 Pemain Pertama sebagai Starter
            final starters = state.players.take(11).toList();
            
            return Column(
              children: [
                // 1. PITCH VISUALIZER
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.electricCyan, width: 2),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.green.withOpacity(0.2),
                    ),
                    child: Stack(
                      children: [
                        // Background Lapangan (Optional)
                        // TacticalPitch(starters: starters), 
                        
                        // Placeholder Text jika TacticalPitch belum siap
                        const Center(child: Text("TACTICAL VIEW", style: TextStyle(color: Colors.white54))),
                      ],
                    ),
                  ),
                ),

                // 2. FORMATION INFO
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Text("FORMATION: 4-3-3", style: TextStyle(color: AppColors.neonYellow, fontWeight: FontWeight.bold)),
                      Text("STYLE: ATTACK", style: TextStyle(color: AppColors.hotPink, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}