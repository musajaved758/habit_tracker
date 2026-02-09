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

  @HiveField(5, defaultValue: 'DAILY')
  final String frequency;

  @HiveField(6, defaultValue: 1)
  final int targetValue;

  @HiveField(7, defaultValue: 'TIMES')
  final String targetUnit;

  @HiveField(8)
  final DateTime? reminderTime;

  @HiveField(9, defaultValue: 'MEDIUM')
  final String priority;

  @HiveField(10, defaultValue: '')
  final String motivationNote;

  @HiveField(11)
  final DateTime endDate;

  @HiveField(12)
  final int categoryIcon;

  HabitModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.endDate,
    this.completedDates = const [],
    this.category = 'Other',
    this.categoryIcon = 0xe24a, // Default icon (Icons.fitness_center)
    this.frequency = 'DAILY',
    this.targetValue = 1,
    this.targetUnit = 'TIMES',
    this.reminderTime,
    this.priority = 'MEDIUM',
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
    DateTime? endDate,
    List<DateTime>? completedDates,
    String? category,
    int? categoryIcon,
    String? frequency,
    int? targetValue,
    String? targetUnit,
    DateTime? reminderTime,
    String? priority,
    String? motivationNote,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      endDate: endDate ?? this.endDate,
      completedDates: completedDates ?? this.completedDates,
      category: category ?? this.category,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      frequency: frequency ?? this.frequency,
      targetValue: targetValue ?? this.targetValue,
      targetUnit: targetUnit ?? this.targetUnit,
      reminderTime: reminderTime ?? this.reminderTime,
      priority: priority ?? this.priority,
      motivationNote: motivationNote ?? this.motivationNote,
    );
  }
}
