import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/match_card_model.dart';
import '../../logic/match_bloc.dart';
import '../../logic/match_event.dart';
import '../../logic/match_state.dart';

class HandDeckWidget extends StatelessWidget {
  const HandDeckWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchBloc, MatchState>(
      builder: (context, state) {
        // Kartu hanya muncul saat Pause Event
        if (!state.isEventTriggered) return const SizedBox.shrink();

        return Container(
          height: 160,
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: state.playerHand.map((card) {
              return GestureDetector(
                onTap: () => context.read<MatchBloc>().add(PlayCard(card)),
                child: _buildCardUI(card),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCardUI(MatchCard card) {
    // Ambil warna dan icon
    Color c = card.color ?? AppColors.electricCyan;
    IconData ic = card.icon ?? Icons.help_outline;

    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c, width: 2),
        boxShadow: [BoxShadow(color: c.withOpacity(0.4), blurRadius: 10)]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(ic, color: c, size: 32),
          const SizedBox(height: 8),
          Text(
            card.name.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: c, 
              fontWeight: FontWeight.bold, 
              fontSize: 12,
              fontFamily: 'Rajdhani'
            ),
          ),
          const SizedBox(height: 4),
          // Label Tipe
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: c.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
            child: Text(card.type.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 8)),
          )
        ],
      ),
    );
  }
}