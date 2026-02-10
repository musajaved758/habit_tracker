import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:operation_brotherhood/core/utils/colors.dart';
import 'package:operation_brotherhood/features/challenge/presentation/providers/challenge_provider.dart';
import 'package:operation_brotherhood/features/challenge/data/models/challenge_model.dart';

class ChallengeScreen extends HookConsumerWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenges = ref.watch(challengeProvider);

    // Find active challenges from the watched state (up to 5)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final List<ChallengeModel> activeChallenges = challenges
        .where((challenge) {
          final endDate = challenge.startDate.add(
            Duration(days: challenge.duration),
          );
          return (challenge.startDate.isBefore(today) ||
                  challenge.startDate.isAtSameMomentAs(today)) &&
              endDate.isAfter(today);
        })
        .take(5)
        .toList();

    bool hasMissedDay = activeChallenges.any((challenge) {
      if (challenge.startDate.isAtSameMomentAs(today) ||
          challenge.startDate.isAfter(today))
        return false;
      return !challenge.isCompletedOn(yesterday);
    });

    if (activeChallenges.isEmpty) {
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
                'NO ACTIVE MISSIONS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Awaiting orders, Commander.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
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
          'MISSIONS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: null,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          children: [
            ...activeChallenges.map((challenge) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildModernChallengeCard(context, ref, challenge),
              );
            }).toList(),
            if (hasMissedDay) ...[
              const SizedBox(height: 24),
              _buildPunishmentCard(activeChallenges.first),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModernChallengeCard(
    BuildContext context,
    WidgetRef ref,
    ChallengeModel challenge,
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
        color: AppColors.habitSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.habitBorder.withOpacity(0.5)),
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
                          _statusBadge(challenge.threatLevel, threatColor),
                          const SizedBox(width: 8),
                          _statusBadge(
                            'DAY ${challenge.daysElapsed + 1}',
                            Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        challenge.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white54),
                  color: AppColors.habitSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditDialog(context, ref, challenge);
                    } else if (value == 'delete') {
                      _showAbandonDialog(context, ref, challenge);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text(
                        'Edit Mission',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Abandon Mission',
                        style: TextStyle(color: AppColors.highPriorityColor),
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
                        color: AppColors.habitPrimary.withOpacity(0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      '${(challenge.progress * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white38,
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
                    backgroundColor: AppColors.habitBg,
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.habitPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: isTodayCompleted
                ? null // LOCK BUTTON once completed
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
                    ? AppColors.habitPrimary.withOpacity(0.1)
                    : AppColors.habitPrimary,
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
                    color: isTodayCompleted
                        ? AppColors.habitPrimary
                        : Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isTodayCompleted ? 'MISSION COMPLETED' : 'MARK COMPLETED',
                    style: TextStyle(
                      color: isTodayCompleted
                          ? AppColors.habitPrimary
                          : Colors.white,
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

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    ChallengeModel challenge,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.habitBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => _EditChallengeForm(challenge: challenge),
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

  Widget _buildPunishmentCard(ChallengeModel challenge) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.habitSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.highPriorityColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.highPriorityColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'FAILURE CONSEQUENCE',
                style: TextStyle(
                  color: AppColors.highPriorityColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.specificConsequence,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'DUE IMMEDIATELY UPON FAILURE',
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.highPriorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  challenge.consequenceType == 'PHYSICAL'
                      ? Icons.fitness_center
                      : Icons.monetization_on,
                  color: AppColors.highPriorityColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditChallengeForm extends HookConsumerWidget {
  final ChallengeModel challenge;
  const _EditChallengeForm({required this.challenge});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController(text: challenge.name);
    final durationController = useTextEditingController(
      text: challenge.duration.toString(),
    );
    final threatLevel = useState(challenge.threatLevel);
    final consequenceType = useState(challenge.consequenceType);
    final specificConsequence = useState(challenge.specificConsequence);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Center(
              child: Text(
                'EDIT MISSION',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildChSectionHeader('MISSION IDENTIFICATION'),
            _buildChLabel('CHALLENGE NAME'),
            _buildChTextField(nameController, 'E.G. NO-SURRENDER-MARCH'),
            const SizedBox(height: 20),
            _buildChLabel('DURATION (DAYS)'),
            _buildChTextField(
              durationController,
              '30',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 30),
            _buildChSectionHeader('THREAT LEVEL'),
            Row(
              children: [
                Expanded(
                  child: _buildChToggleItem(
                    'EASY',
                    threatLevel.value == 'EASY',
                    () => threatLevel.value = 'EASY',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildChToggleItem(
                    'MEDIUM',
                    threatLevel.value == 'MEDIUM',
                    () => threatLevel.value = 'MEDIUM',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildChToggleItem(
                    'HARD',
                    threatLevel.value == 'HARD',
                    () => threatLevel.value = 'HARD',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildChSectionHeader('FAILURE CONSEQUENCE'),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.habitSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildChConsequenceTypeItem(
                      'DONATE',
                      consequenceType.value == 'DONATE',
                      () => consequenceType.value = 'DONATE',
                    ),
                  ),
                  Expanded(
                    child: _buildChConsequenceTypeItem(
                      'PHYSICAL',
                      consequenceType.value == 'PHYSICAL',
                      () => consequenceType.value = 'PHYSICAL',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildChSpecificConsequenceCard(
                    'COLD SHOWER',
                    Icons.ac_unit,
                    specificConsequence.value == 'COLD SHOWER',
                    () => specificConsequence.value = 'COLD SHOWER',
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildChSpecificConsequenceCard(
                    'PUSHUPS (50)',
                    Icons.fitness_center,
                    specificConsequence.value == 'PUSHUPS (50)',
                    () => specificConsequence.value = 'PUSHUPS (50)',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final updated = challenge.copyWith(
                    name: nameController.text.toUpperCase(),
                    duration:
                        int.tryParse(durationController.text) ??
                        challenge.duration,
                    threatLevel: threatLevel.value,
                    consequenceType: consequenceType.value,
                    specificConsequence: specificConsequence.value,
                  );
                  ref.read(challengeProvider.notifier).updateChallenge(updated);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.habitPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'UPDATE MISSION',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildChSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.habitPrimary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.habitPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildChTextField(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.habitSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.habitBorder),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildChToggleItem(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.habitPrimary.withOpacity(0.1)
              : AppColors.habitSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.habitPrimary : AppColors.habitBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.habitPrimary : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildChConsequenceTypeItem(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.habitPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildChSpecificConsequenceCard(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: AppColors.habitSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.habitPrimary : AppColors.habitBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.habitPrimary : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 15),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
