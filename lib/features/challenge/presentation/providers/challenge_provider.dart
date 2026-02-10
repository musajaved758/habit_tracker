import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:operation_brotherhood/features/challenge/data/models/challenge_model.dart';
import 'package:operation_brotherhood/core/services/hive_service.dart';
import 'package:uuid/uuid.dart';

final challengeProvider =
    NotifierProvider<ChallengeNotifier, List<ChallengeModel>>(
      ChallengeNotifier.new,
    );

class ChallengeNotifier extends Notifier<List<ChallengeModel>> {
  @override
  List<ChallengeModel> build() {
    return HiveService.getChallenges();
  }

  Future<void> addChallenge({
    required String name,
    required int duration,
    required String threatLevel,
    required String consequenceType,
    required String specificConsequence,
    required DateTime startDate,
  }) async {
    final newChallenge = ChallengeModel(
      id: const Uuid().v4(),
      name: name,
      duration: duration,
      threatLevel: threatLevel,
      consequenceType: consequenceType,
      specificConsequence: specificConsequence,
      startDate: DateTime(startDate.year, startDate.month, startDate.day),
    );
    await HiveService.saveChallenge(newChallenge);
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
