export interface Question {
  id: number
  factor: 'H' | 'E' | 'X' | 'A' | 'C' | 'O'
  facet: number
  reverse: boolean
  ko: string
  en: string
}

// HEXACO-60 문항 (각 요인당 10문항)
export const questions: Question[] = [
  // H - Honesty-Humility (정직-겸손)
  { id: 1, factor: 'H', facet: 1, reverse: false, ko: '나는 아첨을 사용해서 승진하거나 인상을 받으려 하지 않는다.', en: 'I wouldn\'t use flattery to get a raise or promotion at work.' },
  { id: 2, factor: 'H', facet: 1, reverse: true, ko: '내가 원하는 것을 얻기 위해서라면 다른 사람을 조종할 의향이 있다.', en: 'I would be willing to manipulate others to get what I want.' },
  { id: 3, factor: 'H', facet: 2, reverse: false, ko: '나는 뇌물을 받지 않을 것이다, 아무리 액수가 커도.', en: 'I would never accept a bribe, even if it were very large.' },
  { id: 4, factor: 'H', facet: 2, reverse: true, ko: '걸리지 않을 것이 확실하다면, 많은 돈을 훔칠 의향이 있다.', en: 'I\'d be tempted to steal a large sum of money if I knew I could get away with it.' },
  { id: 5, factor: 'H', facet: 3, reverse: false, ko: '비싼 명품을 소유하는 것이 나에게 중요하지 않다.', en: 'Owning expensive luxury goods is not important to me.' },
  { id: 6, factor: 'H', facet: 3, reverse: true, ko: '나는 고급스럽고 높은 지위를 나타내는 물건들을 갖고 싶다.', en: 'I want to have lots of money and expensive possessions.' },
  { id: 7, factor: 'H', facet: 4, reverse: false, ko: '나는 다른 사람들보다 더 많은 존경을 받을 자격이 있다고 생각하지 않는다.', en: 'I don\'t think I\'m entitled to more respect than other people.' },
  { id: 8, factor: 'H', facet: 4, reverse: true, ko: '나는 매우 중요한 사람이라고 생각하며, 다른 사람들도 나를 그렇게 대해야 한다고 생각한다.', en: 'I think that I am entitled to more respect than the average person.' },
  { id: 9, factor: 'H', facet: 1, reverse: false, ko: '내가 누군가에게 무언가를 원할 때, 나는 진심으로 칭찬하기보다 빈정거리지 않는다.', en: 'If I want something from someone, I ask for it directly instead of manipulating.' },
  { id: 10, factor: 'H', facet: 2, reverse: true, ko: '법을 어기더라도 이익이 된다면 그렇게 할 수 있다.', en: 'I could be tempted to break laws if I thought I could get away with it.' },

  // E - Emotionality (정서성)
  { id: 11, factor: 'E', facet: 1, reverse: false, ko: '신체적으로 위험한 상황에 처하면 무섭다.', en: 'I would feel afraid if I had to travel in dangerous conditions.' },
  { id: 12, factor: 'E', facet: 1, reverse: true, ko: '신체적 고통을 주는 상황에서도 별로 걱정이 되지 않는다.', en: 'I don\'t worry much about physical dangers.' },
  { id: 13, factor: 'E', facet: 2, reverse: false, ko: '스트레스를 받으면 누군가의 도움이 필요하다.', en: 'When I\'m stressed, I need support from others.' },
  { id: 14, factor: 'E', facet: 2, reverse: true, ko: '나는 다른 사람들로부터 정서적 지지를 거의 필요로 하지 않는다.', en: 'I rarely need emotional support from others.' },
  { id: 15, factor: 'E', facet: 3, reverse: false, ko: '작은 문제에 대해서도 걱정하는 경향이 있다.', en: 'I tend to worry about little things.' },
  { id: 16, factor: 'E', facet: 3, reverse: true, ko: '나는 거의 걱정하지 않는다.', en: 'I rarely worry about things.' },
  { id: 17, factor: 'E', facet: 4, reverse: false, ko: '슬픈 영화를 보면 눈물이 날 수 있다.', en: 'I sometimes feel emotional when watching sad movies.' },
  { id: 18, factor: 'E', facet: 4, reverse: true, ko: '다른 사람들의 문제에 별로 감정적으로 반응하지 않는다.', en: 'I don\'t usually get emotional about other people\'s problems.' },
  { id: 19, factor: 'E', facet: 1, reverse: false, ko: '위험한 상황에서는 공포를 느낀다.', en: 'I feel frightened in dangerous situations.' },
  { id: 20, factor: 'E', facet: 3, reverse: false, ko: '미래에 대해 걱정할 때가 많다.', en: 'I often worry about the future.' },

  // X - eXtraversion (외향성)
  { id: 21, factor: 'X', facet: 1, reverse: false, ko: '나는 자신에 대해 긍정적으로 느낀다.', en: 'I generally feel positive about myself.' },
  { id: 22, factor: 'X', facet: 1, reverse: true, ko: '나는 다른 사람들에 비해 인기가 적다고 느낀다.', en: 'I feel that I\'m less popular than other people.' },
  { id: 23, factor: 'X', facet: 2, reverse: false, ko: '파티나 사교 모임에서 새로운 사람들과 이야기하는 것을 좋아한다.', en: 'I enjoy talking to strangers at parties.' },
  { id: 24, factor: 'X', facet: 2, reverse: true, ko: '나는 사교 모임을 피하는 편이다.', en: 'I tend to avoid social gatherings.' },
  { id: 25, factor: 'X', facet: 3, reverse: false, ko: '대부분의 날에 기분이 좋고 낙관적이다.', en: 'On most days, I feel cheerful and optimistic.' },
  { id: 26, factor: 'X', facet: 3, reverse: true, ko: '다른 사람들보다 덜 활기차고 활동적이다.', en: 'I feel less energetic than most people my age.' },
  { id: 27, factor: 'X', facet: 4, reverse: false, ko: '나는 그룹 활동에서 자연스럽게 리더 역할을 맡는다.', en: 'In social situations, I naturally take on a leadership role.' },
  { id: 28, factor: 'X', facet: 4, reverse: true, ko: '나는 그룹에서 주목받는 것을 불편해한다.', en: 'I feel uncomfortable being the center of attention.' },
  { id: 29, factor: 'X', facet: 2, reverse: false, ko: '새로운 사람들을 만나는 것이 즐겁다.', en: 'I enjoy meeting new people.' },
  { id: 30, factor: 'X', facet: 3, reverse: false, ko: '나는 대체로 활기차고 에너지가 넘친다.', en: 'I am usually full of energy.' },

  // A - Agreeableness (원만성)
  { id: 31, factor: 'A', facet: 1, reverse: false, ko: '나를 잘못 대한 사람들을 용서하는 편이다.', en: 'I tend to forgive people who have wronged me.' },
  { id: 32, factor: 'A', facet: 1, reverse: true, ko: '누군가 나를 한 번 속이면, 그 사람을 항상 의심할 것이다.', en: 'If someone deceives me once, I will always be suspicious of them.' },
  { id: 33, factor: 'A', facet: 2, reverse: false, ko: '다른 사람들이 나를 부당하게 대해도 화를 잘 안 낸다.', en: 'I rarely get angry, even when people treat me unfairly.' },
  { id: 34, factor: 'A', facet: 2, reverse: true, ko: '사람들이 나를 모욕하면 매우 화가 난다.', en: 'I get very angry when someone insults me.' },
  { id: 35, factor: 'A', facet: 3, reverse: false, ko: '나는 타협과 협상에 능하다.', en: 'I am good at compromise and negotiation.' },
  { id: 36, factor: 'A', facet: 3, reverse: true, ko: '토론에서 내 의견을 고수하는 편이다.', en: 'I tend to stick to my opinions in discussions.' },
  { id: 37, factor: 'A', facet: 4, reverse: false, ko: '다른 사람들의 단점에 관대한 편이다.', en: 'I am generally tolerant of other people\'s faults.' },
  { id: 38, factor: 'A', facet: 4, reverse: true, ko: '나는 다른 사람들을 비판하는 경향이 있다.', en: 'I tend to be critical of others.' },
  { id: 39, factor: 'A', facet: 1, reverse: false, ko: '다른 사람의 실수를 쉽게 잊는다.', en: 'I easily forget others\' mistakes.' },
  { id: 40, factor: 'A', facet: 2, reverse: true, ko: '기분이 상하면 오래 간다.', en: 'When I\'m upset, it lasts for a long time.' },

  // C - Conscientiousness (성실성)
  { id: 41, factor: 'C', facet: 1, reverse: false, ko: '계획을 세우고 그것을 따르는 편이다.', en: 'I like to plan things and follow through.' },
  { id: 42, factor: 'C', facet: 1, reverse: true, ko: '일을 마지막 순간까지 미루는 경향이 있다.', en: 'I tend to put off tasks until the last minute.' },
  { id: 43, factor: 'C', facet: 2, reverse: false, ko: '일할 때 세부 사항에 주의를 기울인다.', en: 'I pay attention to details when I work.' },
  { id: 44, factor: 'C', facet: 2, reverse: true, ko: '실수를 많이 하는 편이다.', en: 'I often make mistakes due to carelessness.' },
  { id: 45, factor: 'C', facet: 3, reverse: false, ko: '모든 일을 완벽하게 하려고 노력한다.', en: 'I strive for perfection in everything I do.' },
  { id: 46, factor: 'C', facet: 3, reverse: true, ko: '업무의 질에 대해 크게 신경 쓰지 않는다.', en: 'I\'m not too concerned about the quality of my work.' },
  { id: 47, factor: 'C', facet: 4, reverse: false, ko: '중요한 결정을 내리기 전에 신중하게 생각한다.', en: 'I think carefully before making important decisions.' },
  { id: 48, factor: 'C', facet: 4, reverse: true, ko: '충동적으로 행동하는 경향이 있다.', en: 'I tend to act on impulse.' },
  { id: 49, factor: 'C', facet: 1, reverse: false, ko: '내 물건들이 깔끔하고 정리되어 있다.', en: 'I keep my belongings neat and organized.' },
  { id: 50, factor: 'C', facet: 2, reverse: false, ko: '맡은 일은 끝까지 완수한다.', en: 'I always complete the tasks I\'m given.' },

  // O - Openness to Experience (개방성)
  { id: 51, factor: 'O', facet: 1, reverse: false, ko: '예술 작품을 감상하는 것을 좋아한다.', en: 'I enjoy appreciating works of art.' },
  { id: 52, factor: 'O', facet: 1, reverse: true, ko: '예술이나 미학에 관심이 별로 없다.', en: 'I\'m not very interested in art or aesthetics.' },
  { id: 53, factor: 'O', facet: 2, reverse: false, ko: '자연의 아름다움에 감동받는다.', en: 'I am moved by the beauty of nature.' },
  { id: 54, factor: 'O', facet: 2, reverse: true, ko: '자연 경관을 보는 것이 지루하다.', en: 'I find looking at natural scenery boring.' },
  { id: 55, factor: 'O', facet: 3, reverse: false, ko: '추상적이거나 이론적인 토론을 즐긴다.', en: 'I enjoy abstract or theoretical discussions.' },
  { id: 56, factor: 'O', facet: 3, reverse: true, ko: '철학적 토론에 관심이 없다.', en: 'I\'m not interested in philosophical discussions.' },
  { id: 57, factor: 'O', facet: 4, reverse: false, ko: '새롭고 창의적인 아이디어에 관심이 많다.', en: 'I\'m interested in new and creative ideas.' },
  { id: 58, factor: 'O', facet: 4, reverse: true, ko: '전통적인 방식을 따르는 것을 선호한다.', en: 'I prefer to stick to traditional ways of doing things.' },
  { id: 59, factor: 'O', facet: 1, reverse: false, ko: '상상력이 풍부하다고 생각한다.', en: 'I consider myself to have a rich imagination.' },
  { id: 60, factor: 'O', facet: 3, reverse: false, ko: '다양한 주제에 대해 배우는 것을 좋아한다.', en: 'I enjoy learning about a wide variety of topics.' },
]

export const factorColors: Record<string, string> = {
  H: '#8B5CF6', // purple
  E: '#EC4899', // pink
  X: '#F59E0B', // amber
  A: '#10B981', // emerald
  C: '#3B82F6', // blue
  O: '#EF4444', // red
}

export const factors = ['H', 'E', 'X', 'A', 'C', 'O'] as const
export type Factor = typeof factors[number]
