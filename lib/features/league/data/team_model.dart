class TeamModel {
  final String name;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int points;
  final bool isPlayerTeam; // Penanda tim kita

  TeamModel({
    required this.name,
    this.played = 0,
    this.won = 0,
    this.drawn = 0,
    this.lost = 0,
    this.points = 0,
    this.isPlayerTeam = false,
  });

  TeamModel copyWith({
    String? name,
    int? played,
    int? won,
    int? drawn,
    int? lost,
    int? points,
    bool? isPlayerTeam,
  }) {
    return TeamModel(
      name: name ?? this.name,
      played: played ?? this.played,
      won: won ?? this.won,
      drawn: drawn ?? this.drawn,
      lost: lost ?? this.lost,
      points: points ?? this.points,
      isPlayerTeam: isPlayerTeam ?? this.isPlayerTeam,
    );
  }
}