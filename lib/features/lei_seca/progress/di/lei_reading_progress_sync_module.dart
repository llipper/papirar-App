import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:papirar/features/lei_seca/progress/data/supabase_lei_reading_progress_sync_repository.dart';
import 'package:papirar/features/lei_seca/progress/domain/lei_reading_progress_sync_repository.dart';

class LeiReadingProgressSyncModule {
  LeiReadingProgressSyncModule._();

  static LeiReadingProgressSyncRepository repository() {
    return SupabaseLeiReadingProgressSyncRepository(Supabase.instance.client);
  }
}
