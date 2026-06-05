import 'package:papirar/features/lei_seca/highlights/domain/lei_highlight.dart';

abstract interface class LeiHighlightRepository {
  Future<List<LeiHighlight>> getAll();

  Future<List<LeiHighlight>> getByLei(String leiId);

  Future<LeiHighlight> create(CreateLeiHighlightInput input);

  Future<void> deleteOverlapping(LeiHighlightRangeInput input);
}
