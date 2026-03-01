import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { motion, AnimatePresence } from 'framer-motion'
import { Link } from 'react-router-dom'
import { HelpCircle, ChevronDown, ChevronRight } from 'lucide-react'

export default function FaqPage() {
  const { i18n } = useTranslation()
  const isKo = i18n.language === 'ko'
  const faqs = getFaqs(isKo)

  return (
    <div className="min-h-screen py-24 px-4">
      <div className="max-w-3xl mx-auto space-y-10">

        {/* Hero */}
        <motion.section
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center space-y-4"
        >
          <div className="w-16 h-16 mx-auto rounded-2xl bg-purple-500/20 flex items-center justify-center">
            <HelpCircle className="w-8 h-8 text-purple-500" />
          </div>
          <h1 className="text-3xl font-black text-white">
            {isKo ? '자주 묻는 질문' : 'Frequently Asked Questions'}
          </h1>
          <p className="text-gray-400 max-w-lg mx-auto">
            {isKo
              ? '6가지 심리 유형 테스트에 대해 자주 묻는 질문과 답변을 모았습니다.'
              : 'Common questions and answers about the 6-Type Personality Test.'}
          </p>
        </motion.section>

        {/* FAQ Items */}
        <div className="space-y-3">
          {faqs.map((faq, i) => (
            <FaqItem key={i} question={faq.q} answer={faq.a} index={i} />
          ))}
        </div>

        {/* CTA */}
        <motion.section
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="text-center space-y-4 pt-6"
        >
          <p className="text-gray-400">
            {isKo ? '더 궁금한 점이 있으신가요?' : 'Still have questions?'}
          </p>
          <div className="flex flex-wrap justify-center gap-3">
            <Link to="/about">
              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                className="inline-flex items-center gap-2 px-6 py-3 rounded-xl text-purple-400 font-semibold border border-purple-500/30 hover:bg-purple-500/10 transition-colors"
              >
                {isKo ? '모델 상세 설명' : 'Learn About the Model'}
                <ChevronRight className="w-4 h-4" />
              </motion.button>
            </Link>
            <Link to="/">
              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                className="inline-flex items-center gap-2 px-6 py-3 rounded-xl text-white font-bold"
                style={{ background: 'linear-gradient(135deg, #8B5CF6, #EC4899)' }}
              >
                {isKo ? '테스트 시작하기' : 'Start the Test'}
                <ChevronRight className="w-4 h-4" />
              </motion.button>
            </Link>
          </div>
        </motion.section>
      </div>
    </div>
  )
}

function FaqItem({ question, answer, index }: { question: string; answer: string; index: number }) {
  const [open, setOpen] = useState(false)

  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: index * 0.03 }}
      className="bg-dark-card border border-dark-border rounded-xl overflow-hidden"
    >
      <button
        onClick={() => setOpen(!open)}
        className="w-full flex items-center justify-between p-5 text-left hover:bg-white/[0.02] transition-colors"
      >
        <span className="font-semibold text-white pr-4">{question}</span>
        <motion.div animate={{ rotate: open ? 180 : 0 }} transition={{ duration: 0.2 }}>
          <ChevronDown className="w-5 h-5 text-gray-500 flex-shrink-0" />
        </motion.div>
      </button>
      <AnimatePresence>
        {open && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.2 }}
            className="overflow-hidden"
          >
            <div className="px-5 pb-5 text-gray-400 leading-relaxed text-sm border-t border-dark-border pt-4">
              {answer}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  )
}

function getFaqs(isKo: boolean) {
  return isKo ? [
    { q: '6가지 심리 유형 테스트는 무엇인가요?',
      a: '6가지 심리 유형 테스트는 캐나다 캘거리 대학교의 Ashton & Lee 교수가 개발한 HEXACO 성격 모델을 기반으로 한 과학적 성격 평가 도구입니다. 정직-겸손(H), 정서성(E), 외향성(X), 원만성(A), 성실성(C), 개방성(O)의 6가지 핵심 성격 차원을 0~100점 연속 척도로 측정합니다.' },
    { q: 'MBTI와 무엇이 다른가요?',
      a: 'MBTI는 4가지 이분법으로 16가지 유형 중 하나로 분류하지만, 6가지 유형 테스트는 6개 요인을 각각 0~100점으로 수치화합니다. 가장 큰 차이는 "정직-겸손" 요인으로, MBTI에는 없지만 직장 윤리, 대인관계, 리더십 등을 예측하는 데 매우 중요한 요인입니다. 또한 연속 점수 방식이므로 성격의 미묘한 차이까지 반영할 수 있습니다.' },
    { q: '테스트 결과는 얼마나 정확한가요?',
      a: 'HEXACO 모델의 재검사 신뢰도(test-retest reliability)는 0.80 이상으로, 시간이 지나도 결과가 일관되게 나타납니다. 다만 본 테스트는 자기 보고식이므로, 응답 시점의 기분이나 환경에 따라 결과가 약간 달라질 수 있습니다. 문항 수가 많은 버전(120문항, 180문항)을 선택하면 더 안정적인 결과를 얻을 수 있습니다.' },
    { q: '60문항, 120문항, 180문항의 차이는 무엇인가요?',
      a: '60문항(빠른 테스트)은 약 5분 소요되며, 6개 요인의 전체 점수를 측정합니다. 120문항(표준 테스트)은 약 10분 소요되며, 각 요인의 하위 요인까지 분석합니다. 180문항(정밀 테스트)은 약 15분 소요되며, 가장 세밀하고 신뢰도 높은 분석 결과를 제공합니다. 시간적 여유가 있다면 120문항 이상을 추천합니다.' },
    { q: '내 개인 정보는 어떻게 처리되나요?',
      a: '모든 테스트 응답 데이터는 사용자의 브라우저(localStorage)에만 저장되며, 서버에 전송되거나 저장되지 않습니다. 결과 공유 시에도 점수 데이터만 URL에 인코딩되며, 개인 식별 정보는 포함되지 않습니다. 브라우저 데이터를 삭제하면 모든 결과가 삭제됩니다.' },
    { q: '결과에 나오는 유명인 매칭은 어떻게 작동하나요?',
      a: '유명인 매칭은 각 유명인의 알려진 성격 특성과 행동 패턴을 기반으로 추정된 HEXACO 프로필과 사용자의 결과를 비교하여, 유사도가 높은 인물을 찾아 제공합니다. 이는 재미와 참고를 위한 것으로, 해당 인물이 실제로 HEXACO 테스트를 받은 것은 아닙니다.' },
    { q: 'MBTI 추정 결과는 정확한가요?',
      a: 'MBTI 추정은 6가지 유형 점수를 기반으로 산출한 참고용 결과이며, 실제 MBTI 검사 결과와 다를 수 있습니다. HEXACO와 MBTI는 근본적으로 다른 모델이므로, 정확한 MBTI 결과를 원하시면 별도의 MBTI 검사를 받으시는 것을 권장합니다.' },
    { q: '성격은 변할 수 있나요?',
      a: '연구에 따르면 성격은 유전적 요인(약 40~60%)과 환경적 요인이 복합적으로 작용하며, 성인기에도 서서히 변화할 수 있습니다. 특히 성실성과 원만성은 나이가 들면서 증가하는 경향이 있고, 외향성과 개방성은 약간 감소하는 경향이 있습니다. 의식적인 노력과 환경 변화를 통해 특정 성격 특성을 발전시킬 수 있습니다.' },
    { q: '이 테스트를 임상 진단에 사용할 수 있나요?',
      a: '아니요, 본 테스트는 교육적·오락적 목적으로 제공되며, 임상 진단, 고용 결정, 법적 판단 등의 목적으로 사용해서는 안 됩니다. 정신 건강 관련 고민이 있으시면 반드시 공인된 심리상담 전문가나 정신건강의학과 전문의와 상담하시기 바랍니다.' },
    { q: '테스트는 무료인가요?',
      a: '네, 테스트 자체는 완전 무료입니다. 60문항, 120문항, 180문항 모든 버전을 무료로 이용할 수 있으며, 결과 확인과 공유도 무료입니다. 사이트 운영 비용은 광고를 통해 충당하고 있습니다.' },
    { q: '여러 번 테스트해도 되나요?',
      a: '네, 원하는 만큼 반복 테스트할 수 있습니다. 다만, 가장 정확한 결과를 얻으려면 한 번 테스트할 때 충분히 시간을 들여 솔직하게 응답하는 것이 중요합니다. 이전 결과는 브라우저에 자동 저장되므로 시간에 따른 변화를 비교해 볼 수도 있습니다.' },
    { q: 'AI 분석은 어떻게 작동하나요?',
      a: 'AI 분석은 구글의 Gemini AI를 활용하여, 사용자의 6가지 요인 점수를 기반으로 성격 특성을 종합 분석합니다. AI는 각 요인의 점수 조합을 해석하여 강점, 성장 영역, 직업 추천, 유사한 유명인 등을 제안합니다. AI 분석 결과는 참고용이며, 전문 심리 상담을 대체하지 않습니다.' },
  ] : [
    { q: 'What is the 6-Type Personality Test?',
      a: 'The 6-Type Personality Test is a scientific personality assessment based on the HEXACO personality model developed by Professors Ashton & Lee at the University of Calgary, Canada. It measures six core personality dimensions — Honesty-Humility (H), Emotionality (E), eXtraversion (X), Agreeableness (A), Conscientiousness (C), and Openness (O) — on a continuous 0–100 scale.' },
    { q: 'How is this different from MBTI?',
      a: 'MBTI classifies people into one of 16 types using four binary dichotomies, while the 6-Type test scores each of six factors on a 0–100 spectrum. The biggest difference is the Honesty-Humility factor, which MBTI lacks but is crucial for predicting workplace ethics, relationships, and leadership. The continuous scoring also captures subtle personality nuances that binary classification cannot.' },
    { q: 'How accurate are the results?',
      a: 'The HEXACO model shows test-retest reliability above 0.80, meaning results are highly consistent over time. However, as a self-report measure, results may vary slightly based on mood or circumstances at the time of response. Choosing the longer version (120 or 180 questions) provides more stable and reliable results.' },
    { q: 'What\'s the difference between 60, 120, and 180 questions?',
      a: 'The 60-question Quick Test (about 5 minutes) measures overall scores for each factor. The 120-question Standard Test (about 10 minutes) analyzes sub-facets within each factor. The 180-question Detailed Test (about 15 minutes) provides the most granular and reliable analysis. If you have time, we recommend 120 questions or more.' },
    { q: 'How is my personal data handled?',
      a: 'All test response data is stored only in your browser\'s localStorage and is never transmitted to or stored on our servers. When sharing results, only score data is encoded in the URL — no personally identifiable information is included. Clearing your browser data removes all results.' },
    { q: 'How does the celebrity matching work?',
      a: 'Celebrity matching compares your HEXACO profile with estimated profiles of famous people, based on their known personality traits and behavioral patterns. This feature is for entertainment and reference purposes only — these celebrities have not actually taken the HEXACO test.' },
    { q: 'Is the MBTI estimate accurate?',
      a: 'The MBTI estimate is derived from your 6-Type scores and is provided for reference only. It may differ from actual MBTI test results. Since HEXACO and MBTI are fundamentally different models, we recommend taking a dedicated MBTI assessment for accurate MBTI results.' },
    { q: 'Can personality change over time?',
      a: 'Research shows personality is influenced by both genetic factors (approximately 40–60%) and environmental factors, and can gradually change throughout adulthood. Conscientiousness and Agreeableness tend to increase with age, while Extraversion and Openness may slightly decrease. Intentional effort and environmental changes can help develop specific personality traits.' },
    { q: 'Can this test be used for clinical diagnosis?',
      a: 'No. This test is provided for educational and entertainment purposes only and should not be used for clinical diagnosis, employment decisions, or legal judgments. If you have mental health concerns, please consult a licensed psychologist or mental health professional.' },
    { q: 'Is the test free?',
      a: 'Yes, the test is completely free. All versions (60, 120, and 180 questions) are available at no cost, and viewing and sharing results is also free. Site operating costs are covered through advertising.' },
    { q: 'Can I take the test multiple times?',
      a: 'Yes, you can retake the test as many times as you like. However, for the most accurate results, take sufficient time to answer honestly in each session. Previous results are automatically saved in your browser, so you can compare changes over time.' },
    { q: 'How does the AI analysis work?',
      a: 'AI analysis uses Google\'s Gemini AI to comprehensively analyze your personality based on your six factor scores. The AI interprets the combination of scores to suggest strengths, growth areas, career recommendations, and similar famous people. AI analysis results are for reference and do not replace professional psychological counseling.' },
  ]
}
