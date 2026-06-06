import 'package:papirar/domain/entities/lei_audio_explanation.dart';

class LeiTextLinkRange {
  final int startOffset;
  final int endOffset;
  final String href;

  const LeiTextLinkRange({
    required this.startOffset,
    required this.endOffset,
    required this.href,
  });
}

/// Texto de leitura de uma lei (conteúdo vindo do JSON em assets).
class LeiTexto {
  final String id;
  final String titulo;
  final String sigla;
  final List<String> blocos;
  final Map<int, LeiAudioExplanation> audiosPorBloco;
  final Map<int, List<LeiTextLinkRange>> linksPorBloco;

  const LeiTexto({
    required this.id,
    required this.titulo,
    required this.sigla,
    required this.blocos,
    this.audiosPorBloco = const {},
    this.linksPorBloco = const {},
  });

  bool get isEmpty => blocos.isEmpty;
}