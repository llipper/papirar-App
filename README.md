Arquitetura do App Concursos Flutter
Nome do Projeto: Papira Concursos 
Versão da Arquitetura: 1.0 (Junho/2026)
Plataformas: Android + iOS (Flutter)
Objetivo: App offline-first, extremamente performático, com foco em questões, simulados, lei seca com áudio e ranking em tempo real.
1. Visão Geral

Público-alvo: Concurseiros brasileiros
Funcionalidades principais:
Banco com milhares de questões
Filtro avançado (carreira,concurso, banca, ano,disciplina, topico, Assunto, dificuldade)
Simulados cronometrados
Lei seca com áudio explicativo
Desempenho detalhado + gráficos
Ranking por concurso / geral (tempo real)
Modo offline completo


2. Tecnologias e Pacotes (pubspec.yaml)
YAMLdependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Banco Local (melhor performance)
  isar: ^3.1.8
  isar_flutter_libs: ^3.1.8
  isar_generator: ^3.1.8

  # Backend + Auth + Realtime
  supabase_flutter: ^2.8.0

  # Áudio (background + lockscreen)
  just_audio: ^0.9.39
  audio_service: ^0.18.0
  audio_session: ^0.1.18

  # Navegação
  go_router: ^14.2.0

  # UI & Gráficos
  fl_chart: ^0.70.0
  google_fonts: ^6.2.1
  flutter_native_splash: ^2.4.4
  lottie: ^3.1.2

  # Utils
  shared_preferences: ^2.3.0
  connectivity_plus: ^6.1.0
  path_provider: ^2.1.4
  uuid: ^4.5.0
  intl: ^0.19.0
  flutter_dotenv: ^5.2.0
Comandos iniciais:
Bashflutter create concurso_papira
cd concurso_papira
flutter pub add [todos os pacotes acima]
flutter pub run build_runner build --delete-conflicting-outputs
3. Estrutura de Pastas (Clean Architecture + Feature-First)
textconcurso_papira/
├── android/
├── ios/
├── lib/
│   ├── core/
│   │   ├── config/              # env, constants, themes
│   │   ├── di/                  # Dependency Injection (Riverpod)
│   │   ├── extensions/
│   │   ├── theme/
│   │   ├── utils/
│   │   └── error/               # Failure, exceptions
│   │
│   ├── data/
│   │   ├── datasources/         # Isar + Supabase
│   │   ├── models/              # Isar models + DTOs
│   │   └── repositories/        # Implementações
│   │
│   ├── domain/
│   │   ├── entities/            # Entidades puras
│   │   ├── repositories/        # Interfaces
│   │   └── usecases/            # Casos de uso (opcional, mas recomendado)
│   │
│   ├── features/
│   │   ├── auth/
│   │   ├── home/
│   │   ├── questoes/
│   │   ├── simulados/
│   │   ├── lei_seca/
│   │   ├── ranking/
│   │   ├── desempenho/
│   │   └── perfil/
│   │
│   ├── shared/
│   │   ├── widgets/
│   │   ├── components/
│   │   └── services/
│   │
│   ├── providers/               # Riverpod providers globais
│   └── main.dart
│
├── assets/
│   ├── images/
│   ├── icons/
│   └── animations/
│
├── test/
└── ARCHITECTURE.md
4. Princípios de Arquitetura

Clean Architecture (camadas: Presentation → Domain → Data)
Offline-First (Isar como fonte principal)
Feature-First (cada feature é independente)
Riverpod 2.0 (com riverpod_annotation + build_runner)
Repository Pattern
Single Responsibility

5. Modelos Principais (exemplos)
lib/domain/entities/questao.dart
Dartclass Questao {
  final String id;
  final String enunciado;
  final List<String> alternativas;
  final int gabarito;
  final String materia;
  final String assunto;
  final String banca;
  final String carreira;
  final int ano;
  final String? comentario;
  final String? audioExplicacaoUrl;
  final DateTime criadoEm;
}
lib/domain/entities/lei_seca.dart
Dartclass LeiSeca {
  final String id;
  final String artigo;
  final String texto;
  final String materia;
  final String audioUrl;
  final bool isDownloaded;
}
6. State Management (Riverpod)

Todos os providers ficam em lib/providers/
Uso de AsyncNotifierProvider, NotifierProvider e StateProvider
Separação clara: questoes_provider.dart, simulado_provider.dart, etc.

7. Banco de Dados

Isar → principal (questões, simulados, progresso, lei seca)
Supabase → ranking em tempo real + sync de novos conteúdos
Sincronização automática quando online

8. Fluxo de Features (resumo)









































FeatureTela PrincipalProviders PrincipaisBanco LocalQuestõesLista + Filtro AvançadoquestoesFilterProviderIsarSimuladosLista + ExecuçãosimuladoProviderIsarLei SecaLista + PlayerleiSecaProvider + audioPlayerIsarRankingGlobal / Por ConcursorankingProvider (Supabase)-DesempenhoGráficos + EstatísticasdesempenhoProviderIsar
9. Áudio (Lei Seca)

just_audio + audio_service
Player global (background, notificação, lockscreen)
Download automático de áudios para offline

10. Navegação

GoRouter com ShellRoute
Rotas protegidas (auth)
Deep linking futuro

11. Próximos Passos Recomendados (faça nesta ordem)

Criar o projeto + adicionar pacotes
Configurar Isar + Supabase
Criar os models e Isar schemas
Montar o core/ e providers/
Implementar a feature Questões + Filtro Avançado (é o coração do app)# papirar-App
