import 'package:papirar/features/perfil/domain/entities/user_profile.dart';

class ProfileDto {
  final String id;
  final String email;
  final String displayName;
  final String username;
  final String bio;
  final String? avatarPath;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileDto({
    required this.id,
    required this.email,
    required this.displayName,
    required this.username,
    required this.bio,
    required this.avatarPath,
    required this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileDto.fromMap(
    Map<String, dynamic> map, {
    required String email,
    required String? avatarUrl,
  }) {
    return ProfileDto(
      id: map['id'] as String,
      email: email,
      displayName: map['display_name'] as String? ?? 'Aluno Papirar',
      username: map['username'] as String? ?? 'papirar',
      bio: map['bio'] as String? ?? '',
      avatarPath: map['avatar_path'] as String?,
      avatarUrl: avatarUrl,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? ''),
    );
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      email: email,
      displayName: displayName,
      username: username,
      bio: bio,
      avatarPath: avatarPath,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
