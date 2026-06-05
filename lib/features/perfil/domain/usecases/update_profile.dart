import 'package:papirar/features/perfil/domain/entities/user_profile.dart';
import 'package:papirar/features/perfil/domain/repositories/profile_repository.dart';

class UpdateProfile {
  final ProfileRepository _repository;

  const UpdateProfile(this._repository);

  Future<UserProfile> call({
    required String displayName,
    required String username,
    required String bio,
  }) {
    return _repository.updateProfile(
      displayName: displayName,
      username: username,
      bio: bio,
    );
  }
}
