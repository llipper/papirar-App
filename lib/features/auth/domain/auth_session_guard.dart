import 'package:supabase_flutter/supabase_flutter.dart';

class AuthSessionGuard {
  AuthSessionGuard._();

  static bool get hasActiveSession {
    try {
      return Supabase.instance.client.auth.currentSession != null;
    } catch (_) {
      return false;
    }
  }
}
