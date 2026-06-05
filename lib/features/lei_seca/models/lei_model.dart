import 'package:papirar/features/lei_seca/constants/lei_assets.dart';

class LeiModel {
  final String id;
  final String titulo;
  final String sigla;
  final String categoria;
  final String ultimaAtualizacao;
  /// Caminho do asset JSON (`lib/features/lei_seca/json/...`). Null = sem texto ainda.
  final String? jsonAsset;

  LeiModel({
    required this.id,
    required this.titulo,
    required this.sigla,
    required this.categoria,
    required this.ultimaAtualizacao,
    this.jsonAsset,
  });

  static List<LeiModel> get mockLeis => [
        LeiModel(
          id: '1',
          titulo: 'Constituição Federal de 1988',
          sigla: 'CF/88',
          categoria: 'Direito Constitucional',
          ultimaAtualizacao: '2024',
          jsonAsset: LeiAssets.constituicao88,
        ),
        LeiModel(
          id: '2',
          titulo: 'Código Penal',
          sigla: 'CP',
          categoria: 'Direito Penal',
          ultimaAtualizacao: '2024',
          jsonAsset: LeiAssets.codigoPenal,
        ),
        LeiModel(
          id: '3',
          titulo: 'Código de Processo Penal',
          sigla: 'CPP',
          categoria: 'Direito Penal',
          ultimaAtualizacao: '2024',
          jsonAsset: LeiAssets.codigoProcessoPenal,
        ),
        LeiModel(
          id: '4',
          titulo: 'Código Penal Militar',
          sigla: 'CPM',
          categoria: 'Direito Penal',
          ultimaAtualizacao: '2024',
          jsonAsset: LeiAssets.codigoPenalMilitar,
        ),
        LeiModel(
          id: '5',
          titulo: 'Código de Processo Penal Militar',
          sigla: 'CPPM',
          categoria: 'Direito Penal',
          ultimaAtualizacao: '2024',
          jsonAsset: LeiAssets.codigoProcessoPenalMilitar,
        ),
        LeiModel(
          id: '6',
          titulo: 'Código de Trânsito Brasileiro',
          sigla: 'CTB',
          categoria: 'Direito Penal',
          ultimaAtualizacao: '2024',
          jsonAsset: LeiAssets.codigoTransitoBrasileiro,
        ),
        LeiModel(
          id: '7',
          titulo: 'Estatuto da Criança e do Adolescente',
          sigla: 'ECA',
          categoria: 'Estatutos',
          ultimaAtualizacao: '2024',
          jsonAsset: LeiAssets.estatutoCriancaAdolescente,
        ),
        LeiModel(
          id: '8',
          titulo: 'Estatuto do Desarmamento',
          sigla: 'Lei 10.826',
          categoria: 'Estatutos',
          ultimaAtualizacao: '2024',
          jsonAsset: LeiAssets.estatutoDesarmamento,
        ),
        LeiModel(
          id: '9',
          titulo: 'Estatuto dos Militares',
          sigla: 'Lei 6.880',
          categoria: 'Estatutos',
          ultimaAtualizacao: '2024',
          jsonAsset: LeiAssets.estatutoMilitares,
        ),
        LeiModel(
          id: '10',
          titulo: 'Lei 8.112 - Servidores Públicos Federais',
          sigla: 'Lei 8.112',
          categoria: 'Administrativo',
          ultimaAtualizacao: '2026',
          jsonAsset: LeiAssets.lei8112ServidoresPublicosFederais,
        ),
        LeiModel(
          id: '11',
          titulo: 'Lei 9.784 - Processo Administrativo Federal',
          sigla: 'Lei 9.784',
          categoria: 'Administrativo',
          ultimaAtualizacao: '2026',
          jsonAsset: LeiAssets.lei9784ProcessoAdministrativoFederal,
        ),
        LeiModel(
          id: '12',
          titulo: 'Lei 14.133 - Licitações e Contratos',
          sigla: 'Lei 14.133',
          categoria: 'Administrativo',
          ultimaAtualizacao: '2026',
          jsonAsset: LeiAssets.lei14133LicitacoesContratos,
        ),
        LeiModel(
          id: '13',
          titulo: 'Lei 8.429 - Improbidade Administrativa',
          sigla: 'Lei 8.429',
          categoria: 'Administrativo',
          ultimaAtualizacao: '2026',
          jsonAsset: LeiAssets.lei8429ImprobidadeAdministrativa,
        ),
        LeiModel(
          id: '14',
          titulo: 'Lei 12.527 - Acesso à Informação',
          sigla: 'LAI',
          categoria: 'Administrativo',
          ultimaAtualizacao: '2026',
          jsonAsset: LeiAssets.lei12527AcessoInformacao,
        ),
        LeiModel(
          id: '15',
          titulo: 'Lei 12.846 - Anticorrupção',
          sigla: 'Lei 12.846',
          categoria: 'Administrativo',
          ultimaAtualizacao: '2026',
          jsonAsset: LeiAssets.lei12846Anticorrupcao,
        ),
        LeiModel(
          id: '16',
          titulo: 'Lei 13.709 - LGPD',
          sigla: 'LGPD',
          categoria: 'Proteção de Dados',
          ultimaAtualizacao: '2026',
          jsonAsset: LeiAssets.lei13709Lgpd,
        ),
        LeiModel(
          id: '17',
          titulo: 'Convenção Americana de Direitos Humanos',
          sigla: 'CADH',
          categoria: 'Direitos Humanos',
          ultimaAtualizacao: '2026',
          jsonAsset: LeiAssets.convencaoAmericanaDireitosHumanos,
        ),
        LeiModel(
          id: '18',
          titulo: 'Pacto Internacional dos Direitos Civis e Políticos',
          sigla: 'PIDCP',
          categoria: 'Direitos Humanos',
          ultimaAtualizacao: '2026',
          jsonAsset: LeiAssets.pactoDireitosCivisPoliticos,
        ),
        LeiModel(
          id: '19',
          titulo: 'Pacto Internacional dos Direitos Econômicos, Sociais e Culturais',
          sigla: 'PIDESC',
          categoria: 'Direitos Humanos',
          ultimaAtualizacao: '2026',
          jsonAsset: LeiAssets.pactoDireitosEconomicosSociaisCulturais,
        ),
        LeiModel(
          id: '20',
          titulo: 'Convenção Contra a Tortura',
          sigla: 'CCT',
          categoria: 'Direitos Humanos',
          ultimaAtualizacao: '2026',
          jsonAsset: LeiAssets.convencaoContraTortura,
        ),
        LeiModel(
          id: '21',
          titulo: 'Convenção sobre os Direitos das Pessoas com Deficiência',
          sigla: 'CDPD',
          categoria: 'Direitos Humanos',
          ultimaAtualizacao: '2026',
          jsonAsset: LeiAssets.convencaoDireitosPessoasDeficiencia,
        ),
      ];
}
