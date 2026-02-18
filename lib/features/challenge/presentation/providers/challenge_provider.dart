import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_mind/features/challenge/data/models/challenge_model.dart';
import 'package:iron_mind/core/services/hive_service.dart';
import 'package:uuid/uuid.dart';

final challengeProvider =
    NotifierProvider<ChallengeNotifier, List<ChallengeModel>>(
      ChallengeNotifier.new,
    );

class ChallengeNotifier extends Notifier<List<ChallengeModel>> {
  @override
  List<ChallengeModel> build() {
    final challenges = HiveService.getChallenges();
    final order = HiveService.getSetting('challenge_order') as List?;

    if (order == null || order.isEmpty) return challenges;

    // Create a map for quick lookup
    final challengeMap = {for (var c in challenges) c.id: c};

    // Build sorted list based on order
    final List<ChallengeModel> sorted = [];
    for (var id in order) {
      if (challengeMap.containsKey(id)) {
        sorted.add(challengeMap[id]!);
        challengeMap.remove(id);
      }
    }

    // Add any challenges not in the order list (new ones)
    sorted.addAll(challengeMap.values);

    return sorted;
  }

  Future<void> reorderChallenges(
    int oldIndex,
    int newIndex,
    List<String> visibleIds,
  ) async {
    if (oldIndex < 0 || oldIndex >= visibleIds.length) return;

    // Normalize newIndex for move
    int normalizedNewIndex = newIndex;
    if (oldIndex < newIndex) {
      normalizedNewIndex -= 1;
    }
    if (normalizedNewIndex < 0) normalizedNewIndex = 0;
    if (normalizedNewIndex >= visibleIds.length)
      normalizedNewIndex = visibleIds.length - 1;

    if (oldIndex == normalizedNewIndex) return;

    final String oldId = visibleIds[oldIndex];
    final String targetId = visibleIds[normalizedNewIndex];

    final List<ChallengeModel> newList = List.from(state);
    final masterOldIndex = newList.indexWhere((c) => c.id == oldId);
    final masterTargetIndex = newList.indexWhere((c) => c.id == targetId);

    if (masterOldIndex == -1 || masterTargetIndex == -1) return;

    final item = newList.removeAt(masterOldIndex);
    newList.insert(masterTargetIndex, item);

    state = newList;

    // Persist order
    final order = newList.map((c) => c.id).toList();
    await HiveService.saveSetting('challenge_order', order);
  }

  Future<void> addChallenge({
    required String name,
    required int duration,
    required String threatLevel,
    required String consequenceType,
    required String specificConsequence,
    required DateTime startDate,
    List<ChallengeMilestone> roadmap = const [],
  }) async {
    final newChallenge = ChallengeModel(
      id: const Uuid().v4(),
      name: name,
      duration: duration,
      threatLevel: threatLevel,
      consequenceType: consequenceType,
      specificConsequence: specificConsequence,
      startDate: DateTime(startDate.year, startDate.month, startDate.day),
      roadmap: roadmap,
    );
    await HiveService.saveChallenge(newChallenge);
    ref.invalidateSelf();
  }

  Future<void> toggleMilestoneCompletion(
    String challengeId,
    String milestoneId,
  ) async {
    final challenge = state.firstWhere((c) => c.id == challengeId);
    final updatedRoadmap = challenge.roadmap.map((m) {
      if (m.id == milestoneId) {
        return m.copyWith(isCompleted: !m.isCompleted);
      }
      return m;
    }).toList();

    final updatedChallenge = challenge.copyWith(roadmap: updatedRoadmap);
    await HiveService.updateChallenge(updatedChallenge);
    ref.invalidateSelf();
  }

  Future<void> toggleSubtaskCompletion(
    String challengeId,
    String milestoneId,
    String subtaskId,
  ) async {
    final challenge = state.firstWhere((c) => c.id == challengeId);
    final updatedRoadmap = challenge.roadmap.map((m) {
      if (m.id == milestoneId) {
        final updatedSubtasks = m.subtasks.map((s) {
          if (s.id == subtaskId) {
            return s.copyWith(isCompleted: !s.isCompleted);
          }
          return s;
        }).toList();
        return m.copyWith(subtasks: updatedSubtasks);
      }
      return m;
    }).toList();

    final updatedChallenge = challenge.copyWith(roadmap: updatedRoadmap);
    await HiveService.updateChallenge(updatedChallenge);
    ref.invalidateSelf();
  }

  Future<void> updateSubtasks(
    String challengeId,
    String milestoneId,
    List<ChallengeSubtask> subtasks,
  ) async {
    final challenge = state.firstWhere((c) => c.id == challengeId);
    final updatedRoadmap = challenge.roadmap.map((m) {
      if (m.id == milestoneId) {
        return m.copyWith(subtasks: subtasks);
      }
      return m;
    }).toList();

    final updatedChallenge = challenge.copyWith(roadmap: updatedRoadmap);
    await HiveService.updateChallenge(updatedChallenge);
    ref.invalidateSelf();
  }

  Future<void> toggleCompletion(String challengeId, DateTime date) async {
    await HiveService.toggleChallengeCompletion(challengeId, date);
    ref.invalidateSelf();
  }

  Future<void> deleteChallenge(String id) async {
    await HiveService.deleteChallenge(id);
    ref.invalidateSelf();
  }

  Future<void> updateChallenge(ChallengeModel challenge) async {
    await HiveService.updateChallenge(challenge);
    ref.invalidateSelf();
  }

  Future<void> extendChallenge(String id, int extraDays) async {
    final challenge = state.firstWhere((c) => c.id == id);
    final updatedChallenge = challenge.copyWith(
      duration: challenge.duration + extraDays,
    );
    await HiveService.updateChallenge(updatedChallenge);
    ref.invalidateSelf();
  }

  ChallengeModel? get activeChallenge {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    try {
      return state.firstWhere((challenge) {
        final endDate = challenge.startDate.add(
          Duration(days: challenge.duration),
        );
        return (challenge.startDate.isBefore(today) ||
                challenge.startDate.isAtSameMomentAs(today)) &&
            endDate.isAfter(today);
      });
    } catch (_) {
      return null;
    }
  }
}
