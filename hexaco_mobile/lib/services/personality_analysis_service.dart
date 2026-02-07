import '../models/score.dart';

class FactorAnalysis {
  final String factor;
  final String nameKo;
  final String nameEn;
  final double score;
  final String summaryKo;
  final String summaryEn;
  final String detailKo;
  final String detailEn;
  final String emoji;

  const FactorAnalysis({
    required this.factor,
    required this.nameKo,
    required this.nameEn,
    required this.score,
    required this.summaryKo,
    required this.summaryEn,
    required this.detailKo,
    required this.detailEn,
    required this.emoji,
  });
}

class PersonalityAnalysisService {
  // 각 요인별 분석 데이터 반환
  static List<FactorAnalysis> getFactorAnalyses(Scores scores, bool isKo) {
    return [
      _getHonestyAnalysis(scores.h),
      _getEmotionalityAnalysis(scores.e),
      _getExtraversionAnalysis(scores.x),
      _getAgreeablenessAnalysis(scores.a),
      _getConscientiousnessAnalysis(scores.c),
      _getOpennessAnalysis(scores.o),
    ];
  }

  // 기존 호환성을 위한 메서드
  static String getAnalysis(Scores scores, bool isKo) {
    final analyses = getFactorAnalyses(scores, isKo);
    final buffer = StringBuffer();

    for (final analysis in analyses) {
      buffer.writeln(isKo ? analysis.summaryKo : analysis.summaryEn);
      buffer.writeln();
    }

    buffer.writeln(getOverallAnalysis(scores, isKo));
    return buffer.toString();
  }

  static String _getLevel(double score) {
    if (score >= 70) return 'high';
    if (score >= 40) return 'mid';
    return 'low';
  }

  // H - 정직-겸손 분석 (긍정적)
  static FactorAnalysis _getHonestyAnalysis(double score) {
    final level = _getLevel(score);

    String summaryKo, summaryEn, detailKo, detailEn;

    switch (level) {
      case 'high':
        summaryKo = '진정성 있는 관계를 만드는 사람';
        summaryEn = 'Someone who builds authentic relationships';
        detailKo = '당신은 진실된 마음으로 사람들을 대하는 특별한 능력이 있습니다. '
            '거짓 없이 솔직하게 표현하는 당신의 모습은 주변 사람들에게 신뢰와 안정감을 줍니다. '
            '물질적인 것보다 사람과의 진심 어린 교류를 더 소중히 여기는 당신은, '
            '삶에서 정말 중요한 것이 무엇인지 잘 알고 있습니다. '
            '겸손하고 꾸밈없는 태도는 당신만의 매력이며, 이것이 깊고 의미 있는 인간관계를 만드는 비결입니다.';
        detailEn = 'You have a special gift for connecting with people through genuine sincerity. '
            'Your honest and straightforward nature brings trust and comfort to those around you. '
            'Valuing heartfelt connections over material things shows you understand what truly matters in life. '
            'Your humble and authentic attitude is your unique charm, and it\'s the secret to building deep, meaningful relationships.';
        break;
      case 'mid':
        summaryKo = '균형 잡힌 처세술의 달인';
        summaryEn = 'A master of balanced social navigation';
        detailKo = '당신은 상황을 읽고 적절하게 대응하는 뛰어난 사회적 지능을 가지고 있습니다. '
            '진심을 담으면서도 상대방의 기분을 배려할 줄 아는 당신의 능력은 많은 사람들이 부러워하는 것입니다. '
            '현실적이면서도 따뜻한 마음을 잃지 않는 당신은 어떤 환경에서도 조화롭게 어울릴 수 있습니다. '
            '이런 유연함은 다양한 사람들과 좋은 관계를 맺는 데 큰 자산이 됩니다.';
        detailEn = 'You possess remarkable social intelligence, reading situations and responding appropriately. '
            'Your ability to be sincere while considering others\' feelings is something many admire. '
            'Realistic yet warm-hearted, you blend harmoniously into any environment. '
            'This flexibility is a great asset for building positive relationships with diverse people.';
        break;
      default:
        summaryKo = '목표를 향해 달려가는 추진력의 소유자';
        summaryEn = 'A driven achiever focused on goals';
        detailKo = '당신은 명확한 목표 의식과 이를 달성하기 위한 추진력을 가지고 있습니다. '
            '성공을 향한 열정이 강하고, 자신의 능력과 성취를 당당히 표현할 줄 압니다. '
            '이런 자신감과 야망은 리더십의 핵심 요소이며, 당신을 성장시키는 원동력입니다. '
            '경쟁 환경에서 빛나는 당신의 능력은 큰 성과를 이루어낼 잠재력을 보여줍니다.';
        detailEn = 'You have clear goal awareness and the drive to achieve them. '
            'Your passion for success is strong, and you confidently express your abilities and achievements. '
            'This confidence and ambition are core elements of leadership and the driving force behind your growth. '
            'Your ability to shine in competitive environments shows great potential for significant achievements.';
    }

    return FactorAnalysis(
      factor: 'H',
      nameKo: '정직-겸손',
      nameEn: 'Honesty-Humility',
      score: score,
      summaryKo: summaryKo,
      summaryEn: summaryEn,
      detailKo: detailKo,
      detailEn: detailEn,
      emoji: '💎',
    );
  }

  // E - 정서성 분석 (긍정적)
  static FactorAnalysis _getEmotionalityAnalysis(double score) {
    final level = _getLevel(score);

    String summaryKo, summaryEn, detailKo, detailEn;

    switch (level) {
      case 'high':
        summaryKo = '깊은 공감 능력의 소유자';
        summaryEn = 'A person with deep empathy';
        detailKo = '당신의 풍부한 감수성은 세상을 더 아름답게 느끼게 해주는 선물입니다. '
            '다른 사람의 마음을 깊이 이해하고 공감하는 능력은 당신을 훌륭한 친구이자 조력자로 만듭니다. '
            '감정을 솔직하게 표현하는 당신은 주변 사람들과 진정한 유대감을 형성합니다. '
            '이런 정서적 깊이는 예술, 창작, 그리고 사람을 돕는 모든 분야에서 빛을 발합니다.';
        detailEn = 'Your rich sensitivity is a gift that helps you experience the world more beautifully. '
            'Your ability to deeply understand and empathize with others makes you a wonderful friend and helper. '
            'Expressing emotions honestly, you form genuine bonds with those around you. '
            'This emotional depth shines in arts, creative work, and any field that involves helping people.';
        break;
      case 'mid':
        summaryKo = '감성과 이성의 조화로운 균형';
        summaryEn = 'Harmonious balance of emotion and reason';
        detailKo = '당신은 감정과 논리 사이에서 아름다운 균형을 이루고 있습니다. '
            '상황에 따라 공감하기도 하고, 차분하게 분석하기도 하는 당신의 유연함은 큰 강점입니다. '
            '필요할 때 정서적 지지를 주고받으면서도 독립적으로 문제를 해결할 수 있습니다. '
            '이런 균형감은 다양한 상황에서 현명한 판단을 내리는 데 도움이 됩니다.';
        detailEn = 'You achieve a beautiful balance between emotion and logic. '
            'Your flexibility to empathize or analyze calmly depending on the situation is a great strength. '
            'You can give and receive emotional support while independently solving problems when needed. '
            'This balance helps you make wise decisions in various situations.';
        break;
      default:
        summaryKo = '흔들림 없는 내면의 힘';
        summaryEn = 'Unwavering inner strength';
        detailKo = '당신의 정서적 안정감은 어떤 상황에서도 침착함을 유지하게 해주는 소중한 자산입니다. '
            '스트레스 상황에서도 흔들리지 않는 당신은 위기 상황에서 신뢰할 수 있는 사람입니다. '
            '논리적이고 이성적인 판단력은 복잡한 문제를 해결하는 데 큰 힘이 됩니다. '
            '독립적으로 어려움을 헤쳐나가는 당신의 강인함은 많은 사람들에게 귀감이 됩니다.';
        detailEn = 'Your emotional stability is a precious asset that helps you stay calm in any situation. '
            'Unshaken even under stress, you are someone people can rely on in crisis. '
            'Your logical and rational judgment is a great strength in solving complex problems. '
            'Your resilience in independently overcoming difficulties inspires many people.';
    }

    return FactorAnalysis(
      factor: 'E',
      nameKo: '정서성',
      nameEn: 'Emotionality',
      score: score,
      summaryKo: summaryKo,
      summaryEn: summaryEn,
      detailKo: detailKo,
      detailEn: detailEn,
      emoji: '💝',
    );
  }

  // X - 외향성 분석 (긍정적)
  static FactorAnalysis _getExtraversionAnalysis(double score) {
    final level = _getLevel(score);

    String summaryKo, summaryEn, detailKo, detailEn;

    switch (level) {
      case 'high':
        summaryKo = '사람들에게 에너지를 주는 태양 같은 존재';
        summaryEn = 'A sun-like presence energizing everyone';
        detailKo = '당신의 밝고 활기찬 에너지는 주변 사람들을 행복하게 만드는 힘이 있습니다. '
            '모임에서 자연스럽게 분위기를 이끄는 당신은 사람들을 하나로 모으는 특별한 재능이 있습니다. '
            '새로운 사람들과 쉽게 친해지고, 긍정적인 에너지를 전파하는 당신은 어디서나 환영받습니다. '
            '이런 사교성과 리더십은 팀을 이끌고 프로젝트를 성공시키는 데 핵심적인 역할을 합니다.';
        detailEn = 'Your bright and vibrant energy has the power to bring happiness to those around you. '
            'Naturally leading the atmosphere in gatherings, you have a special talent for bringing people together. '
            'Easily connecting with new people and spreading positive energy, you are welcomed everywhere. '
            'This sociability and leadership play a crucial role in leading teams and achieving project success.';
        break;
      case 'mid':
        summaryKo = '상황에 따라 빛나는 다재다능한 매력';
        summaryEn = 'Versatile charm that shines in any situation';
        detailKo = '당신은 사교적인 순간과 조용한 시간 모두를 즐길 줄 아는 균형 잡힌 사람입니다. '
            '필요할 때 리더십을 발휘하면서도, 혼자만의 시간도 소중히 여기는 당신의 유연함은 큰 강점입니다. '
            '다양한 사회적 상황에 자연스럽게 적응하며, 어떤 그룹에서도 편안하게 어울립니다. '
            '이런 적응력은 다양한 사람들과 깊이 있는 관계를 맺는 데 도움이 됩니다.';
        detailEn = 'You are a balanced person who enjoys both social moments and quiet time. '
            'Your flexibility to show leadership when needed while also valuing alone time is a great strength. '
            'Naturally adapting to various social situations, you blend comfortably into any group. '
            'This adaptability helps you build deep relationships with diverse people.';
        break;
      default:
        summaryKo = '깊이 있는 사색과 통찰의 소유자';
        summaryEn = 'A person of deep reflection and insight';
        detailKo = '당신의 조용하고 사려 깊은 성격은 세상을 더 깊이 이해하게 해줍니다. '
            '소수의 사람들과 깊은 관계를 맺는 당신은 진정한 우정이 무엇인지 잘 알고 있습니다. '
            '혼자 시간을 보내며 생각을 정리하는 것은 창의성과 통찰력의 원천입니다. '
            '경청하고 관찰하는 능력은 다른 사람들이 놓치는 것을 발견하게 해주는 특별한 강점입니다.';
        detailEn = 'Your quiet and thoughtful nature helps you understand the world more deeply. '
            'Building deep relationships with a few people, you truly understand what genuine friendship means. '
            'Spending time alone to organize thoughts is a source of creativity and insight. '
            'Your ability to listen and observe is a special strength that helps you notice what others miss.';
    }

    return FactorAnalysis(
      factor: 'X',
      nameKo: '외향성',
      nameEn: 'Extraversion',
      score: score,
      summaryKo: summaryKo,
      summaryEn: summaryEn,
      detailKo: detailKo,
      detailEn: detailEn,
      emoji: '✨',
    );
  }

  // A - 원만성 분석 (긍정적)
  static FactorAnalysis _getAgreeablenessAnalysis(double score) {
    final level = _getLevel(score);

    String summaryKo, summaryEn, detailKo, detailEn;

    switch (level) {
      case 'high':
        summaryKo = '조화로운 관계를 만드는 평화의 메신저';
        summaryEn = 'A messenger of peace creating harmony';
        detailKo = '당신의 따뜻하고 이해심 깊은 마음은 주변에 평화로운 분위기를 만듭니다. '
            '갈등 상황에서도 서로를 이해시키고 화합으로 이끄는 당신은 팀의 소중한 존재입니다. '
            '다른 사람의 관점을 존중하고 배려하는 능력은 깊은 신뢰 관계를 형성하게 해줍니다. '
            '당신의 관대함과 용서하는 마음은 주변 사람들에게 큰 위안과 힘이 됩니다.';
        detailEn = 'Your warm and understanding heart creates a peaceful atmosphere around you. '
            'Even in conflict, you help people understand each other and lead toward harmony, making you invaluable to any team. '
            'Your ability to respect and consider others\' perspectives helps form deep trusting relationships. '
            'Your generosity and forgiving nature are a great comfort and strength to those around you.';
        break;
      case 'mid':
        summaryKo = '배려와 원칙 사이의 현명한 균형';
        summaryEn = 'Wise balance between consideration and principles';
        detailKo = '당신은 타인을 배려하면서도 자신의 의견을 적절히 표현할 줄 아는 현명한 사람입니다. '
            '협력과 주장 사이에서 균형을 찾는 능력은 건강한 인간관계의 핵심입니다. '
            '상황을 파악하고 최선의 해결책을 찾는 당신의 판단력은 많은 사람들에게 신뢰를 줍니다. '
            '공정함을 추구하면서도 유연하게 대처하는 모습은 성숙한 인격의 표현입니다.';
        detailEn = 'You are wise, considering others while appropriately expressing your own opinions. '
            'Your ability to balance cooperation and assertion is key to healthy relationships. '
            'Your judgment in assessing situations and finding the best solutions earns many people\'s trust. '
            'Pursuing fairness while remaining flexible shows mature character.';
        break;
      default:
        summaryKo = '솔직한 피드백으로 성장을 돕는 사람';
        summaryEn = 'Someone who helps growth through honest feedback';
        detailKo = '당신은 필요한 말을 솔직하게 할 수 있는 용기를 가지고 있습니다. '
            '정의롭지 못한 상황에서 물러서지 않는 당신의 단호함은 존경받을 만한 특성입니다. '
            '비판적 사고력은 문제의 핵심을 파악하고 더 나은 방향을 제시하는 데 도움이 됩니다. '
            '당신의 솔직한 의견은 팀이 성장하고 발전하는 데 중요한 역할을 합니다.';
        detailEn = 'You have the courage to say what needs to be said honestly. '
            'Your firmness in not backing down from unjust situations is an admirable trait. '
            'Critical thinking helps identify core issues and suggest better directions. '
            'Your honest opinions play an important role in helping teams grow and develop.';
    }

    return FactorAnalysis(
      factor: 'A',
      nameKo: '원만성',
      nameEn: 'Agreeableness',
      score: score,
      summaryKo: summaryKo,
      summaryEn: summaryEn,
      detailKo: detailKo,
      detailEn: detailEn,
      emoji: '🤝',
    );
  }

  // C - 성실성 분석 (긍정적)
  static FactorAnalysis _getConscientiousnessAnalysis(double score) {
    final level = _getLevel(score);

    String summaryKo, summaryEn, detailKo, detailEn;

    switch (level) {
      case 'high':
        summaryKo = '꿈을 현실로 만드는 실행력의 달인';
        summaryEn = 'A master of execution turning dreams into reality';
        detailKo = '당신의 체계적이고 성실한 성격은 목표를 반드시 달성하게 만드는 힘입니다. '
            '계획을 세우고 꾸준히 실천하는 능력은 성공의 가장 확실한 비결입니다. '
            '세부사항까지 꼼꼼하게 챙기는 당신의 완벽주의는 높은 품질의 결과물을 만들어냅니다. '
            '약속을 지키고 책임감 있게 행동하는 당신은 모두가 믿고 의지할 수 있는 사람입니다.';
        detailEn = 'Your systematic and diligent nature is the power that ensures you achieve your goals. '
            'The ability to plan and consistently execute is the surest secret to success. '
            'Your perfectionism in attending to details produces high-quality results. '
            'Keeping promises and acting responsibly, you are someone everyone can trust and rely on.';
        break;
      case 'mid':
        summaryKo = '계획과 즉흥 사이의 멋진 균형';
        summaryEn = 'A wonderful balance between planning and spontaneity';
        detailKo = '당신은 계획적인 면과 유연한 면을 모두 가진 균형 잡힌 사람입니다. '
            '중요한 일에는 체계적으로 접근하면서도, 때로는 흐름에 맡기는 여유도 있습니다. '
            '상황에 따라 우선순위를 조정할 줄 아는 판단력은 효율적인 삶을 가능하게 합니다. '
            '이런 유연성 덕분에 예상치 못한 변화에도 잘 적응할 수 있습니다.';
        detailEn = 'You are a balanced person with both planned and flexible aspects. '
            'Approaching important tasks systematically while also going with the flow sometimes shows great wisdom. '
            'Your judgment in adjusting priorities based on circumstances enables an efficient life. '
            'This flexibility helps you adapt well to unexpected changes.';
        break;
      default:
        summaryKo = '자유로운 영혼의 창의적 탐험가';
        summaryEn = 'A creative explorer with a free spirit';
        detailKo = '당신의 자유로운 성격은 창의성과 즉흥성이 빛나게 합니다. '
            '엄격한 틀에 얽매이지 않는 당신은 새로운 가능성을 발견하는 데 탁월합니다. '
            '큰 그림을 보는 능력은 세부사항에 빠져 방향을 잃지 않게 해줍니다. '
            '유연하게 상황에 대응하는 적응력은 빠르게 변화하는 세상에서 큰 강점입니다.';
        detailEn = 'Your free-spirited nature lets creativity and spontaneity shine. '
            'Not bound by strict frameworks, you excel at discovering new possibilities. '
            'Your ability to see the big picture prevents getting lost in details. '
            'Your adaptability in responding flexibly to situations is a great strength in our rapidly changing world.';
    }

    return FactorAnalysis(
      factor: 'C',
      nameKo: '성실성',
      nameEn: 'Conscientiousness',
      score: score,
      summaryKo: summaryKo,
      summaryEn: summaryEn,
      detailKo: detailKo,
      detailEn: detailEn,
      emoji: '🎯',
    );
  }

  // O - 개방성 분석 (긍정적)
  static FactorAnalysis _getOpennessAnalysis(double score) {
    final level = _getLevel(score);

    String summaryKo, summaryEn, detailKo, detailEn;

    switch (level) {
      case 'high':
        summaryKo = '끝없는 호기심으로 세상을 탐험하는 사람';
        summaryEn = 'An explorer discovering the world with endless curiosity';
        detailKo = '당신의 풍부한 상상력과 호기심은 세상을 더 넓게 경험하게 해줍니다. '
            '새로운 아이디어와 문화에 열린 마음은 삶을 풍요롭게 만드는 원동력입니다. '
            '예술적 감수성과 지적 탐구심은 당신만의 독특한 시각을 형성합니다. '
            '틀에 박힌 생각을 넘어 창의적인 해결책을 찾아내는 능력은 혁신의 핵심입니다.';
        detailEn = 'Your rich imagination and curiosity help you experience the world more broadly. '
            'An open mind to new ideas and cultures is the driving force enriching your life. '
            'Artistic sensitivity and intellectual curiosity form your unique perspective. '
            'Your ability to find creative solutions beyond conventional thinking is at the heart of innovation.';
        break;
      case 'mid':
        summaryKo = '새로움과 익숙함 사이의 지혜로운 선택';
        summaryEn = 'Wise choices between novelty and familiarity';
        detailKo = '당신은 새로운 것을 탐구하면서도 검증된 것의 가치를 아는 현명한 사람입니다. '
            '창의성을 발휘하면서도 현실적인 제약을 고려하는 균형감각이 있습니다. '
            '상황에 따라 혁신과 전통 사이에서 최선의 선택을 할 줄 압니다. '
            '이런 실용적 지혜는 아이디어를 실제로 구현하는 데 큰 도움이 됩니다.';
        detailEn = 'You are wise, exploring new things while appreciating proven values. '
            'You have the balance to exercise creativity while considering practical constraints. '
            'You know how to make the best choices between innovation and tradition depending on the situation. '
            'This practical wisdom greatly helps in actually implementing ideas.';
        break;
      default:
        summaryKo = '안정적인 기반 위에 신뢰를 쌓는 사람';
        summaryEn = 'Someone building trust on a stable foundation';
        detailKo = '당신의 실용적이고 현실적인 관점은 확실한 결과를 만들어냅니다. '
            '검증된 방법을 신뢰하고 꾸준히 실천하는 것은 안정적인 성과의 비결입니다. '
            '구체적인 사실에 기반한 판단력은 신뢰할 수 있는 결정을 내리게 해줍니다. '
            '당신의 일관성과 예측 가능함은 팀에 안정감을 주는 소중한 특성입니다.';
        detailEn = 'Your practical and realistic perspective produces reliable results. '
            'Trusting proven methods and consistently practicing them is the secret to stable performance. '
            'Judgment based on concrete facts helps make trustworthy decisions. '
            'Your consistency and predictability are precious traits that bring stability to any team.';
    }

    return FactorAnalysis(
      factor: 'O',
      nameKo: '개방성',
      nameEn: 'Openness',
      score: score,
      summaryKo: summaryKo,
      summaryEn: summaryEn,
      detailKo: detailKo,
      detailEn: detailEn,
      emoji: '🌈',
    );
  }

  // 종합 분석 (긍정적, 1000자 정도)
  static String getOverallAnalysis(Scores scores, bool isKo) {
    final traits = <String>[];
    final strengths = <String>[];

    // 특징적인 요인들 식별 (모두 긍정적으로)
    if (scores.h >= 70) {
      traits.add(isKo ? '진정성 있는 마음' : 'authentic heart');
      strengths.add(isKo ? '신뢰할 수 있는 인간관계' : 'trustworthy relationships');
    } else if (scores.h < 40) {
      traits.add(isKo ? '목표 지향적 추진력' : 'goal-oriented drive');
      strengths.add(isKo ? '성취와 성공을 향한 열정' : 'passion for achievement');
    }

    if (scores.e >= 70) {
      traits.add(isKo ? '깊은 공감 능력' : 'deep empathy');
      strengths.add(isKo ? '따뜻한 인간적 교류' : 'warm human connections');
    } else if (scores.e < 40) {
      traits.add(isKo ? '흔들림 없는 안정감' : 'unwavering stability');
      strengths.add(isKo ? '위기 상황에서의 침착함' : 'composure in crisis');
    }

    if (scores.x >= 70) {
      traits.add(isKo ? '밝은 에너지' : 'bright energy');
      strengths.add(isKo ? '사람들을 하나로 모으는 힘' : 'power to unite people');
    } else if (scores.x < 40) {
      traits.add(isKo ? '깊이 있는 사색' : 'deep reflection');
      strengths.add(isKo ? '통찰력과 관찰력' : 'insight and observation');
    }

    if (scores.a >= 70) {
      traits.add(isKo ? '따뜻한 배려심' : 'warm consideration');
      strengths.add(isKo ? '조화로운 관계 형성' : 'harmonious relationships');
    } else if (scores.a < 40) {
      traits.add(isKo ? '솔직한 표현력' : 'honest expression');
      strengths.add(isKo ? '건설적인 피드백 능력' : 'constructive feedback');
    }

    if (scores.c >= 70) {
      traits.add(isKo ? '체계적인 실행력' : 'systematic execution');
      strengths.add(isKo ? '목표 달성의 확실성' : 'certain goal achievement');
    } else if (scores.c < 40) {
      traits.add(isKo ? '자유로운 창의성' : 'free creativity');
      strengths.add(isKo ? '유연한 적응력' : 'flexible adaptability');
    }

    if (scores.o >= 70) {
      traits.add(isKo ? '풍부한 호기심' : 'rich curiosity');
      strengths.add(isKo ? '혁신적인 아이디어' : 'innovative ideas');
    } else if (scores.o < 40) {
      traits.add(isKo ? '현실적인 판단력' : 'realistic judgment');
      strengths.add(isKo ? '안정적인 성과' : 'stable results');
    }

    if (traits.isEmpty) {
      traits.add(isKo ? '조화로운 균형감' : 'harmonious balance');
      strengths.add(isKo ? '다재다능한 적응력' : 'versatile adaptability');
    }

    final traitList = traits.join(', ');
    final strengthList = strengths.join(', ');

    if (isKo) {
      return '🌟 당신만의 특별한 성격 프로필 🌟\n\n'
          '축하합니다! 당신의 HEXACO 성격 분석이 완료되었습니다.\n\n'
          '당신은 $traitList을(를) 가진 특별한 사람입니다. '
          '이런 성격 조합은 $strengthList에서 빛을 발합니다.\n\n'
          '세상에는 완벽한 성격이란 없습니다. 모든 성향에는 고유한 강점이 있으며, '
          '당신의 성격도 그 자체로 충분히 가치 있고 아름답습니다. '
          '중요한 것은 자신의 특성을 이해하고, 그것을 삶에서 어떻게 활용하느냐입니다.\n\n'
          '당신의 강점을 더욱 발휘하고, 자신을 있는 그대로 사랑하세요. '
          '당신은 이미 충분히 훌륭한 사람입니다. '
          '오늘 이 테스트를 통해 자신을 돌아보는 시간을 가졌다는 것 자체가 '
          '자기 성장에 관심을 가진 긍정적인 모습입니다.\n\n'
          '앞으로의 여정에서 당신의 고유한 성격이 더욱 빛나기를 응원합니다! ✨\n\n'
          '※ 이 결과는 재미와 자기 이해를 위한 것이며, 당신의 무한한 가능성을 제한하지 않습니다.';
    } else {
      return '🌟 Your Special Personality Profile 🌟\n\n'
          'Congratulations! Your HEXACO personality analysis is complete.\n\n'
          'You are a special person with $traitList. '
          'This personality combination shines in $strengthList.\n\n'
          'There is no perfect personality in the world. Every trait has its unique strengths, '
          'and your personality is valuable and beautiful as it is. '
          'What matters is understanding your characteristics and how you utilize them in life.\n\n'
          'Embrace your strengths and love yourself as you are. '
          'You are already a wonderful person. '
          'Taking the time to reflect on yourself through this test today '
          'shows your positive interest in personal growth.\n\n'
          'We cheer for your unique personality to shine even brighter on your journey ahead! ✨\n\n'
          '※ These results are for fun and self-understanding, and do not limit your infinite potential.';
    }
  }
}
