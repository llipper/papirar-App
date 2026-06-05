import 'package:papirar/features/lei_seca/progress/domain/lei_reading_progress.dart';

abstract interface class LeiReadingProgressSyncRepository {
  Future<List<LeiReadingProgress>> getCurrentUserProgress();

  Future<void> saveSession({
    required String leiId,
    required String leiTitle,
    required String leiSigla,
    required double lastOffset,
    required int additionalSeconds,
  });
}
