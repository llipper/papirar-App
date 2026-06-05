import 'package:papirar/data/repositories/lei_reading_progress_repository_impl.dart';
import 'package:papirar/data/repositories/lei_seca_repository_impl.dart';
import 'package:papirar/domain/repositories/lei_reading_progress_repository.dart';
import 'package:papirar/domain/repositories/lei_seca_repository.dart';

/// Ponto único de injeção da feature (expandir com Riverpod depois).
final LeiSecaRepository leiSecaRepository = LeiSecaRepositoryImpl();
final LeiReadingProgressRepository leiReadingProgressRepository =
    LeiReadingProgressRepositoryImpl();