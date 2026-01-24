import 'dart:math';

import '../models/score.dart';
import '../models/type_profile.dart';
import '../constants.dart';

class TypeMatch {
  final TypeProfile profile;
  final int similarity;

  const TypeMatch({
    required this.profile,
    required this.similarity,
  });
}

class RecommendationService {
  static int _similarity(List<double> user, List<double> target) {
    double sum = 0;
    for (var i = 0; i < user.length; i += 1) {
      sum += pow(user[i] - target[i], 2) as double;
    }
    final distance = sqrt(sum);
    final maxDistance = sqrt(6 * pow(100, 2));
    return ((1 - distance / maxDistance) * 100).round();
  }

  static List<TypeMatch> topMatches(Scores scores, List<TypeProfile> profiles, {int count = 3}) {
    final user = scores.asList();
    final matches = profiles.map((profile) {
      final target = factorOrder.map((f) => profile.scores[f] ?? 50).toList();
      final similarity = _similarity(user, target);
      return TypeMatch(profile: profile, similarity: similarity);
    }).toList();

    matches.sort((a, b) => b.similarity.compareTo(a.similarity));
    return matches.take(count).toList(growable: false);
  }
}
