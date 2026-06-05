import 'dart:typed_data';

import 'package:papirar/features/perfil/domain/entities/user_profile.dart';

abstract interface class ProfileRepository {
  Future<UserProfile> getCurrentProfile();

  Future<UserProfile> updateProfile({
    required String displayName,
    required String username,
    required String bio,
  });

  Future<UserProfile> uploadAvatar({
    required Uint8List bytes,
    required String extension,
  });
}
