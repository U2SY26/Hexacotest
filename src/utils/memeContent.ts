// Meme content service - ported from mobile app
// Provides catchy personality titles, meme quotes, character matches, and MBTI estimation

interface Scores {
  H: number
  E: number
  X: number
  A: number
  C: number
  O: number
}

export interface PersonalityTitle {
  titleKo: string
  titleEn: string
  emoji: string
  descriptionKo: string
  descriptionEn: string
}

export interface MemeQuote {
  factor: string
  quoteKo: string
  quoteEn: string
  emoji: string
}

export interface CharacterMatch {
  nameKo: string
  nameEn: string
  source: string
  emoji: string
  reasonKo: string
  reasonEn: string
}

export interface MBTIMatch {
  mbti: string
  descriptionKo: string
  descriptionEn: string
}

export function getPersonalityTitle(scores: Scores): PersonalityTitle {
  const scoreMap = scores
  const entries = Object.entries(scoreMap) as [string, number][]
  entries.sort((a, b) => b[1] - a[1])
  const top1 = entries[0][0]

  // Special combinations
  if (scores.H >= 70 && scores.A >= 70) {
    return {
      titleKo: '천사표 인간',
      titleEn: 'Angel Among Us',
      emoji: '😇',
      descriptionKo: '정직하고 배려심 깊은 당신은 모두의 버팀목',
      descriptionEn: "Honest and caring, you are everyone's pillar",
    }
  }

  if (scores.X >= 70 && scores.O >= 70) {
    return {
      titleKo: '인싸 크리에이터',
      titleEn: 'Social Creator',
      emoji: '🎪',
      descriptionKo: '어디서든 주목받는 창의적 에너지',
      descriptionEn: 'Creative energy that shines everywhere',
    }
  }

  if (scores.C >= 70 && scores.H >= 70) {
    return {
      titleKo: '믿음직한 MVP',
      titleEn: 'Reliable MVP',
      emoji: '🏆',
      descriptionKo: '성실하고 정직한 당신은 팀의 핵심',
      descriptionEn: "Diligent and honest, you are the team's core",
    }
  }

  if (scores.E >= 70 && scores.A >= 70) {
    return {
      titleKo: '힐링 요정',
      titleEn: 'Healing Fairy',
      emoji: '🧚',
      descriptionKo: '따뜻한 공감으로 모두를 치유하는 존재',
      descriptionEn: 'A being who heals everyone with warm empathy',
    }
  }

  if (scores.X >= 70 && scores.A >= 70) {
    return {
      titleKo: '분위기 메이커',
      titleEn: 'Mood Maker',
      emoji: '🎉',
      descriptionKo: '밝은 에너지로 모든 모임을 즐겁게!',
      descriptionEn: 'Making every gathering fun with bright energy!',
    }
  }

  if (scores.C >= 70 && scores.O >= 70) {
    return {
      titleKo: '비전 실행가',
      titleEn: 'Vision Executor',
      emoji: '🚀',
      descriptionKo: '꿈을 현실로 만드는 전략적 창의가',
      descriptionEn: 'A strategic creative who makes dreams reality',
    }
  }

  if (scores.E < 40 && scores.C >= 70) {
    return {
      titleKo: '냉철한 프로',
      titleEn: 'Cool Professional',
      emoji: '🎯',
      descriptionKo: '감정에 휘둘리지 않는 철저한 실행력',
      descriptionEn: 'Thorough execution unswayed by emotions',
    }
  }

  if (scores.X < 40 && scores.O >= 70) {
    return {
      titleKo: '몽상가 천재',
      titleEn: 'Dreamer Genius',
      emoji: '💭',
      descriptionKo: '조용히 세상을 바꾸는 아이디어 뱅크',
      descriptionEn: 'Quietly changing the world with ideas',
    }
  }

  if (scores.H < 40 && scores.C >= 70) {
    return {
      titleKo: '야망의 전략가',
      titleEn: 'Ambitious Strategist',
      emoji: '♟️',
      descriptionKo: '목표를 위해 모든 것을 계획하는 당신',
      descriptionEn: 'Planning everything for your goals',
    }
  }

  if (scores.A < 40 && scores.X >= 70) {
    return {
      titleKo: '카리스마 리더',
      titleEn: 'Charismatic Leader',
      emoji: '👑',
      descriptionKo: '주장이 뚜렷한 당당한 리더십',
      descriptionEn: 'Confident leadership with clear opinions',
    }
  }

  // Single top factor
  const singleTitles: Record<string, PersonalityTitle> = {
    H: {
      titleKo: '진심 100% 인간',
      titleEn: '100% Genuine Soul',
      emoji: '💎',
      descriptionKo: '거짓 없이 살아가는 맑은 영혼',
      descriptionEn: 'A pure soul living without pretense',
    },
    E: {
      titleKo: '공감왕',
      titleEn: 'Empathy King',
      emoji: '💝',
      descriptionKo: '모든 감정을 함께 느끼는 섬세한 존재',
      descriptionEn: 'A sensitive being feeling all emotions together',
    },
    X: {
      titleKo: '에너지 폭탄',
      titleEn: 'Energy Bomb',
      emoji: '⚡',
      descriptionKo: '어디서든 활력을 불어넣는 존재',
      descriptionEn: 'A being that brings energy everywhere',
    },
    A: {
      titleKo: '평화의 수호자',
      titleEn: 'Peace Guardian',
      emoji: '🕊️',
      descriptionKo: '갈등을 조율하는 조화의 달인',
      descriptionEn: 'A master of harmony who mediates conflicts',
    },
    C: {
      titleKo: '계획의 신',
      titleEn: 'Planning God',
      emoji: '📋',
      descriptionKo: '모든 것을 체계적으로 완수하는 당신',
      descriptionEn: 'You who systematically complete everything',
    },
    O: {
      titleKo: '상상력 부자',
      titleEn: 'Imagination Rich',
      emoji: '🌈',
      descriptionKo: '끝없는 호기심으로 세상을 탐험',
      descriptionEn: 'Exploring the world with endless curiosity',
    },
  }

  return singleTitles[top1] || {
    titleKo: '다재다능 만능인',
    titleEn: 'Versatile Talent',
    emoji: '⭐',
    descriptionKo: '모든 면에서 균형 잡힌 멋진 사람',
    descriptionEn: 'A wonderful person balanced in all aspects',
  }
}

function getHMeme(score: number): MemeQuote {
  if (score >= 80) return { factor: 'H', quoteKo: '거짓말하면 얼굴에 다 써있는 타입', quoteEn: 'Type whose face shows every lie', emoji: '🫣' }
  if (score >= 60) return { factor: 'H', quoteKo: '양심이 살아있어서 범죄 못 저지르는 타입', quoteEn: "Type who can't commit crimes due to conscience", emoji: '😇' }
  if (score >= 40) return { factor: 'H', quoteKo: '선의의 거짓말은 가끔 필요하다고 믿는 타입', quoteEn: 'Type who believes white lies are sometimes needed', emoji: '🤫' }
  if (score >= 20) return { factor: 'H', quoteKo: '협상의 달인, 원하는 건 꼭 얻어내는 타입', quoteEn: 'Master negotiator who always gets what they want', emoji: '🤝' }
  return { factor: 'H', quoteKo: '정글의 법칙을 몸소 실천하는 야망가', quoteEn: 'Ambitious one living by the law of the jungle', emoji: '🦁' }
}

function getEMeme(score: number): MemeQuote {
  if (score >= 80) return { factor: 'E', quoteKo: '슬픈 영화 보면 3일은 우는 감성 폭탄', quoteEn: 'Emotional bomb crying 3 days after sad movies', emoji: '😭' }
  if (score >= 60) return { factor: 'E', quoteKo: '친구 고민 상담하다가 같이 우는 타입', quoteEn: 'Type who cries with friends during their problems', emoji: '🥺' }
  if (score >= 40) return { factor: 'E', quoteKo: '감정과 이성 사이 줄타기 마스터', quoteEn: 'Master of walking the line between emotion and logic', emoji: '⚖️' }
  if (score >= 20) return { factor: 'E', quoteKo: '공포영화 보면서 팝콘 먹는 강심장', quoteEn: 'Strong-hearted one eating popcorn during horror movies', emoji: '🍿' }
  return { factor: 'E', quoteKo: '좀비 아포칼립스에서 살아남을 자 여기 있다', quoteEn: 'Here stands the zombie apocalypse survivor', emoji: '🧟' }
}

function getXMeme(score: number): MemeQuote {
  if (score >= 80) return { factor: 'X', quoteKo: '모임에서 마이크 잡으면 안 놓는 타입', quoteEn: 'Type who never lets go of the mic at parties', emoji: '🎤' }
  if (score >= 60) return { factor: 'X', quoteKo: '혼자 있으면 배터리 방전되는 외향 충전 타입', quoteEn: 'Type whose battery drains when alone', emoji: '🔋' }
  if (score >= 40) return { factor: 'X', quoteKo: '인싸/아싸 스위치 자유자재 조절러', quoteEn: 'Free switch between social butterfly and homebody', emoji: '🎚️' }
  if (score >= 20) return { factor: 'X', quoteKo: '약속 취소 문자가 명절 보너스급 기쁨', quoteEn: 'Canceled plans feel like holiday bonuses', emoji: '🎁' }
  return { factor: 'X', quoteKo: '집이 최고야... 밖은 위험해...', quoteEn: 'Home is best... outside is dangerous...', emoji: '🏠' }
}

function getAMeme(score: number): MemeQuote {
  if (score >= 80) return { factor: 'A', quoteKo: '싸움 붙으면 둘 다 편드는 평화주의자', quoteEn: 'Peacemaker who sides with both in arguments', emoji: '☮️' }
  if (score >= 60) return { factor: 'A', quoteKo: '악플도 이해하려 노력하는 부처님 마인드', quoteEn: 'Buddha mindset trying to understand even haters', emoji: '🙏' }
  if (score >= 40) return { factor: 'A', quoteKo: '할 말은 하지만 상처는 안 주는 균형 달인', quoteEn: 'Balance master who speaks up without hurting', emoji: '💬' }
  if (score >= 20) return { factor: 'A', quoteKo: '옳은 소리에 타협 없는 정의의 용사', quoteEn: "Justice warrior uncompromising on what's right", emoji: '⚔️' }
  return { factor: 'A', quoteKo: '팩트 폭격기, 돌직구 장인', quoteEn: 'Fact bomber, master of brutal honesty', emoji: '💣' }
}

function getCMeme(score: number): MemeQuote {
  if (score >= 80) return { factor: 'C', quoteKo: '여행 가면 분 단위 일정표 짜는 타입', quoteEn: 'Type who makes minute-by-minute travel schedules', emoji: '📅' }
  if (score >= 60) return { factor: 'C', quoteKo: 'To-do 리스트 완료 체크가 최고의 힐링', quoteEn: 'Checking off to-do lists is the ultimate healing', emoji: '✅' }
  if (score >= 40) return { factor: 'C', quoteKo: '급한 일은 열심히, 나머지는 힘 빼기 달인', quoteEn: 'Works hard on urgent stuff, relaxes on the rest', emoji: '🎿' }
  if (score >= 20) return { factor: 'C', quoteKo: '마감 5분 전이 진정한 시작이다', quoteEn: '5 minutes before deadline is the real start', emoji: '⏰' }
  return { factor: 'C', quoteKo: '계획? 그게 뭔데요 먹는 건가요?', quoteEn: "Plans? What's that, is it edible?", emoji: '🤷' }
}

function getOMeme(score: number): MemeQuote {
  if (score >= 80) return { factor: 'O', quoteKo: '유튜브 알고리즘의 끝을 본 자', quoteEn: "One who's seen the end of YouTube algorithm", emoji: '🕳️' }
  if (score >= 60) return { factor: 'O', quoteKo: '새로운 취미 3개월 주기로 갈아타는 타입', quoteEn: 'Type who switches hobbies every 3 months', emoji: '🎨' }
  if (score >= 40) return { factor: 'O', quoteKo: '신기한 건 좋지만 검증된 것도 좋아', quoteEn: 'New things are cool but proven ones are nice too', emoji: '🔍' }
  if (score >= 20) return { factor: 'O', quoteKo: '인생 최애 메뉴 10년째 같은 거 시키는 중', quoteEn: 'Been ordering the same favorite menu for 10 years', emoji: '🍜' }
  return { factor: 'O', quoteKo: '변화? 현실은 실험실이 아닙니다', quoteEn: "Change? Reality isn't a laboratory", emoji: '🧪' }
}

export function getMemeQuotes(scores: Scores): MemeQuote[] {
  return [
    getHMeme(scores.H),
    getEMeme(scores.E),
    getXMeme(scores.X),
    getAMeme(scores.A),
    getCMeme(scores.C),
    getOMeme(scores.O),
  ]
}

export function getMainMemeQuote(scores: Scores): MemeQuote {
  const quotes = getMemeQuotes(scores)
  let maxDeviation = 0
  let mainQuote = quotes[0]

  const scoreArr = [scores.H, scores.E, scores.X, scores.A, scores.C, scores.O]
  for (let i = 0; i < quotes.length; i++) {
    const deviation = Math.abs(scoreArr[i] - 50)
    if (deviation > maxDeviation) {
      maxDeviation = deviation
      mainQuote = quotes[i]
    }
  }

  return mainQuote
}

export function getCharacterMatch(scores: Scores): CharacterMatch {
  const entries = Object.entries(scores) as [string, number][]
  entries.sort((a, b) => b[1] - a[1])
  const top1 = entries[0][0]

  // Combination-based matching
  if (scores.H >= 65 && scores.C >= 65) {
    return { nameKo: '세종대왕', nameEn: 'King Sejong', source: '역사', emoji: '📖', reasonKo: '정직함과 성실함으로 백성을 섬긴 성군', reasonEn: 'A great king who served with honesty and diligence' }
  }
  if (scores.X >= 65 && scores.E >= 65) {
    return { nameKo: '김삼순 (내 이름은 김삼순)', nameEn: 'Kim Sam-soon', source: '드라마', emoji: '🧁', reasonKo: '감성적이고 활발한 사랑스러운 캐릭터', reasonEn: 'Emotional and lively lovable character' }
  }
  if (scores.C >= 65 && scores.A < 40) {
    return { nameKo: '장그래 (미생)', nameEn: 'Jang Geu-rae (Misaeng)', source: '드라마', emoji: '📊', reasonKo: '묵묵히 자신의 길을 걸어가는 성실한 영혼', reasonEn: 'A diligent soul quietly walking their own path' }
  }
  if (scores.X >= 65 && scores.H >= 65) {
    return { nameKo: '도깨비 (공유)', nameEn: 'Goblin (Gong Yoo)', source: '드라마', emoji: '✨', reasonKo: '카리스마 있으면서도 진심을 담은 존재', reasonEn: 'A charismatic being with genuine heart' }
  }
  if (scores.O >= 65 && scores.X < 40) {
    return { nameKo: '셜록 홈즈', nameEn: 'Sherlock Holmes', source: '문학/영화', emoji: '🔎', reasonKo: '천재적 통찰력을 가진 내향적 탐구자', reasonEn: 'An introverted explorer with genius insight' }
  }
  if (scores.E >= 65 && scores.A >= 65) {
    return { nameKo: '김복주 (역도요정 김복주)', nameEn: 'Kim Bok-joo', source: '드라마', emoji: '💪', reasonKo: '따뜻한 마음으로 주변을 감싸는 캐릭터', reasonEn: 'A character who embraces others with warmth' }
  }
  if (scores.H < 40 && scores.X >= 65) {
    return { nameKo: '빈센조 (빈센조)', nameEn: 'Vincenzo', source: '드라마', emoji: '🖤', reasonKo: '야망과 카리스마를 겸비한 다크히어로', reasonEn: 'A dark hero with ambition and charisma' }
  }
  if (scores.A >= 65 && scores.C >= 65) {
    return { nameKo: '데어데블', nameEn: 'Daredevil', source: '마블', emoji: '⚖️', reasonKo: '정의롭고 책임감 있는 수호자', reasonEn: 'A righteous and responsible guardian' }
  }

  // Single factor based
  const singleMatches: Record<string, CharacterMatch> = {
    H: { nameKo: '강마루 (그 겨울 바람이 분다)', nameEn: 'Kang Ma-ru', source: '드라마', emoji: '❄️', reasonKo: '순수하고 정직한 영혼의 소유자', reasonEn: 'Owner of a pure and honest soul' },
    E: { nameKo: '윤세리 (사랑의 불시착)', nameEn: 'Yoon Se-ri', source: '드라마', emoji: '💖', reasonKo: '감정이 풍부하고 사랑에 충실한 캐릭터', reasonEn: 'Emotionally rich and faithful in love' },
    X: { nameKo: '토니 스타크', nameEn: 'Tony Stark', source: '마블', emoji: '🦸', reasonKo: '자신감 넘치는 활발한 천재', reasonEn: 'A confident and lively genius' },
    A: { nameKo: '이민호 (더 킹: 영원의 군주)', nameEn: 'Lee Gon', source: '드라마', emoji: '👑', reasonKo: '배려심 깊고 조화를 추구하는 리더', reasonEn: 'A considerate leader who seeks harmony' },
    C: { nameKo: '캡틴 아메리카', nameEn: 'Captain America', source: '마블', emoji: '🛡️', reasonKo: '원칙을 지키는 책임감 있는 리더', reasonEn: 'A responsible leader who keeps principles' },
    O: { nameKo: '엘리 (업)', nameEn: 'Ellie (Up)', source: '디즈니/픽사', emoji: '🎈', reasonKo: '모험을 꿈꾸는 호기심 가득한 영혼', reasonEn: 'A curious soul dreaming of adventure' },
  }

  return singleMatches[top1] || { nameKo: '스파이더맨', nameEn: 'Spider-Man', source: '마블', emoji: '🕷️', reasonKo: '다재다능하고 균형 잡힌 영웅', reasonEn: 'A versatile and balanced hero' }
}

export function getMBTIMatch(scores: Scores): MBTIMatch {
  let mbti = ''
  mbti += scores.X >= 50 ? 'E' : 'I'
  mbti += scores.O >= 50 ? 'N' : 'S'
  mbti += scores.A >= 50 ? 'F' : 'T'
  mbti += scores.C >= 50 ? 'J' : 'P'

  const descriptionsKo: Record<string, string> = {
    ENFJ: '정의로운 사회운동가', ENFP: '재기발랄한 활동가',
    ENTJ: '대담한 통솔자', ENTP: '뜨거운 논쟁을 즐기는 변론가',
    ESFJ: '사교적인 외교관', ESFP: '자유로운 영혼의 연예인',
    ESTJ: '엄격한 관리자', ESTP: '모험을 즐기는 사업가',
    INFJ: '선의의 옹호자', INFP: '열정적인 중재자',
    INTJ: '용의주도한 전략가', INTP: '논리적인 사색가',
    ISFJ: '용감한 수호자', ISFP: '호기심 많은 예술가',
    ISTJ: '청렴결백한 논리주의자', ISTP: '만능 재주꾼',
  }

  const descriptionsEn: Record<string, string> = {
    ENFJ: 'The Protagonist', ENFP: 'The Campaigner',
    ENTJ: 'The Commander', ENTP: 'The Debater',
    ESFJ: 'The Consul', ESFP: 'The Entertainer',
    ESTJ: 'The Executive', ESTP: 'The Entrepreneur',
    INFJ: 'The Advocate', INFP: 'The Mediator',
    INTJ: 'The Architect', INTP: 'The Logician',
    ISFJ: 'The Defender', ISFP: 'The Adventurer',
    ISTJ: 'The Logistician', ISTP: 'The Virtuoso',
  }

  return {
    mbti,
    descriptionKo: descriptionsKo[mbti] || '독특한 성격의 소유자',
    descriptionEn: descriptionsEn[mbti] || 'Unique Personality',
  }
}
