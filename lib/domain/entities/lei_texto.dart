import 'package:papirar/domain/entities/lei_audio_explanation.dart';

/// Texto de leitura de uma lei (conteúdo vindo do JSON em assets).
class LeiTexto {
  final String id;
  final String titulo;
  final String sigla;
  final List<String> blocos;
  final Map<int, LeiAudioExplanation> audiosPorBloco;

  const LeiTexto({
    required this.id,
    required this.titulo,
    required this.sigla,
    required this.blocos,
    this.audiosPorBloco = const {},
  });

  bool get isEmpty => blocos.isEmpty;
}
