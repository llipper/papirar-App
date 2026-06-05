import 'dart:typed_data';

import 'package:papirar/features/perfil/data/datasources/profile_remote_datasource.dart';
import 'package:papirar/features/perfil/domain/entities/user_profile.dart';
import 'package:papirar/features/perfil/domain/repositories/profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  const SupabaseProfileRepository(this._remoteDataSource);

  static UserProfile? _cachedProfile;
  static Future<UserProfile>? _pendingProfile;

  @override
  Future<UserProfile> getCurrentProfile() async {
    final cached = _cachedProfile;
    if (cached != null) return cached;

    final pending = _pendingProfile;
    if (pending != null) return pending;

    _pendingProfile = _loadCurrentProfile();
    return _pendingProfile!;
  }

  Future<UserProfile> _loadCurrentProfile() async {
    try {
      final dto = await _remoteDataSource.getCurrentProfile();
      final profile = dto.toEntity();
      _cachedProfile = profile;
      return profile;
    } finally {
      _pendingProfile = null;
    }
  }

  @override
  Future<UserProfile> updateProfile({
    required String displayName,
    required String username,
    required String bio,
  }) async {
    final dto = await _remoteDataSource.updateProfile(
      displayName: displayName,
      username: username,
      bio: bio,
    );
    final profile = dto.toEntity();
    _cachedProfile = profile;
    return profile;
  }

  @override
  Future<UserProfile> uploadAvatar({
    required Uint8List bytes,
    required String extension,
  }) async {
    final dto = await _remoteDataSource.uploadAvatar(
      bytes: bytes,
      extension: extension,
    );
    final profile = dto.toEntity();
    _cachedProfile = profile;
    return profile;
  }
}
