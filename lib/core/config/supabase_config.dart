import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static const _urlKey = 'SUPABASE_URL';
  static const _anonKey = 'SUPABASE_ANON_KEY';

  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');

    final url = dotenv.env[_urlKey]?.trim() ?? '';
    final anonKey = dotenv.env[_anonKey]?.trim() ?? '';

    if (url.isEmpty || anonKey.isEmpty) {
      throw StateError(
        'Supabase não configurado. Preencha SUPABASE_URL e SUPABASE_ANON_KEY no .env.',
      );
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
  }
}
