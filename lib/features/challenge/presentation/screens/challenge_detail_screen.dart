import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iron_mind/core/utils/colors.dart';
import 'package:iron_mind/features/challenge/data/models/challenge_model.dart';
import 'package:iron_mind/features/challenge/presentation/providers/challenge_provider.dart';

class ChallengeDetailScreen extends HookConsumerWidget {
  final ChallengeModel challenge;

  const ChallengeDetailScreen({super.key, required this.challenge});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allChallenges = ref.watch(challengeProvider);
    final freshChallenge = allChallenges.firstWhere(
      (c) => c.id == challenge.id,
      orElse: () => challenge,
    );
    final colors = Theme.of(context).appColors;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          freshChallenge.name.toUpperCase(),
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildOverviewCard(freshChallenge, colors),
            const SizedBox(height: 20),
            _buildCalendar(context, ref, freshChallenge, colors),
            const SizedBox(height: 20),
            _buildMilestonesList(freshChallenge, colors),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(ChallengeModel challenge, AppColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoColumn('STREAK', '${challenge.currentStreak} Days', colors),
              _infoColumn(
                'REMAINING',
                '${challenge.daysRemaining} Days',
                colors,
              ),
              _infoColumn('THREAT', challenge.threatLevel, colors),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: challenge.progress,
              minHeight: 10,
              backgroundColor: colors.progressBarBg,
              valueColor: AlwaysStoppedAnimation(colors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(challenge.progress * 100).toInt()}% COMPLETED',
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoColumn(String label, String value, AppColorScheme colors) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar(
    BuildContext context,
    WidgetRef ref,
    ChallengeModel challenge,
    AppColorScheme colors,
  ) {
    final startDate = challenge.startDate;
    final duration = challenge.duration;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MISSION LOG',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemCount: duration,
            itemBuilder: (context, index) {
              final date = startDate.add(Duration(days: index));
              final isCompleted = challenge.isCompletedOn(date);
              final isToday = _isSameDay(date, DateTime.now());
              final isPast = date.isBefore(DateTime.now()) && !isToday;
              final isFuture = date.isAfter(DateTime.now()) && !isToday;

              Color bgColor = colors.chipBg;
              Color textColor = colors.textMuted;
              Border? border;

              if (isCompleted) {
                bgColor = colors.primary;
                textColor = Colors.white;
              } else if (isPast && !isCompleted) {
                bgColor = AppColors.highPriorityColor.withOpacity(0.2);
                textColor = AppColors.highPriorityColor;
                border = Border.all(
                  color: AppColors.highPriorityColor.withOpacity(0.5),
                );
              } else if (isToday) {
                border = Border.all(color: colors.primary);
                textColor = colors.textPrimary;
              }

              return InkWell(
                onTap: isFuture
                    ? null
                    : () {
                        ref
                            .read(challengeProvider.notifier)
                            .toggleCompletion(challenge.id, date);
                      },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: border,
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Day',
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 8,
                        ),
                      ),
                      Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonesList(ChallengeModel challenge, AppColorScheme colors) {
    if (challenge.roadmap.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MILESTONES',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          ...challenge.roadmap.map(
            (milestone) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.flag, color: colors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          milestone.title,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (milestone.subtasks.isNotEmpty)
                          Text(
                            '${milestone.subtasks.length} subtasks',
                            style: TextStyle(
                              color: colors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
