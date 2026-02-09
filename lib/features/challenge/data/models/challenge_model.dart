import 'package:hive/hive.dart';

part 'challenge_model.g.dart';

@HiveType(typeId: 1)
class ChallengeModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int duration; // in days

  @HiveField(3)
  final String threatLevel; // EASY, MEDIUM, HARD

  @HiveField(4)
  final String consequenceType; // DONATE, PHYSICAL

  @HiveField(5)
  final String specificConsequence; // COLD SHOWER, PUSHUPS (50), etc.

  @HiveField(6)
  final DateTime startDate;

  @HiveField(7)
  final List<DateTime> completedDates;

  ChallengeModel({
    required this.id,
    required this.name,
    required this.duration,
    required this.threatLevel,
    required this.consequenceType,
    required this.specificConsequence,
    required this.startDate,
    this.completedDates = const [],
  });

  bool isCompletedOn(DateTime date) {
    return completedDates.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
  }

  int get daysElapsed {
    final now = DateTime.now();
    final difference = now.difference(startDate).inDays;
    return difference >= 0 ? difference : 0;
  }

  int get daysRemaining {
    final remaining = duration - daysElapsed;
    return remaining >= 0 ? remaining : 0;
  }

  double get progress {
    if (duration == 0) return 0.0;
    return completedDates.length / duration;
  }

  ChallengeModel copyWith({
    String? id,
    String? name,
    int? duration,
    String? threatLevel,
    String? consequenceType,
    String? specificConsequence,
    DateTime? startDate,
    List<DateTime>? completedDates,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      threatLevel: threatLevel ?? this.threatLevel,
      consequenceType: consequenceType ?? this.consequenceType,
      specificConsequence: specificConsequence ?? this.specificConsequence,
      startDate: startDate ?? this.startDate,
      completedDates: completedDates ?? this.completedDates,
    );
  }
}
