import { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { motion, AnimatePresence } from 'framer-motion'
import { Brain, Users, Share2, Sparkles, ChevronRight, Hexagon, Clock, Zap, Target, Star, TrendingUp, Globe, CheckCircle } from 'lucide-react'
import { useTestStore } from '../stores/testStore'
import { testVersions } from '../data/questions'
import ElectricBorder from '../components/ElectricBorder'
import DecryptedText from '../components/DecryptedText'

const fadeInUp = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.6 }
}

const staggerContainer = {
  animate: {
    transition: {
      staggerChildren: 0.1
    }
  }
}

const versionIcons = {
  60: Zap,
  120: Clock,
  180: Target,
}

// Floating particles component
function FloatingParticles() {
  return (
    <div className="absolute inset-0 overflow-hidden pointer-events-none">
      {[...Array(20)].map((_, i) => (
        <motion.div
          key={i}
          className="absolute w-2 h-2 bg-purple-500/30 rounded-full"
          initial={{
            x: Math.random() * window.innerWidth,
            y: Math.random() * window.innerHeight,
          }}
          animate={{
            x: [null, Math.random() * window.innerWidth, Math.random() * window.innerWidth],
            y: [null, Math.random() * window.innerHeight, Math.random() * window.innerHeight],
            scale: [1, 1.5, 1],
            opacity: [0.3, 0.6, 0.3],
          }}
          transition={{
            duration: 10 + Math.random() * 20,
            repeat: Infinity,
            ease: "linear",
          }}
        />
      ))}
      {[...Array(10)].map((_, i) => (
        <motion.div
          key={`star-${i}`}
          className="absolute w-1 h-1 bg-pink-400/50 rounded-full"
          initial={{
            x: Math.random() * window.innerWidth,
            y: Math.random() * window.innerHeight,
          }}
          animate={{
            opacity: [0, 1, 0],
            scale: [0, 1.5, 0],
          }}
          transition={{
            duration: 2 + Math.random() * 3,
            repeat: Infinity,
            delay: Math.random() * 5,
          }}
        />
      ))}
    </div>
  )
}

// Sample question preview
function SampleQuestionPreview() {
  const { i18n } = useTranslation()
  const [currentQ, setCurrentQ] = useState(0)

  const sampleQuestions = [
    {
      factor: 'H',
      ko: '친구가 새로 산 옷이 어울리는지 물었을 때, 솔직히 별로여도 있는 그대로 말해줄 것 같다.',
      en: 'If a friend asked how their new outfit looked and it didn\'t suit them, I would tell them honestly.'
    },
    {
      factor: 'E',
      ko: '무서운 영화를 볼 때 눈을 가리거나 소리를 줄이는 편이다.',
      en: 'When watching scary movies, I tend to cover my eyes or turn down the volume.'
    },
    {
      factor: 'X',
      ko: '파티나 모임에서 처음 보는 사람에게 먼저 말을 거는 편이다.',
      en: 'At parties or gatherings, I tend to approach and start conversations with strangers.'
    },
    {
      factor: 'C',
      ko: '여행 전에 상세한 일정과 체크리스트를 미리 준비하는 편이다.',
      en: 'I tend to prepare detailed schedules and checklists before traveling.'
    },
    {
      factor: 'O',
      ko: '미술관이나 갤러리에서 작품을 감상할 때 시간 가는 줄 모른다.',
      en: 'When appreciating artworks at museums or galleries, I lose track of time.'
    },
  ]

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentQ((prev) => (prev + 1) % sampleQuestions.length)
    }, 4000)
    return () => clearInterval(interval)
  }, [])

  const factorColors: Record<string, string> = {
    H: '#8B5CF6',
    E: '#EC4899',
    X: '#F97316',
    A: '#22C55E',
    C: '#3B82F6',
    O: '#06B6D4',
  }

  return (
    <motion.div
      initial={{ opacity: 0 }}
      whileInView={{ opacity: 1 }}
      viewport={{ once: true }}
      className="relative bg-dark-card/50 backdrop-blur-xl border border-dark-border rounded-3xl p-8 overflow-hidden"
    >
      <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-purple-500 via-pink-500 to-purple-500" />

      <div className="flex items-center gap-3 mb-6">
        <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-purple-500/20 to-pink-500/20 flex items-center justify-center">
          <Brain className="w-5 h-5 text-purple-400" />
        </div>
        <div>
          <h3 className="text-lg font-bold text-white">
            {i18n.language === 'ko' ? '샘플 질문 미리보기' : 'Sample Questions'}
          </h3>
          <p className="text-sm text-gray-500">
            {i18n.language === 'ko' ? '실제 테스트에서 만나게 될 질문들입니다' : 'Questions you\'ll encounter in the test'}
          </p>
        </div>
      </div>

      <AnimatePresence mode="wait">
        <motion.div
          key={currentQ}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: -20 }}
          transition={{ duration: 0.5 }}
          className="min-h-[100px]"
        >
          <div
            className="inline-flex items-center gap-2 px-3 py-1 rounded-full text-sm mb-4"
            style={{
              backgroundColor: `${factorColors[sampleQuestions[currentQ].factor]}20`,
              color: factorColors[sampleQuestions[currentQ].factor]
            }}
          >
            <span className="font-bold">{sampleQuestions[currentQ].factor}</span>
          </div>
          <p className="text-xl text-gray-200 leading-relaxed">
            {i18n.language === 'ko' ? sampleQuestions[currentQ].ko : sampleQuestions[currentQ].en}
          </p>
        </motion.div>
      </AnimatePresence>

      <div className="flex justify-center gap-2 mt-6">
        {sampleQuestions.map((_, i) => (
          <motion.button
            key={i}
            onClick={() => setCurrentQ(i)}
            className={`w-2 h-2 rounded-full transition-all ${
              i === currentQ ? 'bg-purple-500 w-6' : 'bg-gray-600'
            }`}
          />
        ))}
      </div>
    </motion.div>
  )
}

// Stats section
function StatsSection() {
  const { i18n } = useTranslation()

  const stats = [
    {
      icon: Users,
      value: '50K+',
      label: i18n.language === 'ko' ? '테스트 완료' : 'Tests Taken',
      color: 'from-purple-500 to-pink-500'
    },
    {
      icon: Globe,
      value: '180',
      label: i18n.language === 'ko' ? '심리학적 질문' : 'Psych Questions',
      color: 'from-pink-500 to-orange-500'
    },
    {
      icon: Star,
      value: '4.8',
      label: i18n.language === 'ko' ? '평균 평점' : 'Avg Rating',
      color: 'from-orange-500 to-yellow-500'
    },
    {
      icon: TrendingUp,
      value: '97%',
      label: i18n.language === 'ko' ? '정확도' : 'Accuracy',
      color: 'from-green-500 to-teal-500'
    },
  ]

  return (
    <section className="py-16">
      <div className="max-w-6xl mx-auto px-4">
        <motion.div
          variants={staggerContainer}
          initial="initial"
          whileInView="animate"
          viewport={{ once: true }}
          className="grid grid-cols-2 md:grid-cols-4 gap-4"
        >
          {stats.map(({ icon: Icon, value, label, color }, index) => (
            <motion.div
              key={index}
              variants={fadeInUp}
              whileHover={{ scale: 1.05, y: -5 }}
              className="relative group"
            >
              <div className="absolute inset-0 bg-gradient-to-r opacity-0 group-hover:opacity-20 rounded-2xl blur-xl transition-opacity"
                   style={{ background: `linear-gradient(to right, var(--tw-gradient-stops))` }} />
              <div className="card text-center py-8 relative">
                <div className={`w-12 h-12 mx-auto mb-4 rounded-xl bg-gradient-to-br ${color} bg-opacity-20 flex items-center justify-center`}>
                  <Icon className="w-6 h-6 text-white" />
                </div>
                <motion.div
                  initial={{ scale: 0 }}
                  whileInView={{ scale: 1 }}
                  viewport={{ once: true }}
                  transition={{ delay: index * 0.1, type: "spring" }}
                  className="text-3xl md:text-4xl font-bold text-white mb-1"
                >
                  {value}
                </motion.div>
                <div className="text-gray-400 text-sm">{label}</div>
              </div>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </section>
  )
}

// Benefits list
function BenefitsList() {
  const { i18n } = useTranslation()

  const benefits = i18n.language === 'ko' ? [
    '과학적으로 검증된 HEXACO 모델 기반',
    '상황 기반 질문으로 진짜 성격 파악',
    'AI 기반 맞춤형 성격 분석 리포트',
    '나와 비슷한 유명인 매칭',
    '무료로 즉시 결과 확인',
  ] : [
    'Based on scientifically validated HEXACO model',
    'Situation-based questions reveal true personality',
    'AI-powered personalized analysis report',
    'Match with similar famous personalities',
    'Free instant results',
  ]

  return (
    <motion.div
      initial={{ opacity: 0, x: -30 }}
      whileInView={{ opacity: 1, x: 0 }}
      viewport={{ once: true }}
      className="space-y-3"
    >
      {benefits.map((benefit, i) => (
        <motion.div
          key={i}
          initial={{ opacity: 0, x: -20 }}
          whileInView={{ opacity: 1, x: 0 }}
          viewport={{ once: true }}
          transition={{ delay: i * 0.1 }}
          className="flex items-center gap-3"
        >
          <div className="w-6 h-6 rounded-full bg-gradient-to-r from-purple-500 to-pink-500 flex items-center justify-center flex-shrink-0">
            <CheckCircle className="w-4 h-4 text-white" />
          </div>
          <span className="text-gray-300">{benefit}</span>
        </motion.div>
      ))}
    </motion.div>
  )
}

export default function LandingPage() {
  const { t, i18n } = useTranslation()
  const { reset, setTestVersion, testVersion } = useTestStore()

  const features = [
    { icon: Brain, key: 'scientific' },
    { icon: Users, key: 'persona' },
    { icon: Share2, key: 'share' },
  ]

  const hexacoFactors = ['H', 'E', 'X', 'A', 'C', 'O'] as const

  const typingTexts = i18n.language === 'ko'
    ? ['진짜 나를 발견하세요', '숨겨진 성격을 찾으세요', '나다운 삶을 시작하세요']
    : ['Discover your true self', 'Find your hidden traits', 'Start living authentically']

  return (
    <div className="min-h-screen pt-20 relative">
      <FloatingParticles />

      {/* Hero Section */}
      <section className="relative overflow-hidden py-20 md:py-32">
        {/* Animated background elements */}
        <div className="absolute inset-0 overflow-hidden">
          <motion.div
            className="absolute top-20 left-10 w-72 h-72 bg-purple-500/10 rounded-full blur-3xl"
            animate={{
              scale: [1, 1.2, 1],
              opacity: [0.3, 0.5, 0.3],
            }}
            transition={{ duration: 8, repeat: Infinity }}
          />
          <motion.div
            className="absolute bottom-20 right-10 w-96 h-96 bg-pink-500/10 rounded-full blur-3xl"
            animate={{
              scale: [1.2, 1, 1.2],
              opacity: [0.3, 0.5, 0.3],
            }}
            transition={{ duration: 8, repeat: Infinity, delay: 1 }}
          />
          <motion.div
            className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-gradient-to-r from-purple-500/5 to-pink-500/5 rounded-full blur-3xl"
            animate={{
              rotate: 360,
            }}
            transition={{ duration: 60, repeat: Infinity, ease: 'linear' }}
          />
        </div>

        <div className="relative max-w-6xl mx-auto px-4">
          <div className="grid md:grid-cols-2 gap-12 items-center">
            {/* Left side - Text content */}
            <div className="text-center md:text-left">
              <motion.div
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ duration: 0.8 }}
                className="mb-6 inline-block"
              >
                <div className="flex items-center gap-2 px-4 py-2 bg-purple-500/10 border border-purple-500/20 rounded-full">
                  <Sparkles className="w-4 h-4 text-purple-400" />
                  <span className="text-sm text-purple-300">
                    {i18n.language === 'ko' ? '과학적 성격 분석' : 'Scientific Personality Analysis'}
                  </span>
                </div>
              </motion.div>

              <motion.h1
                {...fadeInUp}
                className="text-5xl md:text-7xl font-bold mb-4"
              >
                <span className="gradient-text">{t('landing.title')}</span>
              </motion.h1>

              <motion.h2
                {...fadeInUp}
                transition={{ delay: 0.1 }}
                className="text-3xl md:text-5xl font-bold text-white mb-6"
              >
                {t('landing.subtitle')}
              </motion.h2>

              <motion.div
                {...fadeInUp}
                transition={{ delay: 0.15 }}
                className="h-12 mb-6"
              >
                <DecryptedText
                  text={typingTexts[0]}
                  speed={60}
                  maxIterations={10}
                  animateOn="view"
                  revealDirection="start"
                  className="text-xl md:text-2xl text-purple-300"
                  parentClassName="text-xl md:text-2xl text-purple-300"
                />
              </motion.div>

              <motion.p
                {...fadeInUp}
                transition={{ delay: 0.2 }}
                className="text-lg text-gray-400 max-w-xl mb-8 whitespace-pre-line"
              >
                {t('landing.description')}
              </motion.p>

              {/* Quick version selector */}
              <motion.div
                {...fadeInUp}
                transition={{ delay: 0.25 }}
                className="flex items-center gap-2 justify-center md:justify-start mb-6"
              >
                <span className="text-gray-500 text-sm">
                  {i18n.language === 'ko' ? '문항 수:' : 'Questions:'}
                </span>
                <div className="flex gap-2">
                  {([60, 120, 180] as const).map((v) => (
                    <ElectricBorder
                      key={v}
                      color={testVersion === v ? '#8B5CF6' : '#4B5563'}
                      speed={1}
                      chaos={testVersion === v ? 0.5 : 0.2}
                      thickness={2}
                      style={{ borderRadius: 9999 }}
                    >
                      <button
                        onClick={() => setTestVersion(v)}
                        className={`px-4 py-2 text-sm font-medium transition-all ${
                          testVersion === v
                            ? 'bg-purple-500/20 text-white'
                            : 'bg-dark-card text-gray-400 hover:text-white'
                        }`}
                        style={{ borderRadius: 9999 }}
                      >
                        {v}
                      </button>
                    </ElectricBorder>
                  ))}
                </div>
              </motion.div>

              <motion.div
                {...fadeInUp}
                transition={{ delay: 0.3 }}
                className="flex flex-col sm:flex-row gap-4 justify-center md:justify-start"
              >
                <ElectricBorder
                  color="#8B5CF6"
                  speed={1}
                  chaos={0.5}
                  thickness={2}
                  style={{ borderRadius: 12 }}
                >
                  <Link
                    to="/test"
                    onClick={() => reset()}
                    className="px-6 py-3 bg-gradient-to-r from-purple-600/80 to-pink-600/80 inline-flex items-center justify-center gap-2 text-lg font-semibold text-white group"
                    style={{ borderRadius: 12 }}
                  >
                    <Sparkles className="w-5 h-5 group-hover:rotate-12 transition-transform" />
                    {testVersion}{t('landing.selectVersion.questions')} {t('landing.cta')}
                    <ChevronRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
                  </Link>
                </ElectricBorder>
                <a
                  href="#learn-more"
                  className="btn-secondary inline-flex items-center justify-center gap-2"
                >
                  {i18n.language === 'ko' ? '더 알아보기' : 'Learn More'}
                </a>
              </motion.div>
            </div>

            {/* Right side - Hexagon animation */}
            <motion.div
              initial={{ opacity: 0, scale: 0.8 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ duration: 1, delay: 0.3 }}
              className="relative hidden md:flex items-center justify-center"
            >
              <div className="relative w-80 h-80">
                {/* Outer rotating ring */}
                <motion.div
                  animate={{ rotate: 360 }}
                  transition={{ duration: 30, repeat: Infinity, ease: 'linear' }}
                  className="absolute inset-0"
                >
                  {hexacoFactors.map((factor, i) => {
                    const angle = (i * 60 - 90) * (Math.PI / 180)
                    const x = 50 + 45 * Math.cos(angle)
                    const y = 50 + 45 * Math.sin(angle)
                    return (
                      <motion.div
                        key={factor}
                        className="absolute w-12 h-12 rounded-xl bg-dark-card border border-dark-border flex items-center justify-center"
                        style={{
                          left: `${x}%`,
                          top: `${y}%`,
                          transform: 'translate(-50%, -50%)',
                        }}
                        whileHover={{ scale: 1.2 }}
                      >
                        <span className="text-lg font-bold gradient-text">{factor}</span>
                      </motion.div>
                    )
                  })}
                </motion.div>

                {/* Center hexagon */}
                <motion.div
                  animate={{ rotate: -360 }}
                  transition={{ duration: 20, repeat: Infinity, ease: 'linear' }}
                  className="absolute inset-0 flex items-center justify-center"
                >
                  <div className="relative">
                    <Hexagon className="w-32 h-32 text-purple-500/50" strokeWidth={1} />
                    <motion.div
                      className="absolute inset-0 flex items-center justify-center"
                      animate={{ scale: [1, 1.1, 1] }}
                      transition={{ duration: 2, repeat: Infinity }}
                    >
                      <Hexagon className="w-24 h-24 text-pink-500/50" strokeWidth={1} />
                    </motion.div>
                  </div>
                </motion.div>

                {/* Glowing orbs */}
                <motion.div
                  className="absolute top-1/2 left-1/2 w-4 h-4 bg-purple-500 rounded-full"
                  style={{ transform: 'translate(-50%, -50%)' }}
                  animate={{
                    boxShadow: [
                      '0 0 20px 10px rgba(139, 92, 246, 0.3)',
                      '0 0 40px 20px rgba(139, 92, 246, 0.5)',
                      '0 0 20px 10px rgba(139, 92, 246, 0.3)',
                    ],
                  }}
                  transition={{ duration: 2, repeat: Infinity }}
                />
              </div>
            </motion.div>
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <StatsSection />

      {/* Sample Question Preview */}
      <section className="py-16" id="learn-more">
        <div className="max-w-6xl mx-auto px-4">
          <div className="grid md:grid-cols-2 gap-12 items-center">
            <SampleQuestionPreview />
            <div className="space-y-6">
              <motion.h2
                initial={{ opacity: 0 }}
                whileInView={{ opacity: 1 }}
                viewport={{ once: true }}
                className="text-3xl md:text-4xl font-bold text-white"
              >
                {i18n.language === 'ko'
                  ? '단순한 질문이 아닌,\n상황 기반 분석'
                  : 'Not simple questions,\nSituation-based analysis'}
              </motion.h2>
              <motion.p
                initial={{ opacity: 0 }}
                whileInView={{ opacity: 1 }}
                viewport={{ once: true }}
                className="text-gray-400"
              >
                {i18n.language === 'ko'
                  ? '"나는 정직하다" 같은 직접적인 질문 대신, 실제 상황에서 어떻게 행동할지를 묻습니다. 이를 통해 사회적 바람직성 편향을 줄이고, 진짜 성격을 파악할 수 있습니다.'
                  : 'Instead of direct questions like "I am honest," we ask how you would behave in real situations. This reduces social desirability bias and reveals your true personality.'}
              </motion.p>
              <BenefitsList />
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20">
        <div className="max-w-6xl mx-auto px-4">
          <motion.div
            variants={staggerContainer}
            initial="initial"
            whileInView="animate"
            viewport={{ once: true }}
            className="grid md:grid-cols-3 gap-6"
          >
            {features.map(({ icon: Icon, key }) => (
              <motion.div
                key={key}
                variants={fadeInUp}
                whileHover={{ y: -10 }}
                className="card group relative overflow-hidden"
              >
                <div className="absolute top-0 right-0 w-32 h-32 bg-gradient-to-br from-purple-500/10 to-pink-500/10 rounded-full blur-2xl opacity-0 group-hover:opacity-100 transition-opacity" />
                <div className="relative">
                  <div className="w-14 h-14 rounded-xl bg-gradient-to-br from-purple-500/20 to-pink-500/20
                                flex items-center justify-center mb-4
                                group-hover:from-purple-500/30 group-hover:to-pink-500/30 transition-all">
                    <Icon className="w-7 h-7 text-purple-400" />
                  </div>
                  <h3 className="text-xl font-bold text-white mb-2">
                    {t(`landing.features.${key}.title`)}
                  </h3>
                  <p className="text-gray-400">
                    {t(`landing.features.${key}.description`)}
                  </p>
                </div>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </section>

      {/* HEXACO Explanation Section */}
      <section className="py-20">
        <div className="max-w-6xl mx-auto px-4">
          <motion.div
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
            className="text-center mb-12"
          >
            <h2 className="text-3xl md:text-4xl font-bold text-white mb-4">
              {t('landing.hexaco.title')}
            </h2>
            <p className="text-gray-400 max-w-3xl mx-auto">
              {t('landing.hexaco.description')}
            </p>
          </motion.div>

          <motion.div
            variants={staggerContainer}
            initial="initial"
            whileInView="animate"
            viewport={{ once: true }}
            className="grid md:grid-cols-2 lg:grid-cols-3 gap-4"
          >
            {hexacoFactors.map((factor) => (
              <motion.div
                key={factor}
                variants={fadeInUp}
                whileHover={{ scale: 1.02 }}
                className="card relative overflow-hidden"
              >
                <div className="absolute top-0 right-0 text-8xl font-bold text-white/5">
                  {factor}
                </div>
                <div className="relative">
                  <div className="flex items-center gap-3 mb-3">
                    <span className="text-3xl font-bold gradient-text">{factor}</span>
                    <div>
                      <p className="font-semibold text-white">
                        {t(`landing.hexaco.factors.${factor}.name`)}
                      </p>
                      <p className="text-sm text-gray-500">
                        {t(`landing.hexaco.factors.${factor}.full`)}
                      </p>
                    </div>
                  </div>
                  <p className="text-gray-400 text-sm">
                    {t(`landing.hexaco.factors.${factor}.desc`)}
                  </p>
                </div>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </section>

      {/* Test Version Selection */}
      <section className="py-20">
        <div className="max-w-5xl mx-auto px-4">
          <motion.div
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
            className="text-center mb-10"
          >
            <h2 className="text-3xl md:text-4xl font-bold text-white mb-4">
              {t('landing.selectVersion.title')}
            </h2>
            <p className="text-gray-400">
              {t('landing.selectVersion.description')}
            </p>
          </motion.div>

          <motion.div
            variants={staggerContainer}
            initial="initial"
            whileInView="animate"
            viewport={{ once: true }}
            className="grid md:grid-cols-3 gap-6"
          >
            {testVersions.map((version) => {
              const Icon = versionIcons[version.value]
              const isSelected = testVersion === version.value
              return (
                <motion.button
                  key={version.value}
                  variants={fadeInUp}
                  onClick={() => setTestVersion(version.value)}
                  whileHover={{ scale: 1.03, y: -5 }}
                  whileTap={{ scale: 0.98 }}
                  className={`card text-left transition-all ${
                    isSelected
                      ? 'ring-2 ring-purple-500 bg-purple-500/10'
                      : 'hover:border-purple-500/50'
                  }`}
                >
                  <div className="flex items-center justify-between mb-4">
                    <div className={`w-12 h-12 rounded-xl flex items-center justify-center ${
                      isSelected
                        ? 'bg-purple-500'
                        : 'bg-gradient-to-br from-purple-500/20 to-pink-500/20'
                    }`}>
                      <Icon className={`w-6 h-6 ${isSelected ? 'text-white' : 'text-purple-400'}`} />
                    </div>
                    {isSelected && (
                      <motion.span
                        initial={{ scale: 0 }}
                        animate={{ scale: 1 }}
                        className="px-3 py-1 bg-purple-500 text-white text-xs rounded-full"
                      >
                        {t('landing.selectVersion.selected')}
                      </motion.span>
                    )}
                  </div>
                  <h3 className="text-2xl font-bold text-white mb-1">
                    {version.value}{t('landing.selectVersion.questions')}
                  </h3>
                  <p className="text-gray-400 text-sm mb-3">
                    {t(version.descKey)}
                  </p>
                  <div className="flex items-center gap-2 text-gray-500 text-sm">
                    <Clock className="w-4 h-4" />
                    <span>{t('landing.selectVersion.time', { minutes: version.minutes })}</span>
                  </div>
                </motion.button>
              )
            })}
          </motion.div>

          <motion.div
            {...fadeInUp}
            transition={{ delay: 0.4 }}
            className="text-center mt-10"
          >
            <Link
              to="/test"
              onClick={() => reset()}
              className="btn-primary inline-flex items-center gap-2 text-lg px-8 py-4 group"
            >
              <Sparkles className="w-5 h-5 group-hover:rotate-12 transition-transform" />
              {testVersion}{t('landing.selectVersion.questions')} {t('landing.cta')}
              <ChevronRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
            </Link>
          </motion.div>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-8 border-t border-dark-border">
        <div className="max-w-6xl mx-auto px-4 text-center text-gray-500 text-sm">
          <p>HEXACO Personality Test</p>
          <p className="mt-1">Based on HEXACO-PI-R by Ashton & Lee</p>
          <p className="mt-3">
            <Link to="/privacy" className="hover:text-purple-400 transition-colors">
              {i18n.language === 'ko' ? '개인정보처리방침' : 'Privacy Policy'}
            </Link>
          </p>
        </div>
      </footer>
    </div>
  )
}
