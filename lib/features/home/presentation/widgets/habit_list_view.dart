import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:operation_brotherhood/features/habit/presentation/providers/habit_provider.dart';
import 'package:operation_brotherhood/features/home/presentation/widgets/habit_card.dart';

class HabitListView extends HookConsumerWidget {
  final DateTime selectedDate;

  const HabitListView({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider);
    final filteredHabits = habits.where((habit) {
      final date = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );
      final startDate = DateTime(
        habit.createdAt.year,
        habit.createdAt.month,
        habit.createdAt.day,
      );
      final endDate = DateTime(
        habit.endDate.year,
        habit.endDate.month,
        habit.endDate.day,
      );

      // 1. Range Check (Habit must be active on the selected date)
      final isInRange =
          (date.isAtSameMomentAs(startDate) || date.isAfter(startDate)) &&
          (date.isAtSameMomentAs(endDate) || date.isBefore(endDate));

      if (!isInRange) return false;

      // 2. Frequency Check (Weekly habits only on weekends)
      if (habit.frequency == 'WEEKLY') {
        final isWeekend =
            date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday;
        if (!isWeekend) return false;
      }

      return true;
    }).toList();

    if (filteredHabits.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "No habits for this day.\nStay focused!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: filteredHabits.length,
      itemBuilder: (context, index) {
        final habit = filteredHabits[index];
        final isCompleted = habit.isCompletedOn(selectedDate);

        // "Missed" logic: If date is in the past (before today) and not completed.
        final now = DateTime.now();
        final selectedDateOnly = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
        );
        final todayOnly = DateTime(now.year, now.month, now.day);

        final isPast = selectedDateOnly.isBefore(todayOnly);
        final isMissed = isPast && !isCompleted;

        return HabitCard(
          isCompleted: isCompleted,
          onCompleteTap: (val) {
            ref
                .read(habitProvider.notifier)
                .toggleCompletion(habit.id, selectedDate);
          },
          title: habit.name,
          subTitle: isCompleted
              ? "Completed ✓"
              : (isMissed ? "Missed!" : "Pending"),
          categoryIcon: habit.categoryIcon,
          priority: habit.priority,
          motivationNote: habit.motivationNote,
          selectedDate: selectedDate,
        );
      },
    );
  }
}
