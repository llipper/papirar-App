import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class LeiAudioExplanationPlayer extends ChangeNotifier {
  LeiAudioExplanationPlayer._() {
    _playerStateSubscription = _player.playerStateStream.listen(
      _handlePlayerState,
    );
  }

  static final instance = LeiAudioExplanationPlayer._();

  final AudioPlayer _player = AudioPlayer();
  late final StreamSubscription<PlayerState> _playerStateSubscription;

  String? _currentUrl;

  String? get currentUrl => _currentUrl;

  bool get isPlaying => _player.playing;

  bool isPlayingUrl(String url) {
    return _currentUrl == url &&
        _player.playing &&
        _player.processingState != ProcessingState.completed;
  }

  Future<void> toggle(String url) async {
    if (_currentUrl != url) {
      _currentUrl = url;
      await _player.setUrl(url);
    }

    if (_player.playing) {
      await _player.pause();
      notifyListeners();
      return;
    }

    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
    }

    unawaited(_player.play().whenComplete(notifyListeners));
    notifyListeners();
  }

  Future<void> stop() async {
    await _player.stop();
    _currentUrl = null;
    notifyListeners();
  }

  void _handlePlayerState(PlayerState state) {
    if (state.processingState != ProcessingState.completed) return;
    unawaited(_resetCompletedAudio());
  }

  Future<void> _resetCompletedAudio() async {
    await _player.pause();
    await _player.seek(Duration.zero);
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_playerStateSubscription.cancel());
    unawaited(_player.dispose());
    super.dispose();
  }
}
