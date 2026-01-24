class TypeProfile {
  final String id;
  final String nameKo;
  final String nameEn;
  final String descriptionKo;
  final String descriptionEn;
  final Map<String, double> scores;

  const TypeProfile({
    required this.id,
    required this.nameKo,
    required this.nameEn,
    required this.descriptionKo,
    required this.descriptionEn,
    required this.scores,
  });

  factory TypeProfile.fromJson(Map<String, dynamic> json) {
    final rawScores = json['scores'] as Map<String, dynamic>;
    return TypeProfile(
      id: json['id'] as String,
      nameKo: json['nameKo'] as String,
      nameEn: json['nameEn'] as String,
      descriptionKo: json['descriptionKo'] as String,
      descriptionEn: json['descriptionEn'] as String,
      scores: rawScores.map((key, value) => MapEntry(key, (value as num).toDouble())),
    );
  }
}
