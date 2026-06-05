import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:papirar/core/sync/app_sync_events.dart';
import 'package:papirar/core/system/system_ui_service.dart';
import 'package:papirar/domain/repositories/lei_reading_progress_repository.dart';
import 'package:papirar/features/lei_seca/controllers/lei_reading_controller.dart';
import 'package:papirar/features/lei_seca/di/lei_seca_module.dart';
import 'package:papirar/features/lei_seca/audio/lei_audio_explanation_player.dart';
import 'package:papirar/features/lei_seca/models/lei_model.dart';
import 'package:papirar/features/lei_seca/progress/di/lei_reading_progress_sync_module.dart';
import 'package:papirar/features/lei_seca/progress/domain/lei_reading_progress_sync_repository.dart';
import 'package:papirar/features/lei_seca/utils/lei_reading_styles.dart';
import 'package:papirar/features/lei_seca/widgets/reading/lei_reading_back_gesture.dart';
import 'package:papirar/features/lei_seca/widgets/reading/lei_reading_content_list.dart';
import 'package:papirar/features/lei_seca/widgets/reading/lei_reading_message_view.dart';
import 'package:papirar/features/lei_seca/widgets/reading_bottom_bar.dart';
import 'package:papirar/core/theme/app_theme_provider.dart';

class LeiReadingScreen extends ConsumerStatefulWidget {
  final LeiModel lei;

  const LeiReadingScreen({super.key, required this.lei});

  @override
  ConsumerState<LeiReadingScreen> createState() => _LeiReadingScreenState();
}

class _LeiReadingScreenState extends ConsumerState<LeiReadingScreen>
    with WidgetsBindingObserver {
  late final LeiReadingController _controller;
  final LeiReadingProgressRepository _progressRepo =
      leiReadingProgressRepository;
  final LeiReadingProgressSyncRepository _progressSyncRepo =
      LeiReadingProgressSyncModule.repository();
  final ScrollController _scrollController = ScrollController();

  bool _isBottomBarVisible = true;
  bool _scrollRestaurado = false;
  int _syncedStudySeconds = 0;
  Timer? _salvarScrollDebounce;
  Timer? _progressSyncTimer;

  String get _progressKey => widget.lei.jsonAsset ?? widget.lei.id;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemUiService.ocultarBarraNavegacaoAndroid();
    _controller = LeiReadingController(leiSecaRepository);
    _controller.addListener(_onControllerUpdate);
    _scrollController.addListener(_onScroll);
    _controller.carregar(widget.lei.jsonAsset);
    _progressSyncTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      unawaited(_sincronizarProgressoRemoto());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SystemUiService.ocultarBarraNavegacaoAndroid();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _salvarPosicaoLeitura();
      unawaited(_sincronizarProgressoRemoto());
    }
  }

  void _onControllerUpdate() {
    if (_controller.status == LeiReadingStatus.ready && !_scrollRestaurado) {
      _restaurarPosicaoLeitura();
    }
    if (mounted) setState(() {});
  }

  Future<void> _restaurarPosicaoLeitura() async {
    final offset = await _progressRepo.obterOffset(_progressKey);
    if (offset == null) {
      _scrollRestaurado = true;
      return;
    }

    void aplicar() {
      if (!_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      _scrollController.jumpTo(offset.clamp(0.0, max));
      _scrollRestaurado = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      aplicar();
      WidgetsBinding.instance.addPostFrameCallback((_) => aplicar());
    });
  }

  void _agendarSalvarPosicao() {
    _salvarScrollDebounce?.cancel();
    _salvarScrollDebounce = Timer(const Duration(milliseconds: 400), () {
      _salvarPosicaoLeitura();
    });
  }

  Future<void> _salvarPosicaoLeitura() async {
    if (!_scrollController.hasClients) return;
    if (_controller.status != LeiReadingStatus.ready) return;
    await _progressRepo.salvarOffset(_progressKey, _scrollController.offset);
  }

  Future<void> _sincronizarProgressoRemoto() async {
    if (!_scrollController.hasClients) return;
    if (_controller.status != LeiReadingStatus.ready) return;

    final deltaSeconds = _controller.secondsElapsed - _syncedStudySeconds;
    if (deltaSeconds <= 0) return;

    try {
      await _progressSyncRepo.saveSession(
        leiId: _controller.texto?.id ?? widget.lei.id,
        leiTitle: _controller.texto?.titulo ?? widget.lei.titulo,
        leiSigla: _controller.texto?.sigla ?? widget.lei.sigla,
        lastOffset: _scrollController.offset,
        additionalSeconds: deltaSeconds,
      );
      _syncedStudySeconds = _controller.secondsElapsed;
      AppSyncEvents.instance.notifyStudyActivityChanged();
    } catch (_) {
      // O progresso local continua salvo mesmo se a sincronização remota falhar.
    }
  }

  void _voltar() {
    _salvarScrollDebounce?.cancel();
    _salvarPosicaoLeitura();
    unawaited(_sincronizarProgressoRemoto());
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _salvarScrollDebounce?.cancel();
    _progressSyncTimer?.cancel();
    _salvarPosicaoLeitura();
    unawaited(_sincronizarProgressoRemoto());
    SystemUiService.restaurarBarrasSistema();
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    unawaited(LeiAudioExplanationPlayer.instance.stop());
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    _agendarSalvarPosicao();

    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse) {
      if (_isBottomBarVisible) setState(() => _isBottomBarVisible = false);
    } else if (direction == ScrollDirection.forward) {
      if (!_isBottomBarVisible) setState(() => _isBottomBarVisible = true);
    }
  }

  void _onToggleMode() {
    final wasListen = _controller.isListening;
    _controller.toggleMode();
    if (!wasListen && _controller.isListening && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Modo Listen: reprodução em áudio será disponibilizada em breve.',
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appThemeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF2F2F2);
    final textColor = isDark
        ? const Color(0xFFE0E0E0)
        : const Color(0xFF111111);
    final styles = LeiReadingStyles.fromTheme(
      textColor: textColor,
      textSize: _controller.textSize,
    );

    final titulo = _controller.texto?.titulo.isNotEmpty == true
        ? _controller.texto!.titulo
        : widget.lei.titulo;
    final sigla = _controller.texto?.sigla.isNotEmpty == true
        ? _controller.texto!.sigla
        : widget.lei.sigla;

    final bottomReserved = ReadingBottomBarLayout.reservedBottom(context);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          _salvarPosicaoLeitura();
          unawaited(_sincronizarProgressoRemoto());
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: LeiReadingBackGesture(
          onBack: _voltar,
          child: Stack(
            fit: StackFit.expand,
            children: [
              SafeArea(
                bottom: false,
                child: _buildBody(
                  context,
                  styles,
                  titulo,
                  sigla,
                  bottomReserved,
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                bottom: _isBottomBarVisible
                    ? 0
                    : -ReadingBottomBarLayout.reservedBottom(context),
                left: 0,
                right: 0,
                child: ValueListenableBuilder<int>(
                  valueListenable: _controller.secondsElapsedListenable,
                  builder: (context, _, __) {
                    return ReadingBottomBar(
                      isDark: isDark,
                      formattedTime: _controller.formattedStudyTime,
                      mode: _controller.mode,
                      textSize: _controller.textSize,
                      onToggleMode: _onToggleMode,
                      onToggleTheme: () =>
                          ref.read(appThemeModeProvider.notifier).toggle(),
                      onTextSizeChanged: _controller.setTextSize,
                      onCollapse: () =>
                          setState(() => _isBottomBarVisible = false),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    LeiReadingStyles styles,
    String titulo,
    String sigla,
    double bottomReserved,
  ) {
    switch (_controller.status) {
      case LeiReadingStatus.loading:
        return Center(
          child: CircularProgressIndicator(color: styles.textColor),
        );
      case LeiReadingStatus.unavailable:
      case LeiReadingStatus.error:
        return LeiReadingMessageView(
          mensagem: _controller.mensagemErro ?? 'Erro desconhecido.',
          styles: styles,
          onBack: _voltar,
        );
      case LeiReadingStatus.ready:
        return LeiReadingContentList(
          scrollController: _scrollController,
          blocos: _controller.texto!.blocos,
          audiosPorBloco: _controller.texto!.audiosPorBloco,
          leiId: _controller.texto!.id,
          sigla: sigla,
          titulo: titulo,
          styles: styles,
          bottomPadding: bottomReserved,
          onBack: _voltar,
          highlightsByPart: _controller.highlightsByPart,
          onHighlight: _controller.marcarTexto,
          onRemoveHighlight: _controller.desmarcarTexto,
        );
    }
  }
}
