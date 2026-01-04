import 'package:equatable/equatable.dart';

class Player extends Equatable {
  final String name;
  final String position; // FWD, MID, DEF, GK
  final int rating;
  final double stamina; // 0.0 - 1.0
  final String? imagePath;
  
  // [BARU] STATISTIK MUSIM INI
  final int seasonGoals;
  final int seasonAssists;
  final int seasonYellowCards;
  final int seasonRedCards;
  final int seasonAppearances;
  final double averageRating; // Rata-rata performa

  const Player({
    required this.name,
    required this.position,
    required this.rating,
    this.stamina = 1.0,
    this.imagePath,
    this.seasonGoals = 0,
    this.seasonAssists = 0,
    this.seasonYellowCards = 0,
    this.seasonRedCards = 0,
    this.seasonAppearances = 0,
    this.averageRating = 6.0,
  });

  Player copyWith({
    String? name,
    String? position,
    int? rating,
    double? stamina,
    String? imagePath,
    int? seasonGoals,
    int? seasonAssists,
    int? seasonYellowCards,
    int? seasonRedCards,
    int? seasonAppearances,
    double? averageRating,
  }) {
    return Player(
      name: name ?? this.name,
      position: position ?? this.position,
      rating: rating ?? this.rating,
      stamina: stamina ?? this.stamina,
      imagePath: imagePath ?? this.imagePath,
      seasonGoals: seasonGoals ?? this.seasonGoals,
      seasonAssists: seasonAssists ?? this.seasonAssists,
      seasonYellowCards: seasonYellowCards ?? this.seasonYellowCards,
      seasonRedCards: seasonRedCards ?? this.seasonRedCards,
      seasonAppearances: seasonAppearances ?? this.seasonAppearances,
      averageRating: averageRating ?? this.averageRating,
    );
  }

  // Data Dummy Awal
  static List<Player> get dummySquad => [
    const Player(name: "K. NAKAMURA", position: "FWD", rating: 82),
    const Player(name: "J. STEEL", position: "FWD", rating: 78),
    const Player(name: "A. VOLKOV", position: "MID", rating: 80),
    const Player(name: "M. ROSSI", position: "MID", rating: 76),
    const Player(name: "L. SILVA", position: "MID", rating: 79),
    const Player(name: "C. O'CONNOR", position: "MID", rating: 75),
    const Player(name: "H. KIM", position: "DEF", rating: 77),
    const Player(name: "B. JONES", position: "DEF", rating: 74),
    const Player(name: "S. MULLER", position: "DEF", rating: 81),
    const Player(name: "P. DUBOIS", position: "DEF", rating: 76),
    const Player(name: "G. BUFFON", position: "GK", rating: 83),
    // Cadangan
    const Player(name: "R. CHEN", position: "MID", rating: 72),
    const Player(name: "D. ALVES", position: "DEF", rating: 71),
    const Player(name: "T. SMITH", position: "FWD", rating: 70),
  ];

  @override
  List<Object?> get props => [name, position, rating, stamina, imagePath, seasonGoals, seasonAssists, seasonAppearances, averageRating];
}