// MBTI Compatibility Utility
// Provides Best 3 and Worst 3 MBTI type compatibility for any given MBTI type.

export interface MBTICompatResult {
  mbti: string;
  compatType: 'best' | 'worst';
  reason: { ko: string; en: string };
  emoji: string;
}

export interface MBTICompatibility {
  best: MBTICompatResult[];
  worst: MBTICompatResult[];
}

// ---------------------------------------------------------------------------
// MBTI type descriptions (brief, for display)
// ---------------------------------------------------------------------------

export const mbtiDescriptions: Record<string, { ko: string; en: string; emoji: string }> = {
  ENFP: { ko: '재기발랄한 활동가', en: 'The Campaigner', emoji: '🦋' },
  ENFJ: { ko: '정의로운 사회운동가', en: 'The Protagonist', emoji: '🌟' },
  ENTP: { ko: '뜨거운 논쟁을 즐기는 변론가', en: 'The Debater', emoji: '⚡' },
  ENTJ: { ko: '대담한 통솔자', en: 'The Commander', emoji: '👑' },
  ESFP: { ko: '자유로운 영혼의 연예인', en: 'The Entertainer', emoji: '🎉' },
  ESFJ: { ko: '사교적인 외교관', en: 'The Consul', emoji: '🤝' },
  ESTP: { ko: '모험을 즐기는 사업가', en: 'The Entrepreneur', emoji: '🏄' },
  ESTJ: { ko: '엄격한 관리자', en: 'The Executive', emoji: '📋' },
  INFP: { ko: '열정적인 중재자', en: 'The Mediator', emoji: '🌸' },
  INFJ: { ko: '선의의 옹호자', en: 'The Advocate', emoji: '🔮' },
  INTP: { ko: '논리적인 사색가', en: 'The Logician', emoji: '🧩' },
  INTJ: { ko: '용의주도한 전략가', en: 'The Architect', emoji: '🏗️' },
  ISFP: { ko: '호기심 많은 예술가', en: 'The Adventurer', emoji: '🎨' },
  ISFJ: { ko: '용감한 수호자', en: 'The Defender', emoji: '🛡️' },
  ISTP: { ko: '만능 재주꾼', en: 'The Virtuoso', emoji: '🔧' },
  ISTJ: { ko: '청렴결백한 논리주의자', en: 'The Logistician', emoji: '📊' },
};

// ---------------------------------------------------------------------------
// Full compatibility data for all 16 types
// ---------------------------------------------------------------------------

interface CompatEntry {
  mbti: string;
  reason: { ko: string; en: string };
  emoji: string;
}

interface CompatData {
  best: [CompatEntry, CompatEntry, CompatEntry];
  worst: [CompatEntry, CompatEntry, CompatEntry];
}

const compatibilityMap: Record<string, CompatData> = {
  ENFP: {
    best: [
      {
        mbti: 'INFJ',
        reason: {
          ko: '서로의 내면 세계를 깊이 이해하며 영감을 주는 최고의 조합',
          en: 'Deep mutual understanding of inner worlds with endless inspiration',
        },
        emoji: '💞',
      },
      {
        mbti: 'INTJ',
        reason: {
          ko: '창의성과 전략이 만나 함께 큰 꿈을 현실로 만드는 관계',
          en: 'Creativity meets strategy to turn big dreams into reality together',
        },
        emoji: '🚀',
      },
      {
        mbti: 'ENFJ',
        reason: {
          ko: '따뜻한 에너지와 열정이 시너지를 내는 활력 넘치는 관계',
          en: 'Warm energy and passion create vibrant synergy',
        },
        emoji: '🔥',
      },
    ],
    worst: [
      {
        mbti: 'ISTJ',
        reason: {
          ko: '자유로운 영혼과 규칙 중시의 충돌로 답답함을 느끼기 쉬움',
          en: 'Free spirit clashes with rule-oriented nature, causing frustration',
        },
        emoji: '⛓️',
      },
      {
        mbti: 'ESTJ',
        reason: {
          ko: '감정보다 효율을 앞세우는 소통 방식에 서로 지치기 쉬움',
          en: 'Efficiency-over-feelings communication style exhausts both sides',
        },
        emoji: '😤',
      },
      {
        mbti: 'ISTP',
        reason: {
          ko: '감정 표현의 온도 차이로 연결감을 느끼기 어려운 관계',
          en: 'Emotional expression gap makes it hard to feel connected',
        },
        emoji: '🧊',
      },
    ],
  },

  ENFJ: {
    best: [
      {
        mbti: 'INFP',
        reason: {
          ko: '서로의 가치관을 존중하며 깊은 정서적 교감을 나누는 관계',
          en: 'Mutual respect for values with deep emotional connection',
        },
        emoji: '💕',
      },
      {
        mbti: 'ISFP',
        reason: {
          ko: '따뜻한 리더십과 섬세한 감성이 조화롭게 어우러지는 조합',
          en: 'Warm leadership harmonizes beautifully with delicate sensitivity',
        },
        emoji: '🌷',
      },
      {
        mbti: 'ENFP',
        reason: {
          ko: '함께하면 세상을 바꿀 수 있을 것 같은 에너지 넘치는 관계',
          en: 'Together they feel they can change the world with boundless energy',
        },
        emoji: '✨',
      },
    ],
    worst: [
      {
        mbti: 'ISTP',
        reason: {
          ko: '감정적 소통을 원하지만 상대는 논리적 거리두기를 선호',
          en: 'Desires emotional communication but partner prefers logical distance',
        },
        emoji: '🚧',
      },
      {
        mbti: 'ESTP',
        reason: {
          ko: '깊은 대화를 원하지만 상대는 행동과 즉흥을 더 중시',
          en: 'Craves deep conversation while partner values action and spontaneity',
        },
        emoji: '💨',
      },
      {
        mbti: 'INTP',
        reason: {
          ko: '감정적 친밀감과 지적 독립성 사이에서 갈등이 생기기 쉬움',
          en: 'Tension between emotional intimacy and intellectual independence',
        },
        emoji: '🔀',
      },
    ],
  },

  ENTP: {
    best: [
      {
        mbti: 'INFJ',
        reason: {
          ko: '지적 호기심과 직관적 통찰이 만나 끝없는 대화를 나누는 관계',
          en: 'Intellectual curiosity meets intuitive insight for endless conversation',
        },
        emoji: '🧠',
      },
      {
        mbti: 'INTJ',
        reason: {
          ko: '서로의 아이디어를 발전시키며 함께 성장하는 최강의 두뇌 조합',
          en: 'Power duo that elevates each other\'s ideas and grows together',
        },
        emoji: '💡',
      },
      {
        mbti: 'ENFP',
        reason: {
          ko: '새로운 가능성을 함께 탐험하며 지루할 틈이 없는 관계',
          en: 'Exploring new possibilities together with never a dull moment',
        },
        emoji: '🎯',
      },
    ],
    worst: [
      {
        mbti: 'ISFJ',
        reason: {
          ko: '변화를 추구하는 성향과 안정을 원하는 성향이 부딪히기 쉬움',
          en: 'Change-seeking nature clashes with stability-seeking tendencies',
        },
        emoji: '⚔️',
      },
      {
        mbti: 'ESFJ',
        reason: {
          ko: '논쟁을 즐기는 방식이 화합을 중시하는 상대에겐 상처가 될 수 있음',
          en: 'Debate-loving style can hurt a harmony-focused partner',
        },
        emoji: '💔',
      },
      {
        mbti: 'ISTJ',
        reason: {
          ko: '관습을 깨려는 성향과 전통을 지키려는 성향의 근본적 충돌',
          en: 'Fundamental clash between convention-breaking and tradition-keeping',
        },
        emoji: '🧱',
      },
    ],
  },

  ENTJ: {
    best: [
      {
        mbti: 'INFP',
        reason: {
          ko: '강한 리더십과 부드러운 공감 능력이 서로를 완벽히 보완',
          en: 'Strong leadership perfectly complemented by gentle empathy',
        },
        emoji: '🤝',
      },
      {
        mbti: 'INTP',
        reason: {
          ko: '실행력과 분석력이 합쳐져 어떤 목표든 달성할 수 있는 조합',
          en: 'Execution power combined with analytical depth conquers any goal',
        },
        emoji: '🏆',
      },
      {
        mbti: 'ENFP',
        reason: {
          ko: '비전을 실현하는 리더와 영감을 주는 창의력의 환상적 만남',
          en: 'Vision-realizing leader meets inspiring creative force',
        },
        emoji: '🌈',
      },
    ],
    worst: [
      {
        mbti: 'ISFP',
        reason: {
          ko: '목표 지향적 추진력이 자유로운 감성을 억압할 수 있음',
          en: 'Goal-driven intensity can suppress free-spirited sensitivity',
        },
        emoji: '😰',
      },
      {
        mbti: 'ISFJ',
        reason: {
          ko: '직접적인 의사소통이 배려 중심의 상대에겐 공격적으로 느껴질 수 있음',
          en: 'Direct communication style can feel aggressive to a caring partner',
        },
        emoji: '🛑',
      },
      {
        mbti: 'ESFP',
        reason: {
          ko: '장기 계획과 즉흥적 즐거움 사이의 우선순위 갈등',
          en: 'Priority conflict between long-term planning and spontaneous fun',
        },
        emoji: '🎭',
      },
    ],
  },

  INFP: {
    best: [
      {
        mbti: 'ENFJ',
        reason: {
          ko: '서로의 이상과 가치를 공유하며 깊은 신뢰를 쌓는 관계',
          en: 'Sharing ideals and values while building deep trust together',
        },
        emoji: '💖',
      },
      {
        mbti: 'ENTJ',
        reason: {
          ko: '서로의 부족한 부분을 완벽하게 채워주는 이상적인 조합',
          en: 'Perfect complement filling each other\'s gaps beautifully',
        },
        emoji: '🧲',
      },
      {
        mbti: 'INFJ',
        reason: {
          ko: '말하지 않아도 통하는 깊은 내면의 교감을 나눌 수 있는 관계',
          en: 'Profound unspoken connection through deep inner understanding',
        },
        emoji: '🌙',
      },
    ],
    worst: [
      {
        mbti: 'ESTJ',
        reason: {
          ko: '감정보다 규칙을 우선하는 방식이 내면의 상처를 줄 수 있음',
          en: 'Rules-over-feelings approach can wound the sensitive inner world',
        },
        emoji: '💢',
      },
      {
        mbti: 'ESTP',
        reason: {
          ko: '깊은 의미를 추구하는 성향과 즉각적 행동 중시의 차이',
          en: 'Gap between seeking deep meaning and valuing immediate action',
        },
        emoji: '🌪️',
      },
      {
        mbti: 'ISTJ',
        reason: {
          ko: '창의적 자유와 체계적 질서 사이에서 서로 답답함을 느끼기 쉬움',
          en: 'Creative freedom vs systematic order leads to mutual frustration',
        },
        emoji: '📏',
      },
    ],
  },

  INFJ: {
    best: [
      {
        mbti: 'ENFP',
        reason: {
          ko: '직관과 감성이 만나 서로에게 끊임없는 영감을 주는 황금 조합',
          en: 'Intuition meets emotion for a golden pair of endless inspiration',
        },
        emoji: '🌟',
      },
      {
        mbti: 'ENTP',
        reason: {
          ko: '깊은 통찰과 날카로운 지성이 함께 세상을 탐구하는 관계',
          en: 'Deep insight and sharp intellect explore the world together',
        },
        emoji: '🔭',
      },
      {
        mbti: 'INTJ',
        reason: {
          ko: '조용하지만 강렬한 내면의 교감으로 서로를 깊이 이해하는 관계',
          en: 'Quiet but intense inner connection with profound mutual understanding',
        },
        emoji: '🤫',
      },
    ],
    worst: [
      {
        mbti: 'ESTP',
        reason: {
          ko: '내면 탐구와 외부 자극 추구의 근본적인 방향 차이',
          en: 'Fundamental directional difference between inner depth and outer thrills',
        },
        emoji: '↔️',
      },
      {
        mbti: 'ESFP',
        reason: {
          ko: '의미 있는 대화를 원하지만 상대는 가벼운 즐거움을 선호',
          en: 'Seeks meaningful dialogue while partner prefers lighthearted fun',
        },
        emoji: '🎈',
      },
      {
        mbti: 'ESTJ',
        reason: {
          ko: '감정적 깊이와 실용적 효율 사이에서 소통의 벽을 느끼기 쉬움',
          en: 'Communication wall between emotional depth and practical efficiency',
        },
        emoji: '🧱',
      },
    ],
  },

  INTP: {
    best: [
      {
        mbti: 'ENTJ',
        reason: {
          ko: '분석적 사고와 실행력이 만나 불가능을 가능으로 바꾸는 조합',
          en: 'Analytical thinking meets execution power to make the impossible possible',
        },
        emoji: '⚙️',
      },
      {
        mbti: 'ESTJ',
        reason: {
          ko: '이론과 실천이 균형을 이루며 서로에게 새로운 시각을 열어주는 관계',
          en: 'Theory and practice balance, opening new perspectives for each other',
        },
        emoji: '⚖️',
      },
      {
        mbti: 'ENTP',
        reason: {
          ko: '지적 탐구를 함께 즐기며 끝없는 아이디어를 주고받는 관계',
          en: 'Shared intellectual exploration with an endless exchange of ideas',
        },
        emoji: '♟️',
      },
    ],
    worst: [
      {
        mbti: 'ESFJ',
        reason: {
          ko: '논리적 분석과 감정적 배려 사이에서 자주 오해가 생기는 관계',
          en: 'Frequent misunderstandings between logical analysis and emotional care',
        },
        emoji: '😶',
      },
      {
        mbti: 'ESFP',
        reason: {
          ko: '깊은 사색과 즉흥적 행동의 리듬 차이로 피로감을 느끼기 쉬움',
          en: 'Rhythm mismatch between deep reflection and spontaneous action causes fatigue',
        },
        emoji: '🥱',
      },
      {
        mbti: 'ENFJ',
        reason: {
          ko: '감정적 관여를 원하는 상대에게 지적 거리두기가 냉담하게 느껴질 수 있음',
          en: 'Intellectual distancing can feel cold to an emotionally engaged partner',
        },
        emoji: '❄️',
      },
    ],
  },

  INTJ: {
    best: [
      {
        mbti: 'ENFP',
        reason: {
          ko: '전략적 사고에 창의적 에너지가 더해져 놀라운 시너지를 만드는 관계',
          en: 'Strategic thinking supercharged by creative energy for amazing synergy',
        },
        emoji: '🎆',
      },
      {
        mbti: 'ENTP',
        reason: {
          ko: '지적 도전을 함께 즐기며 서로의 성장을 이끄는 동반자 관계',
          en: 'Intellectual sparring partners who drive each other\'s growth',
        },
        emoji: '🏹',
      },
      {
        mbti: 'INFJ',
        reason: {
          ko: '깊은 직관력을 공유하며 말 없이도 서로를 이해하는 특별한 관계',
          en: 'Shared deep intuition with remarkable unspoken understanding',
        },
        emoji: '🔮',
      },
    ],
    worst: [
      {
        mbti: 'ESFP',
        reason: {
          ko: '장기적 계획과 순간의 즐거움 사이에서 가치관 충돌이 일어나기 쉬움',
          en: 'Value clash between long-term planning and living in the moment',
        },
        emoji: '🎪',
      },
      {
        mbti: 'ESFJ',
        reason: {
          ko: '독립적 사고와 사회적 조화 중시 사이에서 갈등을 느끼기 쉬움',
          en: 'Tension between independent thinking and social harmony priorities',
        },
        emoji: '🔇',
      },
      {
        mbti: 'ISFP',
        reason: {
          ko: '체계적 접근과 자유로운 흐름 사이에서 서로의 방식이 답답하게 느껴질 수 있음',
          en: 'Systematic approach vs free-flowing style can feel stifling to each other',
        },
        emoji: '🌊',
      },
    ],
  },

  ESFP: {
    best: [
      {
        mbti: 'ISTJ',
        reason: {
          ko: '즐거운 에너지와 안정적인 기반이 만나 서로에게 균형을 주는 관계',
          en: 'Fun energy and stable foundation create perfect balance for each other',
        },
        emoji: '🎡',
      },
      {
        mbti: 'ISFJ',
        reason: {
          ko: '밝은 성격이 따뜻한 돌봄과 어우러져 편안한 관계를 만드는 조합',
          en: 'Bright personality blends with warm caring for a comfortable bond',
        },
        emoji: '🏡',
      },
      {
        mbti: 'ESTP',
        reason: {
          ko: '함께 모험을 즐기며 매 순간을 최대한 즐길 수 있는 파트너',
          en: 'Adventure partners who make the most of every moment together',
        },
        emoji: '🤸',
      },
    ],
    worst: [
      {
        mbti: 'INTJ',
        reason: {
          ko: '즉흥적 즐거움과 철저한 계획 사이에서 서로를 이해하기 어려움',
          en: 'Hard to understand each other between spontaneous fun and meticulous planning',
        },
        emoji: '🤔',
      },
      {
        mbti: 'INTP',
        reason: {
          ko: '활동적인 에너지와 조용한 사색 사이에서 리듬이 맞지 않는 관계',
          en: 'Active energy and quiet contemplation create mismatched rhythms',
        },
        emoji: '🐢',
      },
      {
        mbti: 'INFJ',
        reason: {
          ko: '표면적 즐거움과 깊은 의미 추구 사이에서 소통의 간극이 생기기 쉬움',
          en: 'Communication gap between surface-level fun and deep meaning-seeking',
        },
        emoji: '🕳️',
      },
    ],
  },

  ESTP: {
    best: [
      {
        mbti: 'ISFJ',
        reason: {
          ko: '대담한 행동력과 세심한 배려가 서로에게 새로운 세계를 열어주는 관계',
          en: 'Bold action and careful attention open new worlds for each other',
        },
        emoji: '🌍',
      },
      {
        mbti: 'ISTJ',
        reason: {
          ko: '실용적 에너지와 체계적 안정감이 함께 강력한 팀을 만드는 관계',
          en: 'Practical energy and systematic stability form a powerful team',
        },
        emoji: '💪',
      },
      {
        mbti: 'ESFP',
        reason: {
          ko: '함께라면 어떤 상황에서도 즐거움을 찾을 수 있는 최고의 파트너',
          en: 'Ultimate partners who find fun in any situation together',
        },
        emoji: '🎊',
      },
    ],
    worst: [
      {
        mbti: 'INFJ',
        reason: {
          ko: '즉각적 행동과 깊은 성찰 사이에서 속도 차이를 느끼기 쉬움',
          en: 'Speed difference between immediate action and deep reflection',
        },
        emoji: '🐇',
      },
      {
        mbti: 'INFP',
        reason: {
          ko: '현실적 접근과 이상주의적 사고 사이에서 갈등이 생기기 쉬움',
          en: 'Conflict between realistic approach and idealistic thinking',
        },
        emoji: '☁️',
      },
      {
        mbti: 'ENFJ',
        reason: {
          ko: '자유로운 행동을 원하지만 상대는 감정적 유대를 강하게 요구',
          en: 'Wants freedom of action while partner demands strong emotional bonds',
        },
        emoji: '🪢',
      },
    ],
  },

  ESFJ: {
    best: [
      {
        mbti: 'ISFP',
        reason: {
          ko: '따뜻한 돌봄과 섬세한 감성이 서로에게 안정감을 주는 조합',
          en: 'Warm caring and delicate sensitivity provide mutual comfort',
        },
        emoji: '🫂',
      },
      {
        mbti: 'ISTP',
        reason: {
          ko: '사교적 에너지와 독립적 능력이 조화를 이루는 균형 잡힌 관계',
          en: 'Social energy and independent capability create balanced harmony',
        },
        emoji: '🎯',
      },
      {
        mbti: 'ESFP',
        reason: {
          ko: '사람을 좋아하는 따뜻한 마음이 통해 함께하면 늘 즐거운 관계',
          en: 'Shared love for people creates an always-joyful connection',
        },
        emoji: '🥰',
      },
    ],
    worst: [
      {
        mbti: 'INTP',
        reason: {
          ko: '감정적 소통을 원하지만 상대는 논리적 분석을 우선시하여 서운함이 쌓임',
          en: 'Desires emotional communication but partner prioritizes logical analysis',
        },
        emoji: '😞',
      },
      {
        mbti: 'ENTP',
        reason: {
          ko: '화합을 중시하는데 상대의 끊임없는 논쟁이 불편하게 느껴질 수 있음',
          en: 'Harmony-focused nature finds partner\'s constant debating uncomfortable',
        },
        emoji: '😣',
      },
      {
        mbti: 'INTJ',
        reason: {
          ko: '따뜻한 교류를 원하지만 상대의 독립적 태도에 거리감을 느끼기 쉬움',
          en: 'Wants warm interaction but feels distant from partner\'s independent attitude',
        },
        emoji: '🚪',
      },
    ],
  },

  ESTJ: {
    best: [
      {
        mbti: 'INTP',
        reason: {
          ko: '실행력과 분석력이 만나 효율적으로 목표를 달성하는 강력한 조합',
          en: 'Execution meets analysis for efficient goal achievement',
        },
        emoji: '📈',
      },
      {
        mbti: 'ISTP',
        reason: {
          ko: '실용적인 두 사람이 만나 현실적인 문제를 함께 해결하는 관계',
          en: 'Two practical minds joining forces to solve real-world problems',
        },
        emoji: '🔨',
      },
      {
        mbti: 'ISFJ',
        reason: {
          ko: '체계적 리더십과 헌신적 서포트가 어우러진 안정적인 관계',
          en: 'Systematic leadership paired with devoted support creates stability',
        },
        emoji: '🏠',
      },
    ],
    worst: [
      {
        mbti: 'ENFP',
        reason: {
          ko: '체계와 규칙을 중시하는데 상대의 자유분방함에 답답함을 느끼기 쉬움',
          en: 'Values structure and rules, frustrated by partner\'s free-spirited nature',
        },
        emoji: '😫',
      },
      {
        mbti: 'INFP',
        reason: {
          ko: '현실적 효율을 추구하는데 상대의 이상주의가 비현실적으로 느껴짐',
          en: 'Pursuing practical efficiency, finds partner\'s idealism unrealistic',
        },
        emoji: '🙄',
      },
      {
        mbti: 'INFJ',
        reason: {
          ko: '결과 중심의 접근과 과정 중시의 태도 사이에서 마찰이 생기기 쉬움',
          en: 'Friction between results-focused approach and process-oriented attitude',
        },
        emoji: '⚡',
      },
    ],
  },

  ISFP: {
    best: [
      {
        mbti: 'ENFJ',
        reason: {
          ko: '조용한 감성과 따뜻한 리더십이 서로를 자연스럽게 끌어당기는 관계',
          en: 'Quiet sensitivity and warm leadership naturally attract each other',
        },
        emoji: '🌻',
      },
      {
        mbti: 'ESFJ',
        reason: {
          ko: '섬세한 예술적 감각과 사교적 따뜻함이 조화를 이루는 관계',
          en: 'Delicate artistic sense harmonizes with social warmth',
        },
        emoji: '🎶',
      },
      {
        mbti: 'INFP',
        reason: {
          ko: '깊은 감성과 가치관을 공유하며 조용한 행복을 나누는 관계',
          en: 'Sharing deep emotions and values for quiet shared happiness',
        },
        emoji: '🍃',
      },
    ],
    worst: [
      {
        mbti: 'ENTJ',
        reason: {
          ko: '자유로운 흐름을 원하지만 상대의 강한 통제력에 압박감을 느끼기 쉬움',
          en: 'Wants free flow but feels pressured by partner\'s strong control',
        },
        emoji: '😓',
      },
      {
        mbti: 'ESTJ',
        reason: {
          ko: '감성적 자유와 체계적 규율 사이에서 서로를 이해하기 어려운 관계',
          en: 'Hard to bridge emotional freedom and systematic discipline',
        },
        emoji: '🚫',
      },
      {
        mbti: 'ENTP',
        reason: {
          ko: '조용한 자기 표현과 활발한 논쟁 사이에서 에너지 소모가 큰 관계',
          en: 'Energy-draining gap between quiet self-expression and active debate',
        },
        emoji: '🔋',
      },
    ],
  },

  ISTP: {
    best: [
      {
        mbti: 'ESFJ',
        reason: {
          ko: '독립적 능력과 따뜻한 돌봄이 서로에게 새로운 균형을 주는 관계',
          en: 'Independent capability and warm caring bring new balance to each other',
        },
        emoji: '⚖️',
      },
      {
        mbti: 'ESTJ',
        reason: {
          ko: '실용적 사고방식을 공유하며 효율적으로 함께 일할 수 있는 관계',
          en: 'Shared practical mindset enables efficient collaboration',
        },
        emoji: '🤜',
      },
      {
        mbti: 'ESTP',
        reason: {
          ko: '행동 중심의 성향이 통하여 함께 도전을 즐길 수 있는 관계',
          en: 'Action-oriented natures align for enjoying challenges together',
        },
        emoji: '🏔️',
      },
    ],
    worst: [
      {
        mbti: 'ENFJ',
        reason: {
          ko: '감정적 관여 요구가 독립성을 중시하는 성향에 부담이 될 수 있음',
          en: 'Emotional involvement demands can burden an independence-loving nature',
        },
        emoji: '😮‍💨',
      },
      {
        mbti: 'ENFP',
        reason: {
          ko: '감정 표현의 풍부함과 절제 사이에서 서로 불편함을 느끼기 쉬움',
          en: 'Discomfort between emotional expressiveness and emotional restraint',
        },
        emoji: '🎭',
      },
      {
        mbti: 'INFJ',
        reason: {
          ko: '실용적 접근과 깊은 감정 탐구 사이에서 소통의 어려움이 있는 관계',
          en: 'Communication difficulty between practical approach and deep emotional exploration',
        },
        emoji: '🔇',
      },
    ],
  },

  ISFJ: {
    best: [
      {
        mbti: 'ESFP',
        reason: {
          ko: '안정적인 돌봄과 밝은 에너지가 만나 서로에게 활력을 주는 관계',
          en: 'Stable caring meets bright energy, bringing vitality to each other',
        },
        emoji: '🌞',
      },
      {
        mbti: 'ESTP',
        reason: {
          ko: '세심한 배려와 대담한 행동력이 서로에게 새로운 경험을 선물하는 관계',
          en: 'Careful consideration and bold action gift new experiences to each other',
        },
        emoji: '🎁',
      },
      {
        mbti: 'ISTJ',
        reason: {
          ko: '서로의 헌신과 책임감을 이해하며 깊은 신뢰를 쌓는 든든한 관계',
          en: 'Mutual devotion and responsibility build deep, reliable trust',
        },
        emoji: '🤲',
      },
    ],
    worst: [
      {
        mbti: 'ENTP',
        reason: {
          ko: '안정을 중시하는데 상대의 끊임없는 변화 추구에 불안감을 느끼기 쉬움',
          en: 'Values stability but feels anxious from partner\'s constant pursuit of change',
        },
        emoji: '😰',
      },
      {
        mbti: 'ENTJ',
        reason: {
          ko: '배려 중심의 소통이 상대의 직접적 화법에 상처받기 쉬움',
          en: 'Care-centered communication easily wounded by partner\'s blunt directness',
        },
        emoji: '🥺',
      },
      {
        mbti: 'INTJ',
        reason: {
          ko: '따뜻한 교류를 원하지만 상대의 냉철한 독립성에 서운함을 느끼기 쉬움',
          en: 'Wants warm exchange but feels hurt by partner\'s cool independence',
        },
        emoji: '🧊',
      },
    ],
  },

  ISTJ: {
    best: [
      {
        mbti: 'ESFP',
        reason: {
          ko: '체계적인 안정감에 즐거운 활력이 더해져 삶이 풍요로워지는 관계',
          en: 'Systematic stability enriched by joyful vitality makes life fuller',
        },
        emoji: '🌺',
      },
      {
        mbti: 'ENFP',
        reason: {
          ko: '견고한 기반과 창의적 영감이 만나 서로에게 새로운 시야를 열어주는 관계',
          en: 'Solid foundation meets creative inspiration, opening new horizons',
        },
        emoji: '🔑',
      },
      {
        mbti: 'ISFJ',
        reason: {
          ko: '책임감과 헌신을 공유하며 묵묵히 서로를 지지하는 든든한 관계',
          en: 'Shared responsibility and devotion with steadfast mutual support',
        },
        emoji: '🏰',
      },
    ],
    worst: [
      {
        mbti: 'ENFP',
        reason: {
          ko: '규칙과 자유 사이에서 갈등이 생기면 타협점을 찾기 어려움',
          en: 'When rules vs freedom conflicts arise, compromise is hard to find',
        },
        emoji: '😤',
      },
      {
        mbti: 'ENTP',
        reason: {
          ko: '전통과 관습을 중시하는데 상대가 끊임없이 도전하여 피로감을 느낌',
          en: 'Values tradition but partner\'s constant challenging causes fatigue',
        },
        emoji: '😩',
      },
      {
        mbti: 'INFP',
        reason: {
          ko: '사실 기반의 소통과 감정 기반의 소통 사이에서 오해가 잦은 관계',
          en: 'Frequent misunderstandings between fact-based and emotion-based communication',
        },
        emoji: '🔀',
      },
    ],
  },
};

// ---------------------------------------------------------------------------
// Validation helpers
// ---------------------------------------------------------------------------

const VALID_MBTI_TYPES = [
  'ENFP', 'ENFJ', 'ENTP', 'ENTJ',
  'INFP', 'INFJ', 'INTP', 'INTJ',
  'ESFP', 'ESFJ', 'ESTP', 'ESTJ',
  'ISFP', 'ISFJ', 'ISTP', 'ISTJ',
] as const;

export type MBTIType = (typeof VALID_MBTI_TYPES)[number];

function isValidMBTI(mbti: string): mbti is MBTIType {
  return VALID_MBTI_TYPES.includes(mbti.toUpperCase() as MBTIType);
}

// ---------------------------------------------------------------------------
// Main export
// ---------------------------------------------------------------------------

/**
 * Returns the top 3 best and top 3 worst MBTI compatibility matches
 * for the given MBTI type.
 *
 * @param myMBTI - A valid MBTI type string (case-insensitive), e.g. "ENFP"
 * @returns An object containing `best` and `worst` arrays of MBTICompatResult
 * @throws Error if the provided MBTI type is invalid
 */
export function getMBTICompatibility(myMBTI: string): MBTICompatibility {
  const normalized = myMBTI.toUpperCase().trim();

  if (!isValidMBTI(normalized)) {
    throw new Error(
      `Invalid MBTI type: "${myMBTI}". Must be one of: ${VALID_MBTI_TYPES.join(', ')}`
    );
  }

  const data = compatibilityMap[normalized];

  const best: MBTICompatResult[] = data.best.map((entry) => ({
    mbti: entry.mbti,
    compatType: 'best' as const,
    reason: entry.reason,
    emoji: entry.emoji,
  }));

  const worst: MBTICompatResult[] = data.worst.map((entry) => ({
    mbti: entry.mbti,
    compatType: 'worst' as const,
    reason: entry.reason,
    emoji: entry.emoji,
  }));

  return { best, worst };
}
