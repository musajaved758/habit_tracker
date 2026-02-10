import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iron_mind/core/utils/colors.dart';
import 'package:iron_mind/features/habit/presentation/providers/habit_provider.dart';
import 'package:intl/intl.dart';

class DailySummaryCard extends HookConsumerWidget {
  final DateTime selectedDate;

  const DailySummaryCard({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider);
    final colors = Theme.of(context).appColors;

    final activeHabits = habits.where((habit) {
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

      final isInRange =
          (date.isAtSameMomentAs(startDate) || date.isAfter(startDate)) &&
          (date.isAtSameMomentAs(endDate) || date.isBefore(endDate));

      if (!isInRange) return false;

      if (habit.frequency == 'WEEKLY') {
        return date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday;
      }
      return true;
    }).toList();

    final completedTask = activeHabits
        .where((habit) => habit.isCompletedOn(selectedDate))
        .length;
    final totalTask = activeHabits.length;
    final efficiencyPercentage = totalTask > 0
        ? (completedTask / totalTask) * 100
        : 0.0;
    final formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);

    String status = "PENDING";
    Color statusColor = colors.primary;

    if (totalTask == 0) {
      status = "NO HABITS";
      statusColor = colors.textMuted;
    } else if (completedTask == totalTask) {
      status = "COMPLETED";
      statusColor = colors.primary;
    } else if (completedTask > 0) {
      status = "IN PROGRESS";
      statusColor = colors.accent;
    }

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate.toUpperCase(),
                style: TextStyle(
                  color: colors.textMuted,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Efficiency Percentage
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "${efficiencyPercentage.toStringAsFixed(0)}%",
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Efficiency",
                style: TextStyle(color: colors.textSecondary, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: totalTask > 0 ? completedTask / totalTask : 0,
              minHeight: 12,
              backgroundColor: colors.progressBarBg,
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            ),
          ),
          const SizedBox(height: 30),

          // Footer Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                icon: Icons.check_outlined,
                iconColor: colors.primary,
                value: '$completedTask / $totalTask',
                label: "COMPLETED",
                colors: colors,
              ),
              _buildStatItem(
                icon: Icons.hourglass_empty,
                iconColor: colors.accent,
                value: '${totalTask - completedTask}',
                label: "REMAINING",
                colors: colors,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required AppColorScheme colors,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
