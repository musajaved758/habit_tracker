import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iron_mind/core/utils/colors.dart';
import 'package:iron_mind/features/challenge/presentation/providers/challenge_provider.dart';
import 'package:iron_mind/features/challenge/data/models/challenge_model.dart';
import 'package:iron_mind/features/habit/habit_screen.dart';
import 'package:iron_mind/features/challenge/presentation/screens/challenge_detail_screen.dart';

class ChallengeScreen extends HookConsumerWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allChallenges = ref.watch(challengeProvider);
    final challenges = allChallenges.take(5).toList();
    final colors = Theme.of(context).appColors;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'MISSIONS',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: challenges.isEmpty
          ? _buildEmptyState(colors)
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: challenges.length,
              itemBuilder: (context, index) {
                final challenge = challenges[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: _buildChallengeCard(context, ref, challenge, colors),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(AppColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.military_tech,
            size: 64,
            color: colors.textMuted.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'NO ACTIVE MISSIONS',
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(
    BuildContext context,
    WidgetRef ref,
    ChallengeModel challenge,
    AppColorScheme colors,
  ) {
    final today = DateTime.now();
    final isTodayCompleted = challenge.isCompletedOn(today);

    Color threatColor = challenge.threatLevel == 'HARD'
        ? AppColors.highPriorityColor
        : (challenge.threatLevel == 'MEDIUM'
              ? AppColors.mediumPriorityColor
              : AppColors.lowPriorityColor);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChallengeDetailScreen(challenge: challenge),
                ),
              );
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 10, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _statusBadge(
                                  challenge.threatLevel,
                                  threatColor,
                                ),
                                const SizedBox(width: 8),
                                _statusBadge(
                                  'DAY ${challenge.daysElapsed + 1}',
                                  colors.textMuted,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              challenge.name,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: colors.textMuted),
                        color: colors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (value) {
                          if (value == 'delete') {
                            _showAbandonDialog(context, ref, challenge, colors);
                          } else if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    HabitScreen(challengeToEdit: challenge),
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(
                              'Edit Mission',
                              style: TextStyle(color: colors.textPrimary),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Abandon Mission',
                              style: TextStyle(
                                color: AppColors.highPriorityColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${challenge.daysRemaining} DAYS REMAINING',
                            style: TextStyle(
                              color: colors.primary.withOpacity(0.8),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            '${(challenge.progress * 100).toInt()}%',
                            style: TextStyle(
                              color: colors.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: challenge.progress,
                          minHeight: 6,
                          backgroundColor: colors.progressBarBg,
                          valueColor: AlwaysStoppedAnimation(colors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          InkWell(
            onTap: isTodayCompleted
                ? null
                : () {
                    ref
                        .read(challengeProvider.notifier)
                        .toggleCompletion(challenge.id, DateTime.now());
                  },
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isTodayCompleted
                    ? colors.primary.withOpacity(0.1)
                    : colors.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isTodayCompleted
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    color: isTodayCompleted ? colors.primary : Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isTodayCompleted ? 'MISSION COMPLETED' : 'MARK COMPLETED',
                    style: TextStyle(
                      color: isTodayCompleted ? colors.primary : Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 1.2,
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

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showAbandonDialog(
    BuildContext context,
    WidgetRef ref,
    ChallengeModel challenge,
    AppColorScheme colors,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.dialogBg,
        title: Text(
          'ABANDON MISSION?',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'A True Brother never retreats. Are you sure you want to surrender?',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('STAY STRONG', style: TextStyle(color: colors.primary)),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(challengeProvider.notifier)
                  .deleteChallenge(challenge.id);
              Navigator.pop(context);
            },
            child: const Text(
              'SURRENDER',
              style: TextStyle(color: AppColors.highPriorityColor),
            ),
          ),
        ],
      ),
    );
  }
}
