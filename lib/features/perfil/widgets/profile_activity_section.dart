import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:papirar/features/lei_seca/highlights/domain/lei_highlight.dart';
import 'package:papirar/features/lei_seca/progress/domain/lei_reading_progress.dart';
import 'package:papirar/features/perfil/presentation/controllers/profile_activity_controller.dart';
import 'package:papirar/features/perfil/widgets/profile_colors.dart';

enum _ProfileActivityTab { leitura, marcacao, salvos }

class ProfileActivitySection extends StatefulWidget {
  final ProfileColors colors;

  const ProfileActivitySection({super.key, required this.colors});

  @override
  State<ProfileActivitySection> createState() => _ProfileActivitySectionState();
}

class _ProfileActivitySectionState extends State<ProfileActivitySection> {
  late final ProfileActivityController _controller;
  _ProfileActivityTab _selected = _ProfileActivityTab.leitura;

  @override
  void initState() {
    super.initState();
    _controller = ProfileActivityController()
      ..startSyncListener()
      ..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Column(
          children: [
            _ProfileTabs(
              colors: widget.colors,
              selected: _selected,
              onChanged: (tab) => setState(() => _selected = tab),
            ),
            const SizedBox(height: 14),
            if (_controller.isLoading)
              _ProfileLoadingState(colors: widget.colors)
            else if (_controller.errorMessage != null)
              _ProfileEmptyState(
                colors: widget.colors,
                icon: Icons.warning_amber_rounded,
                title: 'Atividades indisponíveis',
                message: _controller.errorMessage!,
              )
            else
              switch (_selected) {
                _ProfileActivityTab.leitura => _ReadingShelf(
                  colors: widget.colors,
                  readings: _controller.readings,
                ),
                _ProfileActivityTab.marcacao => _HighlightList(
                  colors: widget.colors,
                  highlights: _controller.highlights,
                ),
                _ProfileActivityTab.salvos => _ProfileEmptyState(
                  colors: widget.colors,
                  icon: Icons.download_for_offline_outlined,
                  title: 'Nenhum livro offline',
                  message:
                      'Os livros baixados para leitura offline vão aparecer aqui quando o recurso for ativado.',
                ),
              },
          ],
        );
      },
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  final ProfileColors colors;
  final _ProfileActivityTab selected;
  final ValueChanged<_ProfileActivityTab> onChanged;

  const _ProfileTabs({
    required this.colors,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const tabs = [
      (_ProfileActivityTab.leitura, 'Leitura'),
      (_ProfileActivityTab.marcacao, 'Marcação'),
      (_ProfileActivityTab.salvos, 'Salvos'),
    ];

    return Container(
      height: 42,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.line)),
      ),
      child: Row(
        children: [
          for (final tab in tabs)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onChanged(tab.$1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      tab.$2,
                      style: GoogleFonts.quicksand(
                        color: selected == tab.$1 ? colors.text : colors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 2,
                      width: selected == tab.$1 ? 34 : 0,
                      decoration: BoxDecoration(
                        color: colors.text,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReadingShelf extends StatelessWidget {
  final ProfileColors colors;
  final List<LeiReadingProgress> readings;

  const _ReadingShelf({required this.colors, required this.readings});

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return _ProfileEmptyState(
        colors: colors,
        icon: Icons.menu_book_rounded,
        title: 'Nenhuma leitura registrada',
        message:
            'Abra um livro da Lei Seca para começar a registrar progresso.',
      );
    }

    return Column(
      children: [
        for (final item in readings) ...[
          _ReadingBookTile(colors: colors, item: item),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ReadingBookTile extends StatelessWidget {
  final ProfileColors colors;
  final LeiReadingProgress item;

  const _ReadingBookTile({required this.colors, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.inner,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              item.leiSigla.isEmpty ? 'LS' : item.leiSigla,
              style: GoogleFonts.quicksand(
                color: colors.text,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.leiTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.quicksand(
                    color: colors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tempo estudado: ${_formatSeconds(item.totalSeconds)}',
                  style: GoogleFonts.quicksand(
                    color: colors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightList extends StatelessWidget {
  final ProfileColors colors;
  final List<LeiHighlight> highlights;

  const _HighlightList({required this.colors, required this.highlights});

  @override
  Widget build(BuildContext context) {
    if (highlights.isEmpty) {
      return _ProfileEmptyState(
        colors: colors,
        icon: Icons.bookmark_add_outlined,
        title: 'Nenhuma marcação',
        message: 'As partes marcadas no texto da Lei Seca vão aparecer aqui.',
      );
    }

    return Column(
      children: [
        for (final item in highlights.take(8)) ...[
          _HighlightTile(colors: colors, item: item),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _HighlightTile extends StatelessWidget {
  final ProfileColors colors;
  final LeiHighlight item;

  const _HighlightTile({required this.colors, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: item.color.backgroundColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_titleForLei(item.leiId)} • ${item.color.label}',
                  style: GoogleFonts.quicksand(
                    color: colors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.selectedText,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.quicksand(
                    color: colors.text,
                    fontSize: 13,
                    height: 1.28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileLoadingState extends StatelessWidget {
  final ProfileColors colors;

  const _ProfileLoadingState({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 22),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.line),
      ),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2, color: colors.text),
        ),
      ),
    );
  }
}

class _ProfileEmptyState extends StatelessWidget {
  final ProfileColors colors;
  final IconData icon;
  final String title;
  final String message;

  const _ProfileEmptyState({
    required this.colors,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.line),
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.inner,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colors.text, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.quicksand(
              color: colors.text,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              color: colors.muted,
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatSeconds(int seconds) {
  if (seconds < 60) return '${seconds}s';
  final minutes = seconds ~/ 60;
  if (minutes < 60) return '${minutes}min';
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  return rest == 0 ? '${hours}h' : '${hours}h ${rest}min';
}

String _titleForLei(String leiId) {
  return switch (leiId) {
    'constituicao88' => 'CF/88',
    'codigo_penal' => 'Código Penal',
    'codigo_processo_penal' => 'Código de Processo Penal',
    'codigo_penal_militar' => 'Código Penal Militar',
    'codigo_processo_penal_militar' => 'Código de Processo Penal Militar',
    'codigo_transito_brasileiro' => 'Código de Trânsito Brasileiro',
    'estatuto_crianca_adolescente' => 'ECA',
    'estatuto_desarmamento' => 'Estatuto do Desarmamento',
    'estatuto_militares' => 'Estatuto dos Militares',
    _ => 'Lei Seca',
  };
}
