import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:papirar/features/perfil/data/models/profile_dto.dart';

abstract interface class ProfileRemoteDataSource {
  Future<ProfileDto> getCurrentProfile();

  Future<ProfileDto> updateProfile({
    required String displayName,
    required String username,
    required String bio,
  });

  Future<ProfileDto> uploadAvatar({
    required Uint8List bytes,
    required String extension,
  });
}

class SupabaseProfileRemoteDataSource implements ProfileRemoteDataSource {
  final SupabaseClient _client;

  const SupabaseProfileRemoteDataSource(this._client);

  static const _profilesTable = 'profiles';
  static const _avatarsBucket = 'avatars';

  @override
  Future<ProfileDto> getCurrentProfile() async {
    final user = _requireUser();
    final row = await _loadOrCreateProfile(user);
    return _toDto(row, user.email ?? '');
  }

  @override
  Future<ProfileDto> updateProfile({
    required String displayName,
    required String username,
    required String bio,
  }) async {
    final user = _requireUser();
    final row = await _client
        .from(_profilesTable)
        .update({'display_name': displayName, 'username': username, 'bio': bio})
        .eq('id', user.id)
        .select()
        .single();

    return _toDto(row, user.email ?? '');
  }

  @override
  Future<ProfileDto> uploadAvatar({
    required Uint8List bytes,
    required String extension,
  }) async {
    final user = _requireUser();
    final safeExtension = _safeExtension(extension);
    final avatarPath = '${user.id}/avatar.$safeExtension';

    await _client.storage
        .from(_avatarsBucket)
        .uploadBinary(
          avatarPath,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: _contentTypeFor(safeExtension),
          ),
        );

    final row = await _client
        .from(_profilesTable)
        .update({'avatar_path': avatarPath})
        .eq('id', user.id)
        .select()
        .single();

    return _toDto(row, user.email ?? '');
  }

  User _requireUser() {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Usuário não autenticado.');
    }
    return user;
  }

  Future<Map<String, dynamic>> _loadOrCreateProfile(User user) async {
    final existing = await _client
        .from(_profilesTable)
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (existing != null) return existing;

    final email = user.email ?? '';
    final username = _defaultUsername(email, user.id);
    return _client
        .from(_profilesTable)
        .insert({
          'id': user.id,
          'display_name':
              user.userMetadata?['name'] as String? ?? email.split('@').first,
          'username': username,
          'bio': '',
        })
        .select()
        .single();
  }

  ProfileDto _toDto(Map<String, dynamic> row, String email) {
    final avatarPath = row['avatar_path'] as String?;
    final avatarUrl = avatarPath == null
        ? null
        : '${_client.storage.from(_avatarsBucket).getPublicUrl(avatarPath)}?v=${row['updated_at']}';

    return ProfileDto.fromMap(row, email: email, avatarUrl: avatarUrl);
  }

  String _defaultUsername(String email, String userId) {
    final prefix = email.split('@').first.toLowerCase();
    final clean = prefix.replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    final base = clean.length >= 3 ? clean : 'aluno';
    return '${base}_${userId.replaceAll('-', '').substring(0, 6)}'.substring(
      0,
      30,
    );
  }

  String _safeExtension(String extension) {
    final clean = extension.toLowerCase().replaceAll('.', '');
    return switch (clean) {
      'jpg' || 'jpeg' => 'jpg',
      'png' => 'png',
      'webp' => 'webp',
      _ => 'jpg',
    };
  }

  String _contentTypeFor(String extension) {
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }
}
