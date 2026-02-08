class Scores {
  final double h;
  final double e;
  final double x;
  final double a;
  final double c;
  final double o;

  const Scores({
    required this.h,
    required this.e,
    required this.x,
    required this.a,
    required this.c,
    required this.o,
  });

  Map<String, double> toMap() {
    return {
      'H': h,
      'E': e,
      'X': x,
      'A': a,
      'C': c,
      'O': o,
    };
  }

  List<double> asList() => [h, e, x, a, c, o];

  factory Scores.fromMap(Map<String, double> map) {
    return Scores(
      h: map['H'] ?? 50,
      e: map['E'] ?? 50,
      x: map['X'] ?? 50,
      a: map['A'] ?? 50,
      c: map['C'] ?? 50,
      o: map['O'] ?? 50,
    );
  }
}
