import 'package:papirar/features/auth/domain/entities/auth_action_result.dart';
import 'package:papirar/features/auth/domain/repositories/auth_repository.dart';

class SignOut {
  final AuthRepository _repository;

  const SignOut(this._repository);

  Future<AuthActionResult> call() {
    return _repository.signOut();
  }
}
