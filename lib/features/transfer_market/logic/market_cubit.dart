import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'market_state.dart';
import '../../squad_management/data/player_model.dart';

// ENUM GACHA TIER
enum GachaTier {
  basic,   // Murah ($500) -> Rating 60-74
  pro,     // Sedang ($2,500) -> Rating 75-84
  elite    // Mahal ($8,000) -> Rating 85-99
}

class MarketCubit extends Cubit<MarketState> {
  MarketCubit() : super(MarketInitial());

  final Random _rng = Random();

  // 1. GENERATE PASAR (Market Biasa)
  void loadMarket() async {
    emit(MarketLoading());
    await Future.delayed(const Duration(milliseconds: 800));

    final List<MarketPlayer> newPlayers = List.generate(5, (index) {
      // Market biasa rating 70-95 acak
      return _generateRandomPlayer(minR: 70, maxR: 95); 
    });

    emit(MarketLoaded(newPlayers));
  }

  // 2. BELI PEMAIN (Market)
  void buyPlayer(MarketPlayer marketItem) {
    if (state is MarketLoaded) {
      final currentList = (state as MarketLoaded).forSalePlayers;
      final newList = List<MarketPlayer>.from(currentList)..remove(marketItem);
      emit(MarketLoaded(newList));
    }
  }

  // 3. FITUR BARU: GACHA PLAYER
  // Mengembalikan Player object langsung untuk ditampilkan di UI
  Player pullGacha(GachaTier tier) {
    int minR = 60;
    int maxR = 75;

    switch (tier) {
      case GachaTier.basic:
        minR = 60; maxR = 74;
        break;
      case GachaTier.pro:
        minR = 75; maxR = 84;
        break;
      case GachaTier.elite:
        minR = 85; maxR = 99;
        break;
    }

    // Generate pemain sesuai range rating tier
    return _generateRandomPlayer(minR: minR, maxR: maxR).player;
  }

  // HELPER: Generate Pemain dengan Range Rating Tertentu
  MarketPlayer _generateRandomPlayer({required int minR, required int maxR}) {
    final positions = ["FWD", "MID", "DEF", "GK"];
    final position = positions[_rng.nextInt(positions.length)];
    
    // Rating sesuai parameter
    final rating = minR + _rng.nextInt(maxR - minR + 1);
    
    // Harga = Rating * 100 + Variasi
    final price = rating * 100 + (_rng.nextInt(10) * 50);

    final names = [
      "Cyber", "Neon", "Flux", "Glitch", "Viper", "Kuro", "Jett", "Raze", 
      "Nova", "Prime", "Echo", "Spectre", "Phantom", "Ghost", "Omen", 
      "Titan", "Rex", "Axel", "Blade", "Shadow"
    ];
    final name = "${names[_rng.nextInt(names.length)]} ${names[_rng.nextInt(names.length)]}";

    return MarketPlayer(
      player: Player(
        name: name.toUpperCase(),
        position: position,
        rating: rating,
        stamina: 1.0, 
        imagePath: "assets/images/avatar_manager.png",
      ),
      price: price,
    );
  }
}