import 'package:equatable/equatable.dart';
import '../../squad_management/data/player_model.dart';

// Wrapper Model: Pemain + Harga
class MarketPlayer extends Equatable {
  final Player player;
  final int price;

  const MarketPlayer({required this.player, required this.price});

  @override
  List<Object> get props => [player, price];
}

// STATE
abstract class MarketState extends Equatable {
  const MarketState();
  @override
  List<Object> get props => [];
}

class MarketInitial extends MarketState {}

class MarketLoading extends MarketState {}

class MarketLoaded extends MarketState {
  final List<MarketPlayer> forSalePlayers; // Daftar pemain yang dijual

  const MarketLoaded(this.forSalePlayers);

  @override
  List<Object> get props => [forSalePlayers];
}