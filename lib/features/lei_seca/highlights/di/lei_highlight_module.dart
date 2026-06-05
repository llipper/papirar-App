import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:papirar/features/lei_seca/highlights/data/supabase_lei_highlight_repository.dart';
import 'package:papirar/features/lei_seca/highlights/domain/lei_highlight_repository.dart';

class LeiHighlightModule {
  LeiHighlightModule._();

  static LeiHighlightRepository repository() {
    return SupabaseLeiHighlightRepository(Supabase.instance.client);
  }
}
