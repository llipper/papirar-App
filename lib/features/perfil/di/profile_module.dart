import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:papirar/features/perfil/data/datasources/profile_remote_datasource.dart';
import 'package:papirar/features/perfil/data/repositories/supabase_profile_repository.dart';
import 'package:papirar/features/perfil/domain/repositories/profile_repository.dart';
import 'package:papirar/features/perfil/domain/usecases/get_current_profile.dart';
import 'package:papirar/features/perfil/domain/usecases/update_profile.dart';
import 'package:papirar/features/perfil/domain/usecases/upload_profile_avatar.dart';

class ProfileModule {
  ProfileModule._();

  static ProfileRemoteDataSource remoteDataSource() {
    return SupabaseProfileRemoteDataSource(Supabase.instance.client);
  }

  static ProfileRepository repository() {
    return SupabaseProfileRepository(remoteDataSource());
  }

  static GetCurrentProfile getCurrentProfile() {
    return GetCurrentProfile(repository());
  }

  static UpdateProfile updateProfile() {
    return UpdateProfile(repository());
  }

  static UploadProfileAvatar uploadProfileAvatar() {
    return UploadProfileAvatar(repository());
  }
}
