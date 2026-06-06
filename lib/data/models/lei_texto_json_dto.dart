import 'package:papirar/domain/entities/lei_audio_explanation.dart';
import 'package:papirar/domain/entities/lei_texto.dart';

/// DTO do JSON de leitura (`formato: leitura`).
class LeiTextoJsonDto {
  final String id;
  final String titulo;
  final String sigla;
  final List<String> blocos;
  final Map<int, LeiAudioExplanation> audiosPorBloco;
  final Map<int, List<LeiTextLinkRange>> linksPorBloco;

  const LeiTextoJsonDto({
    required this.id,
    required this.titulo,
    required this.sigla,
    required this.blocos,
    this.audiosPorBloco = const {},
    this.linksPorBloco = const {},
  });

  /// Converte `separador` mal escrito no JSON (`"\\n\\n"` → literal `\n\n`).
  static String _separadorParagrafos(Map<String, dynamic> json) {
    final raw = json['separador']?.toString();
    if (raw == null || raw.isEmpty) return '\n\n';
    if (raw == r'\n\n' || raw == r'\n') {
      return raw.replaceAll(r'\n', '\n');
    }
    return raw;
  }

  static String _normalizarTexto(String texto) {
    var t = texto.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    if (t.contains(r'\n')) {
      t = t.replaceAll(r'\n\n', '\n\n').replaceAll(r'\n', '\n');
    }
    return t.trim();
  }

  factory LeiTextoJsonDto.fromJson(Map<String, dynamic> json) {
    final blocos = <String>[];
    final audiosPorBloco = <int, LeiAudioExplanation>{};
    final linksPorBloco = <int, List<LeiTextLinkRange>>{};
    final separador = _separadorParagrafos(json);

    final blocosRaw = json['blocos'] as List<dynamic>?;
    if (blocosRaw != null) {
      for (final item in blocosRaw) {
        if (item is Map<String, dynamic>) {
          final partesRaw = item['partes'] as List<dynamic>?;
          if (partesRaw != null && partesRaw.isNotEmpty) {
            final partes = partesRaw
                .map((p) => _normalizarTexto(p.toString()))
                .where((p) => p.isNotEmpty)
                .toList();
            if (partes.isNotEmpty) {
              final blocoIndex = blocos.length;
              final bloco = partes.join('\n\n');
              blocos.add(bloco);
              _setLinksForBloco(
                linksPorBloco,
                blocoIndex,
                _linksFromNode(item, null, bloco),
              );
            }
            continue;
          }
          final t = item['texto']?.toString();
          if (t != null && t.isNotEmpty) {
            final blocoIndex = blocos.length;
            final bloco = _normalizarTexto(t);
            blocos.add(bloco);
            _setLinksForBloco(
              linksPorBloco,
              blocoIndex,
              _linksFromNode(item, 'texto', bloco),
            );
          }
        } else if (item is String && item.trim().isNotEmpty) {
          blocos.add(_normalizarTexto(item));
        }
      }
    }

    if (blocos.isEmpty) {
      if (json['divisoes'] != null) {
        final rich = _flattenNovoFormatoToBlocos(json);
        blocos.addAll(rich.blocos);
        audiosPorBloco.addAll(rich.audiosPorBloco);
        linksPorBloco.addAll(rich.linksPorBloco);
      } else if (json['titulos'] != null || json['documento'] != null) {
        final richBlocos = _flattenRichToBlocos(json);
        blocos.addAll(richBlocos);
      } else {
        final texto = json['texto']?.toString() ?? '';
        if (texto.isNotEmpty) {
          final normalizado = _normalizarTexto(texto);
          if (separador == '\n\n') {
            blocos.addAll(normalizado.split(RegExp(r'\n\n+')));
          } else {
            blocos.addAll(normalizado.split(separador));
          }
        }
      }
    }

    String derivedId = json['id']?.toString() ?? '';
    String derivedTitulo = json['titulo']?.toString() ?? '';
    String derivedSigla = json['sigla']?.toString() ?? '';
    final doc = json['documento']?.toString() ?? '';
    if (derivedId.isEmpty && doc.contains('Constituição')) {
      derivedId = 'constituicao88';
      derivedTitulo = 'Constituição Federal de 1988';
      derivedSigla = 'CF/88';
    }
    if (derivedId.isEmpty || derivedSigla.isEmpty) {
      final metadata = _metadataDoNovoFormato(json);
      derivedId = derivedId.isEmpty ? metadata.id : derivedId;
      derivedTitulo = derivedTitulo.isEmpty ? metadata.titulo : derivedTitulo;
      derivedSigla = derivedSigla.isEmpty ? metadata.sigla : derivedSigla;
    }

    return LeiTextoJsonDto(
      id: derivedId,
      titulo: derivedTitulo,
      sigla: derivedSigla,
      blocos: blocos,
      audiosPorBloco: audiosPorBloco,
      linksPorBloco: linksPorBloco,
    );
  }

  static ({String id, String titulo, String sigla}) _metadataDoNovoFormato(
    Map<String, dynamic> json,
  ) {
    final fonte = json['fonte']?.toString().toLowerCase() ?? '';
    final titulo = json['titulo']?.toString() ?? '';
    final chave = '$fonte ${titulo.toLowerCase()}';

    if (chave.contains('constituicao')) {
      return (
        id: 'constituicao88',
        titulo: titulo.isEmpty ? 'Constituição Federal de 1988' : titulo,
        sigla: 'CF/88',
      );
    }
    if (chave.contains('processo penal militar')) {
      return (
        id: 'codigo_processo_penal_militar',
        titulo: titulo.isEmpty ? 'Código de Processo Penal Militar' : titulo,
        sigla: 'CPPM',
      );
    }
    if (chave.contains('processo penal')) {
      return (
        id: 'codigo_processo_penal',
        titulo: titulo.isEmpty ? 'Código de Processo Penal' : titulo,
        sigla: 'CPP',
      );
    }
    if (chave.contains('penal militar')) {
      return (
        id: 'codigo_penal_militar',
        titulo: titulo.isEmpty ? 'Código Penal Militar' : titulo,
        sigla: 'CPM',
      );
    }
    if (chave.contains('código penal') || chave.contains('codigo penal')) {
      return (
        id: 'codigo_penal',
        titulo: titulo.isEmpty ? 'Código Penal' : titulo,
        sigla: 'CP',
      );
    }
    if (chave.contains('trânsito') || chave.contains('transito')) {
      return (
        id: 'codigo_transito_brasileiro',
        titulo: titulo.isEmpty ? 'Código de Trânsito Brasileiro' : titulo,
        sigla: 'CTB',
      );
    }
    if (chave.contains('criança') || chave.contains('crianca')) {
      return (
        id: 'estatuto_crianca_adolescente',
        titulo: titulo.isEmpty
            ? 'Estatuto da Criança e do Adolescente'
            : titulo,
        sigla: 'ECA',
      );
    }
    if (chave.contains('desarmamento')) {
      return (
        id: 'estatuto_desarmamento',
        titulo: titulo.isEmpty ? 'Estatuto do Desarmamento' : titulo,
        sigla: 'ED',
      );
    }
    if (chave.contains('militares')) {
      return (
        id: 'estatuto_militares',
        titulo: titulo.isEmpty ? 'Estatuto dos Militares' : titulo,
        sigla: 'EM',
      );
    }

    return (id: 'lei_seca', titulo: titulo, sigla: '');
  }

  static ({
    List<String> blocos,
    Map<int, LeiAudioExplanation> audiosPorBloco,
    Map<int, List<LeiTextLinkRange>> linksPorBloco,
  })
  _flattenNovoFormatoToBlocos(Map<String, dynamic> json) {
    final result = <String>[];
    final audiosPorBloco = <int, LeiAudioExplanation>{};
    final linksPorBloco = <int, List<LeiTextLinkRange>>{};

    _appendListaTexto(result, json['preambulo'], linksPorBloco);
    _appendDivisoes(result, json['divisoes'], audiosPorBloco, linksPorBloco);
    _appendDivisao(result, json['adct'], audiosPorBloco, linksPorBloco);
    _appendDivisao(result, json['anexo'], audiosPorBloco, linksPorBloco);

    return (
      blocos: result.where((b) => b.trim().isNotEmpty).toList(),
      audiosPorBloco: audiosPorBloco,
      linksPorBloco: linksPorBloco,
    );
  }

  static void _appendListaTexto(
    List<String> result,
    dynamic value,
    Map<int, List<LeiTextLinkRange>> linksPorBloco,
  ) {
    if (value is! List<dynamic>) return;
    for (final item in value) {
      final texto = item is Map<String, dynamic> ? item['texto'] : item;
      final bloco = _normalizarTexto(texto?.toString() ?? '');
      if (bloco.isNotEmpty) {
        final blocoIndex = result.length;
        result.add(bloco);
        if (item is Map<String, dynamic>) {
          _setLinksForBloco(
            linksPorBloco,
            blocoIndex,
            _linksFromNode(item, 'texto', bloco),
          );
        }
      }
    }
  }

  static void _appendDivisoes(
    List<String> result,
    dynamic value,
    Map<int, LeiAudioExplanation> audiosPorBloco,
    Map<int, List<LeiTextLinkRange>> linksPorBloco,
  ) {
    if (value is! List<dynamic>) return;
    for (final item in value) {
      _appendDivisao(result, item, audiosPorBloco, linksPorBloco);
    }
  }

  static void _appendDivisao(
    List<String> result,
    dynamic value,
    Map<int, LeiAudioExplanation> audiosPorBloco,
    Map<int, List<LeiTextLinkRange>> linksPorBloco,
  ) {
    if (value is! Map<String, dynamic>) return;

    final rotulo = _normalizarTexto(value['rotulo']?.toString() ?? '');
    final titulo = _normalizarTexto(value['titulo']?.toString() ?? '');
    if (rotulo.isNotEmpty) result.add(rotulo);
    if (titulo.isNotEmpty && titulo != rotulo) result.add(titulo);

    _appendListaTexto(result, value['itens'], linksPorBloco);
    _appendArtigos(result, value['artigos'], audiosPorBloco, linksPorBloco);
    _appendDivisoes(result, value['divisoes'], audiosPorBloco, linksPorBloco);
  }

  static void _appendArtigos(
    List<String> result,
    dynamic value,
    Map<int, LeiAudioExplanation> audiosPorBloco,
    Map<int, List<LeiTextLinkRange>> linksPorBloco,
  ) {
    if (value is! List<dynamic>) return;
    for (final item in value) {
      if (item is! Map<String, dynamic>) continue;

      final rotulo = _normalizarTexto(item['rotulo']?.toString() ?? '');
      final numero = item['numero']?.toString() ?? '';
      final label = _normalizarMarcadorOrdinal(
        rotulo.isNotEmpty ? rotulo : 'Art. $numero',
      );
      final labelIndex = result.length;
      result.add(label);
      _appendAudio(audiosPorBloco, labelIndex, item['audio'], label);

      final partes = <_BlocoLeiParte>[];
      final rubrica = _normalizarTexto(item['rubrica']?.toString() ?? '');
      if (rubrica.isNotEmpty) {
        partes.add(
          _BlocoLeiParte.rubrica(
            rubrica,
            links: _linksFromNode(item, 'rubrica', rubrica),
          ),
        );
      }
      _appendSubtitulos(partes, item['subtitulos']);
      _appendTexto(partes, item, 'caput');
      _appendDispositivos(partes, item['penas'], tipo: _TipoDispositivo.pena);
      _appendDispositivos(
        partes,
        item['alineas'],
        tipo: _TipoDispositivo.alinea,
      );
      _appendDispositivos(
        partes,
        item['incisos'],
        tipo: _TipoDispositivo.inciso,
      );
      _appendDispositivos(
        partes,
        item['paragrafos'],
        tipo: _TipoDispositivo.paragrafo,
      );

      _appendPartes(result, audiosPorBloco, linksPorBloco, partes);
    }
  }

  static void _appendPartes(
    List<String> result,
    Map<int, LeiAudioExplanation> audiosPorBloco,
    Map<int, List<LeiTextLinkRange>> linksPorBloco,
    List<_BlocoLeiParte> partes,
  ) {
    final buffer = <_BlocoLeiParte>[];

    void flushBuffer() {
      if (buffer.isEmpty) return;
      final blocoIndex = result.length;
      result.add(buffer.map((p) => p.texto).join('\n\n'));
      _setLinksForBloco(linksPorBloco, blocoIndex, _linksForPartes(buffer));
      buffer.clear();
    }

    for (final parte in partes) {
      if (parte.audio == null) {
        buffer.add(parte);
        continue;
      }

      final pendingRubrica = buffer.isNotEmpty && buffer.last.isRubrica
          ? buffer.removeLast()
          : null;
      flushBuffer();
      final blocoIndex = result.length;
      final blocoPartes = pendingRubrica == null
          ? [parte]
          : [pendingRubrica, parte];
      result.add(blocoPartes.map((p) => p.texto).join('\n\n'));
      _setLinksForBloco(
        linksPorBloco,
        blocoIndex,
        _linksForPartes(blocoPartes),
      );
      audiosPorBloco[blocoIndex] = parte.audio!;
    }

    flushBuffer();
  }

  static void _appendAudio(
    Map<int, LeiAudioExplanation> audiosPorBloco,
    int blocoIndex,
    dynamic value,
    String fallbackTitle,
  ) {
    if (value == null) return;

    if (value is String && value.trim().isNotEmpty) {
      audiosPorBloco[blocoIndex] = LeiAudioExplanation(
        id: _safeAudioId(fallbackTitle),
        title: 'Explicação de $fallbackTitle',
        url: value.trim(),
      );
      return;
    }

    if (value is! Map<String, dynamic>) return;
    final url = value['url']?.toString().trim() ?? '';
    if (url.isEmpty) return;
    final id = value['id']?.toString().trim() ?? '';
    final title = (value['titulo'] ?? value['title'])?.toString().trim() ?? '';

    audiosPorBloco[blocoIndex] = LeiAudioExplanation(
      id: id.isNotEmpty ? id : _safeAudioId(fallbackTitle),
      title: title.isNotEmpty ? title : 'Explicação de $fallbackTitle',
      url: url,
    );
  }

  static String _safeAudioId(String value) {
    return value
        .toLowerCase()
        .replaceAll('º', '')
        .replaceAll('ª', '')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  static void _appendDispositivos(
    List<_BlocoLeiParte> result,
    dynamic value, {
    required _TipoDispositivo tipo,
  }) {
    if (value is! List<dynamic>) return;
    for (final item in value) {
      if (item is! Map<String, dynamic>) continue;

      final rubrica = _normalizarTexto(item['rubrica']?.toString() ?? '');
      if (rubrica.isNotEmpty) {
        result.add(
          _BlocoLeiParte.rubrica(
            rubrica,
            links: _linksFromNode(item, 'rubrica', rubrica),
          ),
        );
      }
      _appendSubtitulos(result, item['subtitulos']);

      final texto = _normalizarTexto(item['texto']?.toString() ?? '');
      final linha = switch (tipo) {
        _TipoDispositivo.pena => texto.isEmpty ? '' : 'Pena - $texto',
        _TipoDispositivo.paragrafo => _linhaParagrafo(item, texto),
        _TipoDispositivo.inciso => _linhaComRotulo(item, texto, useDash: true),
        _TipoDispositivo.alinea => _linhaComRotulo(item, texto, useDash: false),
      };
      if (linha.isNotEmpty) {
        result.add(
          _BlocoLeiParte(
            linha,
            audio: _parseAudio(item['audio'], _fallbackAudioTitle(tipo, item)),
            links: _linksFromNode(item, 'texto', linha),
          ),
        );
      }

      _appendDispositivos(result, item['penas'], tipo: _TipoDispositivo.pena);
      _appendDispositivos(
        result,
        item['alineas'],
        tipo: _TipoDispositivo.alinea,
      );
      _appendDispositivos(
        result,
        item['incisos'],
        tipo: _TipoDispositivo.inciso,
      );
      _appendDispositivos(
        result,
        item['paragrafos'],
        tipo: _TipoDispositivo.paragrafo,
      );
    }
  }

  static void _appendTexto(
    List<_BlocoLeiParte> result,
    Map<String, dynamic> item,
    String key,
  ) {
    final texto = _normalizarTexto(item[key]?.toString() ?? '');
    if (texto.isNotEmpty) {
      result.add(
        _BlocoLeiParte(texto, links: _linksFromNode(item, key, texto)),
      );
    }
  }

  static void _appendSubtitulos(List<_BlocoLeiParte> result, dynamic value) {
    if (value is! List<dynamic>) return;
    for (final item in value) {
      final texto = item is Map<String, dynamic> ? item['texto'] : item;
      final bloco = _normalizarTexto(texto?.toString() ?? '');
      if (bloco.isNotEmpty) {
        result.add(
          _BlocoLeiParte(
            bloco,
            links: item is Map<String, dynamic>
                ? _linksFromNode(item, 'texto', bloco)
                : const [],
          ),
        );
      }
    }
  }

  static LeiAudioExplanation? _parseAudio(dynamic value, String fallbackTitle) {
    if (value == null) return null;

    if (value is String && value.trim().isNotEmpty) {
      return LeiAudioExplanation(
        id: _safeAudioId(fallbackTitle),
        title: 'Explicação de $fallbackTitle',
        url: value.trim(),
      );
    }

    if (value is! Map<String, dynamic>) return null;
    final url = value['url']?.toString().trim() ?? '';
    if (url.isEmpty) return null;
    final id = value['id']?.toString().trim() ?? '';
    final title = (value['titulo'] ?? value['title'])?.toString().trim() ?? '';

    return LeiAudioExplanation(
      id: id.isNotEmpty ? id : _safeAudioId(fallbackTitle),
      title: title.isNotEmpty ? title : 'Explicação de $fallbackTitle',
      url: url,
    );
  }

  static String _fallbackAudioTitle(
    _TipoDispositivo tipo,
    Map<String, dynamic> item,
  ) {
    final rotulo = _normalizarTexto(item['rotulo']?.toString() ?? '');
    if (rotulo.isNotEmpty) return rotulo;

    final numero =
        item['numero']?.toString() ?? item['letra']?.toString() ?? '';
    if (numero.isEmpty) return 'dispositivo';

    return switch (tipo) {
      _TipoDispositivo.pena => 'pena',
      _TipoDispositivo.paragrafo =>
        numero.toLowerCase() == 'único' || numero.toLowerCase() == 'unico'
            ? 'Parágrafo único'
            : '§ $numero',
      _TipoDispositivo.inciso => 'Inciso $numero',
      _TipoDispositivo.alinea => 'Alínea $numero',
    };
  }

  static String _linhaParagrafo(Map<String, dynamic> item, String texto) {
    final rotulo = _normalizarMarcadorOrdinal(
      _normalizarTexto(item['rotulo']?.toString() ?? ''),
    );
    if (rotulo.isNotEmpty) return '$rotulo - $texto'.trim();

    final numero = _normalizarMarcadorOrdinal(item['numero']?.toString() ?? '');
    if (numero.toLowerCase() == 'único' || numero.toLowerCase() == 'unico') {
      return 'Parágrafo único - $texto'.trim();
    }
    return numero.isEmpty ? texto : '§ $numero - $texto'.trim();
  }

  static String _linhaComRotulo(
    Map<String, dynamic> item,
    String texto, {
    required bool useDash,
  }) {
    final rotulo = _normalizarMarcadorOrdinal(
      _normalizarTexto(item['rotulo']?.toString() ?? ''),
    );
    if (rotulo.isNotEmpty) {
      return useDash ? '$rotulo - $texto'.trim() : '$rotulo $texto'.trim();
    }

    final numeroRaw = item['numero']?.toString() ?? '';
    final letraRaw = item['letra']?.toString() ?? '';
    final numero = _normalizarMarcadorOrdinal(
      numeroRaw.isNotEmpty ? numeroRaw : letraRaw,
    );
    if (numero.isEmpty) return texto;
    return useDash ? '$numero - $texto'.trim() : '$numero $texto'.trim();
  }

  static String _normalizarMarcadorOrdinal(String value) {
    return value
        .replaceAllMapped(
          RegExp(r'\b(Art\.\s*\d+)[o°]\b', caseSensitive: false),
          (match) => '${match.group(1)}º',
        )
        .replaceAllMapped(
          RegExp(r'(§\s*\d+)[o°]\b', caseSensitive: false),
          (match) => '${match.group(1)}º',
        )
        .replaceAllMapped(
          RegExp(r'^(\d+)[o°]$', caseSensitive: false),
          (match) => '${match.group(1)}º',
        );
  }

  /// Flattens the rich hierarchical structure (titulos -> capitulos -> artigos
  /// with incisos/paragrafos and "valido") into the flat blocos list expected
  /// by the reader UI. Invalid items (valido:false or struck) get "-" prefix.
  static List<String> _flattenRichToBlocos(Map<String, dynamic> json) {
    final result = <String>[];

    // Preambulo
    final pre = json['preambulo']?.toString();
    if (pre != null && pre.isNotEmpty) {
      result.add('PREÂMBULO');
      result.add(_normalizarTexto(pre));
    }

    final titulos = json['titulos'] as List<dynamic>? ?? const [];
    for (final t in titulos) {
      if (t is! Map<String, dynamic>) continue;
      final tNum = t['numero']?.toString() ?? '';
      final tTitle = t['titulo']?.toString() ?? '';
      final isSyntheticUnique = tNum.toUpperCase() == 'ÚNICO';
      if (!isSyntheticUnique) {
        result.add("TÍTULO $tNum");
      }
      if (tTitle.isNotEmpty) result.add(_normalizarTexto(tTitle));

      final caps = (t['capitulos'] as List<dynamic>?) ?? const [];
      final directArts = (t['artigos'] as List<dynamic>?) ?? const [];

      final containers = caps.isNotEmpty
          ? caps
          : [
              <String, dynamic>{'artigos': directArts},
            ];

      for (final c in containers) {
        if (c is! Map<String, dynamic>) continue;
        final cNum = c['numero']?.toString();
        final cTitle = c['titulo']?.toString();
        if (cNum != null) {
          result.add("CAPÍTULO $cNum");
          if (cTitle != null && cTitle.isNotEmpty) {
            result.add(_normalizarTexto(cTitle));
          }
        }

        final secs = (c['secoes'] as List<dynamic>?) ?? const [];
        final cArts = (c['artigos'] as List<dynamic>?) ?? const [];

        final artContainers = secs.isNotEmpty
            ? secs
            : [
                <String, dynamic>{'artigos': cArts},
              ];

        for (final ac in artContainers) {
          if (ac is! Map<String, dynamic>) continue;
          final sNum = ac['numero']?.toString();
          final sTitle = ac['titulo']?.toString();
          if (sNum != null) {
            result.add("SEÇÃO $sNum");
            if (sTitle != null && sTitle.isNotEmpty) {
              result.add(_normalizarTexto(sTitle));
            }
          }

          final arts = (ac['artigos'] as List<dynamic>?) ?? const [];
          for (final a in arts) {
            if (a is! Map<String, dynamic>) continue;
            final artNum = a['numero'];
            final caput = a['caput']?.toString() ?? '';
            final artEmenda = a['emenda']?.toString();
            final artValido = a['valido'] as bool? ?? true;

            // Separate the article label ("Art. X") as its own short bloco.
            // This prevents the drop-cap large letter from landing on the "A" of "Art."
            // and allows distinct styling for article names.
            String artLabel = "Art. $artNum";
            if (artEmenda != null && artEmenda.isNotEmpty) {
              artLabel += ' ($artEmenda)';
            }
            if (!artValido) artLabel = '- $artLabel';
            result.add(_normalizarTexto(artLabel));

            // Content bloco(s) for this article: caput + subs (these can receive drop cap on their first letter)
            final contentParts = <String>[];
            if (caput.isNotEmpty) {
              contentParts.add(_normalizarTexto(caput));
            }

            // Direct alíneas on the artigo
            final directAls = (a['alineas'] as List<dynamic>?) ?? const [];
            for (final al in directAls) {
              if (al is! Map<String, dynamic>) continue;
              final aNum = al['numero']?.toString() ?? '';
              final aTxt = al['texto']?.toString() ?? '';
              final aVal = al['valido'] as bool? ?? true;
              final aEm = al['emenda']?.toString();
              String aLine = '$aNum) $aTxt';
              if (aEm != null && aEm.isNotEmpty) aLine += ' ($aEm)';
              if (!aVal) aLine = '- $aLine';
              contentParts.add(_normalizarTexto(aLine));
            }

            final incs = (a['incisos'] as List<dynamic>?) ?? const [];
            for (final inc in incs) {
              if (inc is! Map<String, dynamic>) continue;
              final iNum = inc['numero']?.toString() ?? '';
              final iTxt = inc['texto']?.toString() ?? '';
              final iVal = inc['valido'] as bool? ?? true;
              final iEm = inc['emenda']?.toString();
              String iLine = '$iNum - $iTxt';
              if (iEm != null && iEm.isNotEmpty) iLine += ' ($iEm)';
              if (!iVal) iLine = '- $iLine';
              contentParts.add(_normalizarTexto(iLine));

              final als = (inc['alineas'] as List<dynamic>?) ?? const [];
              for (final al in als) {
                if (al is! Map<String, dynamic>) continue;
                final aNum = al['numero']?.toString() ?? '';
                final aTxt = al['texto']?.toString() ?? '';
                final aVal = al['valido'] as bool? ?? true;
                final aEm = al['emenda']?.toString();
                String aLine = '$aNum) $aTxt';
                if (aEm != null && aEm.isNotEmpty) aLine += ' ($aEm)';
                if (!aVal) aLine = '- $aLine';
                contentParts.add(_normalizarTexto(aLine));
              }
            }

            final pgs = (a['paragrafos'] as List<dynamic>?) ?? const [];
            for (final pg in pgs) {
              if (pg is! Map<String, dynamic>) continue;
              final pNum = pg['numero']?.toString() ?? '';
              final pTxt = pg['texto']?.toString() ?? '';
              final pVal = pg['valido'] as bool? ?? true;
              final pEm = pg['emenda']?.toString();
              String pLine = (pNum == 'único' || pNum.toLowerCase() == 'unico')
                  ? 'Parágrafo único - $pTxt'
                  : '§ $pNum - $pTxt';
              if (pEm != null && pEm.isNotEmpty) pLine += ' ($pEm)';
              if (!pVal) pLine = '- $pLine';
              contentParts.add(_normalizarTexto(pLine));
            }

            if (contentParts.isNotEmpty) {
              result.add(contentParts.join('\n\n'));
            }
          }
        }
      }
    }

    // ADCT
    final adct = json['adct'] as Map<String, dynamic>?;
    if (adct != null) {
      final adctArts = (adct['artigos'] as List<dynamic>?) ?? const [];
      if (adctArts.isNotEmpty) {
        result.add('Ato das Disposições Constitucionais Transitórias');
        for (final a in adctArts) {
          if (a is! Map<String, dynamic>) continue;
          // reuse similar logic as above but simplified (no caps)
          final artNum = a['numero'];
          final caput = a['caput']?.toString() ?? '';
          final artEmenda = a['emenda']?.toString();
          final artValido = a['valido'] as bool? ?? true;

          final parts = <String>[];
          String artHeader = "Art. $artNum $caput".trim();
          if (artEmenda != null && artEmenda.isNotEmpty) {
            artHeader += ' ($artEmenda)';
          }
          if (!artValido) artHeader = '- $artHeader';
          parts.add(_normalizarTexto(artHeader));

          final incs = (a['incisos'] as List<dynamic>?) ?? const [];
          for (final inc in incs) {
            if (inc is! Map<String, dynamic>) continue;
            final iNum = inc['numero']?.toString() ?? '';
            final iTxt = inc['texto']?.toString() ?? '';
            final iVal = inc['valido'] as bool? ?? true;
            String iLine = '$iNum - $iTxt';
            if (!iVal) iLine = '- $iLine';
            parts.add(_normalizarTexto(iLine));
          }

          final pgs = (a['paragrafos'] as List<dynamic>?) ?? const [];
          for (final pg in pgs) {
            if (pg is! Map<String, dynamic>) continue;
            final pNum = pg['numero']?.toString() ?? '';
            final pTxt = pg['texto']?.toString() ?? '';
            final pVal = pg['valido'] as bool? ?? true;
            String pLine = (pNum == 'único')
                ? 'Parágrafo único - $pTxt'
                : '§ $pNum - $pTxt';
            if (!pVal) pLine = '- $pLine';
            parts.add(_normalizarTexto(pLine));
          }

          if (parts.isNotEmpty) {
            result.add(parts.join('\n\n'));
          }
        }
      }
    }

    return result;
  }

  static List<LeiTextLinkRange> _linksFromNode(
    Map<String, dynamic> node,
    String? field,
    String renderedText,
  ) {
    final rawLinks = node['links'];
    if (rawLinks is! List<dynamic> || renderedText.isEmpty) return const [];

    final ranges = <LeiTextLinkRange>[];
    final seen = <String>{};

    for (final item in rawLinks) {
      if (item is! Map<String, dynamic>) continue;

      final linkField = item['campo']?.toString();
      if (field != null && linkField != null && linkField != field) continue;

      final linkText = _normalizarTexto(item['texto']?.toString() ?? '');
      final href = item['href']?.toString().trim() ?? '';
      if (linkText.isEmpty || href.isEmpty) continue;

      final startRaw = item['inicio'];
      final endRaw = item['fim'];
      if (startRaw is num && endRaw is num) {
        final start = startRaw.toInt();
        final end = endRaw.toInt();
        if (start >= 0 && end > start && end <= renderedText.length) {
          final key = '$start:$end:$href';
          if (seen.add(key)) {
            ranges.add(
              LeiTextLinkRange(startOffset: start, endOffset: end, href: href),
            );
          }
          continue;
        }
      }

      var cursor = 0;
      while (cursor < renderedText.length) {
        final start = renderedText.indexOf(linkText, cursor);
        if (start < 0) break;

        final end = start + linkText.length;
        final key = '$start:$end:$href';
        if (seen.add(key)) {
          ranges.add(
            LeiTextLinkRange(startOffset: start, endOffset: end, href: href),
          );
        }
        cursor = end;
      }
    }

    ranges.sort((a, b) => a.startOffset.compareTo(b.startOffset));
    return ranges;
  }

  static List<LeiTextLinkRange> _linksForPartes(List<_BlocoLeiParte> partes) {
    final ranges = <LeiTextLinkRange>[];
    var offset = 0;

    for (var i = 0; i < partes.length; i++) {
      final parte = partes[i];
      for (final link in parte.links) {
        ranges.add(
          LeiTextLinkRange(
            startOffset: offset + link.startOffset,
            endOffset: offset + link.endOffset,
            href: link.href,
          ),
        );
      }
      offset += parte.texto.length;
      if (i < partes.length - 1) offset += 2;
    }

    return ranges;
  }

  static void _setLinksForBloco(
    Map<int, List<LeiTextLinkRange>> linksPorBloco,
    int blocoIndex,
    List<LeiTextLinkRange> links,
  ) {
    if (links.isEmpty) return;
    linksPorBloco[blocoIndex] = List.unmodifiable(links);
  }
}

enum _TipoDispositivo { pena, paragrafo, inciso, alinea }

class _BlocoLeiParte {
  final String texto;
  final LeiAudioExplanation? audio;
  final bool isRubrica;
  final List<LeiTextLinkRange> links;

  const _BlocoLeiParte(this.texto, {this.audio, this.links = const []})
    : isRubrica = false;

  const _BlocoLeiParte.rubrica(this.texto, {this.links = const []})
    : audio = null,
      isRubrica = true;
}
