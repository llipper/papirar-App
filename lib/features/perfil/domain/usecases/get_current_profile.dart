import 'package:papirar/features/perfil/domain/entities/user_profile.dart';
import 'package:papirar/features/perfil/domain/repositories/profile_repository.dart';

class GetCurrentProfile {
  final ProfileRepository _repository;

  const GetCurrentProfile(this._repository);

  Future<UserProfile> call() {
    return _repository.getCurrentProfile();
  }
}
