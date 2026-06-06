import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:papirar/data/models/lei_texto_json_dto.dart';

/// Carrega JSON de leitura dos assets (parse em isolate + cache).
class LeiTextoAssetDatasource {
  final Map<String, LeiTextoJsonDto> _cache = {};

  Future<LeiTextoJsonDto?> carregar(String assetPath) async {
    if (assetPath.isEmpty) return null;

    final cached = _cache[assetPath];
    if (cached != null) return cached;

    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final audioJsonString = await _loadAudioCatalog(assetPath);
      final dto = await compute(_parseDto, [jsonString, audioJsonString]);
      _cache[assetPath] = dto;

      return dto;
    } catch (e) {
      debugPrint('LeiTextoAssetDatasource: $assetPath — $e');
      // Debug: dump what json assets are actually in the bundle
      try {
        final manifest = await rootBundle.loadString('AssetManifest.json');
        final manifestMap = jsonDecode(manifest) as Map<String, dynamic>;
        final jsonAssets = manifestMap.keys
            .where((k) => k.contains('json/') && k.endsWith('.json'))
            .toList();
        debugPrint(
          'Bundled JSON assets (${jsonAssets.length} total): ${jsonAssets.take(10).join(', ')}...',
        );
        if (!manifestMap.containsKey(assetPath)) {
          debugPrint('>>> $assetPath NOT FOUND in AssetManifest.json');
        }
      } catch (manifestErr) {
        debugPrint('Could not load AssetManifest: $manifestErr');
      }
      return null;
    }
  }

  Future<String?> _loadAudioCatalog(String assetPath) async {
    final audioAssetPath = _audioAssetPath(assetPath);
    if (audioAssetPath == null) return null;

    try {
      return await rootBundle.loadString(audioAssetPath);
    } catch (_) {
      return null;
    }
  }

  String? _audioAssetPath(String assetPath) {
    const extension = '.json';
    if (!assetPath.endsWith(extension)) return null;
    return assetPath.replaceRange(
      assetPath.length - extension.length,
      assetPath.length,
      '_audio.json',
    );
  }

  static LeiTextoJsonDto _parseDto(List<String?> jsonStrings) {
    final data = jsonDecode(jsonStrings.first ?? '') as Map<String, dynamic>;
    final audioCatalogString = jsonStrings.length > 1 ? jsonStrings[1] : null;

    return LeiTextoJsonDto.fromJson(
      data,
      audioCatalog: _parseAudioCatalog(audioCatalogString),
    );
  }

  static Map<String, dynamic>? _parseAudioCatalog(String? jsonString) {
    if (jsonString == null || jsonString.trim().isEmpty) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
