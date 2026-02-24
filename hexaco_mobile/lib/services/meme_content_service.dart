import '../models/score.dart';

/// 성격 타이틀 데이터
class PersonalityTitle {
  final String titleKo;
  final String titleEn;
  final String emoji;
  final String descriptionKo;
  final String descriptionEn;

  const PersonalityTitle({
    required this.titleKo,
    required this.titleEn,
    required this.emoji,
    required this.descriptionKo,
    required this.descriptionEn,
  });
}

/// 밈 문구 데이터
class MemeQuote {
  final String factor;
  final String quoteKo;
  final String quoteEn;
  final String emoji;

  const MemeQuote({
    required this.factor,
    required this.quoteKo,
    required this.quoteEn,
    required this.emoji,
  });
}

/// 캐릭터 매칭 데이터
class CharacterMatch {
  final String nameKo;
  final String nameEn;
  final String source; // 드라마/영화/애니 등
  final String emoji;
  final String reasonKo;
  final String reasonEn;

  const CharacterMatch({
    required this.nameKo,
    required this.nameEn,
    required this.source,
    required this.emoji,
    required this.reasonKo,
    required this.reasonEn,
  });
}

/// MBTI 매칭 데이터
class MBTIMatch {
  final String mbti;
  final String descriptionKo;
  final String descriptionEn;

  const MBTIMatch({
    required this.mbti,
    required this.descriptionKo,
    required this.descriptionEn,
  });
}

class MemeContentService {
  /// 점수 조합에 따른 캐치한 성격 타이틀 반환
  static PersonalityTitle getPersonalityTitle(Scores scores) {
    // 가장 높은 2개 요인 찾기
    final scoreMap = scores.toMap();
    final sortedFactors = scoreMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top1 = sortedFactors[0].key;

    // 특수 조합 체크
    if (scores.h >= 70 && scores.a >= 70) {
      return const PersonalityTitle(
        titleKo: '천사표 인간',
        titleEn: 'Angel Among Us',
        emoji: '😇',
        descriptionKo: '정직하고 배려심 깊은 당신은 모두의 버팀목',
        descriptionEn: 'Honest and caring, you are everyone\'s pillar',
      );
    }

    if (scores.x >= 70 && scores.o >= 70) {
      return const PersonalityTitle(
        titleKo: '인싸 크리에이터',
        titleEn: 'Social Creator',
        emoji: '🎪',
        descriptionKo: '어디서든 주목받는 창의적 에너지',
        descriptionEn: 'Creative energy that shines everywhere',
      );
    }

    if (scores.c >= 70 && scores.h >= 70) {
      return const PersonalityTitle(
        titleKo: '믿음직한 MVP',
        titleEn: 'Reliable MVP',
        emoji: '🏆',
        descriptionKo: '성실하고 정직한 당신은 팀의 핵심',
        descriptionEn: 'Diligent and honest, you are the team\'s core',
      );
    }

    if (scores.e >= 70 && scores.a >= 70) {
      return const PersonalityTitle(
        titleKo: '힐링 요정',
        titleEn: 'Healing Fairy',
        emoji: '🧚',
        descriptionKo: '따뜻한 공감으로 모두를 치유하는 존재',
        descriptionEn: 'A being who heals everyone with warm empathy',
      );
    }

    if (scores.x >= 70 && scores.a >= 70) {
      return const PersonalityTitle(
        titleKo: '분위기 메이커',
        titleEn: 'Mood Maker',
        emoji: '🎉',
        descriptionKo: '밝은 에너지로 모든 모임을 즐겁게!',
        descriptionEn: 'Making every gathering fun with bright energy!',
      );
    }

    if (scores.c >= 70 && scores.o >= 70) {
      return const PersonalityTitle(
        titleKo: '비전 실행가',
        titleEn: 'Vision Executor',
        emoji: '🚀',
        descriptionKo: '꿈을 현실로 만드는 전략적 창의가',
        descriptionEn: 'A strategic creative who makes dreams reality',
      );
    }

    if (scores.e < 40 && scores.c >= 70) {
      return const PersonalityTitle(
        titleKo: '냉철한 프로',
        titleEn: 'Cool Professional',
        emoji: '🎯',
        descriptionKo: '감정에 휘둘리지 않는 철저한 실행력',
        descriptionEn: 'Thorough execution unswayed by emotions',
      );
    }

    if (scores.x < 40 && scores.o >= 70) {
      return const PersonalityTitle(
        titleKo: '몽상가 천재',
        titleEn: 'Dreamer Genius',
        emoji: '💭',
        descriptionKo: '조용히 세상을 바꾸는 아이디어 뱅크',
        descriptionEn: 'Quietly changing the world with ideas',
      );
    }

    if (scores.h < 40 && scores.c >= 70) {
      return const PersonalityTitle(
        titleKo: '야망의 전략가',
        titleEn: 'Ambitious Strategist',
        emoji: '♟️',
        descriptionKo: '목표를 위해 모든 것을 계획하는 당신',
        descriptionEn: 'Planning everything for your goals',
      );
    }

    if (scores.a < 40 && scores.x >= 70) {
      return const PersonalityTitle(
        titleKo: '카리스마 리더',
        titleEn: 'Charismatic Leader',
        emoji: '👑',
        descriptionKo: '주장이 뚜렷한 당당한 리더십',
        descriptionEn: 'Confident leadership with clear opinions',
      );
    }

    // 단일 최고 요인 기반 타이틀
    switch (top1) {
      case 'H':
        return const PersonalityTitle(
          titleKo: '진심 100% 인간',
          titleEn: '100% Genuine Soul',
          emoji: '💎',
          descriptionKo: '거짓 없이 살아가는 맑은 영혼',
          descriptionEn: 'A pure soul living without pretense',
        );
      case 'E':
        return const PersonalityTitle(
          titleKo: '공감왕',
          titleEn: 'Empathy King',
          emoji: '💝',
          descriptionKo: '모든 감정을 함께 느끼는 섬세한 존재',
          descriptionEn: 'A sensitive being feeling all emotions together',
        );
      case 'X':
        return const PersonalityTitle(
          titleKo: '에너지 폭탄',
          titleEn: 'Energy Bomb',
          emoji: '⚡',
          descriptionKo: '어디서든 활력을 불어넣는 존재',
          descriptionEn: 'A being that brings energy everywhere',
        );
      case 'A':
        return const PersonalityTitle(
          titleKo: '평화의 수호자',
          titleEn: 'Peace Guardian',
          emoji: '🕊️',
          descriptionKo: '갈등을 조율하는 조화의 달인',
          descriptionEn: 'A master of harmony who mediates conflicts',
        );
      case 'C':
        return const PersonalityTitle(
          titleKo: '계획의 신',
          titleEn: 'Planning God',
          emoji: '📋',
          descriptionKo: '모든 것을 체계적으로 완수하는 당신',
          descriptionEn: 'You who systematically complete everything',
        );
      case 'O':
        return const PersonalityTitle(
          titleKo: '상상력 부자',
          titleEn: 'Imagination Rich',
          emoji: '🌈',
          descriptionKo: '끝없는 호기심으로 세상을 탐험',
          descriptionEn: 'Exploring the world with endless curiosity',
        );
    }

    // 기본값
    return const PersonalityTitle(
      titleKo: '다재다능 만능인',
      titleEn: 'Versatile Talent',
      emoji: '⭐',
      descriptionKo: '모든 면에서 균형 잡힌 멋진 사람',
      descriptionEn: 'A wonderful person balanced in all aspects',
    );
  }

  /// 각 요인별 밈 문구 생성
  static List<MemeQuote> getMemeQuotes(Scores scores) {
    return [
      _getHMeme(scores.h),
      _getEMeme(scores.e),
      _getXMeme(scores.x),
      _getAMeme(scores.a),
      _getCMeme(scores.c),
      _getOMeme(scores.o),
    ];
  }

  /// 공유용 대표 밈 문구 (가장 특징적인 것)
  static MemeQuote getMainMemeQuote(Scores scores) {
    final quotes = getMemeQuotes(scores);
    final scoreMap = scores.toMap();

    // 가장 극단적인(높거나 낮은) 요인 찾기
    double maxDeviation = 0;
    MemeQuote mainQuote = quotes[0];

    for (var i = 0; i < quotes.length; i++) {
      final factor = quotes[i].factor;
      final score = scoreMap[factor] ?? 50;
      final deviation = (score - 50).abs();
      if (deviation > maxDeviation) {
        maxDeviation = deviation;
        mainQuote = quotes[i];
      }
    }

    return mainQuote;
  }

  static MemeQuote _getHMeme(double score) {
    if (score >= 80) {
      return const MemeQuote(
        factor: 'H',
        quoteKo: '거짓말하면 얼굴에 다 써있는 타입',
        quoteEn: 'Type whose face shows every lie',
        emoji: '🫣',
      );
    } else if (score >= 60) {
      return const MemeQuote(
        factor: 'H',
        quoteKo: '양심이 살아있어서 범죄 못 저지르는 타입',
        quoteEn: 'Type who can\'t commit crimes due to conscience',
        emoji: '😇',
      );
    } else if (score >= 40) {
      return const MemeQuote(
        factor: 'H',
        quoteKo: '선의의 거짓말은 가끔 필요하다고 믿는 타입',
        quoteEn: 'Type who believes white lies are sometimes needed',
        emoji: '🤫',
      );
    } else if (score >= 20) {
      return const MemeQuote(
        factor: 'H',
        quoteKo: '협상의 달인, 원하는 건 꼭 얻어내는 타입',
        quoteEn: 'Master negotiator who always gets what they want',
        emoji: '🤝',
      );
    } else {
      return const MemeQuote(
        factor: 'H',
        quoteKo: '정글의 법칙을 몸소 실천하는 야망가',
        quoteEn: 'Ambitious one living by the law of the jungle',
        emoji: '🦁',
      );
    }
  }

  static MemeQuote _getEMeme(double score) {
    if (score >= 80) {
      return const MemeQuote(
        factor: 'E',
        quoteKo: '슬픈 영화 보면 3일은 우는 감성 폭탄',
        quoteEn: 'Emotional bomb crying 3 days after sad movies',
        emoji: '😭',
      );
    } else if (score >= 60) {
      return const MemeQuote(
        factor: 'E',
        quoteKo: '친구 고민 상담하다가 같이 우는 타입',
        quoteEn: 'Type who cries with friends during their problems',
        emoji: '🥺',
      );
    } else if (score >= 40) {
      return const MemeQuote(
        factor: 'E',
        quoteKo: '감정과 이성 사이 줄타기 마스터',
        quoteEn: 'Master of walking the line between emotion and logic',
        emoji: '⚖️',
      );
    } else if (score >= 20) {
      return const MemeQuote(
        factor: 'E',
        quoteKo: '공포영화 보면서 팝콘 먹는 강심장',
        quoteEn: 'Strong-hearted one eating popcorn during horror movies',
        emoji: '🍿',
      );
    } else {
      return const MemeQuote(
        factor: 'E',
        quoteKo: '좀비 아포칼립스에서 살아남을 자 여기 있다',
        quoteEn: 'Here stands the zombie apocalypse survivor',
        emoji: '🧟',
      );
    }
  }

  static MemeQuote _getXMeme(double score) {
    if (score >= 80) {
      return const MemeQuote(
        factor: 'X',
        quoteKo: '모임에서 마이크 잡으면 안 놓는 타입',
        quoteEn: 'Type who never lets go of the mic at parties',
        emoji: '🎤',
      );
    } else if (score >= 60) {
      return const MemeQuote(
        factor: 'X',
        quoteKo: '혼자 있으면 배터리 방전되는 외향 충전 타입',
        quoteEn: 'Type whose battery drains when alone',
        emoji: '🔋',
      );
    } else if (score >= 40) {
      return const MemeQuote(
        factor: 'X',
        quoteKo: '인싸/아싸 스위치 자유자재 조절러',
        quoteEn: 'Free switch between social butterfly and homebody',
        emoji: '🎚️',
      );
    } else if (score >= 20) {
      return const MemeQuote(
        factor: 'X',
        quoteKo: '약속 취소 문자가 명절 보너스급 기쁨',
        quoteEn: 'Canceled plans feel like holiday bonuses',
        emoji: '🎁',
      );
    } else {
      return const MemeQuote(
        factor: 'X',
        quoteKo: '집이 최고야... 밖은 위험해...',
        quoteEn: 'Home is best... outside is dangerous...',
        emoji: '🏠',
      );
    }
  }

  static MemeQuote _getAMeme(double score) {
    if (score >= 80) {
      return const MemeQuote(
        factor: 'A',
        quoteKo: '싸움 붙으면 둘 다 편드는 평화주의자',
        quoteEn: 'Peacemaker who sides with both in arguments',
        emoji: '☮️',
      );
    } else if (score >= 60) {
      return const MemeQuote(
        factor: 'A',
        quoteKo: '악플도 이해하려 노력하는 부처님 마인드',
        quoteEn: 'Buddha mindset trying to understand even haters',
        emoji: '🙏',
      );
    } else if (score >= 40) {
      return const MemeQuote(
        factor: 'A',
        quoteKo: '할 말은 하지만 상처는 안 주는 균형 달인',
        quoteEn: 'Balance master who speaks up without hurting',
        emoji: '💬',
      );
    } else if (score >= 20) {
      return const MemeQuote(
        factor: 'A',
        quoteKo: '옳은 소리에 타협 없는 정의의 용사',
        quoteEn: 'Justice warrior uncompromising on what\'s right',
        emoji: '⚔️',
      );
    } else {
      return const MemeQuote(
        factor: 'A',
        quoteKo: '팩트 폭격기, 돌직구 장인',
        quoteEn: 'Fact bomber, master of brutal honesty',
        emoji: '💣',
      );
    }
  }

  static MemeQuote _getCMeme(double score) {
    if (score >= 80) {
      return const MemeQuote(
        factor: 'C',
        quoteKo: '여행 가면 분 단위 일정표 짜는 타입',
        quoteEn: 'Type who makes minute-by-minute travel schedules',
        emoji: '📅',
      );
    } else if (score >= 60) {
      return const MemeQuote(
        factor: 'C',
        quoteKo: 'To-do 리스트 완료 체크가 최고의 힐링',
        quoteEn: 'Checking off to-do lists is the ultimate healing',
        emoji: '✅',
      );
    } else if (score >= 40) {
      return const MemeQuote(
        factor: 'C',
        quoteKo: '급한 일은 열심히, 나머지는 힘 빼기 달인',
        quoteEn: 'Works hard on urgent stuff, relaxes on the rest',
        emoji: '🎿',
      );
    } else if (score >= 20) {
      return const MemeQuote(
        factor: 'C',
        quoteKo: '마감 5분 전이 진정한 시작이다',
        quoteEn: '5 minutes before deadline is the real start',
        emoji: '⏰',
      );
    } else {
      return const MemeQuote(
        factor: 'C',
        quoteKo: '계획? 그게 뭔데요 먹는 건가요?',
        quoteEn: 'Plans? What\'s that, is it edible?',
        emoji: '🤷',
      );
    }
  }

  static MemeQuote _getOMeme(double score) {
    if (score >= 80) {
      return const MemeQuote(
        factor: 'O',
        quoteKo: '유튜브 알고리즘의 끝을 본 자',
        quoteEn: 'One who\'s seen the end of YouTube algorithm',
        emoji: '🕳️',
      );
    } else if (score >= 60) {
      return const MemeQuote(
        factor: 'O',
        quoteKo: '새로운 취미 3개월 주기로 갈아타는 타입',
        quoteEn: 'Type who switches hobbies every 3 months',
        emoji: '🎨',
      );
    } else if (score >= 40) {
      return const MemeQuote(
        factor: 'O',
        quoteKo: '신기한 건 좋지만 검증된 것도 좋아',
        quoteEn: 'New things are cool but proven ones are nice too',
        emoji: '🔍',
      );
    } else if (score >= 20) {
      return const MemeQuote(
        factor: 'O',
        quoteKo: '인생 최애 메뉴 10년째 같은 거 시키는 중',
        quoteEn: 'Been ordering the same favorite menu for 10 years',
        emoji: '🍜',
      );
    } else {
      return const MemeQuote(
        factor: 'O',
        quoteKo: '변화? 현실은 실험실이 아닙니다',
        quoteEn: 'Change? Reality isn\'t a laboratory',
        emoji: '🧪',
      );
    }
  }

  /// 성격에 맞는 드라마/영화 캐릭터 매칭
  static CharacterMatch getCharacterMatch(Scores scores) {
    final scoreMap = scores.toMap();
    final sortedFactors = scoreMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top1 = sortedFactors[0].key;

    // 조합에 따른 캐릭터 매칭
    if (scores.h >= 65 && scores.c >= 65) {
      return const CharacterMatch(
        nameKo: '세종대왕',
        nameEn: 'King Sejong',
        source: '역사',
        emoji: '📖',
        reasonKo: '정직함과 성실함으로 백성을 섬긴 성군',
        reasonEn: 'A great king who served with honesty and diligence',
      );
    }

    if (scores.x >= 65 && scores.e >= 65) {
      return const CharacterMatch(
        nameKo: '김삼순 (내 이름은 김삼순)',
        nameEn: 'Kim Sam-soon',
        source: '드라마',
        emoji: '🧁',
        reasonKo: '감성적이고 활발한 사랑스러운 캐릭터',
        reasonEn: 'Emotional and lively lovable character',
      );
    }

    if (scores.c >= 65 && scores.a < 40) {
      return const CharacterMatch(
        nameKo: '장그래 (미생)',
        nameEn: 'Jang Geu-rae (Misaeng)',
        source: '드라마',
        emoji: '📊',
        reasonKo: '묵묵히 자신의 길을 걸어가는 성실한 영혼',
        reasonEn: 'A diligent soul quietly walking their own path',
      );
    }

    if (scores.x >= 65 && scores.h >= 65) {
      return const CharacterMatch(
        nameKo: '도깨비 (공유)',
        nameEn: 'Goblin (Gong Yoo)',
        source: '드라마',
        emoji: '✨',
        reasonKo: '카리스마 있으면서도 진심을 담은 존재',
        reasonEn: 'A charismatic being with genuine heart',
      );
    }

    if (scores.o >= 65 && scores.x < 40) {
      return const CharacterMatch(
        nameKo: '셜록 홈즈',
        nameEn: 'Sherlock Holmes',
        source: '문학/영화',
        emoji: '🔎',
        reasonKo: '천재적 통찰력을 가진 내향적 탐구자',
        reasonEn: 'An introverted explorer with genius insight',
      );
    }

    if (scores.e >= 65 && scores.a >= 65) {
      return const CharacterMatch(
        nameKo: '김복주 (역도요정 김복주)',
        nameEn: 'Kim Bok-joo',
        source: '드라마',
        emoji: '💪',
        reasonKo: '따뜻한 마음으로 주변을 감싸는 캐릭터',
        reasonEn: 'A character who embraces others with warmth',
      );
    }

    if (scores.h < 40 && scores.x >= 65) {
      return const CharacterMatch(
        nameKo: '빈센조 (빈센조)',
        nameEn: 'Vincenzo',
        source: '드라마',
        emoji: '🖤',
        reasonKo: '야망과 카리스마를 겸비한 다크히어로',
        reasonEn: 'A dark hero with ambition and charisma',
      );
    }

    if (scores.a >= 65 && scores.c >= 65) {
      return const CharacterMatch(
        nameKo: '데어데블',
        nameEn: 'Daredevil',
        source: '마블',
        emoji: '⚖️',
        reasonKo: '정의롭고 책임감 있는 수호자',
        reasonEn: 'A righteous and responsible guardian',
      );
    }

    // 단일 요인 기반 매칭
    switch (top1) {
      case 'H':
        return const CharacterMatch(
          nameKo: '강마루 (그 겨울 바람이 분다)',
          nameEn: 'Kang Ma-ru',
          source: '드라마',
          emoji: '❄️',
          reasonKo: '순수하고 정직한 영혼의 소유자',
          reasonEn: 'Owner of a pure and honest soul',
        );
      case 'E':
        return const CharacterMatch(
          nameKo: '윤세리 (사랑의 불시착)',
          nameEn: 'Yoon Se-ri',
          source: '드라마',
          emoji: '💖',
          reasonKo: '감정이 풍부하고 사랑에 충실한 캐릭터',
          reasonEn: 'Emotionally rich and faithful in love',
        );
      case 'X':
        return const CharacterMatch(
          nameKo: '토니 스타크',
          nameEn: 'Tony Stark',
          source: '마블',
          emoji: '🦸',
          reasonKo: '자신감 넘치는 활발한 천재',
          reasonEn: 'A confident and lively genius',
        );
      case 'A':
        return const CharacterMatch(
          nameKo: '이민호 (더 킹: 영원의 군주)',
          nameEn: 'Lee Gon',
          source: '드라마',
          emoji: '👑',
          reasonKo: '배려심 깊고 조화를 추구하는 리더',
          reasonEn: 'A considerate leader who seeks harmony',
        );
      case 'C':
        return const CharacterMatch(
          nameKo: '캡틴 아메리카',
          nameEn: 'Captain America',
          source: '마블',
          emoji: '🛡️',
          reasonKo: '원칙을 지키는 책임감 있는 리더',
          reasonEn: 'A responsible leader who keeps principles',
        );
      case 'O':
        return const CharacterMatch(
          nameKo: '엘리 (업)',
          nameEn: 'Ellie (Up)',
          source: '디즈니/픽사',
          emoji: '🎈',
          reasonKo: '모험을 꿈꾸는 호기심 가득한 영혼',
          reasonEn: 'A curious soul dreaming of adventure',
        );
    }

    return const CharacterMatch(
      nameKo: '스파이더맨',
      nameEn: 'Spider-Man',
      source: '마블',
      emoji: '🕷️',
      reasonKo: '다재다능하고 균형 잡힌 영웅',
      reasonEn: 'A versatile and balanced hero',
    );
  }

  /// MBTI 추정 매칭
  static MBTIMatch getMBTIMatch(Scores scores) {
    // 6가지 유형 → MBTI 대략적 매핑
    // X(외향성) → E/I
    // O(개방성) → N/S
    // A(원만성) → F/T (반대)
    // C(성실성) → J/P

    String mbti = '';

    // E/I
    mbti += scores.x >= 50 ? 'E' : 'I';

    // N/S
    mbti += scores.o >= 50 ? 'N' : 'S';

    // F/T (A가 높으면 F 성향)
    mbti += scores.a >= 50 ? 'F' : 'T';

    // J/P
    mbti += scores.c >= 50 ? 'J' : 'P';

    return MBTIMatch(
      mbti: mbti,
      descriptionKo: _getMBTIDescriptionKo(mbti),
      descriptionEn: _getMBTIDescriptionEn(mbti),
    );
  }

  static String _getMBTIDescriptionKo(String mbti) {
    switch (mbti) {
      case 'ENFJ': return '정의로운 사회운동가';
      case 'ENFP': return '재기발랄한 활동가';
      case 'ENTJ': return '대담한 통솔자';
      case 'ENTP': return '뜨거운 논쟁을 즐기는 변론가';
      case 'ESFJ': return '사교적인 외교관';
      case 'ESFP': return '자유로운 영혼의 연예인';
      case 'ESTJ': return '엄격한 관리자';
      case 'ESTP': return '모험을 즐기는 사업가';
      case 'INFJ': return '선의의 옹호자';
      case 'INFP': return '열정적인 중재자';
      case 'INTJ': return '용의주도한 전략가';
      case 'INTP': return '논리적인 사색가';
      case 'ISFJ': return '용감한 수호자';
      case 'ISFP': return '호기심 많은 예술가';
      case 'ISTJ': return '청렴결백한 논리주의자';
      case 'ISTP': return '만능 재주꾼';
      default: return '독특한 성격의 소유자';
    }
  }

  static String _getMBTIDescriptionEn(String mbti) {
    switch (mbti) {
      case 'ENFJ': return 'The Protagonist';
      case 'ENFP': return 'The Campaigner';
      case 'ENTJ': return 'The Commander';
      case 'ENTP': return 'The Debater';
      case 'ESFJ': return 'The Consul';
      case 'ESFP': return 'The Entertainer';
      case 'ESTJ': return 'The Executive';
      case 'ESTP': return 'The Entrepreneur';
      case 'INFJ': return 'The Advocate';
      case 'INFP': return 'The Mediator';
      case 'INTJ': return 'The Architect';
      case 'INTP': return 'The Logician';
      case 'ISFJ': return 'The Defender';
      case 'ISFP': return 'The Adventurer';
      case 'ISTJ': return 'The Logistician';
      case 'ISTP': return 'The Virtuoso';
      default: return 'Unique Personality';
    }
  }

  /// 공유용 한 줄 요약 생성
  static String getShareableSummary(Scores scores, bool isKo) {
    final title = getPersonalityTitle(scores);
    final mainMeme = getMainMemeQuote(scores);
    final mbti = getMBTIMatch(scores);

    if (isKo) {
      return '${title.emoji} ${title.titleKo}\n'
          '${mainMeme.emoji} ${mainMeme.quoteKo}\n'
          '🔮 MBTI 추정: ${mbti.mbti}';
    } else {
      return '${title.emoji} ${title.titleEn}\n'
          '${mainMeme.emoji} ${mainMeme.quoteEn}\n'
          '🔮 MBTI guess: ${mbti.mbti}';
    }
  }
}
