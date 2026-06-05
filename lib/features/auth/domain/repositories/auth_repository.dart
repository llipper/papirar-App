import 'package:papirar/features/auth/domain/entities/auth_action_result.dart';

abstract interface class AuthRepository {
  Future<AuthActionResult> signIn({
    required String email,
    required String password,
  });

  Future<AuthActionResult> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthActionResult> resetPassword(String email);

  Future<AuthActionResult> signOut();
}
