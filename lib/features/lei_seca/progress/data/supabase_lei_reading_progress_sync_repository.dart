import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:papirar/features/lei_seca/progress/domain/lei_reading_progress.dart';
import 'package:papirar/features/lei_seca/progress/domain/lei_reading_progress_sync_repository.dart';

class SupabaseLeiReadingProgressSyncRepository
    implements LeiReadingProgressSyncRepository {
  final SupabaseClient _client;

  const SupabaseLeiReadingProgressSyncRepository(this._client);

  static const _table = 'lei_reading_progress';
  static List<LeiReadingProgress>? _cachedProgress;
  static Future<List<LeiReadingProgress>>? _pendingProgress;

  @override
  Future<List<LeiReadingProgress>> getCurrentUserProgress() async {
    final cached = _cachedProgress;
    if (cached != null) return cached;

    final pending = _pendingProgress;
    if (pending != null) return pending;

    _pendingProgress = _loadCurrentUserProgress();
    return _pendingProgress!;
  }

  Future<List<LeiReadingProgress>> _loadCurrentUserProgress() async {
    final user = _requireUser();
    try {
      final rows = await _client
          .from(_table)
          .select()
          .eq('user_id', user.id)
          .order('updated_at', ascending: false);

      final progress = rows.map(_fromMap).toList();
      _cachedProgress = progress;
      return progress;
    } finally {
      _pendingProgress = null;
    }
  }

  @override
  Future<void> saveSession({
    required String leiId,
    required String leiTitle,
    required String leiSigla,
    required double lastOffset,
    required int additionalSeconds,
  }) async {
    final user = _requireUser();
    final existing = await _client
        .from(_table)
        .select('total_seconds')
        .eq('user_id', user.id)
        .eq('lei_id', leiId)
        .maybeSingle();

    final currentSeconds = (existing?['total_seconds'] as num?)?.toInt() ?? 0;
    final nextSeconds = currentSeconds + additionalSeconds.clamp(0, 86400);

    await _client.from(_table).upsert({
      'user_id': user.id,
      'lei_id': leiId,
      'lei_title': leiTitle,
      'lei_sigla': leiSigla,
      'last_offset': lastOffset,
      'total_seconds': nextSeconds,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id,lei_id');

    _updateCachedProgress(
      leiId: leiId,
      leiTitle: leiTitle,
      leiSigla: leiSigla,
      lastOffset: lastOffset,
      totalSeconds: nextSeconds,
    );
  }

  void _updateCachedProgress({
    required String leiId,
    required String leiTitle,
    required String leiSigla,
    required double lastOffset,
    required int totalSeconds,
  }) {
    final cached = _cachedProgress;
    if (cached == null) return;

    final updated = LeiReadingProgress(
      leiId: leiId,
      leiTitle: leiTitle,
      leiSigla: leiSigla,
      lastOffset: lastOffset,
      totalSeconds: totalSeconds,
      updatedAt: DateTime.now().toUtc(),
    );
    final next = [
      updated,
      ...cached.where((item) => item.leiId != leiId),
    ];
    _cachedProgress = next;
  }

  User _requireUser() {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Usuário não autenticado.');
    }
    return user;
  }

  LeiReadingProgress _fromMap(Map<String, dynamic> map) {
    return LeiReadingProgress(
      leiId: map['lei_id']?.toString() ?? '',
      leiTitle: map['lei_title']?.toString() ?? 'Lei Seca',
      leiSigla: map['lei_sigla']?.toString() ?? '',
      lastOffset: (map['last_offset'] as num?)?.toDouble() ?? 0,
      totalSeconds: (map['total_seconds'] as num?)?.toInt() ?? 0,
      updatedAt:
          DateTime.tryParse(map['updated_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
