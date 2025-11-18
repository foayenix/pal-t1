import '../core/constants/app_constants.dart';

/// Represents a piece of gym equipment.
class Equipment {
  final String id;
  final String name;
  final EquipmentCategory category;
  final String? imageExampleUrl;
  final String defaultExerciseId;

  const Equipment({
    required this.id,
    required this.name,
    required this.category,
    this.imageExampleUrl,
    required this.defaultExerciseId,
  });

  /// Creates Equipment from Firestore document data.
  factory Equipment.fromMap(Map<String, dynamic> map, String documentId) {
    return Equipment(
      id: documentId,
      name: map['name'] as String,
      category: EquipmentCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => EquipmentCategory.other,
      ),
      imageExampleUrl: map['imageExampleUrl'] as String?,
      defaultExerciseId: map['defaultExerciseId'] as String,
    );
  }

  /// Converts Equipment to Firestore document data.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category.name,
      'imageExampleUrl': imageExampleUrl,
      'defaultExerciseId': defaultExerciseId,
    };
  }

  @override
  String toString() => 'Equipment(id: $id, name: $name, category: ${category.displayName})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Equipment && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
