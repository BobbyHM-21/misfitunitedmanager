import 'package:flutter_bloc/flutter_bloc.dart';
import '../../squad_management/data/player_model.dart';
import '../../../../core/constants/app_assets.dart';

// State sederhana: List pemain yang dijual
class MarketState {
  final List<Player> forSale;
  MarketState(this.forSale);
}

class MarketCubit extends Cubit<MarketState> {
  MarketCubit() : super(MarketState([])) {
    loadMarket();
  }

  void loadMarket() {
    // Ceritanya ini data dari Scout / Server
    final marketPlayers = [
      Player(name: "VAYNE", position: "FWD", rating: 92, stamina: 1.0, imagePath: AppAssets.avatarManager),
      Player(name: "ZERI", position: "FWD", rating: 89, stamina: 1.0, imagePath: AppAssets.avatarManager),
      Player(name: "ECHO", position: "MID", rating: 85, stamina: 0.9, imagePath: AppAssets.avatarManager),
      Player(name: "BRAUM", position: "DEF", rating: 88, stamina: 1.0, imagePath: AppAssets.avatarManager),
      Player(name: "VI", position: "MID", rating: 84, stamina: 0.9, imagePath: AppAssets.avatarManager),
    ];
    emit(MarketState(marketPlayers));
  }

  // Hapus pemain dari pasar setelah dibeli
  void removePlayer(Player player) {
    final newList = List<Player>.from(state.forSale)..remove(player);
    emit(MarketState(newList));
  }
}