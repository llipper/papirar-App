import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:papirar/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:papirar/features/auth/domain/entities/auth_action_result.dart';
import 'package:papirar/features/auth/domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  const SupabaseAuthRepository(this._remoteDataSource);

  @override
  Future<AuthActionResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _remoteDataSource.signIn(email: email, password: password);
      return const AuthActionResult.success();
    } on AuthException catch (_) {
      return const AuthActionResult.failure('E-mail ou senha inválidos.');
    } catch (_) {
      return const AuthActionResult.failure(
        'Autenticação indisponível. Configure o Supabase Auth.',
      );
    }
  }

  @override
  Future<AuthActionResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await _remoteDataSource.signUp(
        name: name,
        email: email,
        password: password,
      );
      return const AuthActionResult.success(
        'Conta criada. Verifique seu e-mail antes de entrar.',
      );
    } on AuthException catch (_) {
      return const AuthActionResult.failure(
        'Não foi possível criar a conta com esses dados.',
      );
    } catch (_) {
      return const AuthActionResult.failure(
        'Cadastro indisponível. Configure o Supabase Auth.',
      );
    }
  }

  @override
  Future<AuthActionResult> resetPassword(String email) async {
    try {
      await _remoteDataSource.resetPassword(email);
    } catch (_) {
      // Mensagem genérica evita enumeração de contas.
    }

    return const AuthActionResult.success(
      'Se existir uma conta para esse e-mail, enviaremos as instruções.',
    );
  }

  @override
  Future<AuthActionResult> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const AuthActionResult.success('Sessão encerrada.');
    } catch (_) {
      return const AuthActionResult.failure('Não foi possível sair da conta.');
    }
  }
}
