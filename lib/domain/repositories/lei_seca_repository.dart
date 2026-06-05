import 'package:papirar/domain/entities/lei_texto.dart';

abstract class LeiSecaRepository {
  Future<LeiTexto?> carregarTexto(String assetPath);
}