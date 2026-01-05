import 'package:equatable/equatable.dart';

class Team extends Equatable {
  final String name;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalDifference;
  final int points;
  final int strength; 

  const Team({
    required this.name,
    this.played = 0,
    this.won = 0,
    this.drawn = 0,
    this.lost = 0,
    this.goalDifference = 0,
    this.points = 0,
    required this.strength,
  });

  Team copyWith({
    String? name,
    int? played,
    int? won,
    int? drawn,
    int? lost,
    int? goalDifference,
    int? points,
    int? strength,
  }) {
    return Team(
      name: name ?? this.name,
      played: played ?? this.played,
      won: won ?? this.won,
      drawn: drawn ?? this.drawn,
      lost: lost ?? this.lost,
      goalDifference: goalDifference ?? this.goalDifference,
      points: points ?? this.points,
      strength: strength ?? this.strength,
    );
  }

  // [BARU] Simpan ke JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'played': played,
      'won': won,
      'drawn': drawn,
      'lost': lost,
      'goalDifference': goalDifference,
      'points': points,
      'strength': strength,
    };
  }

  // [BARU] Load dari JSON
  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      name: json['name'],
      played: json['played'] ?? 0,
      won: json['won'] ?? 0,
      drawn: json['drawn'] ?? 0,
      lost: json['lost'] ?? 0,
      goalDifference: json['goalDifference'] ?? 0,
      points: json['points'] ?? 0,
      strength: json['strength'] ?? 60,
    );
  }

  @override
  List<Object> get props => [name, played, won, drawn, lost, goalDifference, points, strength];
}