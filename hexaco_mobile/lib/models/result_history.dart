class ResultHistoryEntry {
  final String id;
  final int timestamp;
  final Map<String, double> scores;
  final String topMatchId;
  final int similarity;
  final String pin;
  final int testVersion;

  const ResultHistoryEntry({
    required this.id,
    required this.timestamp,
    required this.scores,
    required this.topMatchId,
    required this.similarity,
    required this.pin,
    this.testVersion = 60,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp,
      'scores': scores,
      'topMatchId': topMatchId,
      'similarity': similarity,
      'pin': pin,
      'testVersion': testVersion,
    };
  }

  factory ResultHistoryEntry.fromJson(Map<String, dynamic> json) {
    final rawScores = json['scores'] as Map<String, dynamic>;
    return ResultHistoryEntry(
      id: json['id'] as String,
      timestamp: json['timestamp'] as int,
      scores: rawScores.map((key, value) => MapEntry(key, (value as num).toDouble())),
      topMatchId: json['topMatchId'] as String,
      similarity: json['similarity'] as int,
      pin: json['pin'] as String? ?? '',
      testVersion: json['testVersion'] as int? ?? 60,
    );
  }
}
