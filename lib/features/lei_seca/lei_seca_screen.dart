import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:papirar/features/lei_seca/models/lei_model.dart';
import 'package:papirar/features/lei_seca/widgets/lei_category_section.dart';

class LeiSecaScreen extends StatefulWidget {
  const LeiSecaScreen({super.key});

  @override
  State<LeiSecaScreen> createState() => _LeiSecaScreenState();
}

class _LeiSecaScreenState extends State<LeiSecaScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _query = '';
  bool _isSearchOpen = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final leis = _filteredLeis;

    final constLeis = leis
        .where((l) => l.categoria == 'Direito Constitucional')
        .toList();
    final penalLeis = leis
        .where((l) => l.categoria == 'Direito Penal')
        .toList();
    final civilLeis = leis
        .where(
          (l) => l.categoria == 'Direito Civil' || l.categoria == 'Estatutos',
        )
        .toList();
    final administrativoLeis = leis
        .where((l) => l.categoria == 'Administrativo')
        .toList();
    final direitosHumanosLeis = leis
        .where((l) => l.categoria == 'Direitos Humanos')
        .toList();
    final protecaoDadosLeis = leis
        .where((l) => l.categoria == 'Proteção de Dados')
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _LeiSearchField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              query: _query,
              isOpen: _isSearchOpen,
              onOpen: () {
                setState(() => _isSearchOpen = true);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _searchFocusNode.requestFocus();
                });
              },
              onChanged: (value) => setState(() => _query = value),
              onClear: () {
                _searchController.clear();
                setState(() {
                  _query = '';
                  _isSearchOpen = false;
                });
                _searchFocusNode.unfocus();
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                'Minha Legislação',
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: textColor.withValues(alpha: 0.8),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'VADE MECUM',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeOutCubic,
                child: Column(
                  key: ValueKey(_query.trim().toLowerCase()),
                  children: [
                    if (leis.isEmpty)
                      _EmptyLeiSearch(query: _query)
                    else ...[
                      if (constLeis.isNotEmpty) ...[
                        LeiCategorySection(
                          categoryTitle: 'Constitucional',
                          leis: constLeis,
                          overlayColor: Colors.blue,
                        ),
                        const SizedBox(height: 32),
                      ],
                      if (penalLeis.isNotEmpty) ...[
                        LeiCategorySection(
                          categoryTitle: 'Penal',
                          leis: penalLeis,
                          overlayColor: Colors.red,
                        ),
                        const SizedBox(height: 32),
                      ],
                      if (civilLeis.isNotEmpty) ...[
                        LeiCategorySection(
                          categoryTitle: 'Civil & Estatutos',
                          leis: civilLeis,
                          overlayColor: Colors.green,
                        ),
                        const SizedBox(height: 32),
                      ],
                      if (administrativoLeis.isNotEmpty) ...[
                        LeiCategorySection(
                          categoryTitle: 'Administrativo',
                          leis: administrativoLeis,
                          overlayColor: Colors.teal,
                        ),
                        const SizedBox(height: 32),
                      ],
                      if (direitosHumanosLeis.isNotEmpty) ...[
                        LeiCategorySection(
                          categoryTitle: 'Direitos Humanos',
                          leis: direitosHumanosLeis,
                          overlayColor: Colors.deepPurple,
                        ),
                        const SizedBox(height: 32),
                      ],
                      if (protecaoDadosLeis.isNotEmpty)
                        LeiCategorySection(
                          categoryTitle: 'Proteção de Dados',
                          leis: protecaoDadosLeis,
                          overlayColor: Colors.cyan,
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  List<LeiModel> get _filteredLeis {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return LeiModel.mockLeis;

    final words = query.split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
    return LeiModel.mockLeis.where((lei) {
      final text = '${lei.titulo} ${lei.sigla} ${lei.categoria}'.toLowerCase();
      return words.every(text.contains);
    }).toList();
  }
}

class _LeiSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String query;
  final bool isOpen;
  final VoidCallback onOpen;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _LeiSearchField({
    required this.controller,
    required this.focusNode,
    required this.query,
    required this.isOpen,
    required this.onOpen,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final expandedWidth = (MediaQuery.of(context).size.width - 40).clamp(
      260.0,
      360.0,
    );

    if (!isOpen) {
      return SizedBox(
        width: 48,
        height: 48,
        child: IconButton(
          key: const ValueKey('search-icon'),
          onPressed: onOpen,
          icon: Icon(
            Icons.search,
            size: 22,
            color: textColor.withValues(alpha: 0.76),
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: expandedWidth,
      height: 38,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: textColor.withValues(alpha: query.trim().isEmpty ? 0.10 : 0.22),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 160),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeOutCubic,
        child: TextField(
          key: const ValueKey('search-field'),
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
          decoration: InputDecoration(
            hintText: 'Buscar',
            hintStyle: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.42),
            ),
            prefixIcon: Icon(
              Icons.search,
              size: 20,
              color: textColor.withValues(alpha: 0.55),
            ),
            suffixIcon: IconButton(
              onPressed: onClear,
              icon: Icon(
                Icons.close,
                size: 18,
                color: textColor.withValues(alpha: 0.62),
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyLeiSearch extends StatelessWidget {
  final String query;

  const _EmptyLeiSearch({required this.query});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 42, 24, 68),
      child: Text(
        'Nenhum livro encontrado para "${query.trim()}".',
        textAlign: TextAlign.center,
        style: GoogleFonts.quicksand(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: textColor.withValues(alpha: 0.54),
        ),
      ),
    );
  }
}
