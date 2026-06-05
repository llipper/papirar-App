import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papirar/data/models/lei_texto_json_dto.dart';
import 'package:papirar/domain/entities/lei_audio_explanation.dart';
import 'package:papirar/features/lei_seca/constants/lei_assets.dart';
import 'package:papirar/features/lei_seca/utils/lei_reading_styles.dart';
import 'package:papirar/features/lei_seca/widgets/reading/lei_audio_explanation_button.dart';
import 'package:papirar/features/lei_seca/widgets/reading/lei_reading_bloco_item.dart';

/// Garante que cada JSON em assets carrega como o app carrega (sem rodar scripts).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final assets = <String, String>{
    'CF/88': LeiAssets.constituicao88,
    'CP': LeiAssets.codigoPenal,
    'CPP': LeiAssets.codigoProcessoPenal,
    'CPM': LeiAssets.codigoPenalMilitar,
    'CPPM': LeiAssets.codigoProcessoPenalMilitar,
    'CTB': LeiAssets.codigoTransitoBrasileiro,
    'ECA': LeiAssets.estatutoCriancaAdolescente,
    'ED': LeiAssets.estatutoDesarmamento,
    'EM': LeiAssets.estatutoMilitares,
  };

  for (final entry in assets.entries) {
    test('asset ${entry.key} parseia e tem blocos', () async {
      final raw = await rootBundle.loadString(entry.value);
      expect(raw.isNotEmpty, isTrue);

      final map = jsonDecode(raw) as Map<String, dynamic>;
      final dto = LeiTextoJsonDto.fromJson(map);

      expect(dto.id, isNotEmpty);
      expect(dto.titulo, isNotEmpty);
      expect(dto.blocos, isNotEmpty);
      expect(dto.blocos.every((b) => b.trim().isNotEmpty), isTrue);
    });

    test('asset ${entry.key} mostra todos os artigos do JSON', () async {
      final raw = await rootBundle.loadString(entry.value);
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final dto = LeiTextoJsonDto.fromJson(map);

      final totalJson = _contarArtigos(map);
      final totalDto = dto.blocos.where(_ehRotuloArtigo).length;

      expect(totalDto, totalJson);
    });

    test('asset ${entry.key} mostra subtítulos dos artigos', () async {
      final raw = await rootBundle.loadString(entry.value);
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final dto = LeiTextoJsonDto.fromJson(map);

      final subtitulos = _coletarSubtitulos(map);
      for (final subtitulo in subtitulos) {
        expect(
          dto.blocos.any((bloco) => bloco.contains(subtitulo)),
          isTrue,
          reason: 'Subtítulo ausente: $subtitulo',
        );
      }
    });
  }

  test(
    'Código Penal preserva áudios de incisos e parágrafos do Art. 7º',
    () async {
      final raw = await rootBundle.loadString(LeiAssets.codigoPenal);
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final dto = LeiTextoJsonDto.fromJson(map);

      final incisoIIndex = dto.blocos.indexWhere(
        (bloco) => bloco.startsWith('I os crimes:'),
      );
      final paragrafo1Index = dto.blocos.indexWhere(
        (bloco) => bloco.startsWith('§ 1º Nos casos do inciso I'),
      );

      expect(incisoIIndex, isNonNegative);
      expect(paragrafo1Index, isNonNegative);
      expect(dto.audiosPorBloco[incisoIIndex]?.id, 'codigopenal-art-7-i');
      expect(dto.audiosPorBloco[paragrafo1Index]?.id, 'codigopenal-art-7-1');
    },
  );

  test('Código Penal posiciona rubrica do artigo abaixo do rótulo', () async {
    final raw = await rootBundle.loadString(LeiAssets.codigoPenal);
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final dto = LeiTextoJsonDto.fromJson(map);

    final art2Index = dto.blocos.indexOf('Art. 2º');

    expect(art2Index, isNonNegative);
    expect(dto.blocos[art2Index + 1], startsWith('Lei penal no tempo\n\n'));
  });

  test('rubrica de dispositivo fica agrupada ao inciso com áudio', () {
    final dto = LeiTextoJsonDto.fromJson({
      'titulo': 'Lei teste',
      'fonte': 'teste',
      'divisoes': [
        {
          'rotulo': 'PARTE TESTE',
          'artigos': [
            {
              'numero': '1º',
              'rotulo': 'Art. 1º',
              'caput': 'Texto do caput.',
              'incisos': [
                {
                  'numero': 'I',
                  'rubrica': 'Rubrica do inciso',
                  'texto': 'texto do inciso.',
                  'audio': {
                    'id': 'audio-inciso-i',
                    'url': 'https://example.com/audio.mp3',
                  },
                },
              ],
            },
          ],
        },
      ],
    });

    final blocoIndex = dto.blocos.indexOf(
      'Rubrica do inciso\n\nI - texto do inciso.',
    );

    expect(blocoIndex, isNonNegative);
    expect(dto.blocos.contains('Rubrica do inciso'), isFalse);
    expect(dto.audiosPorBloco[blocoIndex]?.id, 'audio-inciso-i');
  });

  testWidgets('áudio de inciso romano com rubrica aparece na rubrica', (
    tester,
  ) async {
    final styles = LeiReadingStyles.fromTheme(
      textColor: Colors.black,
      textSize: 16,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LeiReadingBlocoItem(
            bloco: 'Crime consumado\n\nI texto do inciso.',
            useDropCap: false,
            styles: styles,
            leiId: 'lei_teste',
            audioExplanation: const LeiAudioExplanation(
              id: 'audio-inciso-i',
              title: 'Explicação',
              url: 'https://example.com/audio.mp3',
            ),
          ),
        ),
      ),
    );

    final rubrica = find.ancestor(
      of: find.text('Crime consumado'),
      matching: find.byType(Wrap),
    );
    final inciso = find.ancestor(
      of: find.text('I texto do inciso.'),
      matching: find.byType(Wrap),
    );

    expect(
      find.descendant(
        of: rubrica,
        matching: find.byType(LeiAudioExplanationButton),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: inciso,
        matching: find.byType(LeiAudioExplanationButton),
      ),
      findsNothing,
    );
  });
}

int _contarArtigos(dynamic value) {
  if (value is List<dynamic>) {
    return value.fold<int>(0, (sum, item) => sum + _contarArtigos(item));
  }
  if (value is! Map<String, dynamic>) return 0;

  var total = 0;
  final artigos = value['artigos'];
  if (artigos is List<dynamic>) total += artigos.length;
  for (final child in value.values) {
    total += _contarArtigos(child);
  }
  return total;
}

bool _ehRotuloArtigo(String bloco) {
  return RegExp(r'^-?\s*Art\.\s*\S+').hasMatch(bloco.trim());
}

List<String> _coletarSubtitulos(dynamic value) {
  if (value is List<dynamic>) {
    return value.expand(_coletarSubtitulos).toList();
  }
  if (value is! Map<String, dynamic>) return const [];

  final result = <String>[];
  final subtitulos = value['subtitulos'];
  if (subtitulos is List<dynamic>) {
    for (final item in subtitulos) {
      final texto = item is Map<String, dynamic> ? item['texto'] : item;
      final normalizado = texto?.toString().trim() ?? '';
      if (normalizado.isNotEmpty) result.add(normalizado);
    }
  }
  for (final child in value.values) {
    result.addAll(_coletarSubtitulos(child));
  }
  return result;
}
