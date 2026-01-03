class Player {
  final String name;
  final String position; // GK, DEF, MID, FWD
  final int rating; // 0-100
  final double stamina; // 0.0 - 1.0 (Persen)
  final String imagePath; // Foto wajah

  Player({
    required this.name,
    required this.position,
    required this.rating,
    required this.stamina,
    required this.imagePath,
  });

  // --- DATA DUMMY (Sesuai tema Cyberpunk) ---
  static List<Player> get dummySquad => [
    Player(name: "JINX", position: "FWD", rating: 88, stamina: 0.9, imagePath: "assets/images/avatar_manager.png"),
    Player(name: "VICTOR", position: "MID", rating: 85, stamina: 0.7, imagePath: "assets/images/avatar_manager.png"),
    Player(name: "CYPHER", position: "DEF", rating: 82, stamina: 1.0, imagePath: "assets/images/avatar_manager.png"),
    Player(name: "NEON", position: "MID", rating: 79, stamina: 0.5, imagePath: "assets/images/avatar_manager.png"),
    Player(name: "TITAN", position: "GK", rating: 90, stamina: 0.8, imagePath: "assets/images/avatar_manager.png"),
    Player(name: "GHOST", position: "FWD", rating: 75, stamina: 0.6, imagePath: "assets/images/avatar_manager.png"),
  ];
}