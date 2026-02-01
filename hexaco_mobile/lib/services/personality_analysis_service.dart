import '../models/score.dart';

class PersonalityAnalysisService {
  // 6가지 요인 x 3단계(높음/중간/낮음) x 한국어/영어 = 36개 기본 분석
  // 추가로 조합 분석과 종합 분석 포함

  static String getAnalysis(Scores scores, bool isKo) {
    final buffer = StringBuffer();

    // 각 요인별 분석
    buffer.writeln(isKo ? '[ 요인별 성격 분석 ]' : '[ Factor Analysis ]');
    buffer.writeln();
    buffer.writeln(_getHonestyAnalysis(scores.h, isKo));
    buffer.writeln();
    buffer.writeln(_getEmotionalityAnalysis(scores.e, isKo));
    buffer.writeln();
    buffer.writeln(_getExtraversionAnalysis(scores.x, isKo));
    buffer.writeln();
    buffer.writeln(_getAgreeablenessAnalysis(scores.a, isKo));
    buffer.writeln();
    buffer.writeln(_getConscientiousnessAnalysis(scores.c, isKo));
    buffer.writeln();
    buffer.writeln(_getOpennessAnalysis(scores.o, isKo));
    buffer.writeln();

    // 종합 분석
    buffer.writeln(isKo ? '[ 종합 성격 분석 ]' : '[ Overall Analysis ]');
    buffer.writeln();
    buffer.writeln(_getOverallAnalysis(scores, isKo));

    return buffer.toString();
  }

  static String _getLevel(double score) {
    if (score >= 70) return 'high';
    if (score >= 40) return 'mid';
    return 'low';
  }

  // H - 정직-겸손 분석
  static String _getHonestyAnalysis(double score, bool isKo) {
    final level = _getLevel(score);
    if (isKo) {
      switch (level) {
        case 'high':
          return '** H (정직-겸손): ${score.toStringAsFixed(1)}% **\n'
              '당신은 매우 정직하고 겸손한 성향을 가지고 있습니다. 타인을 속이거나 조종하는 것을 싫어하며, '
              '물질적 이익보다 도덕적 가치를 중요시합니다. 특권의식이 낮고 자신을 과시하지 않으며, '
              '공정함과 진실성을 삶의 중요한 원칙으로 삼습니다. 다만, 때로는 자신의 성취를 적절히 '
              '표현하는 것도 필요할 수 있습니다.';
        case 'mid':
          return '** H (정직-겸손): ${score.toStringAsFixed(1)}% **\n'
              '당신은 상황에 따라 정직함과 전략적 사고 사이에서 균형을 찾습니다. 기본적으로 '
              '정직하지만, 필요할 때는 유연하게 대처할 줄 압니다. 물질적 성공과 도덕적 가치 '
              '모두를 중요하게 여기며, 자신의 능력을 적절히 표현할 줄 압니다.';
        default:
          return '** H (정직-겸손): ${score.toStringAsFixed(1)}% **\n'
              '당신은 목표 달성을 위해 전략적으로 행동하는 편입니다. 사회적 지위와 물질적 성공에 '
              '관심이 높고, 자신의 능력과 성취를 적극적으로 표현합니다. 경쟁 상황에서 우위를 점하기 '
              '위해 노력하며, 실용적인 관점에서 상황을 판단합니다.';
      }
    } else {
      switch (level) {
        case 'high':
          return '** H (Honesty-Humility): ${score.toStringAsFixed(1)}% **\n'
              'You have a very honest and humble disposition. You dislike deceiving or manipulating others '
              'and value moral principles over material gains. You have low entitlement, avoid showing off, '
              'and consider fairness and sincerity as important life principles.';
        case 'mid':
          return '** H (Honesty-Humility): ${score.toStringAsFixed(1)}% **\n'
              'You balance honesty with strategic thinking depending on the situation. While fundamentally '
              'honest, you can adapt flexibly when needed. You value both material success and moral values, '
              'and know how to appropriately express your abilities.';
        default:
          return '** H (Honesty-Humility): ${score.toStringAsFixed(1)}% **\n'
              'You tend to act strategically to achieve your goals. You have high interest in social status '
              'and material success, actively expressing your abilities and achievements. You strive to gain '
              'advantage in competitive situations and judge situations from a practical perspective.';
      }
    }
  }

  // E - 정서성 분석
  static String _getEmotionalityAnalysis(double score, bool isKo) {
    final level = _getLevel(score);
    if (isKo) {
      switch (level) {
        case 'high':
          return '** E (정서성): ${score.toStringAsFixed(1)}% **\n'
              '당신은 감정이 풍부하고 민감한 편입니다. 타인의 감정에 쉽게 공감하며, 정서적 유대를 '
              '중요시합니다. 스트레스 상황에서 불안을 느끼기 쉽고, 위험한 상황을 피하려는 경향이 있습니다. '
              '가까운 사람들에게 정서적 지지를 구하며, 감정 표현이 자연스럽습니다.';
        case 'mid':
          return '** E (정서성): ${score.toStringAsFixed(1)}% **\n'
              '당신은 감정과 이성 사이에서 적절한 균형을 유지합니다. 타인의 감정에 공감하면서도 '
              '객관적인 판단을 할 수 있습니다. 스트레스 상황에서도 비교적 안정적으로 대처하며, '
              '필요할 때 정서적 지지를 구하면서도 독립적인 면도 있습니다.';
        default:
          return '** E (정서성): ${score.toStringAsFixed(1)}% **\n'
              '당신은 감정적으로 안정적이고 침착한 편입니다. 스트레스 상황에서도 쉽게 동요하지 않으며, '
              '위험을 두려워하지 않습니다. 독립적으로 문제를 해결하는 것을 선호하고, 감정보다는 '
              '논리적 사고를 중시합니다. 타인에게 정서적 의존을 잘 하지 않습니다.';
      }
    } else {
      switch (level) {
        case 'high':
          return '** E (Emotionality): ${score.toStringAsFixed(1)}% **\n'
              'You are emotionally rich and sensitive. You easily empathize with others\' feelings and value '
              'emotional bonds. You tend to feel anxious in stressful situations and avoid dangerous situations. '
              'You seek emotional support from close ones and express emotions naturally.';
        case 'mid':
          return '** E (Emotionality): ${score.toStringAsFixed(1)}% **\n'
              'You maintain a good balance between emotion and reason. You can empathize with others while '
              'making objective judgments. You handle stress relatively well and seek emotional support '
              'when needed while maintaining independence.';
        default:
          return '** E (Emotionality): ${score.toStringAsFixed(1)}% **\n'
              'You are emotionally stable and calm. You don\'t easily get shaken in stressful situations '
              'and are not afraid of risks. You prefer solving problems independently and value logical '
              'thinking over emotions. You rarely depend emotionally on others.';
      }
    }
  }

  // X - 외향성 분석
  static String _getExtraversionAnalysis(double score, bool isKo) {
    final level = _getLevel(score);
    if (isKo) {
      switch (level) {
        case 'high':
          return '** X (외향성): ${score.toStringAsFixed(1)}% **\n'
              '당신은 사교적이고 활기찬 성격의 소유자입니다. 모임에서 중심이 되는 것을 즐기고, '
              '새로운 사람들을 만나는 것을 좋아합니다. 자신감이 높고 리더십을 발휘하며, '
              '다양한 활동에 적극적으로 참여합니다. 에너지가 넘치고 긍정적인 감정을 자주 경험합니다.';
        case 'mid':
          return '** X (외향성): ${score.toStringAsFixed(1)}% **\n'
              '당신은 상황에 따라 외향적이기도 하고 내향적이기도 합니다. 사교 활동을 즐기면서도 '
              '혼자만의 시간도 필요로 합니다. 필요할 때 리더십을 발휘할 수 있지만, 항상 주목받고 '
              '싶어하지는 않습니다. 유연하게 다양한 사회적 상황에 적응합니다.';
        default:
          return '** X (외향성): ${score.toStringAsFixed(1)}% **\n'
              '당신은 조용하고 내성적인 성향을 가지고 있습니다. 소수의 깊은 관계를 선호하며, '
              '혼자서 시간을 보내는 것을 즐깁니다. 사회적 상황에서 에너지가 소모되는 느낌을 받고, '
              '조용한 활동을 선호합니다. 관찰력이 뛰어나고 깊이 있는 대화를 좋아합니다.';
      }
    } else {
      switch (level) {
        case 'high':
          return '** X (Extraversion): ${score.toStringAsFixed(1)}% **\n'
              'You have a sociable and vibrant personality. You enjoy being the center of gatherings '
              'and love meeting new people. You have high confidence, demonstrate leadership, and '
              'actively participate in various activities. You are energetic and often experience positive emotions.';
        case 'mid':
          return '** X (Extraversion): ${score.toStringAsFixed(1)}% **\n'
              'You can be both extroverted and introverted depending on the situation. You enjoy social '
              'activities but also need alone time. You can show leadership when needed but don\'t always '
              'want to be the center of attention. You adapt flexibly to various social situations.';
        default:
          return '** X (Extraversion): ${score.toStringAsFixed(1)}% **\n'
              'You have a quiet and introverted disposition. You prefer a few deep relationships and '
              'enjoy spending time alone. Social situations can be draining, and you prefer quiet activities. '
              'You have excellent observation skills and enjoy deep conversations.';
      }
    }
  }

  // A - 원만성 분석
  static String _getAgreeablenessAnalysis(double score, bool isKo) {
    final level = _getLevel(score);
    if (isKo) {
      switch (level) {
        case 'high':
          return '** A (원만성): ${score.toStringAsFixed(1)}% **\n'
              '당신은 타인을 잘 용서하고 관대한 성격입니다. 갈등을 피하고 조화로운 관계를 추구하며, '
              '비판보다는 칭찬을 선호합니다. 타인의 관점을 이해하려 노력하고, 협력적인 분위기를 만듭니다. '
              '때로는 자신의 의견을 더 적극적으로 표현하는 것도 필요할 수 있습니다.';
        case 'mid':
          return '** A (원만성): ${score.toStringAsFixed(1)}% **\n'
              '당신은 협력과 경쟁 사이에서 균형을 유지합니다. 타인을 배려하면서도 필요할 때는 '
              '자신의 의견을 분명히 표현합니다. 갈등 상황에서 상황을 파악하고 적절히 대응하며, '
              '공정한 해결책을 찾으려 합니다.';
        default:
          return '** A (원만성): ${score.toStringAsFixed(1)}% **\n'
              '당신은 자신의 의견을 명확하게 표현하고 비판적 사고를 중시합니다. 불공정한 상황에서 '
              '쉽게 물러서지 않으며, 때로는 갈등을 통해 더 나은 결과를 이끌어냅니다. '
              '실수에 대해 엄격한 기준을 적용하고, 솔직한 피드백을 제공합니다.';
      }
    } else {
      switch (level) {
        case 'high':
          return '** A (Agreeableness): ${score.toStringAsFixed(1)}% **\n'
              'You are forgiving and generous. You avoid conflict and seek harmonious relationships, '
              'preferring praise over criticism. You try to understand others\' perspectives and create '
              'a cooperative atmosphere. Sometimes expressing your opinions more assertively may be helpful.';
        case 'mid':
          return '** A (Agreeableness): ${score.toStringAsFixed(1)}% **\n'
              'You balance cooperation and competition. While considerate of others, you clearly express '
              'your opinions when needed. In conflict situations, you assess the situation and respond '
              'appropriately, seeking fair solutions.';
        default:
          return '** A (Agreeableness): ${score.toStringAsFixed(1)}% **\n'
              'You clearly express your opinions and value critical thinking. You don\'t easily back down '
              'in unfair situations and sometimes achieve better results through conflict. You apply strict '
              'standards to mistakes and provide honest feedback.';
      }
    }
  }

  // C - 성실성 분석
  static String _getConscientiousnessAnalysis(double score, bool isKo) {
    final level = _getLevel(score);
    if (isKo) {
      switch (level) {
        case 'high':
          return '** C (성실성): ${score.toStringAsFixed(1)}% **\n'
              '당신은 체계적이고 꼼꼼한 성격입니다. 계획을 세우고 그에 따라 행동하며, 세부사항에 '
              '주의를 기울입니다. 높은 기준을 가지고 일하며, 약속과 마감을 중요시합니다. '
              '목표 달성을 위해 끈기 있게 노력하고, 정리정돈과 효율성을 추구합니다.';
        case 'mid':
          return '** C (성실성): ${score.toStringAsFixed(1)}% **\n'
              '당신은 계획과 유연성 사이에서 균형을 유지합니다. 중요한 일에는 체계적으로 접근하지만, '
              '때로는 즉흥적으로 행동하기도 합니다. 마감을 지키려 노력하면서도 '
              '상황에 따라 우선순위를 조정할 줄 압니다.';
        default:
          return '** C (성실성): ${score.toStringAsFixed(1)}% **\n'
              '당신은 자유롭고 유연한 성격입니다. 엄격한 계획보다는 상황에 따라 행동하는 것을 선호하며, '
              '즉흥성과 창의성을 발휘합니다. 세부사항보다는 큰 그림에 집중하고, '
              '다양한 가능성을 열어두는 것을 좋아합니다.';
      }
    } else {
      switch (level) {
        case 'high':
          return '** C (Conscientiousness): ${score.toStringAsFixed(1)}% **\n'
              'You are organized and meticulous. You make plans and act accordingly, paying attention to '
              'details. You work with high standards and value commitments and deadlines. You persistently '
              'work toward goals and pursue organization and efficiency.';
        case 'mid':
          return '** C (Conscientiousness): ${score.toStringAsFixed(1)}% **\n'
              'You balance planning and flexibility. You approach important tasks systematically but '
              'sometimes act spontaneously. You try to meet deadlines while knowing how to adjust '
              'priorities based on circumstances.';
        default:
          return '** C (Conscientiousness): ${score.toStringAsFixed(1)}% **\n'
              'You have a free and flexible personality. You prefer acting based on circumstances rather '
              'than strict plans, exercising spontaneity and creativity. You focus on the big picture '
              'rather than details and like keeping various possibilities open.';
      }
    }
  }

  // O - 개방성 분석
  static String _getOpennessAnalysis(double score, bool isKo) {
    final level = _getLevel(score);
    if (isKo) {
      switch (level) {
        case 'high':
          return '** O (개방성): ${score.toStringAsFixed(1)}% **\n'
              '당신은 호기심이 많고 창의적인 성격입니다. 새로운 아이디어와 경험에 열려 있으며, '
              '예술과 지적 활동을 즐깁니다. 추상적인 개념에 관심이 많고, 상상력이 풍부합니다. '
              '다양한 관점을 탐구하고, 전통적인 방식에 의문을 제기하기도 합니다.';
        case 'mid':
          return '** O (개방성): ${score.toStringAsFixed(1)}% **\n'
              '당신은 새로운 것과 익숙한 것 사이에서 균형을 유지합니다. 새로운 아이디어에 열려 있으면서도 '
              '검증된 방법을 존중합니다. 창의성을 발휘하면서도 현실적인 측면도 고려하며, '
              '상황에 따라 전통과 혁신 사이에서 적절히 선택합니다.';
        default:
          return '** O (개방성): ${score.toStringAsFixed(1)}% **\n'
              '당신은 실용적이고 전통을 중시하는 성격입니다. 검증된 방법과 구체적인 사실을 선호하며, '
              '안정성과 예측 가능성을 중요시합니다. 현실적인 해결책을 찾는 것을 좋아하고, '
              '익숙한 환경에서 편안함을 느낍니다.';
      }
    } else {
      switch (level) {
        case 'high':
          return '** O (Openness): ${score.toStringAsFixed(1)}% **\n'
              'You are curious and creative. You are open to new ideas and experiences, enjoying art '
              'and intellectual activities. You are interested in abstract concepts and have a rich imagination. '
              'You explore various perspectives and sometimes question traditional ways.';
        case 'mid':
          return '** O (Openness): ${score.toStringAsFixed(1)}% **\n'
              'You balance between the new and the familiar. While open to new ideas, you also respect '
              'proven methods. You exercise creativity while considering practical aspects, choosing '
              'appropriately between tradition and innovation based on the situation.';
        default:
          return '** O (Openness): ${score.toStringAsFixed(1)}% **\n'
              'You are practical and value tradition. You prefer proven methods and concrete facts, '
              'valuing stability and predictability. You like finding realistic solutions and feel '
              'comfortable in familiar environments.';
      }
    }
  }

  // 종합 분석
  static String _getOverallAnalysis(Scores scores, bool isKo) {
    final List<String> traits = [];

    // 특징적인 요인들 식별
    if (scores.h >= 70) traits.add(isKo ? '높은 도덕성' : 'high morality');
    if (scores.h < 40) traits.add(isKo ? '전략적 사고' : 'strategic thinking');
    if (scores.e >= 70) traits.add(isKo ? '풍부한 감성' : 'rich emotionality');
    if (scores.e < 40) traits.add(isKo ? '정서적 안정감' : 'emotional stability');
    if (scores.x >= 70) traits.add(isKo ? '사교적 성향' : 'sociability');
    if (scores.x < 40) traits.add(isKo ? '내향적 깊이' : 'introverted depth');
    if (scores.a >= 70) traits.add(isKo ? '협력적 태도' : 'cooperative attitude');
    if (scores.a < 40) traits.add(isKo ? '비판적 사고' : 'critical thinking');
    if (scores.c >= 70) traits.add(isKo ? '체계적 성실함' : 'systematic diligence');
    if (scores.c < 40) traits.add(isKo ? '유연한 적응력' : 'flexible adaptability');
    if (scores.o >= 70) traits.add(isKo ? '창의적 개방성' : 'creative openness');
    if (scores.o < 40) traits.add(isKo ? '실용적 현실감' : 'practical realism');

    final traitList = traits.isEmpty
        ? (isKo ? '균형 잡힌 성향' : 'balanced traits')
        : traits.join(', ');

    if (isKo) {
      return '당신의 HEXACO 프로필은 $traitList을(를) 특징으로 합니다.\n\n'
          '이러한 성격 조합은 다양한 상황에서 고유한 강점을 발휘할 수 있습니다. '
          '자신의 성향을 이해하고 활용하면, 대인관계와 목표 달성에 있어 더 효과적으로 '
          '행동할 수 있습니다.\n\n'
          '성격은 고정된 것이 아니라 경험과 노력에 따라 발전할 수 있습니다. '
          '강점을 더욱 발휘하고, 성장이 필요한 영역에서는 의식적인 노력을 기울여 보세요.';
    } else {
      return 'Your HEXACO profile is characterized by $traitList.\n\n'
          'This combination of personality traits can demonstrate unique strengths in various situations. '
          'Understanding and utilizing your tendencies can help you act more effectively in relationships '
          'and achieving goals.\n\n'
          'Personality is not fixed and can develop through experience and effort. '
          'Try to leverage your strengths more and make conscious efforts in areas that need growth.';
    }
  }
}
