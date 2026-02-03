import { useEffect, useState, useRef } from 'react'
import { Link, useSearchParams } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { motion, AnimatePresence } from 'framer-motion'
import {
  Radar, RadarChart, PolarGrid, PolarAngleAxis,
  PolarRadiusAxis, ResponsiveContainer
} from 'recharts'
import { Download, Link2, RotateCcw, Home, Check, Twitter, AlertTriangle, Info, Brain } from 'lucide-react'
import html2canvas from 'html2canvas'
import { decodeResults, useTestStore } from '../stores/testStore'
import { factorColors, factors, Factor } from '../data/questions'
import { findTopMatches, MatchResult } from '../utils/matching'
import { categoryColors } from '../data/personas'
import { CelebrityDisclaimer } from '../components/common/DisclaimerSection'

interface AnalysisFactor {
  factor: Factor
  overview: string
  strengths: string[]
  risks: string[]
  growth: string
}

interface AnalysisResponse {
  summary: string
  factors: AnalysisFactor[]
}

// Loading screen with animated messages
function LoadingScreen({ language }: { language: string }) {
  const [messageIndex, setMessageIndex] = useState(0)
  const isKo = language === 'ko'

  const messages = isKo
    ? [
        '당신의 성격을 분석하고 있어요...',
        '6가지 요인을 계산 중...',
        '100가지 유형과 비교하는 중...',
        '가장 비슷한 유형을 찾고 있어요...',
        '두근두근...',
        '결과를 준비하고 있어요...',
      ]
    : [
        'Analyzing your personality...',
        'Calculating 6 factors...',
        'Comparing with 100 types...',
        'Finding your closest match...',
        'Drumroll please...',
        'Preparing your results...',
      ]

  useEffect(() => {
    const timer = setInterval(() => {
      setMessageIndex((prev) => (prev + 1) % messages.length)
    }, 800)
    return () => clearInterval(timer)
  }, [messages.length])

  const progress = ((messageIndex + 1) / messages.length) * 100

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-dark-bg">
      {/* Animated orb */}
      <motion.div
        className="relative w-32 h-32 mb-12"
        animate={{
          scale: [1, 1.1, 1],
        }}
        transition={{
          duration: 1.5,
          repeat: Infinity,
          ease: 'easeInOut',
        }}
      >
        <div className="absolute inset-0 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center">
          <Brain className="w-16 h-16 text-white" />
        </div>
        <motion.div
          className="absolute inset-0 rounded-full"
          animate={{
            boxShadow: [
              '0 0 30px rgba(139, 92, 246, 0.3), 0 0 60px rgba(236, 72, 153, 0.2)',
              '0 0 50px rgba(139, 92, 246, 0.5), 0 0 80px rgba(236, 72, 153, 0.4)',
              '0 0 30px rgba(139, 92, 246, 0.3), 0 0 60px rgba(236, 72, 153, 0.2)',
            ],
          }}
          transition={{
            duration: 1.5,
            repeat: Infinity,
            ease: 'easeInOut',
          }}
        />
      </motion.div>

      {/* Message */}
      <AnimatePresence mode="wait">
        <motion.p
          key={messageIndex}
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: -10 }}
          className="text-white text-lg font-medium mb-8 text-center"
        >
          {messages[messageIndex]}
        </motion.p>
      </AnimatePresence>

      {/* Progress bar */}
      <div className="w-48 h-1.5 bg-dark-card rounded-full overflow-hidden">
        <motion.div
          className="h-full bg-gradient-to-r from-purple-500 to-pink-500 rounded-full"
          animate={{ width: `${progress}%` }}
          transition={{ duration: 0.3 }}
        />
      </div>

      {/* Percentage */}
      <p className="text-gray-400 text-sm mt-4">
        {Math.round(progress)}%
      </p>
    </div>
  )
}

// Factor card component
function FactorCard({
  factor,
  score,
  name,
  description,
  delay,
}: {
  factor: Factor
  score: number
  name: string
  description: string
  delay: number
}) {
  const color = factorColors[factor]
  const isHigh = score >= 50

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay }}
      className="relative overflow-hidden rounded-xl border border-dark-border p-4"
      style={{
        background: `linear-gradient(135deg, ${color}20 0%, transparent 60%)`,
      }}
    >
      <div className="flex items-center gap-2 mb-3">
        <span
          className="text-2xl font-bold"
          style={{ color }}
        >
          {factor}
        </span>
        <span className="text-gray-400 text-sm truncate flex-1">
          {name}
        </span>
      </div>

      <div className="text-2xl font-bold text-white mb-2">
        {score.toFixed(1)}%
      </div>

      <div className="h-1.5 bg-dark-bg rounded-full overflow-hidden mb-3">
        <motion.div
          initial={{ width: 0 }}
          animate={{ width: `${score}%` }}
          transition={{ delay: delay + 0.2, duration: 0.8 }}
          className="h-full rounded-full"
          style={{ backgroundColor: color }}
        />
      </div>

      <p className="text-xs text-gray-400 leading-relaxed">
        {description}
      </p>
    </motion.div>
  )
}

// Match card component
function MatchCard({
  match,
  rank,
  language,
}: {
  match: MatchResult
  rank: number
  language: string
}) {
  const { t } = useTranslation()
  const name = match.persona.name[language as 'ko' | 'en']
  const description = match.persona.description[language as 'ko' | 'en']

  return (
    <div className="flex items-center gap-4 p-4 rounded-xl bg-dark-bg/50">
      {/* Avatar */}
      <div className="relative flex-shrink-0">
        <div className="w-14 h-14 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center">
          <span className="text-xl font-bold text-white">
            {name[0]}
          </span>
        </div>
        <div className="absolute -top-1 -right-1 w-6 h-6 rounded-full bg-dark-card border border-dark-border flex items-center justify-center">
          <span className="text-xs font-bold text-gray-400">#{rank}</span>
        </div>
      </div>

      {/* Info */}
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2 mb-1">
          <h3 className="font-bold text-white truncate">{name}</h3>
          <span
            className="text-xs px-2 py-0.5 rounded-full flex-shrink-0"
            style={{
              backgroundColor: categoryColors[match.persona.category],
              color: 'white',
            }}
          >
            {t(`result.category.${match.persona.category}`)}
          </span>
        </div>
        <p className="text-sm text-gray-400 line-clamp-2">{description}</p>
      </div>

      {/* Similarity */}
      <div className="flex-shrink-0 text-right">
        <div className="text-lg font-bold text-purple-400">
          {match.similarity}%
        </div>
        {match.similarity >= 80 && (
          <span className="text-xs text-emerald-400">
            {language === 'ko' ? '찰떡!' : 'Match!'}
          </span>
        )}
      </div>
    </div>
  )
}

export default function ResultPage() {
  const { t, i18n } = useTranslation()
  const [searchParams] = useSearchParams()
  const resultRef = useRef<HTMLDivElement>(null)
  const [copied, setCopied] = useState(false)
  const [topMatches, setTopMatches] = useState<MatchResult[]>([])
  const [analysis, setAnalysis] = useState<AnalysisResponse | null>(null)
  const [analysisError, setAnalysisError] = useState<string | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  const storeScores = useTestStore(state => state.scores)
  const reset = useTestStore(state => state.reset)

  const encodedResult = searchParams.get('r')
  const scores = encodedResult ? decodeResults(encodedResult) : storeScores
  const match = topMatches[0]
  const analysisFactors = analysis
    ? factors
        .map(factor => analysis.factors.find(item => item.factor === factor))
        .filter((item): item is AnalysisFactor => Boolean(item))
    : []

  const factorNamesKo: Record<Factor, string> = {
    H: '정직-겸손',
    E: '정서성',
    X: '외향성',
    A: '원만성',
    C: '성실성',
    O: '개방성',
  }

  const factorNamesEn: Record<Factor, string> = {
    H: 'Honesty-Humility',
    E: 'Emotionality',
    X: 'Extraversion',
    A: 'Agreeableness',
    C: 'Conscientiousness',
    O: 'Openness',
  }

  const getFactorDescription = (factor: Factor, score: number, isKo: boolean) => {
    const isHigh = score >= 50
    const descriptions: Record<Factor, { high: { ko: string; en: string }; low: { ko: string; en: string } }> = {
      H: {
        high: {
          ko: '진실되고 공정하며, 물질적 이득보다 도덕적 가치를 중시합니다.',
          en: 'Sincere and fair, valuing moral principles over material gain.',
        },
        low: {
          ko: '자신의 이익을 위해 적극적으로 행동하며, 사회적 지위에 관심이 많습니다.',
          en: 'Actively pursues interests and cares about social status.',
        },
      },
      E: {
        high: {
          ko: '감정적으로 민감하고, 다른 사람들과 깊은 유대감을 형성합니다.',
          en: 'Emotionally sensitive and forms deep bonds with others.',
        },
        low: {
          ko: '정서적으로 안정되어 있으며, 스트레스 상황에서도 침착함을 유지합니다.',
          en: 'Emotionally stable and remains calm under stress.',
        },
      },
      X: {
        high: {
          ko: '사교적이고 활발하며, 사람들과 함께 있을 때 에너지를 얻습니다.',
          en: 'Sociable and energetic, gaining energy from being with people.',
        },
        low: {
          ko: '조용하고 내성적이며, 혼자만의 시간을 즐깁니다.',
          en: 'Quiet and introverted, enjoying time alone.',
        },
      },
      A: {
        high: {
          ko: '타인을 쉽게 용서하고, 갈등을 피하며 협력적입니다.',
          en: 'Easily forgives others, avoids conflict, and is cooperative.',
        },
        low: {
          ko: '자신의 의견을 강하게 표현하고, 필요시 비판도 서슴지 않습니다.',
          en: 'Expresses opinions strongly and doesn\'t hesitate to criticize.',
        },
      },
      C: {
        high: {
          ko: '체계적이고 목표 지향적이며, 계획에 따라 행동합니다.',
          en: 'Organized, goal-oriented, and acts according to plans.',
        },
        low: {
          ko: '유연하고 즉흥적이며, 규칙에 얽매이지 않습니다.',
          en: 'Flexible and spontaneous, not bound by rules.',
        },
      },
      O: {
        high: {
          ko: '창의적이고 호기심이 많으며, 새로운 경험을 추구합니다.',
          en: 'Creative, curious, and seeks new experiences.',
        },
        low: {
          ko: '실용적이고 전통적인 방식을 선호합니다.',
          en: 'Practical and prefers traditional approaches.',
        },
      },
    }
    return isHigh
      ? (isKo ? descriptions[factor].high.ko : descriptions[factor].high.en)
      : (isKo ? descriptions[factor].low.ko : descriptions[factor].low.en)
  }

  useEffect(() => {
    if (!scores) {
      setIsLoading(false)
      return
    }

    let cancelled = false
    setIsLoading(true)
    setAnalysis(null)
    setAnalysisError(null)

    const delay = new Promise(resolve => {
      setTimeout(resolve, 4000) // 4 seconds loading
    })

    const matchesPromise = delay.then(() => findTopMatches(scores, 5))

    const analysisPromise = fetch('/api/analyze', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        scores,
        language: i18n.language === 'ko' ? 'ko' : 'en'
      })
    }).then(async response => {
      if (!response.ok) {
        throw new Error('Failed to load analysis')
      }
      return response.json() as Promise<AnalysisResponse>
    })

    Promise.allSettled([matchesPromise, analysisPromise]).then(results => {
      if (cancelled) return

      const matchResult = results[0]
      if (matchResult.status === 'fulfilled') {
        setTopMatches(matchResult.value)
      } else {
        setTopMatches(findTopMatches(scores, 5))
      }

      const analysisResult = results[1]
      if (analysisResult.status === 'fulfilled') {
        setAnalysis(analysisResult.value)
      } else {
        setAnalysisError(i18n.language === 'ko'
          ? 'AI 분석을 불러오지 못했습니다.'
          : 'Failed to load AI analysis.')
      }

      setIsLoading(false)
    })

    return () => {
      cancelled = true
    }
  }, [scores, i18n.language])

  const chartData = scores
    ? factors.map(factor => ({
        factor,
        value: scores[factor],
        fullMark: 100
      }))
    : []

  const copyLink = async () => {
    await navigator.clipboard.writeText(window.location.href)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  const shareTwitter = () => {
    const text = i18n.language === 'ko'
      ? `나의 HEXACO 성격 테스트 결과! ${match?.persona.name.ko}와(과) ${match?.similarity}% 유사합니다.`
      : `My HEXACO Personality Test Results! ${match?.similarity}% similar to ${match?.persona.name.en}.`
    const url = encodeURIComponent(window.location.href)
    window.open(`https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}&url=${url}`, '_blank')
  }

  const downloadImage = async () => {
    if (!resultRef.current) return

    try {
      const canvas = await html2canvas(resultRef.current, {
        backgroundColor: '#0f0f23',
        scale: 2
      })
      const link = document.createElement('a')
      link.download = 'hexaco-result.png'
      link.href = canvas.toDataURL()
      link.click()
    } catch (error) {
      console.error('Failed to download image:', error)
    }
  }

  if (isLoading) {
    return <LoadingScreen language={i18n.language} />
  }

  if (!scores) {
    return (
      <div className="min-h-screen pt-24 flex flex-col items-center justify-center text-center px-4">
        <h2 className="text-2xl font-bold text-white mb-4">
          {i18n.language === 'ko' ? '결과를 찾을 수 없습니다' : 'Results not found'}
        </h2>
        <p className="text-gray-400 mb-8">
          {i18n.language === 'ko'
            ? '테스트를 먼저 완료해주세요'
            : 'Please complete the test first'}
        </p>
        <Link to="/test" className="btn-primary">
          {t('common.start')}
        </Link>
      </div>
    )
  }

  const isKo = i18n.language === 'ko'

  return (
    <div className="min-h-screen pt-20 pb-12 px-4">
      <div className="max-w-4xl mx-auto">
        <div ref={resultRef} className="space-y-6 p-4">
          {/* Title */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-center"
          >
            <h1 className="text-2xl md:text-3xl font-bold gradient-text mb-2">
              {isKo ? '결과' : 'Results'}
            </h1>
            <p className="text-gray-400 text-sm">
              {isKo
                ? '100가지 유형 중 가장 가까운 유형을 추천합니다.'
                : 'We recommend the closest match among 100 types.'}
            </p>
          </motion.div>

          {/* Top Match Card */}
          {match && (
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: 0.2 }}
              className="relative overflow-hidden rounded-2xl border border-purple-500/30 p-6"
              style={{
                background: 'linear-gradient(135deg, rgba(139, 92, 246, 0.15) 0%, rgba(236, 72, 153, 0.15) 100%)',
              }}
            >
              <div className="flex items-start gap-4">
                {/* Avatar */}
                <div className="w-16 h-16 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center flex-shrink-0">
                  <span className="text-2xl font-bold text-white">
                    {match.persona.name[isKo ? 'ko' : 'en'][0]}
                  </span>
                </div>

                {/* Info */}
                <div className="flex-1 min-w-0">
                  <h2 className="text-xl font-bold text-white mb-1">
                    {match.persona.name[isKo ? 'ko' : 'en']}
                  </h2>
                  <p className="text-sm text-gray-400 mb-3 line-clamp-2">
                    {match.persona.description[isKo ? 'ko' : 'en']}
                  </p>
                  <div className="flex items-center gap-3">
                    <span className="text-purple-400 font-medium">
                      {isKo ? `유사도 ${match.similarity}%` : `${match.similarity}% Similar`}
                    </span>
                    {match.similarity >= 80 && (
                      <span className="px-2 py-0.5 rounded-full bg-emerald-500/20 text-emerald-400 text-xs font-medium">
                        {isKo ? '찰떡궁합!' : 'Perfect Match!'}
                      </span>
                    )}
                  </div>
                </div>
              </div>
            </motion.div>
          )}

          {/* Radar Chart */}
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.3 }}
            className="card"
          >
            <h3 className="text-lg font-bold text-white mb-4">
              {isKo ? '프로필 지도' : 'Profile Map'}
            </h3>
            <div className="h-72 md:h-80">
              <ResponsiveContainer width="100%" height="100%">
                <RadarChart cx="50%" cy="50%" outerRadius="70%" data={chartData}>
                  <PolarGrid stroke="#2d2d44" />
                  <PolarAngleAxis
                    dataKey="factor"
                    tick={{ fill: '#9ca3af', fontSize: 14 }}
                  />
                  <PolarRadiusAxis
                    angle={30}
                    domain={[0, 100]}
                    tick={{ fill: '#6b7280', fontSize: 10 }}
                  />
                  <Radar
                    name="Score"
                    dataKey="value"
                    stroke="#8B5CF6"
                    fill="#8B5CF6"
                    fillOpacity={0.4}
                    strokeWidth={2}
                  />
                </RadarChart>
              </ResponsiveContainer>
            </div>
          </motion.div>

          {/* Factor Scores Grid */}
          <div>
            <h3 className="text-lg font-bold text-white mb-4">
              {isKo ? '요인 점수' : 'Factor Scores'}
            </h3>
            <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
              {factors.map((factor, index) => (
                <FactorCard
                  key={factor}
                  factor={factor}
                  score={scores[factor]}
                  name={isKo ? factorNamesKo[factor] : factorNamesEn[factor]}
                  description={getFactorDescription(factor, scores[factor], isKo)}
                  delay={0.4 + index * 0.1}
                />
              ))}
            </div>
          </div>

          {/* AI Analysis */}
          {analysis && (
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.6 }}
              className="card"
            >
              <div className="flex items-center gap-3 mb-4">
                <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center">
                  <Brain className="w-5 h-5 text-white" />
                </div>
                <div>
                  <h3 className="font-bold text-white">
                    {isKo ? '성격 분석 리포트' : 'Personality Analysis Report'}
                  </h3>
                  <p className="text-xs text-gray-400">
                    {isKo ? 'AI 기반 분석' : 'AI-powered analysis'}
                  </p>
                </div>
              </div>

              <p className="text-gray-300 text-sm mb-6 leading-relaxed">
                {analysis.summary}
              </p>

              <div className="space-y-4">
                {analysisFactors.map(item => (
                  <div
                    key={item.factor}
                    className="rounded-xl p-4"
                    style={{
                      background: `linear-gradient(135deg, ${factorColors[item.factor]}15 0%, transparent 60%)`,
                      borderLeft: `3px solid ${factorColors[item.factor]}`,
                    }}
                  >
                    <div className="flex items-center gap-2 mb-2">
                      <span
                        className="text-lg font-bold"
                        style={{ color: factorColors[item.factor] }}
                      >
                        {item.factor}
                      </span>
                      <span className="text-sm text-gray-400">
                        {isKo ? factorNamesKo[item.factor] : factorNamesEn[item.factor]}
                      </span>
                    </div>
                    <p className="text-sm text-gray-300 mb-3">{item.overview}</p>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-3 text-xs">
                      <div className="bg-dark-bg/50 rounded-lg p-3">
                        <p className="text-gray-400 font-medium mb-2">
                          {isKo ? '강점' : 'Strengths'}
                        </p>
                        <ul className="text-gray-500 space-y-1">
                          {item.strengths?.map((s, i) => (
                            <li key={i} className="flex items-start gap-1">
                              <span className="text-emerald-400">+</span> {s}
                            </li>
                          ))}
                        </ul>
                      </div>
                      <div className="bg-dark-bg/50 rounded-lg p-3">
                        <p className="text-gray-400 font-medium mb-2">
                          {isKo ? '주의점' : 'Risks'}
                        </p>
                        <ul className="text-gray-500 space-y-1">
                          {item.risks?.map((r, i) => (
                            <li key={i} className="flex items-start gap-1">
                              <span className="text-amber-400">!</span> {r}
                            </li>
                          ))}
                        </ul>
                      </div>
                    </div>
                    <p className="text-xs text-gray-500 mt-3">
                      <span className="text-purple-400 font-medium mr-2">
                        {isKo ? '제안' : 'Growth'}
                      </span>
                      {item.growth}
                    </p>
                  </div>
                ))}
              </div>
            </motion.div>
          )}

          {analysisError && (
            <div className="card border border-amber-500/30 bg-amber-500/5 text-amber-200 text-sm">
              {analysisError}
            </div>
          )}

          {/* Top 5 Matches */}
          {topMatches.length > 0 && (
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.8 }}
              className="card"
            >
              <h3 className="text-lg font-bold text-white mb-2">
                {isKo ? '추천 유형 TOP 5' : 'Top 5 Matches'}
              </h3>
              <p className="text-gray-400 text-sm mb-4">
                {t('result.matchDescription')}
              </p>

              <div className="space-y-3">
                {topMatches.map((item, index) => (
                  <MatchCard
                    key={item.persona.id}
                    match={item}
                    rank={index + 1}
                    language={i18n.language}
                  />
                ))}
              </div>

              <CelebrityDisclaimer />
            </motion.div>
          )}

          {/* Legal Notice */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 1 }}
            className="rounded-xl bg-dark-card/50 border border-dark-border p-4"
          >
            <div className="flex items-center gap-2 mb-3">
              <Info className="w-4 h-4 text-gray-400" />
              <span className="text-sm font-medium text-gray-400">
                {isKo ? '법적 고지' : 'Legal Notice'}
              </span>
            </div>
            <ul className="text-xs text-gray-500 space-y-1.5">
              <li className="flex items-start gap-2">
                <AlertTriangle className="w-3 h-3 mt-0.5 flex-shrink-0" />
                <span>
                  {isKo
                    ? '본 테스트는 비공식이며 HEXACO-PI-R과 무관합니다.'
                    : 'Unofficial test, not affiliated with HEXACO-PI-R.'}
                </span>
              </li>
              <li className="flex items-start gap-2">
                <AlertTriangle className="w-3 h-3 mt-0.5 flex-shrink-0" />
                <span>
                  {isKo
                    ? '결과는 오락 및 자기이해 목적이며 전문 심리 진단을 대체하지 않습니다.'
                    : 'For entertainment/self-understanding only, not professional diagnosis.'}
                </span>
              </li>
              <li className="flex items-start gap-2">
                <AlertTriangle className="w-3 h-3 mt-0.5 flex-shrink-0" />
                <span>
                  {isKo
                    ? '테스트 결과는 기기에만 저장되며 수집하지 않습니다.'
                    : 'Results are stored locally and not collected.'}
                </span>
              </li>
            </ul>
          </motion.div>
        </div>

        {/* Share Buttons */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1 }}
          className="mt-6 flex flex-wrap justify-center gap-3"
        >
          <button onClick={copyLink} className="btn-secondary flex items-center gap-2">
            {copied ? <Check className="w-4 h-4 text-green-500" /> : <Link2 className="w-4 h-4" />}
            {copied ? t('common.copied') : t('common.copyLink')}
          </button>

          <button onClick={shareTwitter} className="btn-secondary flex items-center gap-2">
            <Twitter className="w-4 h-4" />
            Twitter
          </button>

          <button onClick={downloadImage} className="btn-secondary flex items-center gap-2">
            <Download className="w-4 h-4" />
            {t('common.save')}
          </button>
        </motion.div>

        {/* Action Buttons */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1.2 }}
          className="mt-6 flex justify-center gap-4"
        >
          <Link
            to="/test"
            onClick={() => reset()}
            className="btn-primary flex items-center gap-2"
          >
            <RotateCcw className="w-4 h-4" />
            {t('common.retry')}
          </Link>

          <Link to="/" className="btn-secondary flex items-center gap-2">
            <Home className="w-4 h-4" />
            {t('common.home')}
          </Link>
        </motion.div>
      </div>
    </div>
  )
}
