import 'package:flutter/material.dart';
import 'package:papirar/features/lei_seca/audio/lei_audio_explanation.dart';
import 'package:papirar/features/lei_seca/audio/lei_audio_explanation_player.dart';
import 'package:papirar/features/lei_seca/config/lei_reading_layout_config.dart';

class LeiAudioExplanationButton extends StatefulWidget {
  final LeiAudioExplanation explanation;
  final double width;
  final double height;
  final double? iconSize;

  const LeiAudioExplanationButton({
    super.key,
    required this.explanation,
    this.width = LeiReadingLayoutConfig.audioButtonWidth,
    this.height = LeiReadingLayoutConfig.audioButtonHeight,
    this.iconSize = LeiReadingLayoutConfig.audioIconSize,
  });

  @override
  State<LeiAudioExplanationButton> createState() =>
      _LeiAudioExplanationButtonState();
}

class _LeiAudioExplanationButtonState extends State<LeiAudioExplanationButton> {
  bool _isLoading = false;

  Future<void> _play() async {
    setState(() => _isLoading = true);
    try {
      await LeiAudioExplanationPlayer.instance.toggle(widget.explanation.url);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final player = LeiAudioExplanationPlayer.instance;

    return Tooltip(
      message: widget.explanation.title,
      child: AnimatedBuilder(
        animation: player,
        builder: (context, _) {
          final isPlaying = player.isPlayingUrl(widget.explanation.url);

          return IconButton(
            visualDensity: LeiReadingLayoutConfig.audioButtonVisualDensity,
            constraints: BoxConstraints.tightFor(
              width: widget.width,
              height: widget.height,
            ),
            padding: LeiReadingLayoutConfig.audioButtonPadding,
            onPressed: _isLoading ? null : _play,
            icon: _isLoading
                ? SizedBox(
                    width: LeiReadingLayoutConfig.audioLoadingSize,
                    height: LeiReadingLayoutConfig.audioLoadingSize,
                    child: CircularProgressIndicator(
                      strokeWidth:
                          LeiReadingLayoutConfig.audioLoadingStrokeWidth,
                      color: color,
                    ),
                  )
                : Icon(
                    isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                    color: color,
                    size: widget.iconSize,
                  ),
          );
        },
      ),
    );
  }
}
