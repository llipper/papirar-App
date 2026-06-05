class AuthActionResult {
  final bool isSuccess;
  final String message;

  const AuthActionResult._({required this.isSuccess, required this.message});

  const AuthActionResult.success([
    String message = 'Autenticado com segurança.',
  ]) : this._(isSuccess: true, message: message);

  const AuthActionResult.failure(String message)
    : this._(isSuccess: false, message: message);
}
