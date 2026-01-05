// Model Tim untuk Klasemen
class TeamModel {
  final String name;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int points;
  final bool isPlayerTeam;

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

  // [BARU] toJson
  Map<String, dynamic> toJson() => {
    'name': name,
    'played': played,
    'won': won,
    'drawn': drawn,
    'lost': lost,
    'points': points,
    'isPlayerTeam': isPlayerTeam,
  };

  // [BARU] fromJson
  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      name: json['name'],
      played: json['played'],
      won: json['won'],
      drawn: json['drawn'],
      lost: json['lost'],
      points: json['points'],
      isPlayerTeam: json['isPlayerTeam'] ?? false,
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

  // [BARU] toJson
  Map<String, dynamic> toJson() => {
    'homeTeam': homeTeam,
    'awayTeam': awayTeam,
    'homeScore': homeScore,
    'awayScore': awayScore,
    'isPlayed': isPlayed,
    'matchday': matchday,
  };

  // [BARU] fromJson
  factory FixtureModel.fromJson(Map<String, dynamic> json) {
    return FixtureModel(
      homeTeam: json['homeTeam'],
      awayTeam: json['awayTeam'],
      homeScore: json['homeScore'],
      awayScore: json['awayScore'],
      isPlayed: json['isPlayed'],
      matchday: json['matchday'],
    );
  }
}

// Model untuk Top Skor / Assist
class PlayerStatEntry {
  final String name;
  final String teamName;
  final int value;
  
  PlayerStatEntry(this.name, this.teamName, this.value);

  // [BARU] toJson
  Map<String, dynamic> toJson() => {
    'name': name,
    'teamName': teamName,
    'value': value,
  };

  // [BARU] fromJson
  factory PlayerStatEntry.fromJson(Map<String, dynamic> json) {
    return PlayerStatEntry(
      json['name'],
      json['teamName'],
      json['value'],
    );
  }
}