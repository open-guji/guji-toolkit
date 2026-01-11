class PunctuationToken {
  final String word;
  final String entity;
  final double score;
  final int index;
  final int? start;
  final int? end;

  PunctuationToken({
    required this.word,
    required this.entity,
    required this.score,
    required this.index,
    this.start,
    this.end,
  });

  factory PunctuationToken.fromJson(Map<String, dynamic> json) {
    return PunctuationToken(
      word: json['word'] as String? ?? '',
      entity: json['entity'] as String? ?? json['label'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      index: json['index'] as int? ?? 0,
      start: json['start'] as int?,
      end: json['end'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'entity': entity,
      'score': score,
      'index': index,
      'start': start,
      'end': end,
    };
  }

  @override
  String toString() {
    return 'PunctuationToken(word: $word, entity: $entity, score: $score)';
  }
}
