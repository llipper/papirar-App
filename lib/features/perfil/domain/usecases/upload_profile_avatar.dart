import 'dart:typed_data';

import 'package:papirar/features/perfil/domain/entities/user_profile.dart';
import 'package:papirar/features/perfil/domain/repositories/profile_repository.dart';

class UploadProfileAvatar {
  final ProfileRepository _repository;

  const UploadProfileAvatar(this._repository);

  Future<UserProfile> call({
    required Uint8List bytes,
    required String extension,
  }) {
    return _repository.uploadAvatar(bytes: bytes, extension: extension);
  }
}
