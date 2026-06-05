import 'dart:io';

import 'package:flutter/services.dart';

/// Controle da UI do sistema (barra de navegação Android, etc.).
abstract final class SystemUiService {
  /// Oculta os 3 botões da barra de navegação no Android; mantém a status bar.
  /// Modo imersivo: se o usuário puxar a barra, ela some de novo sozinha.
  static Future<void> ocultarBarraNavegacaoAndroid() async {
    if (!Platform.isAndroid) return;

    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [SystemUiOverlay.top],
    );
  }

  /// Restaura barras do sistema ao sair da tela imersiva.
  static Future<void> restaurarBarrasSistema() async {
    if (Platform.isAndroid) {
      await ocultarBarraNavegacaoAndroid();
      return;
    }

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}
