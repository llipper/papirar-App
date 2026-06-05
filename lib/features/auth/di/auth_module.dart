import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:papirar/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:papirar/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:papirar/features/auth/domain/repositories/auth_repository.dart';
import 'package:papirar/features/auth/domain/usecases/create_account.dart';
import 'package:papirar/features/auth/domain/usecases/request_password_reset.dart';
import 'package:papirar/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:papirar/features/auth/domain/usecases/sign_out.dart';

class AuthModule {
  AuthModule._();

  static AuthRemoteDataSource remoteDataSource() {
    return SupabaseAuthRemoteDataSource(Supabase.instance.client);
  }

  static AuthRepository repository() {
    return SupabaseAuthRepository(remoteDataSource());
  }

  static SignInWithEmail signInWithEmail() {
    return SignInWithEmail(repository());
  }

  static CreateAccount createAccount() {
    return CreateAccount(repository());
  }

  static RequestPasswordReset requestPasswordReset() {
    return RequestPasswordReset(repository());
  }

  static SignOut signOut() {
    return SignOut(repository());
  }
}
