import 'package:flutter/foundation.dart';
import 'package:papirar/core/sync/app_sync_events.dart';
import 'package:papirar/features/lei_seca/highlights/di/lei_highlight_module.dart';
import 'package:papirar/features/lei_seca/highlights/domain/lei_highlight.dart';
import 'package:papirar/features/lei_seca/highlights/domain/lei_highlight_repository.dart';
import 'package:papirar/features/lei_seca/progress/di/lei_reading_progress_sync_module.dart';
import 'package:papirar/features/lei_seca/progress/domain/lei_reading_progress.dart';
import 'package:papirar/features/lei_seca/progress/domain/lei_reading_progress_sync_repository.dart';
import 'package:papirar/features/perfil/di/profile_module.dart';
import 'package:papirar/features/perfil/domain/entities/user_profile.dart';
import 'package:papirar/features/perfil/domain/usecases/get_current_profile.dart';

class HomeController extends ChangeNotifier {
  final LeiReadingProgressSyncRepository _progressRepository;
  final LeiHighlightRepository _highlightRepository;
  final GetCurrentProfile _getCurrentProfile;

  static UserProfile? _lastKnownProfile;
  static List<LeiReadingProgress> _lastKnownReadings = const [];
  static List<LeiHighlight> _lastKnownHighlights = const [];

  HomeController({
    LeiReadingProgressSyncRepository? progressRepository,
    LeiHighlightRepository? highlightRepository,
    GetCurrentProfile? getCurrentProfile,
  }) : _progressRepository =
           progressRepository ?? LeiReadingProgressSyncModule.repository(),
       _highlightRepository =
           highlightRepository ?? LeiHighlightModule.repository(),
       _getCurrentProfile =
           getCurrentProfile ?? ProfileModule.getCurrentProfile();

  int _lastProfileVersion = AppSyncEvents.instance.profileVersion;
  int _lastStudyActivityVersion = AppSyncEvents.instance.studyActivityVersion;
  bool _isReloading = false;
  bool isLoading = false;
  String? errorMessage;
  UserProfile? profile = _lastKnownProfile;
  List<LeiReadingProgress> readings = _lastKnownReadings;
  List<LeiHighlight> highlights = _lastKnownHighlights;

  LeiReadingProgress? get currentReading {
    return readings.isEmpty ? null : readings.first;
  }

  void startSyncListener() {
    AppSyncEvents.instance.addListener(_onAppSyncEvent);
  }

  @override
  void dispose() {
    AppSyncEvents.instance.removeListener(_onAppSyncEvent);
    super.dispose();
  }

  void _onAppSyncEvent() {
    final events = AppSyncEvents.instance;
    final profileChanged = events.profileVersion != _lastProfileVersion;
    final studyChanged =
        events.studyActivityVersion != _lastStudyActivityVersion;
    if (!profileChanged && !studyChanged) return;

    _lastProfileVersion = events.profileVersion;
    _lastStudyActivityVersion = events.studyActivityVersion;
    load(silent: true);
  }

  Future<void> load({bool silent = false}) async {
    if (_isReloading) return;
    _isReloading = true;
    final hasCurrentData = profile != null || readings.isNotEmpty;
    if (!silent) isLoading = !hasCurrentData;
    errorMessage = null;
    if (!silent && !hasCurrentData) notifyListeners();

    try {
      final profileFuture = _getCurrentProfile();
      final progressFuture = _progressRepository.getCurrentUserProgress();
      final highlightsFuture = _highlightRepository.getAll();
      profile = await profileFuture;
      readings = await progressFuture;
      highlights = await highlightsFuture;
      _lastKnownProfile = profile;
      _lastKnownReadings = readings;
      _lastKnownHighlights = highlights;
    } catch (_) {
      errorMessage = 'Não foi possível carregar seu resumo.';
    } finally {
      _isReloading = false;
      isLoading = false;
      notifyListeners();
    }
  }
}
