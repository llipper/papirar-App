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
      final dto = await compute(_parseDto, jsonString);
      _cache[assetPath] = dto;
      return dto;
    } catch (e) {
      debugPrint('LeiTextoAssetDatasource: $assetPath — $e');
      return null;
    }
  }

  static LeiTextoJsonDto _parseDto(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    return LeiTextoJsonDto.fromJson(data);
  }
}