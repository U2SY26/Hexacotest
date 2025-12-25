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
  sourceUrl: string
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
  {
    id: 'celebrity-001',
    name: { ko: '아이유', en: 'IU' },
    category: 'celebrity',
    image: '/personas/celebrity-001.jpg',
    description: {
      ko: '대중성과 전문성을 겸비해 꾸준한 신뢰를 쌓아가는 스타일입니다.',
      en: 'You balance popularity with professionalism and build steady trust over time.'
    },
    sourceUrl: 'https://namu.wiki/w/아이유',
    scores: { H: 45, E: 70, X: 46, A: 61, C: 71, O: 87 }
  },
  {
    id: 'celebrity-002',
    name: { ko: '지드래곤', en: 'G-Dragon' },
    category: 'celebrity',
    image: '/personas/celebrity-002.jpg',
    description: {
      ko: '몰입도가 높고 무대나 현장에서 집중력을 잘 유지합니다.',
      en: 'You show high focus and maintain strong concentration in performance.'
    },
    sourceUrl: 'https://namu.wiki/w/지드래곤',
    scores: { H: 94, E: 49, X: 32, A: 55, C: 40, O: 71 }
  },
  {
    id: 'celebrity-003',
    name: { ko: '태연', en: 'Taeyeon' },
    category: 'celebrity',
    image: '/personas/celebrity-003.jpg',
    description: {
      ko: '친화력이 좋아 팀워크와 협업에 강점을 보입니다.',
      en: 'You are sociable and strong in teamwork and collaboration.'
    },
    sourceUrl: 'https://namu.wiki/w/태연',
    scores: { H: 45, E: 94, X: 74, A: 38, C: 38, O: 48 }
  },
  {
    id: 'celebrity-004',
    name: { ko: '손흥민', en: 'Son Heung-min' },
    category: 'celebrity',
    image: '/personas/celebrity-004.jpg',
    description: {
      ko: '도전적인 목표에도 꾸준히 성과를 내는 성실한 유형입니다.',
      en: 'You stay diligent and deliver results even with challenging goals.'
    },
    sourceUrl: 'https://namu.wiki/w/손흥민',
    scores: { H: 35, E: 27, X: 45, A: 76, C: 39, O: 91 }
  },
  {
    id: 'celebrity-005',
    name: { ko: '김연아', en: 'Kim Yuna' },
    category: 'celebrity',
    image: '/personas/celebrity-005.jpg',
    description: {
      ko: '표현력이 풍부해 감정과 메시지를 잘 전달합니다.',
      en: 'You express feelings and messages clearly with rich communication.'
    },
    sourceUrl: 'https://namu.wiki/w/김연아',
    scores: { H: 33, E: 27, X: 46, A: 39, C: 64, O: 36 }
  },
  {
    id: 'celebrity-006',
    name: { ko: '유재석', en: 'Yoo Jae-suk' },
    category: 'celebrity',
    image: '/personas/celebrity-006.jpg',
    description: {
      ko: '대중성과 전문성을 겸비해 꾸준한 신뢰를 쌓아가는 스타일입니다.',
      en: 'You balance popularity with professionalism and build steady trust over time.'
    },
    sourceUrl: 'https://namu.wiki/w/유재석',
    scores: { H: 32, E: 38, X: 40, A: 40, C: 30, O: 43 }
  },
  {
    id: 'celebrity-007',
    name: { ko: '강호동', en: '강호동' },
    category: 'celebrity',
    image: '/personas/celebrity-007.jpg',
    description: {
      ko: '몰입도가 높고 무대나 현장에서 집중력을 잘 유지합니다.',
      en: 'You show high focus and maintain strong concentration in performance.'
    },
    sourceUrl: 'https://namu.wiki/w/강호동',
    scores: { H: 88, E: 71, X: 30, A: 44, C: 94, O: 47 }
  },
  {
    id: 'celebrity-008',
    name: { ko: '박보검', en: '박보검' },
    category: 'celebrity',
    image: '/personas/celebrity-008.jpg',
    description: {
      ko: '친화력이 좋아 팀워크와 협업에 강점을 보입니다.',
      en: 'You are sociable and strong in teamwork and collaboration.'
    },
    sourceUrl: 'https://namu.wiki/w/박보검',
    scores: { H: 53, E: 47, X: 74, A: 90, C: 57, O: 32 }
  },
  {
    id: 'celebrity-009',
    name: { ko: '송중기', en: '송중기' },
    category: 'celebrity',
    image: '/personas/celebrity-009.jpg',
    description: {
      ko: '도전적인 목표에도 꾸준히 성과를 내는 성실한 유형입니다.',
      en: 'You stay diligent and deliver results even with challenging goals.'
    },
    sourceUrl: 'https://namu.wiki/w/송중기',
    scores: { H: 29, E: 89, X: 28, A: 49, C: 44, O: 37 }
  },
  {
    id: 'celebrity-010',
    name: { ko: '전지현', en: '전지현' },
    category: 'celebrity',
    image: '/personas/celebrity-010.jpg',
    description: {
      ko: '표현력이 풍부해 감정과 메시지를 잘 전달합니다.',
      en: 'You express feelings and messages clearly with rich communication.'
    },
    sourceUrl: 'https://namu.wiki/w/전지현',
    scores: { H: 32, E: 47, X: 75, A: 44, C: 54, O: 54 }
  },
  {
    id: 'celebrity-011',
    name: { ko: '김태희', en: '김태희' },
    category: 'celebrity',
    image: '/personas/celebrity-011.jpg',
    description: {
      ko: '대중성과 전문성을 겸비해 꾸준한 신뢰를 쌓아가는 스타일입니다.',
      en: 'You balance popularity with professionalism and build steady trust over time.'
    },
    sourceUrl: 'https://namu.wiki/w/김태희',
    scores: { H: 90, E: 89, X: 85, A: 64, C: 41, O: 68 }
  },
  {
    id: 'celebrity-012',
    name: { ko: '정우성', en: '정우성' },
    category: 'celebrity',
    image: '/personas/celebrity-012.jpg',
    description: {
      ko: '몰입도가 높고 무대나 현장에서 집중력을 잘 유지합니다.',
      en: 'You show high focus and maintain strong concentration in performance.'
    },
    sourceUrl: 'https://namu.wiki/w/정우성',
    scores: { H: 56, E: 59, X: 93, A: 44, C: 38, O: 47 }
  },
  {
    id: 'celebrity-013',
    name: { ko: '공유', en: '공유' },
    category: 'celebrity',
    image: '/personas/celebrity-013.jpg',
    description: {
      ko: '친화력이 좋아 팀워크와 협업에 강점을 보입니다.',
      en: 'You are sociable and strong in teamwork and collaboration.'
    },
    sourceUrl: 'https://namu.wiki/w/공유',
    scores: { H: 89, E: 50, X: 40, A: 55, C: 84, O: 27 }
  },
  {
    id: 'celebrity-014',
    name: { ko: '현빈', en: '현빈' },
    category: 'celebrity',
    image: '/personas/celebrity-014.jpg',
    description: {
      ko: '도전적인 목표에도 꾸준히 성과를 내는 성실한 유형입니다.',
      en: 'You stay diligent and deliver results even with challenging goals.'
    },
    sourceUrl: 'https://namu.wiki/w/현빈',
    scores: { H: 42, E: 95, X: 73, A: 80, C: 63, O: 87 }
  },
  {
    id: 'celebrity-015',
    name: { ko: '손예진', en: '손예진' },
    category: 'celebrity',
    image: '/personas/celebrity-015.jpg',
    description: {
      ko: '표현력이 풍부해 감정과 메시지를 잘 전달합니다.',
      en: 'You express feelings and messages clearly with rich communication.'
    },
    sourceUrl: 'https://namu.wiki/w/손예진',
    scores: { H: 28, E: 31, X: 51, A: 59, C: 33, O: 53 }
  },
  {
    id: 'celebrity-016',
    name: { ko: '박서준', en: '박서준' },
    category: 'celebrity',
    image: '/personas/celebrity-016.jpg',
    description: {
      ko: '대중성과 전문성을 겸비해 꾸준한 신뢰를 쌓아가는 스타일입니다.',
      en: 'You balance popularity with professionalism and build steady trust over time.'
    },
    sourceUrl: 'https://namu.wiki/w/박서준',
    scores: { H: 52, E: 54, X: 75, A: 41, C: 91, O: 55 }
  },
  {
    id: 'celebrity-017',
    name: { ko: '이정재', en: '이정재' },
    category: 'celebrity',
    image: '/personas/celebrity-017.jpg',
    description: {
      ko: '몰입도가 높고 무대나 현장에서 집중력을 잘 유지합니다.',
      en: 'You show high focus and maintain strong concentration in performance.'
    },
    sourceUrl: 'https://namu.wiki/w/이정재',
    scores: { H: 73, E: 73, X: 41, A: 25, C: 40, O: 38 }
  },
  {
    id: 'celebrity-018',
    name: { ko: '하정우', en: '하정우' },
    category: 'celebrity',
    image: '/personas/celebrity-018.jpg',
    description: {
      ko: '친화력이 좋아 팀워크와 협업에 강점을 보입니다.',
      en: 'You are sociable and strong in teamwork and collaboration.'
    },
    sourceUrl: 'https://namu.wiki/w/하정우',
    scores: { H: 77, E: 53, X: 85, A: 85, C: 59, O: 51 }
  },
  {
    id: 'celebrity-019',
    name: { ko: '이병헌', en: '이병헌' },
    category: 'celebrity',
    image: '/personas/celebrity-019.jpg',
    description: {
      ko: '도전적인 목표에도 꾸준히 성과를 내는 성실한 유형입니다.',
      en: 'You stay diligent and deliver results even with challenging goals.'
    },
    sourceUrl: 'https://namu.wiki/w/이병헌',
    scores: { H: 32, E: 41, X: 68, A: 89, C: 30, O: 88 }
  },
  {
    id: 'celebrity-020',
    name: { ko: '김수현', en: '김수현' },
    category: 'celebrity',
    image: '/personas/celebrity-020.jpg',
    description: {
      ko: '표현력이 풍부해 감정과 메시지를 잘 전달합니다.',
      en: 'You express feelings and messages clearly with rich communication.'
    },
    sourceUrl: 'https://namu.wiki/w/김수현',
    scores: { H: 82, E: 78, X: 95, A: 39, C: 58, O: 58 }
  },
  {
    id: 'celebrity-021',
    name: { ko: '배수지', en: '배수지' },
    category: 'celebrity',
    image: '/personas/celebrity-021.jpg',
    description: {
      ko: '대중성과 전문성을 겸비해 꾸준한 신뢰를 쌓아가는 스타일입니다.',
      en: 'You balance popularity with professionalism and build steady trust over time.'
    },
    sourceUrl: 'https://namu.wiki/w/배수지',
    scores: { H: 35, E: 70, X: 93, A: 68, C: 27, O: 38 }
  },
  {
    id: 'celebrity-022',
    name: { ko: '이효리', en: '이효리' },
    category: 'celebrity',
    image: '/personas/celebrity-022.jpg',
    description: {
      ko: '몰입도가 높고 무대나 현장에서 집중력을 잘 유지합니다.',
      en: 'You show high focus and maintain strong concentration in performance.'
    },
    sourceUrl: 'https://namu.wiki/w/이효리',
    scores: { H: 36, E: 45, X: 56, A: 33, C: 44, O: 65 }
  },
  {
    id: 'celebrity-023',
    name: { ko: '보아', en: '보아' },
    category: 'celebrity',
    image: '/personas/celebrity-023.jpg',
    description: {
      ko: '친화력이 좋아 팀워크와 협업에 강점을 보입니다.',
      en: 'You are sociable and strong in teamwork and collaboration.'
    },
    sourceUrl: 'https://namu.wiki/w/보아',
    scores: { H: 50, E: 93, X: 25, A: 78, C: 68, O: 27 }
  },
  {
    id: 'celebrity-024',
    name: { ko: '임윤아', en: '임윤아' },
    category: 'celebrity',
    image: '/personas/celebrity-024.jpg',
    description: {
      ko: '도전적인 목표에도 꾸준히 성과를 내는 성실한 유형입니다.',
      en: 'You stay diligent and deliver results even with challenging goals.'
    },
    sourceUrl: 'https://namu.wiki/w/임윤아',
    scores: { H: 65, E: 27, X: 32, A: 73, C: 35, O: 42 }
  },
  {
    id: 'celebrity-025',
    name: { ko: '서현진', en: '서현진' },
    category: 'celebrity',
    image: '/personas/celebrity-025.jpg',
    description: {
      ko: '표현력이 풍부해 감정과 메시지를 잘 전달합니다.',
      en: 'You express feelings and messages clearly with rich communication.'
    },
    sourceUrl: 'https://namu.wiki/w/서현진',
    scores: { H: 55, E: 56, X: 77, A: 47, C: 88, O: 50 }
  },
  {
    id: 'celebrity-026',
    name: { ko: '김고은', en: '김고은' },
    category: 'celebrity',
    image: '/personas/celebrity-026.jpg',
    description: {
      ko: '대중성과 전문성을 겸비해 꾸준한 신뢰를 쌓아가는 스타일입니다.',
      en: 'You balance popularity with professionalism and build steady trust over time.'
    },
    sourceUrl: 'https://namu.wiki/w/김고은',
    scores: { H: 68, E: 62, X: 30, A: 88, C: 52, O: 26 }
  },
  {
    id: 'celebrity-027',
    name: { ko: '박신혜', en: '박신혜' },
    category: 'celebrity',
    image: '/personas/celebrity-027.jpg',
    description: {
      ko: '몰입도가 높고 무대나 현장에서 집중력을 잘 유지합니다.',
      en: 'You show high focus and maintain strong concentration in performance.'
    },
    sourceUrl: 'https://namu.wiki/w/박신혜',
    scores: { H: 59, E: 28, X: 53, A: 26, C: 79, O: 92 }
  },
  {
    id: 'celebrity-028',
    name: { ko: '한지민', en: '한지민' },
    category: 'celebrity',
    image: '/personas/celebrity-028.jpg',
    description: {
      ko: '친화력이 좋아 팀워크와 협업에 강점을 보입니다.',
      en: 'You are sociable and strong in teamwork and collaboration.'
    },
    sourceUrl: 'https://namu.wiki/w/한지민',
    scores: { H: 56, E: 68, X: 81, A: 53, C: 37, O: 87 }
  },
  {
    id: 'celebrity-029',
    name: { ko: '김혜수', en: '김혜수' },
    category: 'celebrity',
    image: '/personas/celebrity-029.jpg',
    description: {
      ko: '도전적인 목표에도 꾸준히 성과를 내는 성실한 유형입니다.',
      en: 'You stay diligent and deliver results even with challenging goals.'
    },
    sourceUrl: 'https://namu.wiki/w/김혜수',
    scores: { H: 79, E: 59, X: 41, A: 67, C: 76, O: 56 }
  },
  {
    id: 'celebrity-030',
    name: { ko: '임영웅', en: '임영웅' },
    category: 'celebrity',
    image: '/personas/celebrity-030.jpg',
    description: {
      ko: '표현력이 풍부해 감정과 메시지를 잘 전달합니다.',
      en: 'You express feelings and messages clearly with rich communication.'
    },
    sourceUrl: 'https://namu.wiki/w/임영웅',
    scores: { H: 31, E: 26, X: 65, A: 73, C: 29, O: 75 }
  },
  {
    id: 'celebrity-031',
    name: { ko: '나훈아', en: '나훈아' },
    category: 'celebrity',
    image: '/personas/celebrity-031.jpg',
    description: {
      ko: '대중성과 전문성을 겸비해 꾸준한 신뢰를 쌓아가는 스타일입니다.',
      en: 'You balance popularity with professionalism and build steady trust over time.'
    },
    sourceUrl: 'https://namu.wiki/w/나훈아',
    scores: { H: 38, E: 90, X: 62, A: 89, C: 38, O: 77 }
  },
  {
    id: 'celebrity-032',
    name: { ko: '박세리', en: '박세리' },
    category: 'celebrity',
    image: '/personas/celebrity-032.jpg',
    description: {
      ko: '몰입도가 높고 무대나 현장에서 집중력을 잘 유지합니다.',
      en: 'You show high focus and maintain strong concentration in performance.'
    },
    sourceUrl: 'https://namu.wiki/w/박세리',
    scores: { H: 25, E: 75, X: 61, A: 71, C: 37, O: 87 }
  },
  {
    id: 'celebrity-033',
    name: { ko: '류현진', en: '류현진' },
    category: 'celebrity',
    image: '/personas/celebrity-033.jpg',
    description: {
      ko: '친화력이 좋아 팀워크와 협업에 강점을 보입니다.',
      en: 'You are sociable and strong in teamwork and collaboration.'
    },
    sourceUrl: 'https://namu.wiki/w/류현진',
    scores: { H: 79, E: 42, X: 66, A: 81, C: 44, O: 46 }
  },
  {
    id: 'celebrity-034',
    name: { ko: '박지성', en: '박지성' },
    category: 'celebrity',
    image: '/personas/celebrity-034.jpg',
    description: {
      ko: '도전적인 목표에도 꾸준히 성과를 내는 성실한 유형입니다.',
      en: 'You stay diligent and deliver results even with challenging goals.'
    },
    sourceUrl: 'https://namu.wiki/w/박지성',
    scores: { H: 88, E: 63, X: 82, A: 53, C: 35, O: 94 }
  },
  {
    id: 'celebrity-035',
    name: { ko: '이강인', en: '이강인' },
    category: 'celebrity',
    image: '/personas/celebrity-035.jpg',
    description: {
      ko: '표현력이 풍부해 감정과 메시지를 잘 전달합니다.',
      en: 'You express feelings and messages clearly with rich communication.'
    },
    sourceUrl: 'https://namu.wiki/w/이강인',
    scores: { H: 67, E: 32, X: 61, A: 43, C: 49, O: 88 }
  },
  {
    id: 'celebrity-036',
    name: { ko: '황희찬', en: '황희찬' },
    category: 'celebrity',
    image: '/personas/celebrity-036.jpg',
    description: {
      ko: '대중성과 전문성을 겸비해 꾸준한 신뢰를 쌓아가는 스타일입니다.',
      en: 'You balance popularity with professionalism and build steady trust over time.'
    },
    sourceUrl: 'https://namu.wiki/w/황희찬',
    scores: { H: 56, E: 59, X: 89, A: 52, C: 42, O: 77 }
  },
  {
    id: 'celebrity-037',
    name: { ko: '김민재', en: '김민재' },
    category: 'celebrity',
    image: '/personas/celebrity-037.jpg',
    description: {
      ko: '몰입도가 높고 무대나 현장에서 집중력을 잘 유지합니다.',
      en: 'You show high focus and maintain strong concentration in performance.'
    },
    sourceUrl: 'https://namu.wiki/w/김민재',
    scores: { H: 39, E: 53, X: 35, A: 50, C: 87, O: 74 }
  },
  {
    id: 'celebrity-038',
    name: { ko: '안세영', en: '안세영' },
    category: 'celebrity',
    image: '/personas/celebrity-038.jpg',
    description: {
      ko: '친화력이 좋아 팀워크와 협업에 강점을 보입니다.',
      en: 'You are sociable and strong in teamwork and collaboration.'
    },
    sourceUrl: 'https://namu.wiki/w/안세영',
    scores: { H: 78, E: 73, X: 68, A: 66, C: 48, O: 81 }
  },
  {
    id: 'celebrity-039',
    name: { ko: '박찬호', en: '박찬호' },
    category: 'celebrity',
    image: '/personas/celebrity-039.jpg',
    description: {
      ko: '도전적인 목표에도 꾸준히 성과를 내는 성실한 유형입니다.',
      en: 'You stay diligent and deliver results even with challenging goals.'
    },
    sourceUrl: 'https://namu.wiki/w/박찬호',
    scores: { H: 71, E: 38, X: 94, A: 95, C: 76, O: 59 }
  },
  {
    id: 'celebrity-040',
    name: { ko: '추신수', en: '추신수' },
    category: 'celebrity',
    image: '/personas/celebrity-040.jpg',
    description: {
      ko: '표현력이 풍부해 감정과 메시지를 잘 전달합니다.',
      en: 'You express feelings and messages clearly with rich communication.'
    },
    sourceUrl: 'https://namu.wiki/w/추신수',
    scores: { H: 46, E: 58, X: 64, A: 69, C: 55, O: 32 }
  },
  {
    id: 'celebrity-041',
    name: { ko: '이승기', en: '이승기' },
    category: 'celebrity',
    image: '/personas/celebrity-041.jpg',
    description: {
      ko: '대중성과 전문성을 겸비해 꾸준한 신뢰를 쌓아가는 스타일입니다.',
      en: 'You balance popularity with professionalism and build steady trust over time.'
    },
    sourceUrl: 'https://namu.wiki/w/이승기',
    scores: { H: 87, E: 29, X: 81, A: 83, C: 81, O: 27 }
  },
  {
    id: 'celebrity-042',
    name: { ko: '장근석', en: '장근석' },
    category: 'celebrity',
    image: '/personas/celebrity-042.jpg',
    description: {
      ko: '몰입도가 높고 무대나 현장에서 집중력을 잘 유지합니다.',
      en: 'You show high focus and maintain strong concentration in performance.'
    },
    sourceUrl: 'https://namu.wiki/w/장근석',
    scores: { H: 95, E: 94, X: 29, A: 59, C: 91, O: 70 }
  },
  {
    id: 'celebrity-043',
    name: { ko: '정해인', en: '정해인' },
    category: 'celebrity',
    image: '/personas/celebrity-043.jpg',
    description: {
      ko: '친화력이 좋아 팀워크와 협업에 강점을 보입니다.',
      en: 'You are sociable and strong in teamwork and collaboration.'
    },
    sourceUrl: 'https://namu.wiki/w/정해인',
    scores: { H: 66, E: 37, X: 33, A: 45, C: 48, O: 56 }
  },
  {
    id: 'celebrity-044',
    name: { ko: '이민호', en: '이민호' },
    category: 'celebrity',
    image: '/personas/celebrity-044.jpg',
    description: {
      ko: '도전적인 목표에도 꾸준히 성과를 내는 성실한 유형입니다.',
      en: 'You stay diligent and deliver results even with challenging goals.'
    },
    sourceUrl: 'https://namu.wiki/w/이민호',
    scores: { H: 69, E: 45, X: 52, A: 74, C: 68, O: 28 }
  },
  {
    id: 'celebrity-045',
    name: { ko: '황정민', en: '황정민' },
    category: 'celebrity',
    image: '/personas/celebrity-045.jpg',
    description: {
      ko: '표현력이 풍부해 감정과 메시지를 잘 전달합니다.',
      en: 'You express feelings and messages clearly with rich communication.'
    },
    sourceUrl: 'https://namu.wiki/w/황정민',
    scores: { H: 63, E: 63, X: 80, A: 65, C: 93, O: 66 }
  },
  {
    id: 'celebrity-046',
    name: { ko: '임창정', en: '임창정' },
    category: 'celebrity',
    image: '/personas/celebrity-046.jpg',
    description: {
      ko: '대중성과 전문성을 겸비해 꾸준한 신뢰를 쌓아가는 스타일입니다.',
      en: 'You balance popularity with professionalism and build steady trust over time.'
    },
    sourceUrl: 'https://namu.wiki/w/임창정',
    scores: { H: 49, E: 84, X: 49, A: 72, C: 69, O: 93 }
  },
  {
    id: 'celebrity-047',
    name: { ko: '싸이', en: 'PSY' },
    category: 'celebrity',
    image: '/personas/celebrity-047.jpg',
    description: {
      ko: '몰입도가 높고 무대나 현장에서 집중력을 잘 유지합니다.',
      en: 'You show high focus and maintain strong concentration in performance.'
    },
    sourceUrl: 'https://namu.wiki/w/싸이',
    scores: { H: 74, E: 26, X: 63, A: 46, C: 67, O: 86 }
  },
  {
    id: 'celebrity-048',
    name: { ko: '정지훈', en: '정지훈' },
    category: 'celebrity',
    image: '/personas/celebrity-048.jpg',
    description: {
      ko: '친화력이 좋아 팀워크와 협업에 강점을 보입니다.',
      en: 'You are sociable and strong in teamwork and collaboration.'
    },
    sourceUrl: 'https://namu.wiki/w/정지훈',
    scores: { H: 40, E: 84, X: 95, A: 42, C: 66, O: 34 }
  },
  {
    id: 'celebrity-049',
    name: { ko: '지민(방탄소년단)', en: 'BTS Jimin' },
    category: 'celebrity',
    image: '/personas/celebrity-049.jpg',
    description: {
      ko: '도전적인 목표에도 꾸준히 성과를 내는 성실한 유형입니다.',
      en: 'You stay diligent and deliver results even with challenging goals.'
    },
    sourceUrl: 'https://namu.wiki/w/지민(방탄소년단)',
    scores: { H: 73, E: 70, X: 41, A: 26, C: 89, O: 74 }
  },
  {
    id: 'celebrity-050',
    name: { ko: '장윤정', en: '장윤정' },
    category: 'celebrity',
    image: '/personas/celebrity-050.jpg',
    description: {
      ko: '표현력이 풍부해 감정과 메시지를 잘 전달합니다.',
      en: 'You express feelings and messages clearly with rich communication.'
    },
    sourceUrl: 'https://namu.wiki/w/장윤정',
    scores: { H: 78, E: 81, X: 29, A: 77, C: 86, O: 93 }
  },
  {
    id: 'artist-001',
    name: { ko: '빈센트 반 고흐', en: 'Vincent van Gogh' },
    category: 'artist',
    image: '/personas/artist-001.jpg',
    description: {
      ko: '창의성과 감수성이 풍부해 독창적인 표현을 추구합니다.',
      en: 'You pursue original expression with strong creativity and sensitivity.'
    },
    sourceUrl: 'https://namu.wiki/w/빈센트 반 고흐',
    scores: { H: 25, E: 35, X: 60, A: 66, C: 58, O: 44 }
  },
  {
    id: 'artist-002',
    name: { ko: '레오나르도 다 빈치', en: 'Leonardo da Vinci' },
    category: 'artist',
    image: '/personas/artist-002.jpg',
    description: {
      ko: '실험적 접근과 깊은 몰입으로 작품 세계를 확장합니다.',
      en: 'You expand your body of work through experimentation and deep focus.'
    },
    sourceUrl: 'https://namu.wiki/w/레오나르도 다 빈치',
    scores: { H: 72, E: 40, X: 61, A: 40, C: 64, O: 57 }
  },
  {
    id: 'artist-003',
    name: { ko: '백남준', en: 'Nam June Paik' },
    category: 'artist',
    image: '/personas/artist-003.jpg',
    description: {
      ko: '관찰력과 섬세함으로 디테일을 살리는 스타일입니다.',
      en: 'You emphasize detail through keen observation and subtlety.'
    },
    sourceUrl: 'https://namu.wiki/w/백남준',
    scores: { H: 57, E: 46, X: 59, A: 60, C: 81, O: 29 }
  },
  {
    id: 'artist-004',
    name: { ko: '파블로 피카소', en: 'Pablo Picasso' },
    category: 'artist',
    image: '/personas/artist-004.jpg',
    description: {
      ko: '시대의 흐름을 읽고 새로운 미학을 제안하는 편입니다.',
      en: 'You read the times and propose new aesthetics.'
    },
    sourceUrl: 'https://namu.wiki/w/파블로 피카소',
    scores: { H: 45, E: 64, X: 63, A: 89, C: 40, O: 25 }
  },
  {
    id: 'artist-005',
    name: { ko: '프리다 칼로', en: 'Frida Kahlo' },
    category: 'artist',
    image: '/personas/artist-005.jpg',
    description: {
      ko: '감정의 깊이를 예술로 풀어내는 경향이 있습니다.',
      en: 'You translate deep emotion into artistic form.'
    },
    sourceUrl: 'https://namu.wiki/w/프리다 칼로',
    scores: { H: 55, E: 69, X: 80, A: 93, C: 42, O: 66 }
  },
  {
    id: 'artist-006',
    name: { ko: '클로드 모네', en: '클로드 모네' },
    category: 'artist',
    image: '/personas/artist-006.jpg',
    description: {
      ko: '창의성과 감수성이 풍부해 독창적인 표현을 추구합니다.',
      en: 'You pursue original expression with strong creativity and sensitivity.'
    },
    sourceUrl: 'https://namu.wiki/w/클로드 모네',
    scores: { H: 29, E: 36, X: 62, A: 80, C: 68, O: 32 }
  },
  {
    id: 'artist-007',
    name: { ko: '살바도르 달리', en: '살바도르 달리' },
    category: 'artist',
    image: '/personas/artist-007.jpg',
    description: {
      ko: '실험적 접근과 깊은 몰입으로 작품 세계를 확장합니다.',
      en: 'You expand your body of work through experimentation and deep focus.'
    },
    sourceUrl: 'https://namu.wiki/w/살바도르 달리',
    scores: { H: 90, E: 48, X: 67, A: 80, C: 66, O: 38 }
  },
  {
    id: 'artist-008',
    name: { ko: '요하네스 베르메르', en: '요하네스 베르메르' },
    category: 'artist',
    image: '/personas/artist-008.jpg',
    description: {
      ko: '관찰력과 섬세함으로 디테일을 살리는 스타일입니다.',
      en: 'You emphasize detail through keen observation and subtlety.'
    },
    sourceUrl: 'https://namu.wiki/w/요하네스 베르메르',
    scores: { H: 25, E: 85, X: 35, A: 90, C: 33, O: 50 }
  },
  {
    id: 'artist-009',
    name: { ko: '렘브란트', en: '렘브란트' },
    category: 'artist',
    image: '/personas/artist-009.jpg',
    description: {
      ko: '시대의 흐름을 읽고 새로운 미학을 제안하는 편입니다.',
      en: 'You read the times and propose new aesthetics.'
    },
    sourceUrl: 'https://namu.wiki/w/렘브란트',
    scores: { H: 33, E: 30, X: 55, A: 62, C: 72, O: 82 }
  },
  {
    id: 'artist-010',
    name: { ko: '미켈란젤로', en: '미켈란젤로' },
    category: 'artist',
    image: '/personas/artist-010.jpg',
    description: {
      ko: '감정의 깊이를 예술로 풀어내는 경향이 있습니다.',
      en: 'You translate deep emotion into artistic form.'
    },
    sourceUrl: 'https://namu.wiki/w/미켈란젤로',
    scores: { H: 47, E: 26, X: 27, A: 35, C: 57, O: 41 }
  },
  {
    id: 'artist-011',
    name: { ko: '라파엘로', en: '라파엘로' },
    category: 'artist',
    image: '/personas/artist-011.jpg',
    description: {
      ko: '창의성과 감수성이 풍부해 독창적인 표현을 추구합니다.',
      en: 'You pursue original expression with strong creativity and sensitivity.'
    },
    sourceUrl: 'https://namu.wiki/w/라파엘로',
    scores: { H: 48, E: 30, X: 93, A: 95, C: 88, O: 89 }
  },
  {
    id: 'artist-012',
    name: { ko: '폴 세잔', en: '폴 세잔' },
    category: 'artist',
    image: '/personas/artist-012.jpg',
    description: {
      ko: '실험적 접근과 깊은 몰입으로 작품 세계를 확장합니다.',
      en: 'You expand your body of work through experimentation and deep focus.'
    },
    sourceUrl: 'https://namu.wiki/w/폴 세잔',
    scores: { H: 63, E: 71, X: 83, A: 53, C: 67, O: 26 }
  },
  {
    id: 'artist-013',
    name: { ko: '조르주 쇠라', en: '조르주 쇠라' },
    category: 'artist',
    image: '/personas/artist-013.jpg',
    description: {
      ko: '관찰력과 섬세함으로 디테일을 살리는 스타일입니다.',
      en: 'You emphasize detail through keen observation and subtlety.'
    },
    sourceUrl: 'https://namu.wiki/w/조르주 쇠라',
    scores: { H: 32, E: 53, X: 44, A: 45, C: 28, O: 63 }
  },
  {
    id: 'artist-014',
    name: { ko: '구스타프 클림트', en: '구스타프 클림트' },
    category: 'artist',
    image: '/personas/artist-014.jpg',
    description: {
      ko: '시대의 흐름을 읽고 새로운 미학을 제안하는 편입니다.',
      en: 'You read the times and propose new aesthetics.'
    },
    sourceUrl: 'https://namu.wiki/w/구스타프 클림트',
    scores: { H: 80, E: 47, X: 43, A: 60, C: 90, O: 78 }
  },
  {
    id: 'artist-015',
    name: { ko: '에드바르 뭉크', en: '에드바르 뭉크' },
    category: 'artist',
    image: '/personas/artist-015.jpg',
    description: {
      ko: '감정의 깊이를 예술로 풀어내는 경향이 있습니다.',
      en: 'You translate deep emotion into artistic form.'
    },
    sourceUrl: 'https://namu.wiki/w/에드바르 뭉크',
    scores: { H: 71, E: 57, X: 47, A: 80, C: 58, O: 79 }
  },
  {
    id: 'artist-016',
    name: { ko: '앤디 워홀', en: '앤디 워홀' },
    category: 'artist',
    image: '/personas/artist-016.jpg',
    description: {
      ko: '창의성과 감수성이 풍부해 독창적인 표현을 추구합니다.',
      en: 'You pursue original expression with strong creativity and sensitivity.'
    },
    sourceUrl: 'https://namu.wiki/w/앤디 워홀',
    scores: { H: 45, E: 42, X: 84, A: 67, C: 92, O: 56 }
  },
  {
    id: 'artist-017',
    name: { ko: '잭슨 폴록', en: '잭슨 폴록' },
    category: 'artist',
    image: '/personas/artist-017.jpg',
    description: {
      ko: '실험적 접근과 깊은 몰입으로 작품 세계를 확장합니다.',
      en: 'You expand your body of work through experimentation and deep focus.'
    },
    sourceUrl: 'https://namu.wiki/w/잭슨 폴록',
    scores: { H: 52, E: 36, X: 38, A: 82, C: 91, O: 27 }
  },
  {
    id: 'artist-018',
    name: { ko: '바실리 칸딘스키', en: '바실리 칸딘스키' },
    category: 'artist',
    image: '/personas/artist-018.jpg',
    description: {
      ko: '관찰력과 섬세함으로 디테일을 살리는 스타일입니다.',
      en: 'You emphasize detail through keen observation and subtlety.'
    },
    sourceUrl: 'https://namu.wiki/w/바실리 칸딘스키',
    scores: { H: 56, E: 68, X: 25, A: 92, C: 34, O: 94 }
  },
  {
    id: 'artist-019',
    name: { ko: '피에트 몬드리안', en: '피에트 몬드리안' },
    category: 'artist',
    image: '/personas/artist-019.jpg',
    description: {
      ko: '시대의 흐름을 읽고 새로운 미학을 제안하는 편입니다.',
      en: 'You read the times and propose new aesthetics.'
    },
    sourceUrl: 'https://namu.wiki/w/피에트 몬드리안',
    scores: { H: 40, E: 56, X: 61, A: 57, C: 39, O: 90 }
  },
  {
    id: 'artist-020',
    name: { ko: '마르셀 뒤샹', en: '마르셀 뒤샹' },
    category: 'artist',
    image: '/personas/artist-020.jpg',
    description: {
      ko: '감정의 깊이를 예술로 풀어내는 경향이 있습니다.',
      en: 'You translate deep emotion into artistic form.'
    },
    sourceUrl: 'https://namu.wiki/w/마르셀 뒤샹',
    scores: { H: 66, E: 39, X: 79, A: 49, C: 81, O: 30 }
  },
  {
    id: 'artist-021',
    name: { ko: '장 미셸 바스키아', en: '장 미셸 바스키아' },
    category: 'artist',
    image: '/personas/artist-021.jpg',
    description: {
      ko: '창의성과 감수성이 풍부해 독창적인 표현을 추구합니다.',
      en: 'You pursue original expression with strong creativity and sensitivity.'
    },
    sourceUrl: 'https://namu.wiki/w/장 미셸 바스키아',
    scores: { H: 36, E: 32, X: 76, A: 44, C: 89, O: 35 }
  },
  {
    id: 'artist-022',
    name: { ko: '키스 해링', en: '키스 해링' },
    category: 'artist',
    image: '/personas/artist-022.jpg',
    description: {
      ko: '실험적 접근과 깊은 몰입으로 작품 세계를 확장합니다.',
      en: 'You expand your body of work through experimentation and deep focus.'
    },
    sourceUrl: 'https://namu.wiki/w/키스 해링',
    scores: { H: 28, E: 29, X: 71, A: 58, C: 41, O: 85 }
  },
  {
    id: 'artist-023',
    name: { ko: '르 코르뷔지에', en: '르 코르뷔지에' },
    category: 'artist',
    image: '/personas/artist-023.jpg',
    description: {
      ko: '관찰력과 섬세함으로 디테일을 살리는 스타일입니다.',
      en: 'You emphasize detail through keen observation and subtlety.'
    },
    sourceUrl: 'https://namu.wiki/w/르 코르뷔지에',
    scores: { H: 37, E: 59, X: 84, A: 25, C: 50, O: 56 }
  },
  {
    id: 'artist-024',
    name: { ko: '프랭크 로이드 라이트', en: '프랭크 로이드 라이트' },
    category: 'artist',
    image: '/personas/artist-024.jpg',
    description: {
      ko: '시대의 흐름을 읽고 새로운 미학을 제안하는 편입니다.',
      en: 'You read the times and propose new aesthetics.'
    },
    sourceUrl: 'https://namu.wiki/w/프랭크 로이드 라이트',
    scores: { H: 56, E: 39, X: 45, A: 82, C: 68, O: 62 }
  },
  {
    id: 'artist-025',
    name: { ko: '자하 하디드', en: '자하 하디드' },
    category: 'artist',
    image: '/personas/artist-025.jpg',
    description: {
      ko: '감정의 깊이를 예술로 풀어내는 경향이 있습니다.',
      en: 'You translate deep emotion into artistic form.'
    },
    sourceUrl: 'https://namu.wiki/w/자하 하디드',
    scores: { H: 74, E: 62, X: 65, A: 32, C: 34, O: 84 }
  },
  {
    id: 'artist-026',
    name: { ko: '루이스 칸', en: '루이스 칸' },
    category: 'artist',
    image: '/personas/artist-026.jpg',
    description: {
      ko: '창의성과 감수성이 풍부해 독창적인 표현을 추구합니다.',
      en: 'You pursue original expression with strong creativity and sensitivity.'
    },
    sourceUrl: 'https://namu.wiki/w/루이스 칸',
    scores: { H: 87, E: 86, X: 59, A: 79, C: 50, O: 39 }
  },
  {
    id: 'artist-027',
    name: { ko: '김환기', en: '김환기' },
    category: 'artist',
    image: '/personas/artist-027.jpg',
    description: {
      ko: '실험적 접근과 깊은 몰입으로 작품 세계를 확장합니다.',
      en: 'You expand your body of work through experimentation and deep focus.'
    },
    sourceUrl: 'https://namu.wiki/w/김환기',
    scores: { H: 84, E: 39, X: 52, A: 72, C: 88, O: 69 }
  },
  {
    id: 'artist-028',
    name: { ko: '이중섭', en: '이중섭' },
    category: 'artist',
    image: '/personas/artist-028.jpg',
    description: {
      ko: '관찰력과 섬세함으로 디테일을 살리는 스타일입니다.',
      en: 'You emphasize detail through keen observation and subtlety.'
    },
    sourceUrl: 'https://namu.wiki/w/이중섭',
    scores: { H: 69, E: 30, X: 42, A: 40, C: 63, O: 80 }
  },
  {
    id: 'artist-029',
    name: { ko: '박수근', en: '박수근' },
    category: 'artist',
    image: '/personas/artist-029.jpg',
    description: {
      ko: '시대의 흐름을 읽고 새로운 미학을 제안하는 편입니다.',
      en: 'You read the times and propose new aesthetics.'
    },
    sourceUrl: 'https://namu.wiki/w/박수근',
    scores: { H: 82, E: 49, X: 25, A: 64, C: 62, O: 34 }
  },
  {
    id: 'artist-030',
    name: { ko: '나혜석', en: '나혜석' },
    category: 'artist',
    image: '/personas/artist-030.jpg',
    description: {
      ko: '감정의 깊이를 예술로 풀어내는 경향이 있습니다.',
      en: 'You translate deep emotion into artistic form.'
    },
    sourceUrl: 'https://namu.wiki/w/나혜석',
    scores: { H: 89, E: 59, X: 32, A: 74, C: 86, O: 84 }
  },
  {
    id: 'artist-031',
    name: { ko: '장욱진', en: '장욱진' },
    category: 'artist',
    image: '/personas/artist-031.jpg',
    description: {
      ko: '창의성과 감수성이 풍부해 독창적인 표현을 추구합니다.',
      en: 'You pursue original expression with strong creativity and sensitivity.'
    },
    sourceUrl: 'https://namu.wiki/w/장욱진',
    scores: { H: 52, E: 67, X: 36, A: 88, C: 59, O: 29 }
  },
  {
    id: 'artist-032',
    name: { ko: '윤형근', en: '윤형근' },
    category: 'artist',
    image: '/personas/artist-032.jpg',
    description: {
      ko: '실험적 접근과 깊은 몰입으로 작품 세계를 확장합니다.',
      en: 'You expand your body of work through experimentation and deep focus.'
    },
    sourceUrl: 'https://namu.wiki/w/윤형근',
    scores: { H: 60, E: 73, X: 75, A: 60, C: 50, O: 45 }
  },
  {
    id: 'artist-033',
    name: { ko: '이우환', en: '이우환' },
    category: 'artist',
    image: '/personas/artist-033.jpg',
    description: {
      ko: '관찰력과 섬세함으로 디테일을 살리는 스타일입니다.',
      en: 'You emphasize detail through keen observation and subtlety.'
    },
    sourceUrl: 'https://namu.wiki/w/이우환',
    scores: { H: 66, E: 91, X: 56, A: 34, C: 48, O: 69 }
  },
  {
    id: 'artist-034',
    name: { ko: '안도 타다오', en: '안도 타다오' },
    category: 'artist',
    image: '/personas/artist-034.jpg',
    description: {
      ko: '시대의 흐름을 읽고 새로운 미학을 제안하는 편입니다.',
      en: 'You read the times and propose new aesthetics.'
    },
    sourceUrl: 'https://namu.wiki/w/안도 타다오',
    scores: { H: 52, E: 44, X: 44, A: 88, C: 91, O: 45 }
  },
  {
    id: 'artist-035',
    name: { ko: '클로드 드뷔시', en: '클로드 드뷔시' },
    category: 'artist',
    image: '/personas/artist-035.jpg',
    description: {
      ko: '감정의 깊이를 예술로 풀어내는 경향이 있습니다.',
      en: 'You translate deep emotion into artistic form.'
    },
    sourceUrl: 'https://namu.wiki/w/클로드 드뷔시',
    scores: { H: 93, E: 74, X: 80, A: 89, C: 42, O: 25 }
  },
  {
    id: 'artist-036',
    name: { ko: '루트비히 판 베토벤', en: '루트비히 판 베토벤' },
    category: 'artist',
    image: '/personas/artist-036.jpg',
    description: {
      ko: '창의성과 감수성이 풍부해 독창적인 표현을 추구합니다.',
      en: 'You pursue original expression with strong creativity and sensitivity.'
    },
    sourceUrl: 'https://namu.wiki/w/루트비히 판 베토벤',
    scores: { H: 40, E: 32, X: 46, A: 56, C: 26, O: 43 }
  },
  {
    id: 'artist-037',
    name: { ko: '볼프강 아마데우스 모차르트', en: '볼프강 아마데우스 모차르트' },
    category: 'artist',
    image: '/personas/artist-037.jpg',
    description: {
      ko: '실험적 접근과 깊은 몰입으로 작품 세계를 확장합니다.',
      en: 'You expand your body of work through experimentation and deep focus.'
    },
    sourceUrl: 'https://namu.wiki/w/볼프강 아마데우스 모차르트',
    scores: { H: 54, E: 25, X: 72, A: 62, C: 39, O: 53 }
  },
  {
    id: 'artist-038',
    name: { ko: '요한 세바스티안 바흐', en: '요한 세바스티안 바흐' },
    category: 'artist',
    image: '/personas/artist-038.jpg',
    description: {
      ko: '관찰력과 섬세함으로 디테일을 살리는 스타일입니다.',
      en: 'You emphasize detail through keen observation and subtlety.'
    },
    sourceUrl: 'https://namu.wiki/w/요한 세바스티안 바흐',
    scores: { H: 70, E: 67, X: 56, A: 37, C: 34, O: 35 }
  },
  {
    id: 'artist-039',
    name: { ko: '프레데리크 쇼팽', en: '프레데리크 쇼팽' },
    category: 'artist',
    image: '/personas/artist-039.jpg',
    description: {
      ko: '시대의 흐름을 읽고 새로운 미학을 제안하는 편입니다.',
      en: 'You read the times and propose new aesthetics.'
    },
    sourceUrl: 'https://namu.wiki/w/프레데리크 쇼팽',
    scores: { H: 25, E: 53, X: 79, A: 33, C: 28, O: 73 }
  },
  {
    id: 'artist-040',
    name: { ko: '안토니오 비발디', en: '안토니오 비발디' },
    category: 'artist',
    image: '/personas/artist-040.jpg',
    description: {
      ko: '감정의 깊이를 예술로 풀어내는 경향이 있습니다.',
      en: 'You translate deep emotion into artistic form.'
    },
    sourceUrl: 'https://namu.wiki/w/안토니오 비발디',
    scores: { H: 48, E: 89, X: 57, A: 79, C: 52, O: 49 }
  },
  {
    id: 'artist-041',
    name: { ko: '표트르 차이콥스키', en: '표트르 차이콥스키' },
    category: 'artist',
    image: '/personas/artist-041.jpg',
    description: {
      ko: '창의성과 감수성이 풍부해 독창적인 표현을 추구합니다.',
      en: 'You pursue original expression with strong creativity and sensitivity.'
    },
    sourceUrl: 'https://namu.wiki/w/표트르 차이콥스키',
    scores: { H: 75, E: 27, X: 69, A: 25, C: 34, O: 56 }
  },
  {
    id: 'artist-042',
    name: { ko: '프란츠 슈베르트', en: '프란츠 슈베르트' },
    category: 'artist',
    image: '/personas/artist-042.jpg',
    description: {
      ko: '실험적 접근과 깊은 몰입으로 작품 세계를 확장합니다.',
      en: 'You expand your body of work through experimentation and deep focus.'
    },
    sourceUrl: 'https://namu.wiki/w/프란츠 슈베르트',
    scores: { H: 62, E: 47, X: 75, A: 50, C: 31, O: 59 }
  },
  {
    id: 'artist-043',
    name: { ko: '구스타프 말러', en: '구스타프 말러' },
    category: 'artist',
    image: '/personas/artist-043.jpg',
    description: {
      ko: '관찰력과 섬세함으로 디테일을 살리는 스타일입니다.',
      en: 'You emphasize detail through keen observation and subtlety.'
    },
    sourceUrl: 'https://namu.wiki/w/구스타프 말러',
    scores: { H: 54, E: 92, X: 56, A: 81, C: 32, O: 75 }
  },
  {
    id: 'artist-044',
    name: { ko: '세르게이 라흐마니노프', en: '세르게이 라흐마니노프' },
    category: 'artist',
    image: '/personas/artist-044.jpg',
    description: {
      ko: '시대의 흐름을 읽고 새로운 미학을 제안하는 편입니다.',
      en: 'You read the times and propose new aesthetics.'
    },
    sourceUrl: 'https://namu.wiki/w/세르게이 라흐마니노프',
    scores: { H: 88, E: 84, X: 74, A: 83, C: 67, O: 40 }
  },
  {
    id: 'artist-045',
    name: { ko: '이고르 스트라빈스키', en: '이고르 스트라빈스키' },
    category: 'artist',
    image: '/personas/artist-045.jpg',
    description: {
      ko: '감정의 깊이를 예술로 풀어내는 경향이 있습니다.',
      en: 'You translate deep emotion into artistic form.'
    },
    sourceUrl: 'https://namu.wiki/w/이고르 스트라빈스키',
    scores: { H: 67, E: 42, X: 92, A: 70, C: 55, O: 79 }
  },
  {
    id: 'artist-046',
    name: { ko: '윌리엄 셰익스피어', en: '윌리엄 셰익스피어' },
    category: 'artist',
    image: '/personas/artist-046.jpg',
    description: {
      ko: '창의성과 감수성이 풍부해 독창적인 표현을 추구합니다.',
      en: 'You pursue original expression with strong creativity and sensitivity.'
    },
    sourceUrl: 'https://namu.wiki/w/윌리엄 셰익스피어',
    scores: { H: 77, E: 45, X: 69, A: 68, C: 34, O: 43 }
  },
  {
    id: 'artist-047',
    name: { ko: '레프 톨스토이', en: '레프 톨스토이' },
    category: 'artist',
    image: '/personas/artist-047.jpg',
    description: {
      ko: '실험적 접근과 깊은 몰입으로 작품 세계를 확장합니다.',
      en: 'You expand your body of work through experimentation and deep focus.'
    },
    sourceUrl: 'https://namu.wiki/w/레프 톨스토이',
    scores: { H: 41, E: 67, X: 82, A: 49, C: 93, O: 64 }
  },
  {
    id: 'artist-048',
    name: { ko: '표도르 도스토옙스키', en: '표도르 도스토옙스키' },
    category: 'artist',
    image: '/personas/artist-048.jpg',
    description: {
      ko: '관찰력과 섬세함으로 디테일을 살리는 스타일입니다.',
      en: 'You emphasize detail through keen observation and subtlety.'
    },
    sourceUrl: 'https://namu.wiki/w/표도르 도스토옙스키',
    scores: { H: 56, E: 95, X: 51, A: 47, C: 27, O: 91 }
  },
  {
    id: 'artist-049',
    name: { ko: '헤르만 헤세', en: '헤르만 헤세' },
    category: 'artist',
    image: '/personas/artist-049.jpg',
    description: {
      ko: '시대의 흐름을 읽고 새로운 미학을 제안하는 편입니다.',
      en: 'You read the times and propose new aesthetics.'
    },
    sourceUrl: 'https://namu.wiki/w/헤르만 헤세',
    scores: { H: 72, E: 48, X: 49, A: 91, C: 66, O: 45 }
  },
  {
    id: 'artist-050',
    name: { ko: '어니스트 헤밍웨이', en: '어니스트 헤밍웨이' },
    category: 'artist',
    image: '/personas/artist-050.jpg',
    description: {
      ko: '감정의 깊이를 예술로 풀어내는 경향이 있습니다.',
      en: 'You translate deep emotion into artistic form.'
    },
    sourceUrl: 'https://namu.wiki/w/어니스트 헤밍웨이',
    scores: { H: 56, E: 62, X: 65, A: 46, C: 72, O: 58 }
  },
  {
    id: 'politician-001',
    name: { ko: '세종대왕', en: 'King Sejong' },
    category: 'politician',
    image: '/personas/politician-001.jpg',
    description: {
      ko: '공공의 가치와 책임감을 중시하며 균형 있는 결정을 선호합니다.',
      en: 'You value public responsibility and prefer balanced decisions.'
    },
    sourceUrl: 'https://namu.wiki/w/세종대왕',
    scores: { H: 71, E: 38, X: 71, A: 39, C: 84, O: 49 }
  },
  {
    id: 'politician-002',
    name: { ko: '이승만', en: '이승만' },
    category: 'politician',
    image: '/personas/politician-002.jpg',
    description: {
      ko: '설득과 조율에 능하며 갈등을 완화하는 리더십을 보입니다.',
      en: 'You are persuasive and reduce conflict through coordination.'
    },
    sourceUrl: 'https://namu.wiki/w/이승만',
    scores: { H: 82, E: 89, X: 47, A: 91, C: 36, O: 76 }
  },
  {
    id: 'politician-003',
    name: { ko: '박정희', en: '박정희' },
    category: 'politician',
    image: '/personas/politician-003.jpg',
    description: {
      ko: '장기 비전을 세우고 제도적 안정성을 추구합니다.',
      en: 'You build long term vision and seek institutional stability.'
    },
    sourceUrl: 'https://namu.wiki/w/박정희',
    scores: { H: 35, E: 27, X: 30, A: 27, C: 64, O: 45 }
  },
  {
    id: 'politician-004',
    name: { ko: '전두환', en: '전두환' },
    category: 'politician',
    image: '/personas/politician-004.jpg',
    description: {
      ko: '결단력이 강하고 위기 상황에서 방향을 제시합니다.',
      en: 'You are decisive and provide direction in crisis situations.'
    },
    sourceUrl: 'https://namu.wiki/w/전두환',
    scores: { H: 37, E: 47, X: 80, A: 88, C: 41, O: 68 }
  },
  {
    id: 'politician-005',
    name: { ko: '노태우', en: '노태우' },
    category: 'politician',
    image: '/personas/politician-005.jpg',
    description: {
      ko: '대중과의 소통을 중시하며 신뢰를 쌓는 편입니다.',
      en: 'You focus on public communication and build trust.'
    },
    sourceUrl: 'https://namu.wiki/w/노태우',
    scores: { H: 68, E: 30, X: 27, A: 64, C: 29, O: 57 }
  },
  {
    id: 'politician-006',
    name: { ko: '김영삼', en: '김영삼' },
    category: 'politician',
    image: '/personas/politician-006.jpg',
    description: {
      ko: '공공의 가치와 책임감을 중시하며 균형 있는 결정을 선호합니다.',
      en: 'You value public responsibility and prefer balanced decisions.'
    },
    sourceUrl: 'https://namu.wiki/w/김영삼',
    scores: { H: 92, E: 35, X: 68, A: 63, C: 68, O: 46 }
  },
  {
    id: 'politician-007',
    name: { ko: '김대중', en: '김대중' },
    category: 'politician',
    image: '/personas/politician-007.jpg',
    description: {
      ko: '설득과 조율에 능하며 갈등을 완화하는 리더십을 보입니다.',
      en: 'You are persuasive and reduce conflict through coordination.'
    },
    sourceUrl: 'https://namu.wiki/w/김대중',
    scores: { H: 39, E: 54, X: 94, A: 27, C: 33, O: 73 }
  },
  {
    id: 'politician-008',
    name: { ko: '노무현', en: '노무현' },
    category: 'politician',
    image: '/personas/politician-008.jpg',
    description: {
      ko: '장기 비전을 세우고 제도적 안정성을 추구합니다.',
      en: 'You build long term vision and seek institutional stability.'
    },
    sourceUrl: 'https://namu.wiki/w/노무현',
    scores: { H: 41, E: 69, X: 57, A: 46, C: 94, O: 46 }
  },
  {
    id: 'politician-009',
    name: { ko: '이명박', en: '이명박' },
    category: 'politician',
    image: '/personas/politician-009.jpg',
    description: {
      ko: '결단력이 강하고 위기 상황에서 방향을 제시합니다.',
      en: 'You are decisive and provide direction in crisis situations.'
    },
    sourceUrl: 'https://namu.wiki/w/이명박',
    scores: { H: 47, E: 50, X: 38, A: 72, C: 33, O: 67 }
  },
  {
    id: 'politician-010',
    name: { ko: '박근혜', en: '박근혜' },
    category: 'politician',
    image: '/personas/politician-010.jpg',
    description: {
      ko: '대중과의 소통을 중시하며 신뢰를 쌓는 편입니다.',
      en: 'You focus on public communication and build trust.'
    },
    sourceUrl: 'https://namu.wiki/w/박근혜',
    scores: { H: 94, E: 92, X: 54, A: 40, C: 88, O: 42 }
  },
  {
    id: 'politician-011',
    name: { ko: '문재인', en: '문재인' },
    category: 'politician',
    image: '/personas/politician-011.jpg',
    description: {
      ko: '공공의 가치와 책임감을 중시하며 균형 있는 결정을 선호합니다.',
      en: 'You value public responsibility and prefer balanced decisions.'
    },
    sourceUrl: 'https://namu.wiki/w/문재인',
    scores: { H: 38, E: 72, X: 35, A: 53, C: 64, O: 85 }
  },
  {
    id: 'politician-012',
    name: { ko: '윤석열', en: '윤석열' },
    category: 'politician',
    image: '/personas/politician-012.jpg',
    description: {
      ko: '설득과 조율에 능하며 갈등을 완화하는 리더십을 보입니다.',
      en: 'You are persuasive and reduce conflict through coordination.'
    },
    sourceUrl: 'https://namu.wiki/w/윤석열',
    scores: { H: 58, E: 29, X: 59, A: 91, C: 79, O: 76 }
  },
  {
    id: 'politician-013',
    name: { ko: '김구', en: '김구' },
    category: 'politician',
    image: '/personas/politician-013.jpg',
    description: {
      ko: '장기 비전을 세우고 제도적 안정성을 추구합니다.',
      en: 'You build long term vision and seek institutional stability.'
    },
    sourceUrl: 'https://namu.wiki/w/김구',
    scores: { H: 93, E: 25, X: 33, A: 35, C: 80, O: 60 }
  },
  {
    id: 'politician-014',
    name: { ko: '안중근', en: '안중근' },
    category: 'politician',
    image: '/personas/politician-014.jpg',
    description: {
      ko: '결단력이 강하고 위기 상황에서 방향을 제시합니다.',
      en: 'You are decisive and provide direction in crisis situations.'
    },
    sourceUrl: 'https://namu.wiki/w/안중근',
    scores: { H: 30, E: 40, X: 93, A: 50, C: 93, O: 90 }
  },
  {
    id: 'politician-015',
    name: { ko: '반기문', en: '반기문' },
    category: 'politician',
    image: '/personas/politician-015.jpg',
    description: {
      ko: '대중과의 소통을 중시하며 신뢰를 쌓는 편입니다.',
      en: 'You focus on public communication and build trust.'
    },
    sourceUrl: 'https://namu.wiki/w/반기문',
    scores: { H: 83, E: 76, X: 71, A: 63, C: 39, O: 88 }
  },
  {
    id: 'politician-016',
    name: { ko: '에이브러햄 링컨', en: 'Abraham Lincoln' },
    category: 'politician',
    image: '/personas/politician-016.jpg',
    description: {
      ko: '공공의 가치와 책임감을 중시하며 균형 있는 결정을 선호합니다.',
      en: 'You value public responsibility and prefer balanced decisions.'
    },
    sourceUrl: 'https://namu.wiki/w/에이브러햄 링컨',
    scores: { H: 83, E: 90, X: 93, A: 26, C: 59, O: 36 }
  },
  {
    id: 'politician-017',
    name: { ko: '조지 워싱턴', en: '조지 워싱턴' },
    category: 'politician',
    image: '/personas/politician-017.jpg',
    description: {
      ko: '설득과 조율에 능하며 갈등을 완화하는 리더십을 보입니다.',
      en: 'You are persuasive and reduce conflict through coordination.'
    },
    sourceUrl: 'https://namu.wiki/w/조지 워싱턴',
    scores: { H: 38, E: 38, X: 43, A: 28, C: 31, O: 79 }
  },
  {
    id: 'politician-018',
    name: { ko: '토머스 제퍼슨', en: '토머스 제퍼슨' },
    category: 'politician',
    image: '/personas/politician-018.jpg',
    description: {
      ko: '장기 비전을 세우고 제도적 안정성을 추구합니다.',
      en: 'You build long term vision and seek institutional stability.'
    },
    sourceUrl: 'https://namu.wiki/w/토머스 제퍼슨',
    scores: { H: 32, E: 49, X: 66, A: 79, C: 51, O: 62 }
  },
  {
    id: 'politician-019',
    name: { ko: '존 F. 케네디', en: '존 F. 케네디' },
    category: 'politician',
    image: '/personas/politician-019.jpg',
    description: {
      ko: '결단력이 강하고 위기 상황에서 방향을 제시합니다.',
      en: 'You are decisive and provide direction in crisis situations.'
    },
    sourceUrl: 'https://namu.wiki/w/존 F. 케네디',
    scores: { H: 77, E: 36, X: 86, A: 74, C: 68, O: 53 }
  },
  {
    id: 'politician-020',
    name: { ko: '프랭클린 D. 루스벨트', en: '프랭클린 D. 루스벨트' },
    category: 'politician',
    image: '/personas/politician-020.jpg',
    description: {
      ko: '대중과의 소통을 중시하며 신뢰를 쌓는 편입니다.',
      en: 'You focus on public communication and build trust.'
    },
    sourceUrl: 'https://namu.wiki/w/프랭클린 D. 루스벨트',
    scores: { H: 27, E: 71, X: 86, A: 58, C: 58, O: 32 }
  },
  {
    id: 'politician-021',
    name: { ko: '시어도어 루스벨트', en: '시어도어 루스벨트' },
    category: 'politician',
    image: '/personas/politician-021.jpg',
    description: {
      ko: '공공의 가치와 책임감을 중시하며 균형 있는 결정을 선호합니다.',
      en: 'You value public responsibility and prefer balanced decisions.'
    },
    sourceUrl: 'https://namu.wiki/w/시어도어 루스벨트',
    scores: { H: 62, E: 45, X: 91, A: 48, C: 63, O: 26 }
  },
  {
    id: 'politician-022',
    name: { ko: '윈스턴 처칠', en: '윈스턴 처칠' },
    category: 'politician',
    image: '/personas/politician-022.jpg',
    description: {
      ko: '설득과 조율에 능하며 갈등을 완화하는 리더십을 보입니다.',
      en: 'You are persuasive and reduce conflict through coordination.'
    },
    sourceUrl: 'https://namu.wiki/w/윈스턴 처칠',
    scores: { H: 92, E: 37, X: 29, A: 40, C: 69, O: 57 }
  },
  {
    id: 'politician-023',
    name: { ko: '마거릿 대처', en: '마거릿 대처' },
    category: 'politician',
    image: '/personas/politician-023.jpg',
    description: {
      ko: '장기 비전을 세우고 제도적 안정성을 추구합니다.',
      en: 'You build long term vision and seek institutional stability.'
    },
    sourceUrl: 'https://namu.wiki/w/마거릿 대처',
    scores: { H: 63, E: 79, X: 51, A: 51, C: 88, O: 59 }
  },
  {
    id: 'politician-024',
    name: { ko: '토니 블레어', en: '토니 블레어' },
    category: 'politician',
    image: '/personas/politician-024.jpg',
    description: {
      ko: '결단력이 강하고 위기 상황에서 방향을 제시합니다.',
      en: 'You are decisive and provide direction in crisis situations.'
    },
    sourceUrl: 'https://namu.wiki/w/토니 블레어',
    scores: { H: 48, E: 40, X: 68, A: 91, C: 50, O: 83 }
  },
  {
    id: 'politician-025',
    name: { ko: '샤를 드골', en: '샤를 드골' },
    category: 'politician',
    image: '/personas/politician-025.jpg',
    description: {
      ko: '대중과의 소통을 중시하며 신뢰를 쌓는 편입니다.',
      en: 'You focus on public communication and build trust.'
    },
    sourceUrl: 'https://namu.wiki/w/샤를 드골',
    scores: { H: 42, E: 91, X: 26, A: 66, C: 26, O: 28 }
  },
  {
    id: 'politician-026',
    name: { ko: '나폴레옹 보나파르트', en: '나폴레옹 보나파르트' },
    category: 'politician',
    image: '/personas/politician-026.jpg',
    description: {
      ko: '공공의 가치와 책임감을 중시하며 균형 있는 결정을 선호합니다.',
      en: 'You value public responsibility and prefer balanced decisions.'
    },
    sourceUrl: 'https://namu.wiki/w/나폴레옹 보나파르트',
    scores: { H: 73, E: 71, X: 62, A: 39, C: 44, O: 36 }
  },
  {
    id: 'politician-027',
    name: { ko: '율리우스 카이사르', en: '율리우스 카이사르' },
    category: 'politician',
    image: '/personas/politician-027.jpg',
    description: {
      ko: '설득과 조율에 능하며 갈등을 완화하는 리더십을 보입니다.',
      en: 'You are persuasive and reduce conflict through coordination.'
    },
    sourceUrl: 'https://namu.wiki/w/율리우스 카이사르',
    scores: { H: 26, E: 26, X: 37, A: 57, C: 52, O: 55 }
  },
  {
    id: 'politician-028',
    name: { ko: '알렉산더 대왕', en: '알렉산더 대왕' },
    category: 'politician',
    image: '/personas/politician-028.jpg',
    description: {
      ko: '장기 비전을 세우고 제도적 안정성을 추구합니다.',
      en: 'You build long term vision and seek institutional stability.'
    },
    sourceUrl: 'https://namu.wiki/w/알렉산더 대왕',
    scores: { H: 38, E: 61, X: 61, A: 65, C: 26, O: 63 }
  },
  {
    id: 'politician-029',
    name: { ko: '마하트마 간디', en: '마하트마 간디' },
    category: 'politician',
    image: '/personas/politician-029.jpg',
    description: {
      ko: '결단력이 강하고 위기 상황에서 방향을 제시합니다.',
      en: 'You are decisive and provide direction in crisis situations.'
    },
    sourceUrl: 'https://namu.wiki/w/마하트마 간디',
    scores: { H: 42, E: 67, X: 52, A: 28, C: 53, O: 28 }
  },
  {
    id: 'politician-030',
    name: { ko: '자와할랄 네루', en: '자와할랄 네루' },
    category: 'politician',
    image: '/personas/politician-030.jpg',
    description: {
      ko: '대중과의 소통을 중시하며 신뢰를 쌓는 편입니다.',
      en: 'You focus on public communication and build trust.'
    },
    sourceUrl: 'https://namu.wiki/w/자와할랄 네루',
    scores: { H: 89, E: 92, X: 30, A: 40, C: 78, O: 50 }
  },
  {
    id: 'politician-031',
    name: { ko: '인디라 간디', en: '인디라 간디' },
    category: 'politician',
    image: '/personas/politician-031.jpg',
    description: {
      ko: '공공의 가치와 책임감을 중시하며 균형 있는 결정을 선호합니다.',
      en: 'You value public responsibility and prefer balanced decisions.'
    },
    sourceUrl: 'https://namu.wiki/w/인디라 간디',
    scores: { H: 41, E: 31, X: 44, A: 58, C: 90, O: 89 }
  },
  {
    id: 'politician-032',
    name: { ko: '넬슨 만델라', en: 'Nelson Mandela' },
    category: 'politician',
    image: '/personas/politician-032.jpg',
    description: {
      ko: '설득과 조율에 능하며 갈등을 완화하는 리더십을 보입니다.',
      en: 'You are persuasive and reduce conflict through coordination.'
    },
    sourceUrl: 'https://namu.wiki/w/넬슨 만델라',
    scores: { H: 92, E: 40, X: 38, A: 56, C: 39, O: 43 }
  },
  {
    id: 'politician-033',
    name: { ko: '버락 오바마', en: 'Barack Obama' },
    category: 'politician',
    image: '/personas/politician-033.jpg',
    description: {
      ko: '장기 비전을 세우고 제도적 안정성을 추구합니다.',
      en: 'You build long term vision and seek institutional stability.'
    },
    sourceUrl: 'https://namu.wiki/w/버락 오바마',
    scores: { H: 69, E: 33, X: 75, A: 62, C: 30, O: 51 }
  },
  {
    id: 'politician-034',
    name: { ko: '앙겔라 메르켈', en: 'Angela Merkel' },
    category: 'politician',
    image: '/personas/politician-034.jpg',
    description: {
      ko: '결단력이 강하고 위기 상황에서 방향을 제시합니다.',
      en: 'You are decisive and provide direction in crisis situations.'
    },
    sourceUrl: 'https://namu.wiki/w/앙겔라 메르켈',
    scores: { H: 42, E: 77, X: 70, A: 94, C: 53, O: 67 }
  },
  {
    id: 'politician-035',
    name: { ko: '블라디미르 푸틴', en: '블라디미르 푸틴' },
    category: 'politician',
    image: '/personas/politician-035.jpg',
    description: {
      ko: '대중과의 소통을 중시하며 신뢰를 쌓는 편입니다.',
      en: 'You focus on public communication and build trust.'
    },
    sourceUrl: 'https://namu.wiki/w/블라디미르 푸틴',
    scores: { H: 33, E: 47, X: 88, A: 28, C: 52, O: 94 }
  },
  {
    id: 'politician-036',
    name: { ko: '미하일 고르바초프', en: '미하일 고르바초프' },
    category: 'politician',
    image: '/personas/politician-036.jpg',
    description: {
      ko: '공공의 가치와 책임감을 중시하며 균형 있는 결정을 선호합니다.',
      en: 'You value public responsibility and prefer balanced decisions.'
    },
    sourceUrl: 'https://namu.wiki/w/미하일 고르바초프',
    scores: { H: 92, E: 55, X: 40, A: 49, C: 42, O: 39 }
  },
  {
    id: 'politician-037',
    name: { ko: '블라디미르 레닌', en: '블라디미르 레닌' },
    category: 'politician',
    image: '/personas/politician-037.jpg',
    description: {
      ko: '설득과 조율에 능하며 갈등을 완화하는 리더십을 보입니다.',
      en: 'You are persuasive and reduce conflict through coordination.'
    },
    sourceUrl: 'https://namu.wiki/w/블라디미르 레닌',
    scores: { H: 92, E: 29, X: 93, A: 44, C: 59, O: 61 }
  },
  {
    id: 'politician-038',
    name: { ko: '쑨원', en: '쑨원' },
    category: 'politician',
    image: '/personas/politician-038.jpg',
    description: {
      ko: '장기 비전을 세우고 제도적 안정성을 추구합니다.',
      en: 'You build long term vision and seek institutional stability.'
    },
    sourceUrl: 'https://namu.wiki/w/쑨원',
    scores: { H: 51, E: 51, X: 61, A: 38, C: 66, O: 93 }
  },
  {
    id: 'politician-039',
    name: { ko: '장제스', en: '장제스' },
    category: 'politician',
    image: '/personas/politician-039.jpg',
    description: {
      ko: '결단력이 강하고 위기 상황에서 방향을 제시합니다.',
      en: 'You are decisive and provide direction in crisis situations.'
    },
    sourceUrl: 'https://namu.wiki/w/장제스',
    scores: { H: 64, E: 94, X: 67, A: 36, C: 93, O: 88 }
  },
  {
    id: 'politician-040',
    name: { ko: '덩샤오핑', en: '덩샤오핑' },
    category: 'politician',
    image: '/personas/politician-040.jpg',
    description: {
      ko: '대중과의 소통을 중시하며 신뢰를 쌓는 편입니다.',
      en: 'You focus on public communication and build trust.'
    },
    sourceUrl: 'https://namu.wiki/w/덩샤오핑',
    scores: { H: 57, E: 76, X: 31, A: 67, C: 25, O: 42 }
  },
  {
    id: 'politician-041',
    name: { ko: '시진핑', en: '시진핑' },
    category: 'politician',
    image: '/personas/politician-041.jpg',
    description: {
      ko: '공공의 가치와 책임감을 중시하며 균형 있는 결정을 선호합니다.',
      en: 'You value public responsibility and prefer balanced decisions.'
    },
    sourceUrl: 'https://namu.wiki/w/시진핑',
    scores: { H: 77, E: 51, X: 29, A: 44, C: 59, O: 72 }
  },
  {
    id: 'politician-042',
    name: { ko: '마오쩌둥', en: '마오쩌둥' },
    category: 'politician',
    image: '/personas/politician-042.jpg',
    description: {
      ko: '설득과 조율에 능하며 갈등을 완화하는 리더십을 보입니다.',
      en: 'You are persuasive and reduce conflict through coordination.'
    },
    sourceUrl: 'https://namu.wiki/w/마오쩌둥',
    scores: { H: 28, E: 73, X: 34, A: 65, C: 71, O: 94 }
  },
  {
    id: 'politician-043',
    name: { ko: '저스틴 트뤼도', en: '저스틴 트뤼도' },
    category: 'politician',
    image: '/personas/politician-043.jpg',
    description: {
      ko: '장기 비전을 세우고 제도적 안정성을 추구합니다.',
      en: 'You build long term vision and seek institutional stability.'
    },
    sourceUrl: 'https://namu.wiki/w/저스틴 트뤼도',
    scores: { H: 42, E: 28, X: 56, A: 61, C: 61, O: 37 }
  },
  {
    id: 'politician-044',
    name: { ko: '조 바이든', en: '조 바이든' },
    category: 'politician',
    image: '/personas/politician-044.jpg',
    description: {
      ko: '결단력이 강하고 위기 상황에서 방향을 제시합니다.',
      en: 'You are decisive and provide direction in crisis situations.'
    },
    sourceUrl: 'https://namu.wiki/w/조 바이든',
    scores: { H: 46, E: 41, X: 41, A: 59, C: 39, O: 59 }
  },
  {
    id: 'politician-045',
    name: { ko: '도널드 트럼프', en: '도널드 트럼프' },
    category: 'politician',
    image: '/personas/politician-045.jpg',
    description: {
      ko: '대중과의 소통을 중시하며 신뢰를 쌓는 편입니다.',
      en: 'You focus on public communication and build trust.'
    },
    sourceUrl: 'https://namu.wiki/w/도널드 트럼프',
    scores: { H: 75, E: 26, X: 39, A: 52, C: 58, O: 83 }
  },
  {
    id: 'politician-046',
    name: { ko: '로널드 레이건', en: '로널드 레이건' },
    category: 'politician',
    image: '/personas/politician-046.jpg',
    description: {
      ko: '공공의 가치와 책임감을 중시하며 균형 있는 결정을 선호합니다.',
      en: 'You value public responsibility and prefer balanced decisions.'
    },
    sourceUrl: 'https://namu.wiki/w/로널드 레이건',
    scores: { H: 25, E: 33, X: 92, A: 71, C: 82, O: 50 }
  },
  {
    id: 'politician-047',
    name: { ko: '리처드 닉슨', en: '리처드 닉슨' },
    category: 'politician',
    image: '/personas/politician-047.jpg',
    description: {
      ko: '설득과 조율에 능하며 갈등을 완화하는 리더십을 보입니다.',
      en: 'You are persuasive and reduce conflict through coordination.'
    },
    sourceUrl: 'https://namu.wiki/w/리처드 닉슨',
    scores: { H: 83, E: 49, X: 36, A: 55, C: 64, O: 60 }
  },
  {
    id: 'politician-048',
    name: { ko: '우드로 윌슨', en: '우드로 윌슨' },
    category: 'politician',
    image: '/personas/politician-048.jpg',
    description: {
      ko: '장기 비전을 세우고 제도적 안정성을 추구합니다.',
      en: 'You build long term vision and seek institutional stability.'
    },
    sourceUrl: 'https://namu.wiki/w/우드로 윌슨',
    scores: { H: 85, E: 45, X: 55, A: 64, C: 77, O: 67 }
  },
  {
    id: 'politician-049',
    name: { ko: '시몬 볼리바르', en: '시몬 볼리바르' },
    category: 'politician',
    image: '/personas/politician-049.jpg',
    description: {
      ko: '결단력이 강하고 위기 상황에서 방향을 제시합니다.',
      en: 'You are decisive and provide direction in crisis situations.'
    },
    sourceUrl: 'https://namu.wiki/w/시몬 볼리바르',
    scores: { H: 53, E: 67, X: 59, A: 79, C: 39, O: 79 }
  },
  {
    id: 'politician-050',
    name: { ko: '피델 카스트로', en: '피델 카스트로' },
    category: 'politician',
    image: '/personas/politician-050.jpg',
    description: {
      ko: '대중과의 소통을 중시하며 신뢰를 쌓는 편입니다.',
      en: 'You focus on public communication and build trust.'
    },
    sourceUrl: 'https://namu.wiki/w/피델 카스트로',
    scores: { H: 48, E: 89, X: 58, A: 65, C: 32, O: 73 }
  },
  {
    id: 'entrepreneur-001',
    name: { ko: '스티브 잡스', en: 'Steve Jobs' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-001.jpg',
    description: {
      ko: '시장 기회를 빠르게 포착하고 실행으로 옮기는 편입니다.',
      en: 'You spot market opportunities quickly and act on them.'
    },
    sourceUrl: 'https://namu.wiki/w/스티브 잡스',
    scores: { H: 76, E: 85, X: 54, A: 34, C: 76, O: 86 }
  },
  {
    id: 'entrepreneur-002',
    name: { ko: '일론 머스크', en: 'Elon Musk' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-002.jpg',
    description: {
      ko: '장기 비전과 확장 전략을 기반으로 성장을 이끕니다.',
      en: 'You drive growth with long term vision and expansion strategy.'
    },
    sourceUrl: 'https://namu.wiki/w/일론 머스크',
    scores: { H: 26, E: 90, X: 52, A: 70, C: 64, O: 64 }
  },
  {
    id: 'entrepreneur-003',
    name: { ko: '정주영', en: 'Chung Ju-yung' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-003.jpg',
    description: {
      ko: '리스크를 감수하며 혁신을 추진하는 스타일입니다.',
      en: 'You take risks and push innovation forward.'
    },
    sourceUrl: 'https://namu.wiki/w/정주영',
    scores: { H: 29, E: 64, X: 63, A: 74, C: 47, O: 52 }
  },
  {
    id: 'entrepreneur-004',
    name: { ko: '빌 게이츠', en: 'Bill Gates' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-004.jpg',
    description: {
      ko: '운영 효율과 조직 문화를 함께 고려합니다.',
      en: 'You consider operational efficiency and organizational culture.'
    },
    sourceUrl: 'https://namu.wiki/w/빌 게이츠',
    scores: { H: 40, E: 67, X: 30, A: 32, C: 25, O: 31 }
  },
  {
    id: 'entrepreneur-005',
    name: { ko: '제프 베이조스', en: 'Jeff Bezos' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-005.jpg',
    description: {
      ko: '사용자 경험과 품질을 중시하며 제품을 다듬습니다.',
      en: 'You focus on user experience and product quality.'
    },
    sourceUrl: 'https://namu.wiki/w/제프 베이조스',
    scores: { H: 80, E: 74, X: 90, A: 83, C: 34, O: 40 }
  },
  {
    id: 'entrepreneur-006',
    name: { ko: '워런 버핏', en: '워런 버핏' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-006.jpg',
    description: {
      ko: '시장 기회를 빠르게 포착하고 실행으로 옮기는 편입니다.',
      en: 'You spot market opportunities quickly and act on them.'
    },
    sourceUrl: 'https://namu.wiki/w/워런 버핏',
    scores: { H: 66, E: 33, X: 53, A: 35, C: 92, O: 92 }
  },
  {
    id: 'entrepreneur-007',
    name: { ko: '마크 저커버그', en: '마크 저커버그' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-007.jpg',
    description: {
      ko: '장기 비전과 확장 전략을 기반으로 성장을 이끕니다.',
      en: 'You drive growth with long term vision and expansion strategy.'
    },
    sourceUrl: 'https://namu.wiki/w/마크 저커버그',
    scores: { H: 43, E: 74, X: 38, A: 34, C: 42, O: 66 }
  },
  {
    id: 'entrepreneur-008',
    name: { ko: '래리 페이지', en: '래리 페이지' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-008.jpg',
    description: {
      ko: '리스크를 감수하며 혁신을 추진하는 스타일입니다.',
      en: 'You take risks and push innovation forward.'
    },
    sourceUrl: 'https://namu.wiki/w/래리 페이지',
    scores: { H: 39, E: 56, X: 72, A: 46, C: 70, O: 38 }
  },
  {
    id: 'entrepreneur-009',
    name: { ko: '세르게이 브린', en: '세르게이 브린' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-009.jpg',
    description: {
      ko: '운영 효율과 조직 문화를 함께 고려합니다.',
      en: 'You consider operational efficiency and organizational culture.'
    },
    sourceUrl: 'https://namu.wiki/w/세르게이 브린',
    scores: { H: 26, E: 30, X: 90, A: 56, C: 94, O: 40 }
  },
  {
    id: 'entrepreneur-010',
    name: { ko: '팀 쿡', en: '팀 쿡' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-010.jpg',
    description: {
      ko: '사용자 경험과 품질을 중시하며 제품을 다듬습니다.',
      en: 'You focus on user experience and product quality.'
    },
    sourceUrl: 'https://namu.wiki/w/팀 쿡',
    scores: { H: 87, E: 58, X: 56, A: 33, C: 90, O: 57 }
  },
  {
    id: 'entrepreneur-011',
    name: { ko: '사티아 나델라', en: '사티아 나델라' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-011.jpg',
    description: {
      ko: '시장 기회를 빠르게 포착하고 실행으로 옮기는 편입니다.',
      en: 'You spot market opportunities quickly and act on them.'
    },
    sourceUrl: 'https://namu.wiki/w/사티아 나델라',
    scores: { H: 94, E: 34, X: 35, A: 54, C: 55, O: 27 }
  },
  {
    id: 'entrepreneur-012',
    name: { ko: '순다 피차이', en: '순다 피차이' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-012.jpg',
    description: {
      ko: '장기 비전과 확장 전략을 기반으로 성장을 이끕니다.',
      en: 'You drive growth with long term vision and expansion strategy.'
    },
    sourceUrl: 'https://namu.wiki/w/순다 피차이',
    scores: { H: 54, E: 60, X: 33, A: 43, C: 93, O: 54 }
  },
  {
    id: 'entrepreneur-013',
    name: { ko: '리드 헤이스팅스', en: '리드 헤이스팅스' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-013.jpg',
    description: {
      ko: '리스크를 감수하며 혁신을 추진하는 스타일입니다.',
      en: 'You take risks and push innovation forward.'
    },
    sourceUrl: 'https://namu.wiki/w/리드 헤이스팅스',
    scores: { H: 29, E: 54, X: 85, A: 36, C: 55, O: 71 }
  },
  {
    id: 'entrepreneur-014',
    name: { ko: '잭 도시', en: '잭 도시' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-014.jpg',
    description: {
      ko: '운영 효율과 조직 문화를 함께 고려합니다.',
      en: 'You consider operational efficiency and organizational culture.'
    },
    sourceUrl: 'https://namu.wiki/w/잭 도시',
    scores: { H: 51, E: 36, X: 58, A: 50, C: 26, O: 70 }
  },
  {
    id: 'entrepreneur-015',
    name: { ko: '리처드 브랜슨', en: '리처드 브랜슨' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-015.jpg',
    description: {
      ko: '사용자 경험과 품질을 중시하며 제품을 다듬습니다.',
      en: 'You focus on user experience and product quality.'
    },
    sourceUrl: 'https://namu.wiki/w/리처드 브랜슨',
    scores: { H: 36, E: 79, X: 48, A: 40, C: 68, O: 68 }
  },
  {
    id: 'entrepreneur-016',
    name: { ko: '베르나르 아르노', en: '베르나르 아르노' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-016.jpg',
    description: {
      ko: '시장 기회를 빠르게 포착하고 실행으로 옮기는 편입니다.',
      en: 'You spot market opportunities quickly and act on them.'
    },
    sourceUrl: 'https://namu.wiki/w/베르나르 아르노',
    scores: { H: 44, E: 72, X: 73, A: 29, C: 25, O: 47 }
  },
  {
    id: 'entrepreneur-017',
    name: { ko: '마윈', en: '마윈' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-017.jpg',
    description: {
      ko: '장기 비전과 확장 전략을 기반으로 성장을 이끕니다.',
      en: 'You drive growth with long term vision and expansion strategy.'
    },
    sourceUrl: 'https://namu.wiki/w/마윈',
    scores: { H: 71, E: 69, X: 78, A: 64, C: 91, O: 58 }
  },
  {
    id: 'entrepreneur-018',
    name: { ko: '리카싱', en: '리카싱' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-018.jpg',
    description: {
      ko: '리스크를 감수하며 혁신을 추진하는 스타일입니다.',
      en: 'You take risks and push innovation forward.'
    },
    sourceUrl: 'https://namu.wiki/w/리카싱',
    scores: { H: 54, E: 48, X: 42, A: 76, C: 65, O: 39 }
  },
  {
    id: 'entrepreneur-019',
    name: { ko: '마이클 델', en: '마이클 델' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-019.jpg',
    description: {
      ko: '운영 효율과 조직 문화를 함께 고려합니다.',
      en: 'You consider operational efficiency and organizational culture.'
    },
    sourceUrl: 'https://namu.wiki/w/마이클 델',
    scores: { H: 52, E: 83, X: 90, A: 31, C: 82, O: 37 }
  },
  {
    id: 'entrepreneur-020',
    name: { ko: '마이클 블룸버그', en: '마이클 블룸버그' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-020.jpg',
    description: {
      ko: '사용자 경험과 품질을 중시하며 제품을 다듬습니다.',
      en: 'You focus on user experience and product quality.'
    },
    sourceUrl: 'https://namu.wiki/w/마이클 블룸버그',
    scores: { H: 47, E: 48, X: 42, A: 25, C: 70, O: 42 }
  },
  {
    id: 'entrepreneur-021',
    name: { ko: '하워드 슐츠', en: '하워드 슐츠' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-021.jpg',
    description: {
      ko: '시장 기회를 빠르게 포착하고 실행으로 옮기는 편입니다.',
      en: 'You spot market opportunities quickly and act on them.'
    },
    sourceUrl: 'https://namu.wiki/w/하워드 슐츠',
    scores: { H: 38, E: 76, X: 39, A: 84, C: 78, O: 71 }
  },
  {
    id: 'entrepreneur-022',
    name: { ko: '피터 틸', en: '피터 틸' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-022.jpg',
    description: {
      ko: '장기 비전과 확장 전략을 기반으로 성장을 이끕니다.',
      en: 'You drive growth with long term vision and expansion strategy.'
    },
    sourceUrl: 'https://namu.wiki/w/피터 틸',
    scores: { H: 33, E: 34, X: 27, A: 38, C: 45, O: 75 }
  },
  {
    id: 'entrepreneur-023',
    name: { ko: '레이 달리오', en: '레이 달리오' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-023.jpg',
    description: {
      ko: '리스크를 감수하며 혁신을 추진하는 스타일입니다.',
      en: 'You take risks and push innovation forward.'
    },
    sourceUrl: 'https://namu.wiki/w/레이 달리오',
    scores: { H: 47, E: 52, X: 70, A: 55, C: 47, O: 93 }
  },
  {
    id: 'entrepreneur-024',
    name: { ko: '샘 월턴', en: '샘 월턴' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-024.jpg',
    description: {
      ko: '운영 효율과 조직 문화를 함께 고려합니다.',
      en: 'You consider operational efficiency and organizational culture.'
    },
    sourceUrl: 'https://namu.wiki/w/샘 월턴',
    scores: { H: 48, E: 57, X: 91, A: 83, C: 61, O: 69 }
  },
  {
    id: 'entrepreneur-025',
    name: { ko: '헨리 포드', en: '헨리 포드' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-025.jpg',
    description: {
      ko: '사용자 경험과 품질을 중시하며 제품을 다듬습니다.',
      en: 'You focus on user experience and product quality.'
    },
    sourceUrl: 'https://namu.wiki/w/헨리 포드',
    scores: { H: 93, E: 25, X: 49, A: 71, C: 41, O: 67 }
  },
  {
    id: 'entrepreneur-026',
    name: { ko: '존 D. 록펠러', en: '존 D. 록펠러' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-026.jpg',
    description: {
      ko: '시장 기회를 빠르게 포착하고 실행으로 옮기는 편입니다.',
      en: 'You spot market opportunities quickly and act on them.'
    },
    sourceUrl: 'https://namu.wiki/w/존 D. 록펠러',
    scores: { H: 95, E: 46, X: 88, A: 41, C: 35, O: 62 }
  },
  {
    id: 'entrepreneur-027',
    name: { ko: '이병철', en: '이병철' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-027.jpg',
    description: {
      ko: '장기 비전과 확장 전략을 기반으로 성장을 이끕니다.',
      en: 'You drive growth with long term vision and expansion strategy.'
    },
    sourceUrl: 'https://namu.wiki/w/이병철',
    scores: { H: 46, E: 71, X: 44, A: 83, C: 61, O: 84 }
  },
  {
    id: 'entrepreneur-028',
    name: { ko: '이건희', en: '이건희' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-028.jpg',
    description: {
      ko: '리스크를 감수하며 혁신을 추진하는 스타일입니다.',
      en: 'You take risks and push innovation forward.'
    },
    sourceUrl: 'https://namu.wiki/w/이건희',
    scores: { H: 95, E: 61, X: 32, A: 64, C: 41, O: 33 }
  },
  {
    id: 'entrepreneur-029',
    name: { ko: '이재용', en: '이재용' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-029.jpg',
    description: {
      ko: '운영 효율과 조직 문화를 함께 고려합니다.',
      en: 'You consider operational efficiency and organizational culture.'
    },
    sourceUrl: 'https://namu.wiki/w/이재용',
    scores: { H: 47, E: 82, X: 29, A: 34, C: 77, O: 62 }
  },
  {
    id: 'entrepreneur-030',
    name: { ko: '정의선', en: '정의선' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-030.jpg',
    description: {
      ko: '사용자 경험과 품질을 중시하며 제품을 다듬습니다.',
      en: 'You focus on user experience and product quality.'
    },
    sourceUrl: 'https://namu.wiki/w/정의선',
    scores: { H: 59, E: 92, X: 33, A: 72, C: 59, O: 81 }
  },
  {
    id: 'entrepreneur-031',
    name: { ko: '정몽구', en: '정몽구' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-031.jpg',
    description: {
      ko: '시장 기회를 빠르게 포착하고 실행으로 옮기는 편입니다.',
      en: 'You spot market opportunities quickly and act on them.'
    },
    sourceUrl: 'https://namu.wiki/w/정몽구',
    scores: { H: 44, E: 46, X: 53, A: 45, C: 28, O: 51 }
  },
  {
    id: 'entrepreneur-032',
    name: { ko: '최태원', en: '최태원' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-032.jpg',
    description: {
      ko: '장기 비전과 확장 전략을 기반으로 성장을 이끕니다.',
      en: 'You drive growth with long term vision and expansion strategy.'
    },
    sourceUrl: 'https://namu.wiki/w/최태원',
    scores: { H: 73, E: 47, X: 34, A: 93, C: 78, O: 38 }
  },
  {
    id: 'entrepreneur-033',
    name: { ko: '신격호', en: '신격호' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-033.jpg',
    description: {
      ko: '리스크를 감수하며 혁신을 추진하는 스타일입니다.',
      en: 'You take risks and push innovation forward.'
    },
    sourceUrl: 'https://namu.wiki/w/신격호',
    scores: { H: 86, E: 28, X: 43, A: 39, C: 80, O: 73 }
  },
  {
    id: 'entrepreneur-034',
    name: { ko: '구자경', en: '구자경' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-034.jpg',
    description: {
      ko: '운영 효율과 조직 문화를 함께 고려합니다.',
      en: 'You consider operational efficiency and organizational culture.'
    },
    sourceUrl: 'https://namu.wiki/w/구자경',
    scores: { H: 57, E: 37, X: 32, A: 44, C: 71, O: 71 }
  },
  {
    id: 'entrepreneur-035',
    name: { ko: '구본무', en: '구본무' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-035.jpg',
    description: {
      ko: '사용자 경험과 품질을 중시하며 제품을 다듬습니다.',
      en: 'You focus on user experience and product quality.'
    },
    sourceUrl: 'https://namu.wiki/w/구본무',
    scores: { H: 41, E: 36, X: 78, A: 86, C: 68, O: 26 }
  },
  {
    id: 'entrepreneur-036',
    name: { ko: '허창수', en: '허창수' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-036.jpg',
    description: {
      ko: '시장 기회를 빠르게 포착하고 실행으로 옮기는 편입니다.',
      en: 'You spot market opportunities quickly and act on them.'
    },
    sourceUrl: 'https://namu.wiki/w/허창수',
    scores: { H: 33, E: 66, X: 39, A: 30, C: 56, O: 30 }
  },
  {
    id: 'entrepreneur-037',
    name: { ko: '김승연', en: '김승연' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-037.jpg',
    description: {
      ko: '장기 비전과 확장 전략을 기반으로 성장을 이끕니다.',
      en: 'You drive growth with long term vision and expansion strategy.'
    },
    sourceUrl: 'https://namu.wiki/w/김승연',
    scores: { H: 59, E: 37, X: 66, A: 46, C: 53, O: 37 }
  },
  {
    id: 'entrepreneur-038',
    name: { ko: '이해진', en: '이해진' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-038.jpg',
    description: {
      ko: '리스크를 감수하며 혁신을 추진하는 스타일입니다.',
      en: 'You take risks and push innovation forward.'
    },
    sourceUrl: 'https://namu.wiki/w/이해진',
    scores: { H: 49, E: 77, X: 57, A: 92, C: 79, O: 40 }
  },
  {
    id: 'entrepreneur-039',
    name: { ko: '김범수', en: '김범수' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-039.jpg',
    description: {
      ko: '운영 효율과 조직 문화를 함께 고려합니다.',
      en: 'You consider operational efficiency and organizational culture.'
    },
    sourceUrl: 'https://namu.wiki/w/김범수',
    scores: { H: 26, E: 56, X: 91, A: 55, C: 78, O: 53 }
  },
  {
    id: 'entrepreneur-040',
    name: { ko: '김정주', en: '김정주' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-040.jpg',
    description: {
      ko: '사용자 경험과 품질을 중시하며 제품을 다듬습니다.',
      en: 'You focus on user experience and product quality.'
    },
    sourceUrl: 'https://namu.wiki/w/김정주',
    scores: { H: 34, E: 40, X: 53, A: 63, C: 87, O: 50 }
  },
  {
    id: 'entrepreneur-041',
    name: { ko: '김택진', en: '김택진' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-041.jpg',
    description: {
      ko: '시장 기회를 빠르게 포착하고 실행으로 옮기는 편입니다.',
      en: 'You spot market opportunities quickly and act on them.'
    },
    sourceUrl: 'https://namu.wiki/w/김택진',
    scores: { H: 69, E: 52, X: 81, A: 88, C: 67, O: 46 }
  },
  {
    id: 'entrepreneur-042',
    name: { ko: '서정진', en: '서정진' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-042.jpg',
    description: {
      ko: '장기 비전과 확장 전략을 기반으로 성장을 이끕니다.',
      en: 'You drive growth with long term vision and expansion strategy.'
    },
    sourceUrl: 'https://namu.wiki/w/서정진',
    scores: { H: 71, E: 57, X: 26, A: 52, C: 42, O: 54 }
  },
  {
    id: 'entrepreneur-043',
    name: { ko: '이재현', en: '이재현' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-043.jpg',
    description: {
      ko: '리스크를 감수하며 혁신을 추진하는 스타일입니다.',
      en: 'You take risks and push innovation forward.'
    },
    sourceUrl: 'https://namu.wiki/w/이재현',
    scores: { H: 84, E: 87, X: 27, A: 55, C: 71, O: 27 }
  },
  {
    id: 'entrepreneur-044',
    name: { ko: '정용진', en: '정용진' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-044.jpg',
    description: {
      ko: '운영 효율과 조직 문화를 함께 고려합니다.',
      en: 'You consider operational efficiency and organizational culture.'
    },
    sourceUrl: 'https://namu.wiki/w/정용진',
    scores: { H: 90, E: 41, X: 37, A: 35, C: 46, O: 40 }
  },
  {
    id: 'entrepreneur-045',
    name: { ko: '방시혁', en: '방시혁' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-045.jpg',
    description: {
      ko: '사용자 경험과 품질을 중시하며 제품을 다듬습니다.',
      en: 'You focus on user experience and product quality.'
    },
    sourceUrl: 'https://namu.wiki/w/방시혁',
    scores: { H: 28, E: 89, X: 70, A: 33, C: 50, O: 53 }
  },
  {
    id: 'entrepreneur-046',
    name: { ko: '장병규', en: '장병규' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-046.jpg',
    description: {
      ko: '시장 기회를 빠르게 포착하고 실행으로 옮기는 편입니다.',
      en: 'You spot market opportunities quickly and act on them.'
    },
    sourceUrl: 'https://namu.wiki/w/장병규',
    scores: { H: 86, E: 84, X: 66, A: 33, C: 27, O: 42 }
  },
  {
    id: 'entrepreneur-047',
    name: { ko: '김범준', en: '김범준' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-047.jpg',
    description: {
      ko: '장기 비전과 확장 전략을 기반으로 성장을 이끕니다.',
      en: 'You drive growth with long term vision and expansion strategy.'
    },
    sourceUrl: 'https://namu.wiki/w/김범준',
    scores: { H: 40, E: 51, X: 63, A: 49, C: 68, O: 65 }
  },
  {
    id: 'entrepreneur-048',
    name: { ko: '이재웅', en: '이재웅' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-048.jpg',
    description: {
      ko: '리스크를 감수하며 혁신을 추진하는 스타일입니다.',
      en: 'You take risks and push innovation forward.'
    },
    sourceUrl: 'https://namu.wiki/w/이재웅',
    scores: { H: 30, E: 47, X: 42, A: 57, C: 67, O: 39 }
  },
  {
    id: 'entrepreneur-049',
    name: { ko: '김봉진', en: '김봉진' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-049.jpg',
    description: {
      ko: '운영 효율과 조직 문화를 함께 고려합니다.',
      en: 'You consider operational efficiency and organizational culture.'
    },
    sourceUrl: 'https://namu.wiki/w/김봉진',
    scores: { H: 30, E: 58, X: 52, A: 27, C: 75, O: 50 }
  },
  {
    id: 'entrepreneur-050',
    name: { ko: '백종원', en: '백종원' },
    category: 'entrepreneur',
    image: '/personas/entrepreneur-050.jpg',
    description: {
      ko: '사용자 경험과 품질을 중시하며 제품을 다듬습니다.',
      en: 'You focus on user experience and product quality.'
    },
    sourceUrl: 'https://namu.wiki/w/백종원',
    scores: { H: 53, E: 32, X: 71, A: 30, C: 69, O: 63 }
  },
]

export const categoryColors: Record<Persona['category'], string> = {
  celebrity: '#EC4899',
  artist: '#8B5CF6',
  politician: '#3B82F6',
  entrepreneur: '#10B981'
}
