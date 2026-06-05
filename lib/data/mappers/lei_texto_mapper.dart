import 'package:papirar/data/models/lei_texto_json_dto.dart';
import 'package:papirar/domain/entities/lei_texto.dart';

class LeiTextoMapper {
  const LeiTextoMapper._();

  static LeiTexto fromDto(LeiTextoJsonDto dto) {
    return LeiTexto(
      id: dto.id,
      titulo: dto.titulo,
      sigla: dto.sigla,
      blocos: List.unmodifiable(dto.blocos),
      audiosPorBloco: Map.unmodifiable(dto.audiosPorBloco),
    );
  }
}
