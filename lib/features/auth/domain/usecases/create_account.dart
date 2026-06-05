import 'package:papirar/features/auth/domain/entities/auth_action_result.dart';
import 'package:papirar/features/auth/domain/repositories/auth_repository.dart';

class CreateAccount {
  final AuthRepository _repository;

  const CreateAccount(this._repository);

  Future<AuthActionResult> call({
    required String name,
    required String email,
    required String password,
  }) {
    return _repository.signUp(name: name, email: email, password: password);
  }
}
