import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:papirar/core/sync/app_sync_events.dart';
import 'package:papirar/domain/entities/lei_texto.dart';
import 'package:papirar/domain/repositories/lei_seca_repository.dart';
import 'package:papirar/features/lei_seca/highlights/di/lei_highlight_module.dart';
import 'package:papirar/features/lei_seca/highlights/domain/lei_highlight.dart';
import 'package:papirar/features/lei_seca/highlights/domain/lei_highlight_repository.dart';

enum LeiReadingStatus { loading, ready, unavailable, error }

enum LeiReadingMode { read, listen }

class LeiReadingController extends ChangeNotifier {
  final LeiSecaRepository _repository;
  final LeiHighlightRepository _highlightRepository;

  LeiReadingController(
    this._repository, {
    LeiHighlightRepository? highlightRepository,
  }) : _highlightRepository =
           highlightRepository ?? LeiHighlightModule.repository() {
    _iniciarCronometro();
  }

  LeiReadingStatus status = LeiReadingStatus.loading;
  LeiTexto? texto;
  String? mensagemErro;

  LeiReadingMode mode = LeiReadingMode.read;
  double textSize = 16;
  int secondsElapsed = 0;
  final ValueNotifier<int> secondsElapsedListenable = ValueNotifier<int>(0);
  final Map<String, List<LeiHighlight>> highlightsByPart = {};

  Timer? _studyTimer;

  String get formattedStudyTime {
    final hours = secondsElapsed ~/ 3600;
    final minutes = ((secondsElapsed % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsElapsed % 60).toString().padLeft(2, '0');
    if (hours > 0) return '$hours:$minutes:$seconds';
    return '$minutes:$seconds';
  }

  bool get isListening => mode == LeiReadingMode.listen;

  void _iniciarCronometro() {
    _studyTimer?.cancel();
    _studyTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mode == LeiReadingMode.read) {
        secondsElapsed++;
        secondsElapsedListenable.value = secondsElapsed;
      }
    });
  }

  void setTextSize(double size) {
    if (textSize == size) return;
    textSize = size;
    notifyListeners();
  }

  void setMode(LeiReadingMode value) {
    if (mode == value) return;
    mode = value;
    notifyListeners();
  }

  void toggleMode() {
    setMode(
      mode == LeiReadingMode.read ? LeiReadingMode.listen : LeiReadingMode.read,
    );
  }

  @override
  void dispose() {
    _studyTimer?.cancel();
    secondsElapsedListenable.dispose();
    super.dispose();
  }

  Future<void> carregar(String? assetPath) async {
    status = LeiReadingStatus.loading;
    mensagemErro = null;
    texto = null;
    notifyListeners();

    if (assetPath == null || assetPath.isEmpty) {
      status = LeiReadingStatus.unavailable;
      mensagemErro = 'O texto desta lei ainda não está disponível.';
      notifyListeners();
      return;
    }

    try {
      final result = await _repository.carregarTexto(assetPath);
      if (result == null || result.isEmpty) {
        status = LeiReadingStatus.error;
        mensagemErro = 'Não foi possível carregar o conteúdo.';
      } else {
        texto = result;
        status = LeiReadingStatus.ready;
        notifyListeners();
        unawaited(_carregarMarcacoes(result.id));
        return;
      }
    } catch (_) {
      status = LeiReadingStatus.error;
      mensagemErro = 'Erro ao carregar o conteúdo da lei.';
    }
    notifyListeners();
  }

  Future<void> _carregarMarcacoes(String leiId) async {
    try {
      highlightsByPart.clear();
      final highlights = await _highlightRepository.getByLei(leiId);
      for (final highlight in highlights) {
        final key = highlightKey(highlight.blocoIndex, highlight.partIndex);
        highlightsByPart.putIfAbsent(key, () => []).add(highlight);
      }
      notifyListeners();
    } catch (_) {
      // Marcações remotas não devem bloquear nem reiniciar a leitura.
    }
  }

  Future<void> marcarTexto(CreateLeiHighlightInput input) async {
    final highlight = await _highlightRepository.create(input);
    final key = highlightKey(highlight.blocoIndex, highlight.partIndex);
    final current = highlightsByPart.putIfAbsent(key, () => []);
    current.removeWhere(
      (h) => h.endOffset > input.startOffset && h.startOffset < input.endOffset,
    );
    current.add(highlight);
    highlightsByPart[key]!.sort(
      (a, b) => a.startOffset.compareTo(b.startOffset),
    );
    AppSyncEvents.instance.notifyStudyActivityChanged();
    notifyListeners();
  }

  Future<void> desmarcarTexto(LeiHighlightRangeInput input) async {
    await _highlightRepository.deleteOverlapping(input);
    final key = highlightKey(input.blocoIndex, input.partIndex);
    highlightsByPart[key]?.removeWhere(
      (h) => h.endOffset > input.startOffset && h.startOffset < input.endOffset,
    );
    AppSyncEvents.instance.notifyStudyActivityChanged();
    notifyListeners();
  }

  static String highlightKey(int blocoIndex, int partIndex) {
    return '$blocoIndex:$partIndex';
  }
}
