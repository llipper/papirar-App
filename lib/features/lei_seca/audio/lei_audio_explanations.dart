import 'package:papirar/features/lei_seca/audio/lei_audio_explanation.dart';

abstract final class LeiAudioExplanations {
  static const _items = <String, LeiAudioExplanation>{
    'constituicao88:preambulo': LeiAudioExplanation(
      id: 'constituicao88-preambulo',
      title: 'Explicação do preâmbulo',
      url:
          'https://pub-c1a7c48bea344fcc9aa3eb6164e56e43.r2.dev/constitutional/preambulo.mp3',
    ),
  };

  static LeiAudioExplanation? byText({
    required String leiId,
    required String text,
  }) {
    final anchor = _anchorForText(text);
    if (anchor == null) return null;
    return _items['$leiId:$anchor'];
  }

  static String? _anchorForText(String text) {
    final value = text.trim();
    if (value == 'PREÂMBULO') return 'preambulo';
    return null;
  }
}
