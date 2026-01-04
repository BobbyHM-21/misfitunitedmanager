// Model Tim untuk Klasemen
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

// Model Pertandingan (Jadwal)
class FixtureModel {
  final String homeTeam;
  final String awayTeam;
  final int? homeScore;
  final int? awayScore;
  final bool isPlayed;
  final int matchday;

  FixtureModel({
    required this.homeTeam,
    required this.awayTeam,
    this.homeScore,
    this.awayScore,
    this.isPlayed = false,
    required this.matchday,
  });

  FixtureModel copyWith({
    String? homeTeam,
    String? awayTeam,
    int? homeScore,
    int? awayScore,
    bool? isPlayed,
    int? matchday,
  }) {
    return FixtureModel(
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      isPlayed: isPlayed ?? this.isPlayed,
      matchday: matchday ?? this.matchday,
    );
  }
}

// Model untuk Top Skor / Assist
class PlayerStatEntry {
  final String name;
  final String teamName;
  final int value; // Jumlah Gol atau Assist
  
  PlayerStatEntry(this.name, this.teamName, this.value);
}