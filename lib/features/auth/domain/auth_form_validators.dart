class AuthFormValidators {
  AuthFormValidators._();

  static final RegExp _emailPattern = RegExp(
    r"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$",
    caseSensitive: false,
  );

  static const Set<String> _blockedPasswords = {
    'password',
    'password123',
    'senha',
    'senha123',
    'admin123',
    'qwerty123',
    '12345678',
    '123456789',
    'papirar123',
  };

  static String normalizeEmail(String value) {
    return value.trim().toLowerCase();
  }

  static String? validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Informe seu nome.';
    if (name.length < 3) return 'Use pelo menos 3 caracteres.';
    if (name.length > 80) return 'Use no máximo 80 caracteres.';
    if (_hasControlChars(name)) return 'Remova caracteres inválidos.';
    if (RegExp(r'https?://|www\.|@').hasMatch(name.toLowerCase())) {
      return 'Use apenas seu nome.';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    final email = normalizeEmail(value ?? '');
    if (email.isEmpty) return 'Informe seu e-mail.';
    if (email.length > 254) return 'E-mail muito longo.';
    if (_hasControlChars(email)) return 'Remova caracteres inválidos.';
    if (!_emailPattern.hasMatch(email)) return 'Informe um e-mail válido.';
    if (email.contains('..')) return 'Informe um e-mail válido.';
    return null;
  }

  static String? validateLoginPassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Informe sua senha.';
    if (_hasControlChars(password)) return 'Senha inválida.';
    return null;
  }

  static String? validateStrongPassword(String? value, {String? email}) {
    final password = value ?? '';
    if (password.isEmpty) return 'Crie uma senha.';
    if (password.length < 12) return 'Use pelo menos 12 caracteres.';
    if (password.length > 128) return 'Use no máximo 128 caracteres.';
    if (_hasControlChars(password)) return 'Remova caracteres inválidos.';
    if (password.contains(' ')) return 'Não use espaços na senha.';

    final lower = password.toLowerCase();
    final emailUser = normalizeEmail(email ?? '').split('@').first;
    if (_blockedPasswords.contains(lower)) {
      return 'Escolha uma senha mais forte.';
    }
    if (emailUser.length >= 3 && lower.contains(emailUser)) {
      return 'Não use parte do e-mail na senha.';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Inclua uma letra minúscula.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Inclua uma letra maiúscula.';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Inclua um número.';
    }
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      return 'Inclua um símbolo.';
    }
    if (RegExp(r'(.)\1{3,}').hasMatch(password)) {
      return 'Evite caracteres repetidos em sequência.';
    }
    return null;
  }

  static String? validatePasswordConfirmation(String? value, String password) {
    if ((value ?? '').isEmpty) return 'Confirme sua senha.';
    if (value != password) return 'As senhas não conferem.';
    return null;
  }

  static bool _hasControlChars(String value) {
    return RegExp(r'[\x00-\x1F\x7F]').hasMatch(value);
  }
}
