import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:papirar/features/lei_seca/highlights/data/lei_highlight_dto.dart';
import 'package:papirar/features/lei_seca/highlights/domain/lei_highlight.dart';
import 'package:papirar/features/lei_seca/highlights/domain/lei_highlight_repository.dart';

class SupabaseLeiHighlightRepository implements LeiHighlightRepository {
  final SupabaseClient _client;

  const SupabaseLeiHighlightRepository(this._client);

  static const _table = 'lei_highlights';
  static List<LeiHighlight>? _cachedAll;
  static final Map<String, List<LeiHighlight>> _cachedByLei = {};
  static Future<List<LeiHighlight>>? _pendingAll;

  @override
  Future<List<LeiHighlight>> getAll() async {
    final cached = _cachedAll;
    if (cached != null) return cached;

    final pending = _pendingAll;
    if (pending != null) return pending;

    _pendingAll = _loadAll();
    return _pendingAll!;
  }

  Future<List<LeiHighlight>> _loadAll() async {
    final user = _requireUser();
    try {
      final rows = await _client
          .from(_table)
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final highlights = rows.map(LeiHighlightDto.fromMap).toList();
      _cachedAll = highlights;
      return highlights;
    } finally {
      _pendingAll = null;
    }
  }

  @override
  Future<List<LeiHighlight>> getByLei(String leiId) async {
    final cached = _cachedByLei[leiId];
    if (cached != null) return cached;

    final user = _requireUser();
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', user.id)
        .eq('lei_id', leiId)
        .order('bloco_index')
        .order('part_index')
        .order('start_offset');

    final highlights = rows.map(LeiHighlightDto.fromMap).toList();
    _cachedByLei[leiId] = highlights;
    return highlights;
  }

  @override
  Future<LeiHighlight> create(CreateLeiHighlightInput input) async {
    final user = _requireUser();
    await deleteOverlapping(
      LeiHighlightRangeInput(
        leiId: input.leiId,
        blocoIndex: input.blocoIndex,
        partIndex: input.partIndex,
        startOffset: input.startOffset,
        endOffset: input.endOffset,
      ),
    );

    final row = await _client
        .from(_table)
        .insert({
          'user_id': user.id,
          'lei_id': input.leiId,
          'bloco_index': input.blocoIndex,
          'part_index': input.partIndex,
          'start_offset': input.startOffset,
          'end_offset': input.endOffset,
          'color': input.color.name,
          'selected_text': input.selectedText,
        })
        .select()
        .single();

    _clearCache(input.leiId);
    return LeiHighlightDto.fromMap(row);
  }

  @override
  Future<void> deleteOverlapping(LeiHighlightRangeInput input) async {
    final user = _requireUser();
    await _client
        .from(_table)
        .delete()
        .eq('user_id', user.id)
        .eq('lei_id', input.leiId)
        .eq('bloco_index', input.blocoIndex)
        .eq('part_index', input.partIndex)
        .lt('start_offset', input.endOffset)
        .gt('end_offset', input.startOffset);
    _clearCache(input.leiId);
  }

  void _clearCache(String leiId) {
    _cachedAll = null;
    _cachedByLei.remove(leiId);
  }

  User _requireUser() {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Usuário não autenticado.');
    }
    return user;
  }
}
