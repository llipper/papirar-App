class ProfileValidators {
  ProfileValidators._();

  static String? validateDisplayName(String? value) {
    final name = value?.trim() ?? '';
    if (name.length < 2) return 'Use pelo menos 2 caracteres.';
    if (name.length > 80) return 'Use no máximo 80 caracteres.';
    if (RegExp(r'[\x00-\x1F\x7F]').hasMatch(name)) {
      return 'Remova caracteres inválidos.';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    final username = value?.trim().toLowerCase() ?? '';
    if (username.length < 3) return 'Use pelo menos 3 caracteres.';
    if (username.length > 30) return 'Use no máximo 30 caracteres.';
    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(username)) {
      return 'Use apenas letras, números e _.';
    }
    return null;
  }

  static String? validateBio(String? value) {
    final bio = value?.trim() ?? '';
    if (bio.length > 180) return 'Use no máximo 180 caracteres.';
    if (RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]').hasMatch(bio)) {
      return 'Remova caracteres inválidos.';
    }
    return null;
  }
}
