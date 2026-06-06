abstract final class LeiReadingTextUtils {
  static int primeiroBlocoLongo(List<String> blocos) {
    for (var i = 0; i < blocos.length; i++) {
      final b = blocos[i].trim();
      if (b.isEmpty) continue;
      if (ehTitulo(b) || ehRotuloArtigo(b)) continue;
      // The very first real body/content paragraph after titles/labels/preambulo
      // gets the decorative large first letter. This keeps it at the "beginning"
      // of the law instead of jumping to Art. 2 or later just because early
      // articles have short text.
      return i;
    }
    return 0;
  }

  static bool ehTitulo(String text) {
    if (text.length >= 80 || text.contains(';')) return false;
    return text.startsWith('TÍTULO') ||
        text.startsWith('CAPÍTULO') ||
        text.startsWith('SEÇÃO') ||
        text == 'PREÂMBULO' ||
        text == text.toUpperCase();
  }

  /// Recognizes standalone "Art. 2", "Art. 2º (Redação...)" etc. labels.
  /// These are now separate blocos so they don't steal the drop-cap large letter.
  static bool ehRotuloArtigo(String text) {
    final t = text.trimLeft();
    if (t.length > 80 || t.contains('\n\n')) return false;
    // Matches "Art. 1", "Art. 2º", "Art. 7-F", "Art. 10-A" etc.
    // Original class [\d\w\-] was kept as base but we explicitly added º and ª
    // because the JSON normalizes to "Art. 4º" / "Art. 5º" etc.
    // Without this, some article rotulos present in the JSON could fail to be
    // recognized as rotulos in the UI (wrong padding + not bold + possibly wrong drop-cap).
    return RegExp(
      r'^-?\s*Art\.?\s*[\d\w\-ºª]+',
      caseSensitive: false,
    ).hasMatch(t);
  }

  static bool ehProvavelRubrica(String text) {
    final t = text.trim();
    if (t.isEmpty || t.length > 70 || t.contains('\n')) return false;
    if (ehTitulo(t) || ehRotuloArtigo(t)) return false;
    if (RegExp(r'^(§|Parágrafo|[IVXLCDM]+\b|[a-z]\))').hasMatch(t)) {
      return false;
    }
    return !RegExp(r'[.;:]$').hasMatch(t);
  }

  static bool ehIncisoRomano(String text) {
    final t = text.trimLeft();
    return RegExp(r'^-?\s*[IVXLCDM]+\b').hasMatch(t);
  }

  static bool ehAlinea(String text) {
    final t = text.trimLeft();
    return RegExp(r'^-?\s*[a-z]\)').hasMatch(t);
  }

  static bool ehParagrafo(String text) {
    final t = text.trimLeft();
    return RegExp(
      r'^(§\s*\d+º|Parágrafo único\.?)',
      caseSensitive: false,
    ).hasMatch(t);
  }

  static String _normalizarQuebras(String texto) {
    var t = texto.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    if (t.contains(r'\n')) {
      t = t.replaceAll(r'\n\n', '\n\n').replaceAll(r'\n', '\n');
    }
    return t;
  }

  static List<String> partes(String bloco) {
    final t = _normalizarQuebras(bloco);
    return t.split(RegExp(r'\n\n+')).where((p) => p.isNotEmpty).toList();
  }
}
