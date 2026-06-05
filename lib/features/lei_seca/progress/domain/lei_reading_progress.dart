class LeiReadingProgress {
  final String leiId;
  final String leiTitle;
  final String leiSigla;
  final double lastOffset;
  final int totalSeconds;
  final DateTime updatedAt;

  const LeiReadingProgress({
    required this.leiId,
    required this.leiTitle,
    required this.leiSigla,
    required this.lastOffset,
    required this.totalSeconds,
    required this.updatedAt,
  });
}
