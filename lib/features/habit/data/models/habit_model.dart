import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 0)
class HabitModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final List<DateTime> completedDates;

  @HiveField(4, defaultValue: 'Other')
  final String category;

  @HiveField(5, defaultValue: 'Daily')
  final String frequency;

  @HiveField(6, defaultValue: 1)
  final int targetValue;

  @HiveField(7, defaultValue: 'Times')
  final String targetUnit;

  @HiveField(8)
  final DateTime? reminderTime;

  @HiveField(9, defaultValue: 'Medium')
  final String difficulty;

  @HiveField(10, defaultValue: '')
  final String motivationNote;

  HabitModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.completedDates = const [],
    this.category = 'Other',
    this.frequency = 'Daily',
    this.targetValue = 1,
    this.targetUnit = 'Times',
    this.reminderTime,
    this.difficulty = 'Medium',
    this.motivationNote = '',
  });

  bool isCompletedOn(DateTime date) {
    return completedDates.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
  }

  HabitModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    List<DateTime>? completedDates,
    String? category,
    String? frequency,
    int? targetValue,
    String? targetUnit,
    DateTime? reminderTime,
    String? difficulty,
    String? motivationNote,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      completedDates: completedDates ?? this.completedDates,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      targetValue: targetValue ?? this.targetValue,
      targetUnit: targetUnit ?? this.targetUnit,
      reminderTime: reminderTime ?? this.reminderTime,
      difficulty: difficulty ?? this.difficulty,
      motivationNote: motivationNote ?? this.motivationNote,
    );
  }
}
