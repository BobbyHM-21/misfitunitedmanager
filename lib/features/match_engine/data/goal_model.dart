class GoalModel {
  final String scorerName;
  final int minute;
  final bool isEnemyGoal; // True jika musuh yang gol

  GoalModel({
    required this.scorerName,
    required this.minute,
    required this.isEnemyGoal,
  });
}