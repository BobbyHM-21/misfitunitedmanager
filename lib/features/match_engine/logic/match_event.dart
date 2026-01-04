import 'package:equatable/equatable.dart'; // Opsional, tapi bagus
import '../data/match_card_model.dart';

abstract class MatchEvent extends Equatable {
  const MatchEvent();

  @override
  List<Object> get props => [];
}

// 1. Event Mulai Match
class StartMatch extends MatchEvent {}

// 2. Event Main Kartu
class PlayCard extends MatchEvent {
  final MatchCard card;
  const PlayCard(this.card);

  @override
  List<Object> get props => [card];
}

// 3. Event Detak Jam (BARU)
class TimerTicked extends MatchEvent {
  final int minute;
  const TimerTicked(this.minute);

  @override
  List<Object> get props => [minute];
}