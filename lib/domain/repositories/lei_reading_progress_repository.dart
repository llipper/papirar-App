/// Persistência da posição de leitura por lei.
abstract class LeiReadingProgressRepository {
  Future<double?> obterOffset(String leiKey);

  Future<void> salvarOffset(String leiKey, double offset);
}