import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:operation_brotherhood/core/utils/colors.dart';
import 'package:operation_brotherhood/features/challenge/presentation/providers/challenge_provider.dart';
import 'package:operation_brotherhood/features/challenge/data/models/challenge_model.dart';

class ChallengeScreen extends HookConsumerWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenges = ref.watch(challengeProvider);

    // Find active challenge from the watched state
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    ChallengeModel? activeChallenge;
    try {
      activeChallenge = challenges.firstWhere((challenge) {
        final endDate = challenge.startDate.add(
          Duration(days: challenge.duration),
        );
        return (challenge.startDate.isBefore(today) ||
                challenge.startDate.isAtSameMomentAs(today)) &&
            endDate.isAfter(today);
      });
    } catch (_) {
      activeChallenge = null;
    }

    final isTodayCompleted =
        activeChallenge?.isCompletedOn(DateTime.now()) ?? false;

    if (activeChallenge == null) {
      return Scaffold(
        backgroundColor: AppColors.habitBg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.military_tech_rounded,
                color: Colors.grey,
                size: 64,
              ),
              const SizedBox(height: 20),
              const Text(
                'NO ACTIVE CHALLENGES',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Accept a new mission to begin.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.habitBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'ACTIVE CHALLENGE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        leading: const Icon(Icons.menu, color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: AppColors.habitSurface,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildChallengeCard(activeChallenge),
            const SizedBox(height: 20),
            _buildActionButtons(
              context,
              ref,
              activeChallenge,
              isTodayCompleted,
            ),
            const SizedBox(height: 20),
            _buildPunishmentCard(activeChallenge),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(ChallengeModel activeChallenge) {
    Color threatColor = activeChallenge.threatLevel == 'HARD'
        ? AppColors.highPriorityColor
        : (activeChallenge.threatLevel == 'MEDIUM'
              ? AppColors.mediumPriorityColor
              : AppColors.lowPriorityColor);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.habitSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.habitBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _statusBadge(activeChallenge.threatLevel, threatColor),
              const SizedBox(width: 10),
              _statusBadge('ACTIVE', AppColors.habitPrimary),
              const Spacer(),
              if (activeChallenge.isCompletedOn(DateTime.now()))
                const Icon(Icons.check_circle, color: AppColors.habitPrimary),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            activeChallenge.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'OPERATION: ${activeChallenge.name.split("-").first}',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            '${activeChallenge.daysRemaining}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text(
            'DAYS REMAINING',
            style: TextStyle(
              color: AppColors.habitPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: activeChallenge.progress,
              minHeight: 10,
              backgroundColor: AppColors.habitBg,
              valueColor: const AlwaysStoppedAnimation(AppColors.habitPrimary),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(activeChallenge.progress * 100).toInt()}% COMPLETED',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    ChallengeModel activeChallenge,
    bool isTodayCompleted,
  ) {
    return Column(
      children: [
        _actionButton(
          label: isTodayCompleted ? 'TODAY COMPLETED' : 'MARK TODAY COMPLETED',
          icon: isTodayCompleted
              ? Icons.check_circle
              : Icons.check_circle_outline,
          color: isTodayCompleted
              ? AppColors.habitPrimary.withOpacity(0.2)
              : Colors.white,
          textColor: isTodayCompleted
              ? AppColors.habitPrimary
              : AppColors.habitBg,
          borderColor: isTodayCompleted ? AppColors.habitPrimary : null,
          onTap: () {
            ref
                .read(challengeProvider.notifier)
                .toggleCompletion(activeChallenge.id, DateTime.now());
          },
        ),
        const SizedBox(height: 12),
        _actionButton(
          label: 'ABANDON MISSION',
          icon: Icons.dangerous_outlined,
          color: Colors.transparent,
          textColor: AppColors.highPriorityColor,
          borderColor: AppColors.highPriorityColor.withOpacity(0.3),
          onTap: () {
            _showAbandonDialog(context, ref, activeChallenge);
          },
        ),
      ],
    );
  }

  void _showAbandonDialog(
    BuildContext context,
    WidgetRef ref,
    ChallengeModel challenge,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.habitSurface,
        title: const Text(
          'ABANDON MISSION?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'A True Brother never retreats. Are you sure you want to surrender?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'STAY STRONG',
              style: TextStyle(color: AppColors.habitPrimary),
            ),
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

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: borderColor != null ? Border.all(color: borderColor) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPunishmentCard(ChallengeModel activeChallenge) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.habitSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.highPriorityColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.highPriorityColor,
              ),
              const SizedBox(width: 10),
              Text(
                'FAILURE CONSEQUENCE',
                style: TextStyle(
                  color: AppColors.highPriorityColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activeChallenge.specificConsequence,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'DUE IMMEDIATELY UPON FAILURE',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.highPriorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  activeChallenge.consequenceType == 'PHYSICAL'
                      ? Icons.fitness_center
                      : Icons.monetization_on,
                  color: AppColors.highPriorityColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
