import { Factor, factors } from '../data/questions'

type Language = 'ko' | 'en'
type Level = 'low' | 'mid' | 'high'
type Scores = Record<Factor, number>

const analysisCopy: Record<Language, Record<Factor, Record<Level, string>>> = {
  ko: {
    H: {
      high: '정직과 공정을 핵심 가치로 삼고, 개인적 이득을 위해 타인을 이용하는 것을 꺼립니다. 겸손함과 성실함이 신뢰와 장기적인 관계를 만듭니다.',
      mid: '개인의 목표와 공정함 사이에서 균형을 잡는 편입니다. 필요할 때는 협상하지만, 과도한 특권 의식이나 조작으로 흐르지 않습니다.',
      low: '목표 달성을 위해 경쟁적으로 움직일 수 있습니다. 의도를 명확히 공유하지 않으면 자기중심적으로 보일 수 있습니다.'
    },
    E: {
      high: '감정 변화에 민감하고 스트레스나 불확실성에 영향을 받기 쉽습니다. 대신 공감 능력이 높아 관계의 안정감을 중요하게 여깁니다.',
      mid: '감정적으로 안정적이면서도 필요한 순간에는 조심스럽게 대비합니다. 도움을 요청하거나 스스로 진정하는 균형이 있습니다.',
      low: '위기 상황에서도 침착함을 유지하고 독립적으로 대응하는 편입니다. 감정을 크게 드러내지 않아 차분하거나 거리감 있게 보일 수 있습니다.'
    },
    X: {
      high: '사교적이고 에너지가 높아 사람들과의 상호작용에서 활력을 얻습니다. 주도적으로 의견을 내고 리더십을 발휘하는 경우가 많습니다.',
      mid: '상황에 따라 적극적으로 나서거나 관찰자로 머무는 유연한 스타일입니다. 대인관계에서 균형 있는 참여가 가능합니다.',
      low: '조용한 환경에서 집중이 잘 되고, 친밀한 소수 관계를 선호합니다. 관심의 중심에 서는 것을 피하며 신중하게 표현합니다.'
    },
    A: {
      high: '갈등을 줄이고 관계의 조화를 중시합니다. 관대하고 용서하는 경향이 있어 협력적인 분위기를 만듭니다.',
      mid: '협력과 원칙 사이에서 균형을 잡습니다. 필요할 때는 단호하게 의견을 내면서도 관계를 해치지 않으려 합니다.',
      low: '비판적 사고와 직설적인 표현을 선호합니다. 불합리하다고 느끼면 맞서는 편이라 갈등 상황이 생길 수 있습니다.'
    },
    C: {
      high: '체계적으로 목표를 세우고 꾸준히 실행합니다. 꼼꼼함과 책임감이 높아 마감과 품질을 중시합니다.',
      mid: '기본적인 계획성은 유지하면서 상황에 따라 유연하게 조정합니다. 큰 흐름을 보며 필요할 때만 세부를 챙깁니다.',
      low: '자유로운 방식으로 즉흥적으로 움직이는 편입니다. 세부 관리나 반복적인 작업에서 집중력이 떨어질 수 있습니다.'
    },
    O: {
      high: '새로운 아이디어와 다양한 경험에 열려 있습니다. 창의적이고 상상력이 풍부하며 변화에 대한 수용성이 높습니다.',
      mid: '새로움을 즐기되 실용성도 함께 고려합니다. 충분히 납득되면 변화를 받아들이는 편입니다.',
      low: '안정적인 방식과 익숙한 환경을 선호합니다. 전통적인 절차나 검증된 방법을 따르는 데 편안함을 느낍니다.'
    }
  },
  en: {
    H: {
      high: 'You value fairness and sincerity, and you avoid exploiting others for personal gain. Modesty and integrity guide how you build trust and long-term relationships.',
      mid: 'You balance personal interests with fairness. You can negotiate when needed without leaning toward manipulation or excessive self-denial.',
      low: 'You can be competitive and goal-focused, even if it means pushing boundaries. Without clear intent-sharing, others may read this as self-serving.'
    },
    E: {
      high: 'You feel emotions deeply and can be sensitive to stress or uncertainty. This often comes with strong empathy and a desire for close, supportive bonds.',
      mid: 'You are emotionally aware but generally steady. You can handle stress while still seeking reassurance when it truly matters.',
      low: 'You stay calm under pressure and prefer independence in tough moments. Because you show fewer emotional cues, some people may perceive you as distant.'
    },
    X: {
      high: 'You gain energy from social interaction and speak up with confidence. Leadership, initiative, and enthusiasm come naturally to you.',
      mid: 'You can switch between social and quiet modes depending on context. You contribute steadily without needing to dominate the room.',
      low: 'You are more reserved and recharge through solitude or small-group settings. You may avoid the spotlight but often observe and think deeply.'
    },
    A: {
      high: 'You prioritize harmony and are patient in conflict. Your forgiving style helps teams cooperate and lowers tension.',
      mid: 'You balance cooperation with assertiveness. You can disagree without escalating and pick your battles.',
      low: 'You are direct and critical when needed. This can drive honest feedback but may create friction if not softened.'
    },
    C: {
      high: 'You plan ahead, stay organized, and follow through consistently. Reliability and high standards shape your work habits.',
      mid: 'You keep a workable structure while staying flexible. You manage responsibilities without feeling overly rigid.',
      low: 'You prefer spontaneity and flexibility over strict routines. This can spur creativity but may reduce consistency or attention to detail.'
    },
    O: {
      high: 'You are curious, imaginative, and open to new ideas and aesthetics. Change and exploration tend to energize you.',
      mid: 'You enjoy new ideas when they are useful or meaningful. You weigh novelty against practicality.',
      low: 'You value familiarity, tradition, and proven methods. Stability and clear structure feel more comfortable than experimentation.'
    }
  }
}

const getLevel = (score: number): Level => {
  if (score >= 70) return 'high'
  if (score >= 40) return 'mid'
  return 'low'
}

export const buildDetailedAnalysis = (scores: Scores, language: Language) => {
  return factors.map(factor => {
    const level = getLevel(scores[factor])
    return {
      factor,
      level,
      text: analysisCopy[language][factor][level]
    }
  })
}
