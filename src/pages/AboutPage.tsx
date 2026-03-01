import { useTranslation } from 'react-i18next'
import { motion } from 'framer-motion'
import { Link } from 'react-router-dom'
import { Brain, BarChart3, Users, BookOpen, Shield, Lightbulb, ChevronRight, Hexagon, GraduationCap, Globe } from 'lucide-react'

export default function AboutPage() {
  const { i18n } = useTranslation()
  const isKo = i18n.language === 'ko'

  return (
    <div className="min-h-screen py-24 px-4">
      <div className="max-w-4xl mx-auto space-y-16">

        {/* ─── Hero ─── */}
        <motion.section
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center space-y-6"
        >
          <div className="w-20 h-20 mx-auto rounded-2xl bg-purple-500/20 flex items-center justify-center">
            <Hexagon className="w-10 h-10 text-purple-500" />
          </div>
          <h1 className="text-3xl md:text-4xl font-black text-white leading-tight">
            {isKo ? '6가지 심리 유형 테스트란?' : 'What Is the 6-Type Personality Test?'}
          </h1>
          <p className="text-gray-400 text-lg max-w-2xl mx-auto leading-relaxed">
            {isKo
              ? '본 테스트는 캐나다 캘거리 대학교의 심리학자 Michael C. Ashton과 Kibeom Lee 교수가 개발한 HEXACO 성격 구조 모델을 기반으로 합니다. 기존 Big Five(5대 성격 요인) 모델에 정직-겸손(Honesty-Humility) 요인을 추가하여, 인간 성격의 6가지 핵심 차원을 과학적으로 측정합니다.'
              : 'This test is based on the HEXACO personality model developed by psychologists Michael C. Ashton and Kibeom Lee at the University of Calgary, Canada. It extends the traditional Big Five model by adding the Honesty-Humility factor, scientifically measuring six core dimensions of human personality.'}
          </p>
        </motion.section>

        {/* ─── Research Foundation ─── */}
        <motion.section
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="space-y-6"
        >
          <div className="flex items-center gap-3 mb-4">
            <div className="w-10 h-10 rounded-xl bg-blue-500/20 flex items-center justify-center">
              <GraduationCap className="w-5 h-5 text-blue-400" />
            </div>
            <h2 className="text-2xl font-bold text-white">
              {isKo ? '학술적 배경' : 'Scientific Background'}
            </h2>
          </div>
          <div className="bg-dark-card border border-dark-border rounded-2xl p-6 md:p-8 space-y-4">
            <p className="text-gray-300 leading-relaxed">
              {isKo
                ? 'HEXACO 모델은 2000년대 초반, 다양한 언어와 문화권에서 수행된 어휘 연구(lexical studies)를 통해 도출되었습니다. 연구진은 한국어, 영어, 프랑스어, 독일어, 이탈리아어, 네덜란드어, 폴란드어, 그리스어, 터키어 등 12개 이상의 언어에서 성격을 설명하는 형용사를 요인분석하여, 문화를 초월한 6가지 핵심 성격 차원을 발견했습니다.'
                : 'The HEXACO model was derived in the early 2000s from lexical studies conducted across diverse languages and cultures. Researchers factor-analyzed personality-describing adjectives in over 12 languages — including Korean, English, French, German, Italian, Dutch, Polish, Greek, and Turkish — discovering six cross-cultural core personality dimensions.'}
            </p>
            <p className="text-gray-300 leading-relaxed">
              {isKo
                ? '이 연구 결과는 European Journal of Personality, Journal of Personality and Social Psychology, Journal of Research in Personality 등 세계적 학술지에 다수 게재되어 학계에서 널리 인정받고 있습니다. 현재까지 1,000편 이상의 학술 논문에서 HEXACO 모델이 인용되었습니다.'
                : 'These findings have been published in leading academic journals including the European Journal of Personality, Journal of Personality and Social Psychology, and Journal of Research in Personality, earning wide recognition in the scientific community. Over 1,000 academic papers have cited the HEXACO model to date.'}
            </p>
          </div>
        </motion.section>

        {/* ─── 6 Factors Explained ─── */}
        <motion.section
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.15 }}
          className="space-y-6"
        >
          <div className="flex items-center gap-3 mb-4">
            <div className="w-10 h-10 rounded-xl bg-purple-500/20 flex items-center justify-center">
              <Brain className="w-5 h-5 text-purple-400" />
            </div>
            <h2 className="text-2xl font-bold text-white">
              {isKo ? '6가지 성격 요인 상세 설명' : 'The Six Personality Factors Explained'}
            </h2>
          </div>
          <div className="space-y-4">
            {factorData(isKo).map((f, i) => (
              <motion.div
                key={f.code}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: 0.2 + i * 0.05 }}
                className="bg-dark-card border border-dark-border rounded-2xl p-6 space-y-3"
              >
                <div className="flex items-center gap-3">
                  <span className="text-2xl">{f.emoji}</span>
                  <div>
                    <h3 className="text-lg font-bold text-white">{f.code}. {f.name}</h3>
                    <p className="text-sm text-gray-500">{f.full}</p>
                  </div>
                </div>
                <p className="text-gray-300 leading-relaxed">{f.description}</p>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-3 mt-2">
                  <div className="bg-green-500/5 border border-green-500/20 rounded-xl p-3">
                    <p className="text-xs font-semibold text-green-400 mb-1">{isKo ? '높은 점수 특징' : 'High Scorers'}</p>
                    <p className="text-sm text-gray-400">{f.high}</p>
                  </div>
                  <div className="bg-amber-500/5 border border-amber-500/20 rounded-xl p-3">
                    <p className="text-xs font-semibold text-amber-400 mb-1">{isKo ? '낮은 점수 특징' : 'Low Scorers'}</p>
                    <p className="text-sm text-gray-400">{f.low}</p>
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        </motion.section>

        {/* ─── How It Works ─── */}
        <motion.section
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="space-y-6"
        >
          <div className="flex items-center gap-3 mb-4">
            <div className="w-10 h-10 rounded-xl bg-emerald-500/20 flex items-center justify-center">
              <BarChart3 className="w-5 h-5 text-emerald-400" />
            </div>
            <h2 className="text-2xl font-bold text-white">
              {isKo ? '테스트 방법론' : 'Test Methodology'}
            </h2>
          </div>
          <div className="bg-dark-card border border-dark-border rounded-2xl p-6 md:p-8 space-y-4">
            <p className="text-gray-300 leading-relaxed">
              {isKo
                ? '본 테스트는 각 요인별 10문항씩 총 60문항(빠른 테스트)부터, 하위 요인별 5문항씩 포함한 120문항(표준 테스트), 최대 180문항(정밀 테스트)까지 3가지 버전을 제공합니다.'
                : 'This test offers three versions: 60 questions (Quick Test) with 10 items per factor, 120 questions (Standard Test) with 5 items per sub-facet, and up to 180 questions (Detailed Test) for maximum precision.'}
            </p>
            <p className="text-gray-300 leading-relaxed">
              {isKo
                ? '각 질문에 대해 0점(전혀 동의하지 않음)부터 100점(매우 동의함)까지 연속 척도로 응답합니다. 이진법(예/아니오) 대신 연속 스펙트럼을 사용하여 성격의 미묘한 차이까지 반영할 수 있습니다. 역채점 문항은 자동으로 보정되며, 각 요인 점수는 해당 문항 응답의 평균으로 산출됩니다.'
                : 'Each question is answered on a continuous scale from 0 (strongly disagree) to 100 (strongly agree). Instead of binary yes/no choices, this continuous spectrum captures subtle personality nuances. Reverse-scored items are automatically corrected, and each factor score is calculated as the average of its item responses.'}
            </p>
            <p className="text-gray-300 leading-relaxed">
              {isKo
                ? '문항 수가 많을수록 각 요인의 하위 차원(facet)을 더 세밀하게 측정할 수 있어 결과의 신뢰도가 높아집니다. 예를 들어, 정직-겸손(H) 요인은 진실성, 공정성, 탐욕 회피, 겸손함의 4가지 하위 차원으로 구성되며, 180문항 버전에서는 각 하위 차원을 개별적으로 분석합니다.'
                : 'More questions allow finer measurement of each factor\'s sub-facets, increasing result reliability. For example, the Honesty-Humility (H) factor consists of four facets — Sincerity, Fairness, Greed Avoidance, and Modesty — each analyzed individually in the 180-question version.'}
            </p>
          </div>
        </motion.section>

        {/* ─── vs MBTI ─── */}
        <motion.section
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.35 }}
          className="space-y-6"
        >
          <div className="flex items-center gap-3 mb-4">
            <div className="w-10 h-10 rounded-xl bg-pink-500/20 flex items-center justify-center">
              <Users className="w-5 h-5 text-pink-400" />
            </div>
            <h2 className="text-2xl font-bold text-white">
              {isKo ? '6가지 유형 vs MBTI: 차이점과 장점' : '6-Type vs MBTI: Key Differences'}
            </h2>
          </div>
          <div className="bg-dark-card border border-dark-border rounded-2xl p-6 md:p-8 space-y-4">
            <p className="text-gray-300 leading-relaxed">
              {isKo
                ? 'MBTI는 4가지 이분법(E/I, S/N, T/F, J/P)으로 사람을 16가지 유형 중 하나로 분류합니다. 반면 6가지 심리 유형 테스트는 6개 요인 각각을 0~100점의 연속 점수로 측정합니다. 이는 "당신은 A 아니면 B"가 아니라, "A와 B 사이에서 당신은 어디에 있는가"를 알려줍니다.'
                : 'MBTI classifies people into one of 16 types using four binary dichotomies (E/I, S/N, T/F, J/P). In contrast, the 6-Type test measures each of six factors on a continuous 0–100 scale. Rather than telling you "you are either A or B," it shows "where you fall on the spectrum between A and B."'}
            </p>
            <p className="text-gray-300 leading-relaxed">
              {isKo
                ? '가장 큰 차이는 정직-겸손(H) 요인입니다. MBTI에는 이에 해당하는 요인이 없지만, HEXACO 연구에서는 이 요인이 직장 내 비윤리적 행동, 대인관계 갈등, 리더십 스타일 등을 예측하는 데 매우 중요하다는 것이 밝혀졌습니다. 또한 원만성(A) 요인에서 분노/인내 관련 특성이 MBTI의 친화성과 다르게 구성되어, 갈등 해결 방식의 개인차를 더 정확하게 포착합니다.'
                : 'The most significant difference is the Honesty-Humility (H) factor. MBTI has no equivalent, but HEXACO research has shown this factor is crucial for predicting workplace ethics, interpersonal conflict, and leadership style. Additionally, the Agreeableness (A) factor includes anger/patience traits differently from MBTI\'s agreeableness, more accurately capturing individual differences in conflict resolution.'}
            </p>

            {/* Comparison table */}
            <div className="overflow-x-auto mt-4">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b border-gray-700">
                    <th className="text-left py-2 text-gray-500">{isKo ? '비교 항목' : 'Comparison'}</th>
                    <th className="text-center py-2 text-purple-400">{isKo ? '6가지 유형' : '6-Type'}</th>
                    <th className="text-center py-2 text-gray-400">MBTI</th>
                  </tr>
                </thead>
                <tbody className="text-gray-300">
                  <tr className="border-b border-gray-800">
                    <td className="py-2">{isKo ? '측정 방식' : 'Measurement'}</td>
                    <td className="text-center text-purple-300">{isKo ? '연속 점수 (0~100)' : 'Continuous (0–100)'}</td>
                    <td className="text-center text-gray-500">{isKo ? '이분법 분류' : 'Binary classification'}</td>
                  </tr>
                  <tr className="border-b border-gray-800">
                    <td className="py-2">{isKo ? '요인 수' : 'Factors'}</td>
                    <td className="text-center text-purple-300">{isKo ? '6개 + 하위 24개' : '6 major + 24 facets'}</td>
                    <td className="text-center text-gray-500">{isKo ? '4개 이분법' : '4 dichotomies'}</td>
                  </tr>
                  <tr className="border-b border-gray-800">
                    <td className="py-2">{isKo ? '정직-겸손 측정' : 'Honesty-Humility'}</td>
                    <td className="text-center text-green-400">✓</td>
                    <td className="text-center text-red-400">✗</td>
                  </tr>
                  <tr className="border-b border-gray-800">
                    <td className="py-2">{isKo ? '학술 논문 인용' : 'Academic citations'}</td>
                    <td className="text-center text-purple-300">{isKo ? '1,000편 이상' : '1,000+'}</td>
                    <td className="text-center text-gray-500">{isKo ? '비학술적 분류' : 'Non-academic'}</td>
                  </tr>
                  <tr>
                    <td className="py-2">{isKo ? '재검사 신뢰도' : 'Test-retest reliability'}</td>
                    <td className="text-center text-purple-300">{isKo ? '높음 (0.8+)' : 'High (0.8+)'}</td>
                    <td className="text-center text-gray-500">{isKo ? '중간 (~0.5)' : 'Moderate (~0.5)'}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </motion.section>

        {/* ─── Use Cases ─── */}
        <motion.section
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
          className="space-y-6"
        >
          <div className="flex items-center gap-3 mb-4">
            <div className="w-10 h-10 rounded-xl bg-cyan-500/20 flex items-center justify-center">
              <Lightbulb className="w-5 h-5 text-cyan-400" />
            </div>
            <h2 className="text-2xl font-bold text-white">
              {isKo ? '활용 분야' : 'Applications'}
            </h2>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {useCases(isKo).map((u, i) => (
              <div key={i} className="bg-dark-card border border-dark-border rounded-xl p-5 space-y-2">
                <div className="flex items-center gap-2">
                  <span className="text-xl">{u.emoji}</span>
                  <h3 className="font-bold text-white">{u.title}</h3>
                </div>
                <p className="text-sm text-gray-400 leading-relaxed">{u.desc}</p>
              </div>
            ))}
          </div>
        </motion.section>

        {/* ─── Limitations & Disclaimer ─── */}
        <motion.section
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.45 }}
          className="space-y-6"
        >
          <div className="flex items-center gap-3 mb-4">
            <div className="w-10 h-10 rounded-xl bg-amber-500/20 flex items-center justify-center">
              <Shield className="w-5 h-5 text-amber-400" />
            </div>
            <h2 className="text-2xl font-bold text-white">
              {isKo ? '주의사항 및 면책' : 'Limitations & Disclaimer'}
            </h2>
          </div>
          <div className="bg-dark-card border border-dark-border rounded-2xl p-6 md:p-8 space-y-4">
            <p className="text-gray-300 leading-relaxed">
              {isKo
                ? '본 테스트는 교육적·오락적 목적으로 제공되며, 전문적인 심리 평가를 대체하지 않습니다. 정신 건강 관련 고민이 있으시면 반드시 전문 심리상담사나 정신건강의학과 전문의와 상담하시기 바랍니다.'
                : 'This test is provided for educational and entertainment purposes only and does not replace professional psychological assessment. If you have mental health concerns, please consult a licensed psychologist or mental health professional.'}
            </p>
            <p className="text-gray-300 leading-relaxed">
              {isKo
                ? '결과는 응답 시점의 자기 보고에 기반하며, 기분, 환경, 이해도에 따라 결과가 달라질 수 있습니다. 유명인 매칭, MBTI 추정, AI 분석은 참고용이며 과학적으로 검증된 것은 아닙니다.'
                : 'Results are based on self-report at the time of response and may vary with mood, environment, and comprehension. Celebrity matches, MBTI estimates, and AI analyses are for reference only and are not scientifically validated.'}
            </p>
            <p className="text-gray-300 leading-relaxed">
              {isKo
                ? '모든 응답 데이터는 사용자의 기기(브라우저 localStorage)에만 저장되며, 서버에 전송되거나 저장되지 않습니다. 개인정보 보호에 대한 자세한 내용은 개인정보처리방침을 참고하세요.'
                : 'All response data is stored only on your device (browser localStorage) and is never transmitted to or stored on our servers. For more information about data protection, please refer to our Privacy Policy.'}
            </p>
          </div>
        </motion.section>

        {/* ─── References ─── */}
        <motion.section
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5 }}
          className="space-y-6"
        >
          <div className="flex items-center gap-3 mb-4">
            <div className="w-10 h-10 rounded-xl bg-indigo-500/20 flex items-center justify-center">
              <BookOpen className="w-5 h-5 text-indigo-400" />
            </div>
            <h2 className="text-2xl font-bold text-white">
              {isKo ? '참고 문헌' : 'References'}
            </h2>
          </div>
          <div className="bg-dark-card border border-dark-border rounded-2xl p-6 space-y-3 text-sm text-gray-400">
            <p>Ashton, M. C., & Lee, K. (2007). Empirical, theoretical, and practical advantages of the HEXACO model of personality structure. <em className="text-gray-300">Personality and Social Psychology Review, 11</em>(2), 150–166.</p>
            <p>Lee, K., & Ashton, M. C. (2004). Psychometric properties of the HEXACO personality inventory. <em className="text-gray-300">Multivariate Behavioral Research, 39</em>(2), 329–358.</p>
            <p>Ashton, M. C., & Lee, K. (2009). The HEXACO–60: A short measure of the major dimensions of personality. <em className="text-gray-300">Journal of Personality Assessment, 91</em>(4), 340–345.</p>
            <p>Lee, K., & Ashton, M. C. (2018). Psychometric properties of the HEXACO-100. <em className="text-gray-300">Assessment, 25</em>(5), 543–556.</p>
          </div>
        </motion.section>

        {/* ─── Global Reach ─── */}
        <motion.section
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.55 }}
          className="space-y-6"
        >
          <div className="flex items-center gap-3 mb-4">
            <div className="w-10 h-10 rounded-xl bg-teal-500/20 flex items-center justify-center">
              <Globe className="w-5 h-5 text-teal-400" />
            </div>
            <h2 className="text-2xl font-bold text-white">
              {isKo ? '글로벌 검증' : 'Global Validation'}
            </h2>
          </div>
          <div className="bg-dark-card border border-dark-border rounded-2xl p-6 md:p-8">
            <p className="text-gray-300 leading-relaxed">
              {isKo
                ? 'HEXACO 모델은 한국, 미국, 캐나다, 영국, 독일, 프랑스, 이탈리아, 네덜란드, 폴란드, 그리스, 터키, 필리핀, 크로아티아, 헝가리 등 세계 각국에서 독립적으로 검증되었습니다. 이는 6가지 성격 요인이 특정 문화에 국한되지 않는 인간 보편적인 성격 구조임을 강력히 시사합니다. 다양한 연구에서 HEXACO 모델이 직무 성과, 학업 성취, 대인관계 만족도, 윤리적 의사결정 등 다양한 행동을 예측하는 데 유효한 것으로 밝혀졌습니다.'
                : 'The HEXACO model has been independently validated in countries worldwide including Korea, USA, Canada, UK, Germany, France, Italy, Netherlands, Poland, Greece, Turkey, Philippines, Croatia, and Hungary. This strongly suggests that the six personality factors represent a universal structure of human personality not limited to any specific culture. Various studies have found the HEXACO model effective in predicting job performance, academic achievement, relationship satisfaction, and ethical decision-making.'}
            </p>
          </div>
        </motion.section>

        {/* ─── CTA ─── */}
        <motion.section
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6 }}
          className="text-center space-y-4"
        >
          <h2 className="text-xl font-bold text-white">
            {isKo ? '지금 바로 테스트해 보세요' : 'Try the Test Now'}
          </h2>
          <Link to="/">
            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              className="inline-flex items-center gap-2 px-8 py-4 rounded-xl text-white font-bold"
              style={{ background: 'linear-gradient(135deg, #8B5CF6, #EC4899)' }}
            >
              {isKo ? '무료 테스트 시작' : 'Start Free Test'}
              <ChevronRight className="w-5 h-5" />
            </motion.button>
          </Link>
        </motion.section>
      </div>
    </div>
  )
}

// ─── Factor Data ─────────────────────────────────────────────────────────────

function factorData(isKo: boolean) {
  return isKo ? [
    { code: 'H', emoji: '🤝', name: '정직-겸손', full: 'Honesty-Humility',
      description: '정직-겸손 요인은 HEXACO 모델의 가장 독창적인 요인입니다. 이 요인은 진실성(Sincerity), 공정성(Fairness), 탐욕 회피(Greed Avoidance), 겸손함(Modesty)의 4가지 하위 요인으로 구성됩니다. 연구에 따르면 H 점수가 낮은 사람은 조직 내 비윤리적 행동, 나르시시즘, 사이코패시 등 "어두운 성격(Dark Triad)"과 강한 상관관계를 보입니다.',
      high: '진실되고 공정하며, 물질적 이득보다 윤리적 가치를 중시합니다. 겸손하고 남을 이용하려 하지 않습니다.',
      low: '사회적 지위와 물질적 성공을 추구하며, 목표를 위해 전략적으로 행동합니다. 자신감 있고 야심적입니다.' },
    { code: 'E', emoji: '💜', name: '정서성', full: 'Emotionality',
      description: '정서성 요인은 두려움(Fearfulness), 불안(Anxiety), 의존성(Dependence), 감수성(Sentimentality)의 4가지 하위 요인으로 구성됩니다. Big Five의 신경증(Neuroticism)과 유사하지만, HEXACO에서는 분노(anger) 관련 특성이 원만성(A) 요인으로 이동하여, 정서적 취약성과 대인간 갈등 경향성을 구분합니다.',
      high: '감정 표현이 풍부하고, 타인과 깊은 유대감을 형성합니다. 공감 능력이 높지만 스트레스에 취약할 수 있습니다.',
      low: '감정적으로 안정되어 있고, 위기 상황에서도 냉정함을 유지합니다. 독립적이며 감정에 휘둘리지 않습니다.' },
    { code: 'X', emoji: '⚡', name: '외향성', full: 'eXtraversion',
      description: '외향성 요인은 사회적 자신감(Social Self-Esteem), 사교성(Social Boldness), 활력(Sociability), 대담함(Liveliness)으로 구성됩니다. 외향성이 높은 사람은 사회적 상호작용에서 에너지를 얻으며, 리더십과 팀워크에서 두각을 나타냅니다.',
      high: '사교적이고 활발하며, 모임에서 자연스럽게 중심 역할을 합니다. 에너지가 넘치고 낙관적입니다.',
      low: '조용하고 내성적이며, 소수와의 깊은 관계를 선호합니다. 혼자만의 시간에서 에너지를 충전합니다.' },
    { code: 'A', emoji: '🕊️', name: '원만성', full: 'Agreeableness',
      description: '원만성 요인은 용서(Forgiveness), 온화함(Gentleness), 유연성(Flexibility), 인내심(Patience)으로 구성됩니다. HEXACO의 원만성은 Big Five와 다르게, 분노 조절과 인내와 관련된 특성을 포함하여 대인 갈등 상황에서의 행동을 더 정확하게 예측합니다.',
      high: '타인을 쉽게 용서하고, 갈등을 피하며, 온화하고 인내심 있게 대합니다. 협력적 환경을 선호합니다.',
      low: '자신의 의견을 강하게 주장하고, 불의에 대해 적극적으로 대응합니다. 비판적 사고가 뛰어납니다.' },
    { code: 'C', emoji: '🎯', name: '성실성', full: 'Conscientiousness',
      description: '성실성 요인은 조직력(Organization), 근면성(Diligence), 완벽주의(Perfectionism), 신중함(Prudence)으로 구성됩니다. 성실성은 학업, 직무 성과, 건강 행동 등 다양한 삶의 결과를 가장 강력하게 예측하는 요인 중 하나입니다.',
      high: '체계적이고 목표 지향적이며, 세부 사항에 주의를 기울입니다. 계획을 세우고 끝까지 실행합니다.',
      low: '유연하고 즉흥적이며, 규칙에 얽매이지 않습니다. 창의적 자유를 중시하고 변화에 빠르게 적응합니다.' },
    { code: 'O', emoji: '🌈', name: '개방성', full: 'Openness to Experience',
      description: '개방성 요인은 미적 감상(Aesthetic Appreciation), 호기심(Inquisitiveness), 창의성(Creativity), 비관습성(Unconventionality)으로 구성됩니다. 개방성이 높은 사람은 예술, 과학, 철학 등 지적 활동에 관심이 많고, 기존의 틀을 벗어나는 사고를 즐깁니다.',
      high: '창의적이고 호기심이 많으며, 새로운 아이디어와 경험에 열려 있습니다. 예술과 미학에 민감합니다.',
      low: '실용적이고 현실적이며, 검증된 방법을 선호합니다. 전통과 안정을 중시합니다.' },
  ] : [
    { code: 'H', emoji: '🤝', name: 'Honesty-Humility', full: 'Honesty-Humility',
      description: 'The Honesty-Humility factor is HEXACO\'s most distinctive contribution. It comprises four facets: Sincerity, Fairness, Greed Avoidance, and Modesty. Research shows that low H scores are strongly correlated with the "Dark Triad" traits — narcissism, psychopathy, and Machiavellianism — as well as unethical workplace behavior.',
      high: 'Sincere and fair, prioritizing ethical values over material gain. Modest and reluctant to manipulate others.',
      low: 'Driven by social status and material success. Strategic, confident, and ambitious in pursuing goals.' },
    { code: 'E', emoji: '💜', name: 'Emotionality', full: 'Emotionality',
      description: 'Emotionality encompasses Fearfulness, Anxiety, Dependence, and Sentimentality. While similar to Big Five Neuroticism, HEXACO moves anger-related traits to Agreeableness (A), cleanly separating emotional vulnerability from interpersonal conflict tendencies.',
      high: 'Emotionally expressive with strong empathy and deep bonds with others. May be more susceptible to stress.',
      low: 'Emotionally stable and composed under pressure. Independent and not easily swayed by feelings.' },
    { code: 'X', emoji: '⚡', name: 'Extraversion', full: 'eXtraversion',
      description: 'Extraversion includes Social Self-Esteem, Social Boldness, Sociability, and Liveliness. High scorers gain energy from social interaction and often excel in leadership and teamwork situations.',
      high: 'Sociable and energetic, naturally gravitating to the center of social gatherings. Optimistic and lively.',
      low: 'Quiet and introspective, preferring deep connections with few people. Recharges through solitude.' },
    { code: 'A', emoji: '🕊️', name: 'Agreeableness', full: 'Agreeableness',
      description: 'Agreeableness comprises Forgiveness, Gentleness, Flexibility, and Patience. Unlike Big Five agreeableness, HEXACO\'s version includes anger management and patience traits, making it more accurate for predicting behavior in interpersonal conflicts.',
      high: 'Forgiving, conflict-averse, gentle, and patient with others. Prefers cooperative environments.',
      low: 'Assertive with strong opinions, actively confronts injustice. Excels at critical thinking.' },
    { code: 'C', emoji: '🎯', name: 'Conscientiousness', full: 'Conscientiousness',
      description: 'Conscientiousness includes Organization, Diligence, Perfectionism, and Prudence. It is one of the strongest predictors of academic achievement, job performance, and healthy behaviors across cultures.',
      high: 'Systematic and goal-oriented with attention to detail. Makes plans and follows through to completion.',
      low: 'Flexible and spontaneous, unbound by rules. Values creative freedom and adapts quickly to change.' },
    { code: 'O', emoji: '🌈', name: 'Openness to Experience', full: 'Openness to Experience',
      description: 'Openness comprises Aesthetic Appreciation, Inquisitiveness, Creativity, and Unconventionality. High scorers are drawn to intellectual pursuits in art, science, and philosophy, and enjoy thinking outside established conventions.',
      high: 'Creative and curious, open to new ideas and experiences. Sensitive to art and aesthetics.',
      low: 'Practical and realistic, preferring proven methods. Values tradition and stability.' },
  ]
}

function useCases(isKo: boolean) {
  return isKo ? [
    { emoji: '🧠', title: '자기 이해', desc: '나의 성격 강점과 성장 가능 영역을 객관적 수치로 확인하고, 더 나은 자기 인식을 발전시킬 수 있습니다.' },
    { emoji: '💼', title: '커리어 탐색', desc: '각 성격 요인과 직무 적합도의 관계를 이해하여, 자신에게 맞는 직업과 업무 환경을 찾는 데 참고할 수 있습니다.' },
    { emoji: '❤️', title: '관계 이해', desc: '나와 상대방의 성격 프로필을 비교하여, 서로의 차이를 이해하고 더 나은 소통 방법을 모색할 수 있습니다.' },
    { emoji: '📈', title: '개인 성장', desc: '시간에 따른 성격 변화를 추적하고, 의식적으로 발전시키고 싶은 영역을 설정하는 데 활용할 수 있습니다.' },
    { emoji: '🎓', title: '심리학 학습', desc: '과학적 성격 모델의 원리를 체험적으로 학습하고, 성격 심리학에 대한 이해를 넓힐 수 있습니다.' },
    { emoji: '👥', title: '팀 빌딩', desc: '팀원들의 성격 프로필을 공유하여 팀 역학을 이해하고, 효과적인 협업 전략을 수립하는 데 참고할 수 있습니다.' },
  ] : [
    { emoji: '🧠', title: 'Self-Understanding', desc: 'View your personality strengths and growth areas as objective scores, developing better self-awareness.' },
    { emoji: '💼', title: 'Career Exploration', desc: 'Understand the relationship between personality factors and job fit to find careers and work environments that suit you.' },
    { emoji: '❤️', title: 'Relationship Insights', desc: 'Compare personality profiles with others to understand differences and discover better communication approaches.' },
    { emoji: '📈', title: 'Personal Growth', desc: 'Track personality changes over time and set intentional development goals for specific areas.' },
    { emoji: '🎓', title: 'Psychology Education', desc: 'Experience the principles of a scientific personality model firsthand and deepen your understanding of personality psychology.' },
    { emoji: '👥', title: 'Team Building', desc: 'Share team members\' profiles to understand team dynamics and develop effective collaboration strategies.' },
  ]
}
