import 'package:flutter/material.dart';
import 'package:papirar/features/lei_seca/utils/lei_reading_styles.dart';

class LeiReadingMessageView extends StatelessWidget {
  final String mensagem;
  final LeiReadingStyles styles;
  final VoidCallback onBack;

  const LeiReadingMessageView({
    super.key,
    required this.mensagem,
    required this.styles,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: styles.textColor, size: 20),
              onPressed: onBack,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                mensagem,
                textAlign: TextAlign.center,
                style: styles.body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}