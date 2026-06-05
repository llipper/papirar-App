sealed class AppFailure {
  final String message;

  const AppFailure(this.message);
}

class AuthFailure extends AppFailure {
  const AuthFailure(super.message);
}

class ConfigurationFailure extends AppFailure {
  const ConfigurationFailure(super.message);
}
