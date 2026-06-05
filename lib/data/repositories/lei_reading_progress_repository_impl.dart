import 'package:papirar/data/datasources/lei_reading_progress_prefs_datasource.dart';
import 'package:papirar/domain/repositories/lei_reading_progress_repository.dart';

class LeiReadingProgressRepositoryImpl implements LeiReadingProgressRepository {
  final LeiReadingProgressPrefsDatasource _datasource;

  LeiReadingProgressRepositoryImpl({LeiReadingProgressPrefsDatasource? datasource})
      : _datasource = datasource ?? LeiReadingProgressPrefsDatasource();

  @override
  Future<double?> obterOffset(String leiKey) => _datasource.obterOffset(leiKey);

  @override
  Future<void> salvarOffset(String leiKey, double offset) =>
      _datasource.salvarOffset(leiKey, offset);
}