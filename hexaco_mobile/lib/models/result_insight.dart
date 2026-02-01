class ResultInsight {
  final String factor;
  final int scoreMin;
  final int scoreMax;
  final String celebrityKo;
  final String celebrityEn;
  final String insightKo;
  final String insightEn;
  final String psychologyKo;
  final String psychologyEn;
  final String neuroscienceKo;
  final String neuroscienceEn;
  final List<String> tipsKo;
  final List<String> tipsEn;

  const ResultInsight({
    required this.factor,
    required this.scoreMin,
    required this.scoreMax,
    required this.celebrityKo,
    required this.celebrityEn,
    required this.insightKo,
    required this.insightEn,
    required this.psychologyKo,
    required this.psychologyEn,
    required this.neuroscienceKo,
    required this.neuroscienceEn,
    required this.tipsKo,
    required this.tipsEn,
  });

  factory ResultInsight.fromJson(Map<String, dynamic> json) {
    return ResultInsight(
      factor: json['factor'] as String,
      scoreMin: json['score_min'] as int,
      scoreMax: json['score_max'] as int,
      celebrityKo: json['celebrity_ko'] as String,
      celebrityEn: json['celebrity_en'] as String,
      insightKo: json['insight_ko'] as String,
      insightEn: json['insight_en'] as String,
      psychologyKo: json['psychology_ko'] as String,
      psychologyEn: json['psychology_en'] as String,
      neuroscienceKo: json['neuroscience_ko'] as String,
      neuroscienceEn: json['neuroscience_en'] as String,
      tipsKo: (json['tips_ko'] as List<dynamic>).cast<String>(),
      tipsEn: (json['tips_en'] as List<dynamic>).cast<String>(),
    );
  }

  bool matchesScore(double score) {
    return score >= scoreMin && score <= scoreMax;
  }

  String getCelebrity(bool isKo) => isKo ? celebrityKo : celebrityEn;
  String getInsight(bool isKo) => isKo ? insightKo : insightEn;
  String getPsychology(bool isKo) => isKo ? psychologyKo : psychologyEn;
  String getNeuroscience(bool isKo) => isKo ? neuroscienceKo : neuroscienceEn;
  List<String> getTips(bool isKo) => isKo ? tipsKo : tipsEn;
}
