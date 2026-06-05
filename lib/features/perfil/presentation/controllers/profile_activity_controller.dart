import 'package:flutter/foundation.dart';
import 'package:papirar/core/sync/app_sync_events.dart';
import 'package:papirar/features/lei_seca/highlights/di/lei_highlight_module.dart';
import 'package:papirar/features/lei_seca/highlights/domain/lei_highlight.dart';
import 'package:papirar/features/lei_seca/highlights/domain/lei_highlight_repository.dart';
import 'package:papirar/features/lei_seca/progress/di/lei_reading_progress_sync_module.dart';
import 'package:papirar/features/lei_seca/progress/domain/lei_reading_progress.dart';
import 'package:papirar/features/lei_seca/progress/domain/lei_reading_progress_sync_repository.dart';

class ProfileActivityController extends ChangeNotifier {
  final LeiReadingProgressSyncRepository _progressRepository;
  final LeiHighlightRepository _highlightRepository;

  static List<LeiReadingProgress> _lastKnownReadings = const [];
  static List<LeiHighlight> _lastKnownHighlights = const [];

  ProfileActivityController({
    LeiReadingProgressSyncRepository? progressRepository,
    LeiHighlightRepository? highlightRepository,
  }) : _progressRepository =
           progressRepository ?? LeiReadingProgressSyncModule.repository(),
       _highlightRepository =
           highlightRepository ?? LeiHighlightModule.repository();

  int _lastStudyActivityVersion = AppSyncEvents.instance.studyActivityVersion;
  bool _isReloading = false;
  bool isLoading = false;
  String? errorMessage;
  List<LeiReadingProgress> readings = _lastKnownReadings;
  List<LeiHighlight> highlights = _lastKnownHighlights;

  void startSyncListener() {
    AppSyncEvents.instance.addListener(_onAppSyncEvent);
  }

  @override
  void dispose() {
    AppSyncEvents.instance.removeListener(_onAppSyncEvent);
    super.dispose();
  }

  void _onAppSyncEvent() {
    final version = AppSyncEvents.instance.studyActivityVersion;
    if (version == _lastStudyActivityVersion) return;
    _lastStudyActivityVersion = version;
    load(silent: true);
  }

  Future<void> load({bool silent = false}) async {
    if (_isReloading) return;
    _isReloading = true;
    final hasCurrentData = readings.isNotEmpty || highlights.isNotEmpty;
    if (!silent) isLoading = !hasCurrentData;
    errorMessage = null;
    if (!silent && !hasCurrentData) notifyListeners();

    try {
      final progressFuture = _progressRepository.getCurrentUserProgress();
      final highlightsFuture = _highlightRepository.getAll();
      readings = await progressFuture;
      highlights = await highlightsFuture;
      _lastKnownReadings = readings;
      _lastKnownHighlights = highlights;
    } catch (_) {
      errorMessage = 'Não foi possível carregar suas atividades.';
    } finally {
      _isReloading = false;
      isLoading = false;
      notifyListeners();
    }
  }
}
