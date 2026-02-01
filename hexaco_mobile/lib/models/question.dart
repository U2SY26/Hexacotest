class Question {
  final int id;
  final String factor;
  final int facet;
  final bool reverse;
  final int tier;
  final String ko;
  final String en;
  final String? koExample;
  final String? enExample;
  final String? illustration;

  const Question({
    required this.id,
    required this.factor,
    required this.facet,
    required this.reverse,
    required this.tier,
    required this.ko,
    required this.en,
    this.koExample,
    this.enExample,
    this.illustration,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      factor: json['factor'] as String,
      facet: json['facet'] as int,
      reverse: json['reverse'] as bool,
      tier: json['tier'] as int,
      ko: json['ko'] as String,
      en: json['en'] as String,
      koExample: json['ko_example'] as String?,
      enExample: json['en_example'] as String?,
      illustration: json['illustration'] as String?,
    );
  }
}
