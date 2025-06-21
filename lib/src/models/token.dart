class MToken {
  final String text;
  final String? tag;
  final String? whitespace;
  String? phonemes;
  double? startTs;
  double? endTs;
  final Map<String, dynamic> extras;

  MToken({
    required this.text,
    this.tag,
    this.whitespace,
    this.phonemes,
    this.startTs,
    this.endTs,
    Map<String, dynamic>? extras,
  }) : extras = extras ?? {};

  MToken copyWith({
    String? text,
    String? tag,
    String? whitespace,
    String? phonemes,
    double? startTs,
    double? endTs,
    Map<String, dynamic>? extras,
  }) {
    return MToken(
      text: text ?? this.text,
      tag: tag ?? this.tag,
      whitespace: whitespace ?? this.whitespace,
      phonemes: phonemes ?? this.phonemes,
      startTs: startTs ?? this.startTs,
      endTs: endTs ?? this.endTs,
      extras: extras ?? Map.from(this.extras),
    );
  }

  @override
  String toString() {
    return 'MToken(text: $text, phonemes: $phonemes, tag: $tag)';
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'tag': tag,
      'whitespace': whitespace,
      'phonemes': phonemes,
      'start_ts': startTs,
      'end_ts': endTs,
      ...extras,
    };
  }

  factory MToken.fromJson(Map<String, dynamic> json) {
    final extras = Map<String, dynamic>.from(json);
    extras.removeWhere((key, value) => 
      ['text', 'tag', 'whitespace', 'phonemes', 'start_ts', 'end_ts'].contains(key));
    
    return MToken(
      text: json['text'] as String,
      tag: json['tag'] as String?,
      whitespace: json['whitespace'] as String?,
      phonemes: json['phonemes'] as String?,
      startTs: json['start_ts'] as double?,
      endTs: json['end_ts'] as double?,
      extras: extras,
    );
  }
}