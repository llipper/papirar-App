import 'package:papirar/features/auth/domain/entities/auth_action_result.dart';
import 'package:papirar/features/auth/domain/repositories/auth_repository.dart';

class SignInWithEmail {
  final AuthRepository _repository;

  const SignInWithEmail(this._repository);

  Future<AuthActionResult> call({
    required String email,
    required String password,
  }) {
    return _repository.signIn(email: email, password: password);
  }
}
