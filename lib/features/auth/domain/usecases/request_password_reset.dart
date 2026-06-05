import 'package:papirar/features/auth/domain/entities/auth_action_result.dart';
import 'package:papirar/features/auth/domain/repositories/auth_repository.dart';

class RequestPasswordReset {
  final AuthRepository _repository;

  const RequestPasswordReset(this._repository);

  Future<AuthActionResult> call(String email) {
    return _repository.resetPassword(email);
  }
}
