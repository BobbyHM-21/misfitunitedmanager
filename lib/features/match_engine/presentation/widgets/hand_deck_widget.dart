import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/match_card_model.dart';
import '../../logic/match_bloc.dart';

// --- TAMBAHKAN IMPORT INI ---
import '../../logic/match_event.dart'; // <-- Agar kenal 'PlayCard'
import '../../logic/match_state.dart'; // <-- Agar kenal 'MatchState'
// ----------------------------

class HandDeckWidget extends StatelessWidget {
  const HandDeckWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchBloc, MatchState>( // Error 'MatchState' hilang
      builder: (context, state) {
        return Container(
          height: 140,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            border: Border(top: BorderSide(color: AppColors.electricCyan, width: 2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            // Kita pakai state.playerHand langsung
            children: state.playerHand.map((card) {
              return GestureDetector(
                onTap: () {
                  // Error 'PlayCard' hilang
                  context.read<MatchBloc>().add(PlayCard(card));
                },
                child: _buildCardUI(card),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // ... (Sisa kode _buildCardUI biarkan sama) ...
   Widget _buildCardUI(MatchCard card) {
    return Container(
      width: 90,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.black87,
        border: Border.all(color: card.color, width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: card.color.withOpacity(0.4), blurRadius: 8)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(card.icon, color: card.color, size: 30),
          const SizedBox(height: 5),
          Text(
            card.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: card.color, 
              fontWeight: FontWeight.bold, 
              fontSize: 12,
              fontFamily: 'Rajdhani'
            ),
          ),
          Text(
            "${card.power}",
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
}