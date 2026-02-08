import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:operation_brotherhood/features/habit/data/models/habit_model.dart';
import 'package:operation_brotherhood/core/services/hive_service.dart';
import 'package:uuid/uuid.dart';

final habitProvider = NotifierProvider<HabitNotifier, List<HabitModel>>(
  HabitNotifier.new,
);

class HabitNotifier extends Notifier<List<HabitModel>> {
  @override
  List<HabitModel> build() {
    return HiveService.getHabits();
  }

  Future<void> addHabit({
    required String name,
    required String category,
    required String frequency,
    required int targetValue,
    required String targetUnit,
    required DateTime? reminderTime,
    required String difficulty,
    required String motivationNote,
  }) async {
    final newHabit = HabitModel(
      id: const Uuid().v4(),
      name: name,
      category: category,
      frequency: frequency,
      targetValue: targetValue,
      targetUnit: targetUnit,
      reminderTime: reminderTime,
      difficulty: difficulty,
      motivationNote: motivationNote,
      createdAt: DateTime.now(),
    );
    await HiveService.saveHabit(newHabit);
    ref.invalidateSelf();
  }

  Future<void> toggleCompletion(String habitId, DateTime date) async {
    await HiveService.toggleHabitCompletion(habitId, date);
    ref.invalidateSelf();
  }
}
