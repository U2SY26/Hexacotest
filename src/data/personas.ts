export interface Persona {
  id: string
  name: {
    ko: string
    en: string
  }
  category: 'celebrity' | 'artist' | 'politician' | 'entrepreneur'
  image: string
  description: {
    ko: string
    en: string
  }
  scores: {
    H: number
    E: number
    X: number
    A: number
    C: number
    O: number
  }
}

export const personas: Persona[] = [
  // 연예인
  {
    id: 'iu',
    name: { ko: '아이유', en: 'IU' },
    category: 'celebrity',
    image: '/personas/iu.jpg',
    description: {
      ko: '섬세한 감성과 겸손함을 갖춘 아티스트로, 자신만의 세계를 구축하면서도 타인을 배려하는 따뜻한 성격입니다.',
      en: 'An artist with delicate sensitivity and humility, building her own world while caring for others.'
    },
    scores: { H: 85, E: 70, X: 55, A: 80, C: 85, O: 90 }
  },
  {
    id: 'bts-jimin',
    name: { ko: 'BTS 지민', en: 'BTS Jimin' },
    category: 'celebrity',
    image: '/personas/jimin.jpg',
    description: {
      ko: '완벽주의적 성향과 높은 감수성을 가진 아티스트로, 무대 위에서 강렬한 카리스마를 발휘합니다.',
      en: 'A perfectionist artist with high sensitivity, showing intense charisma on stage.'
    },
    scores: { H: 75, E: 80, X: 75, A: 85, C: 95, O: 85 }
  },
  {
    id: 'yoo-jaesuk',
    name: { ko: '유재석', en: 'Yoo Jae-suk' },
    category: 'celebrity',
    image: '/personas/yoojaesuk.jpg',
    description: {
      ko: '국민 MC로서 높은 도덕성과 겸손함, 뛰어난 사교성과 배려심을 갖춘 인물입니다.',
      en: 'As a national MC, known for high morality, humility, excellent sociability and consideration.'
    },
    scores: { H: 95, E: 50, X: 90, A: 90, C: 90, O: 65 }
  },

  // 예술가
  {
    id: 'van-gogh',
    name: { ko: '빈센트 반 고흐', en: 'Vincent van Gogh' },
    category: 'artist',
    image: '/personas/vangogh.jpg',
    description: {
      ko: '깊은 감정과 강렬한 내면 세계를 작품에 담아낸 후기 인상파의 거장입니다.',
      en: 'A Post-Impressionist master who captured deep emotions and intense inner world in his works.'
    },
    scores: { H: 80, E: 95, X: 35, A: 60, C: 70, O: 98 }
  },
  {
    id: 'da-vinci',
    name: { ko: '레오나르도 다빈치', en: 'Leonardo da Vinci' },
    category: 'artist',
    image: '/personas/davinci.jpg',
    description: {
      ko: '예술과 과학을 아우르는 천재적 창의성과 끊임없는 호기심의 소유자입니다.',
      en: 'A genius with creativity spanning art and science, driven by endless curiosity.'
    },
    scores: { H: 70, E: 45, X: 50, A: 55, C: 85, O: 99 }
  },
  {
    id: 'paik-namjune',
    name: { ko: '백남준', en: 'Nam June Paik' },
    category: 'artist',
    image: '/personas/namjunepaik.jpg',
    description: {
      ko: '비디오 아트의 선구자로, 전위적이고 실험적인 작품 세계를 개척했습니다.',
      en: 'Pioneer of video art who created an avant-garde and experimental body of work.'
    },
    scores: { H: 65, E: 55, X: 70, A: 50, C: 60, O: 98 }
  },

  // 정치인
  {
    id: 'sejong',
    name: { ko: '세종대왕', en: 'King Sejong' },
    category: 'politician',
    image: '/personas/sejong.jpg',
    description: {
      ko: '백성을 사랑하고 학문을 장려한 조선의 성군으로, 한글 창제의 업적을 남겼습니다.',
      en: 'A sage king of Joseon who loved his people and promoted learning, creating the Korean alphabet.'
    },
    scores: { H: 95, E: 65, X: 60, A: 85, C: 95, O: 90 }
  },
  {
    id: 'lincoln',
    name: { ko: '에이브러햄 링컨', en: 'Abraham Lincoln' },
    category: 'politician',
    image: '/personas/lincoln.jpg',
    description: {
      ko: '노예 해방을 이끈 미국의 16대 대통령으로, 정의와 평등의 가치를 실현했습니다.',
      en: 'The 16th US President who led the abolition of slavery, realizing justice and equality.'
    },
    scores: { H: 90, E: 70, X: 55, A: 75, C: 85, O: 75 }
  },
  {
    id: 'mandela',
    name: { ko: '넬슨 만델라', en: 'Nelson Mandela' },
    category: 'politician',
    image: '/personas/mandela.jpg',
    description: {
      ko: '남아프리카공화국의 아파르트헤이트 종식을 이끈 인권 운동가이자 대통령입니다.',
      en: 'Human rights activist and president who led the end of apartheid in South Africa.'
    },
    scores: { H: 95, E: 60, X: 70, A: 90, C: 90, O: 80 }
  },

  // 경제인
  {
    id: 'steve-jobs',
    name: { ko: '스티브 잡스', en: 'Steve Jobs' },
    category: 'entrepreneur',
    image: '/personas/jobs.jpg',
    description: {
      ko: '애플의 공동 창립자로, 혁신적인 비전과 완벽주의로 기술 산업을 변화시켰습니다.',
      en: 'Co-founder of Apple who transformed the tech industry with innovative vision and perfectionism.'
    },
    scores: { H: 45, E: 55, X: 80, A: 30, C: 95, O: 95 }
  },
  {
    id: 'elon-musk',
    name: { ko: '일론 머스크', en: 'Elon Musk' },
    category: 'entrepreneur',
    image: '/personas/musk.jpg',
    description: {
      ko: '테슬라와 스페이스X의 CEO로, 대담한 비전과 도전 정신으로 미래를 개척합니다.',
      en: 'CEO of Tesla and SpaceX, pioneering the future with bold vision and challenging spirit.'
    },
    scores: { H: 40, E: 35, X: 75, A: 25, C: 80, O: 98 }
  },
  {
    id: 'chung-juyung',
    name: { ko: '정주영', en: 'Chung Ju-yung' },
    category: 'entrepreneur',
    image: '/personas/chungjuyung.jpg',
    description: {
      ko: '현대그룹의 창업자로, 불굴의 도전 정신과 근면함으로 한국 경제 발전에 기여했습니다.',
      en: 'Founder of Hyundai Group, contributing to Korean economic development with indomitable spirit.'
    },
    scores: { H: 65, E: 40, X: 85, A: 45, C: 98, O: 70 }
  }
]

export const categoryColors: Record<Persona['category'], string> = {
  celebrity: '#EC4899',
  artist: '#8B5CF6',
  politician: '#3B82F6',
  entrepreneur: '#10B981'
}
