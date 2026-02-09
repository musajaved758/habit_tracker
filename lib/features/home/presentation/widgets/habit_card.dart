import 'package:flutter/material.dart';
import 'package:operation_brotherhood/core/utils/colors.dart';

import 'package:operation_brotherhood/core/providers/app_providers.dart';

class HabitCard extends StatelessWidget {
  final bool isCompleted;
  final ValueChanged<bool?>? onCompleteTap;
  final String title, subTitle;
  final int categoryIcon;
  final String priority;
  final String motivationNote;
  final DateTime selectedDate;

  const HabitCard({
    super.key,
    required this.isCompleted,
    this.onCompleteTap,
    required this.title,
    required this.subTitle,
    required this.categoryIcon,
    required this.priority,
    required this.motivationNote,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFutureDate = isFuture(selectedDate);

    Color priorityColor;
    switch (priority) {
      case 'HIGH':
        priorityColor = AppColors.highPriorityColor;
        break;
      case 'MEDIUM':
        priorityColor = AppColors.mediumPriorityColor;
        break;
      default:
        priorityColor = AppColors.lowPriorityColor;
    }

    return Opacity(
      opacity: isFutureDate ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          border: Border.all(
            color: isCompleted ? AppColors.habitPrimary : AppColors.border,
            width: isCompleted ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: ListTile(
          onTap: () {
            if (motivationNote.isNotEmpty) {
              _showMotivationDialog(context);
            }
          },
          leading: Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: isCompleted,
              onChanged: isFutureDate ? null : onCompleteTap,
              shape: const CircleBorder(),
              activeColor: AppColors.habitPrimary,
              checkColor: Colors.white,
              side: BorderSide(
                color: isFutureDate
                    ? Colors.grey.withOpacity(0.5)
                    : AppColors.habitPrimary,
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isCompleted ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.bold,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  border: Border.all(color: priorityColor.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  priority,
                  style: TextStyle(
                    color: priorityColor,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Text(
            subTitle,
            style: TextStyle(
              color: isCompleted ? AppColors.habitPrimary : Colors.grey,
              fontSize: 12,
            ),
          ),
          trailing: Icon(
            IconData(categoryIcon, fontFamily: 'MaterialIcons'),
            color: Colors.white70,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _showMotivationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.habitSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.rocket_launch,
                color: AppColors.habitPrimary,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                "My Motivation",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                motivationNote,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.habitPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "CLOSE",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
