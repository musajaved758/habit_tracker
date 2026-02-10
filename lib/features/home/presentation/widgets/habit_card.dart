import 'package:flutter/material.dart';
import 'package:iron_mind/core/utils/colors.dart';

import 'package:iron_mind/core/providers/app_providers.dart';

class HabitCard extends StatelessWidget {
  final bool isCompleted;
  final ValueChanged<bool?>? onCompleteTap;
  final String title, subTitle;
  final int categoryIcon;
  final String priority;
  final String motivationNote;
  final DateTime selectedDate;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

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
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;
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
          color: colors.cardBg,
          border: Border.all(
            color: isCompleted ? colors.primary : colors.border,
            width: isCompleted ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: ListTile(
          onTap: () {
            if (motivationNote.isNotEmpty) {
              _showMotivationDialog(context, colors);
            }
          },
          leading: Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: isCompleted,
              onChanged: isFutureDate ? null : onCompleteTap,
              shape: const CircleBorder(),
              activeColor: colors.primary,
              checkColor: Colors.white,
              side: BorderSide(
                color: isFutureDate
                    ? colors.textMuted.withOpacity(0.5)
                    : colors.primary,
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isCompleted
                        ? colors.textPrimary
                        : colors.textPrimary.withOpacity(0.8),
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
              color: isCompleted ? colors.primary : colors.textMuted,
              fontSize: 12,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                IconData(categoryIcon, fontFamily: 'MaterialIcons'),
                color: colors.textSecondary,
                size: 20,
              ),
              if (onEdit != null || onDelete != null) ...[
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: colors.textSecondary),
                  color: colors.surface,
                  onSelected: (value) {
                    if (value == 'edit' && onEdit != null) {
                      onEdit!();
                    } else if (value == 'delete' && onDelete != null) {
                      onDelete!();
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    if (onEdit != null)
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: colors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Edit',
                              style: TextStyle(color: colors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete,
                              color: AppColors.highPriorityColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: TextStyle(color: colors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showMotivationDialog(BuildContext context, AppColorScheme colors) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: colors.dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.rocket_launch, color: colors.primary, size: 48),
              const SizedBox(height: 16),
              Text(
                "My Motivation",
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                motivationNote,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
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
