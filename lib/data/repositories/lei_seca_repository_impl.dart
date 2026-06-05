import 'package:papirar/data/datasources/lei_texto_asset_datasource.dart';
import 'package:papirar/data/mappers/lei_texto_mapper.dart';
import 'package:papirar/domain/entities/lei_texto.dart';
import 'package:papirar/domain/repositories/lei_seca_repository.dart';

class LeiSecaRepositoryImpl implements LeiSecaRepository {
  final LeiTextoAssetDatasource _datasource;

  LeiSecaRepositoryImpl({LeiTextoAssetDatasource? datasource})
      : _datasource = datasource ?? LeiTextoAssetDatasource();

  @override
  Future<LeiTexto?> carregarTexto(String assetPath) async {
    final dto = await _datasource.carregar(assetPath);
    if (dto == null || dto.blocos.isEmpty) return null;
    return LeiTextoMapper.fromDto(dto);
  }
}