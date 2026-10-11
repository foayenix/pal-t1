import '../core/constants/app_constants.dart';

/// Represents an exercise that can be performed on gym equipment.
class Exercise {
  final String id;
  final String equipmentId;
  final String name;
  final ExerciseDifficulty difficulty;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final List<String> steps;
  final List<String> safetyTips;
  final List<String> commonMistakes;

  const Exercise({
    required this.id,
    required this.equipmentId,
    required this.name,
    required this.difficulty,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.steps,
    required this.safetyTips,
    required this.commonMistakes,
  });

  /// Creates Exercise from serialized map data.
  factory Exercise.fromMap(Map<String, dynamic> map, String documentId) {
    return Exercise(
      id: documentId,
      equipmentId: map['equipmentId'] as String,
      name: map['name'] as String,
      difficulty: ExerciseDifficulty.values.firstWhere(
        (e) => e.name == map['difficulty'],
        orElse: () => ExerciseDifficulty.beginner,
      ),
      primaryMuscles: List<String>.from(map['primaryMuscles'] ?? []),
      secondaryMuscles: List<String>.from(map['secondaryMuscles'] ?? []),
      steps: List<String>.from(map['steps'] ?? []),
      safetyTips: List<String>.from(map['safetyTips'] ?? []),
      commonMistakes: List<String>.from(map['commonMistakes'] ?? []),
    );
  }

  /// Converts Exercise to serializable map data.
  Map<String, dynamic> toMap() {
    return {
      'equipmentId': equipmentId,
      'name': name,
      'difficulty': difficulty.name,
      'primaryMuscles': primaryMuscles,
      'secondaryMuscles': secondaryMuscles,
      'steps': steps,
      'safetyTips': safetyTips,
      'commonMistakes': commonMistakes,
    };
  }

  @override
  String toString() =>
      'Exercise(id: $id, name: $name, difficulty: ${difficulty.displayName})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Exercise && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
