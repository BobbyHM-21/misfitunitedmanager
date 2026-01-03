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
  // ... di dalam class Player ...
  static List<Player> get dummySquad => [
    // 1. GK
    Player(name: "TITAN", position: "GK", rating: 90, stamina: 0.8, imagePath: "assets/images/avatar_manager.png"),
    // 2-5. DEF
    Player(name: "CYPHER", position: "DEF", rating: 82, stamina: 1.0, imagePath: "assets/images/avatar_manager.png"),
    Player(name: "WALL", position: "DEF", rating: 80, stamina: 0.9, imagePath: "assets/images/avatar_manager.png"),
    Player(name: "SHIELD", position: "DEF", rating: 78, stamina: 0.85, imagePath: "assets/images/avatar_manager.png"),
    Player(name: "RUSH", position: "DEF", rating: 81, stamina: 0.9, imagePath: "assets/images/avatar_manager.png"),
    // 6-8. MID
    Player(name: "VICTOR", position: "MID", rating: 85, stamina: 0.7, imagePath: "assets/images/avatar_manager.png"),
    Player(name: "NEON", position: "MID", rating: 79, stamina: 0.5, imagePath: "assets/images/avatar_manager.png"),
    Player(name: "LINK", position: "MID", rating: 83, stamina: 0.8, imagePath: "assets/images/avatar_manager.png"),
    // 9-11. FWD
    Player(name: "JINX", position: "FWD", rating: 88, stamina: 0.9, imagePath: "assets/images/avatar_manager.png"),
    Player(name: "GHOST", position: "FWD", rating: 75, stamina: 0.6, imagePath: "assets/images/avatar_manager.png"),
    Player(name: "BLAZE", position: "FWD", rating: 84, stamina: 0.8, imagePath: "assets/images/avatar_manager.png"),
  ];
}