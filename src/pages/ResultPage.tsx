import { useEffect, useMemo, useState, useRef, useCallback } from 'react'
import { Link, useSearchParams } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { motion, AnimatePresence } from 'framer-motion'
import {
  Radar, RadarChart, PolarGrid, PolarAngleAxis,
  PolarRadiusAxis, ResponsiveContainer
} from 'recharts'
import { Download, Link2, RotateCcw, Home, Check, Twitter, AlertTriangle, Info, Brain, Sparkles, Copy, Coffee, ExternalLink, Image, X, Share2, CheckCircle, Circle } from 'lucide-react'
import html2canvas from 'html2canvas'
import { decodeResults, useTestStore } from '../stores/testStore'
import { factorColors, factors, Factor } from '../data/questions'
import { findTopMatches, MatchResult } from '../utils/matching'
import { categoryColors } from '../data/personas'
import { CelebrityDisclaimer } from '../components/common/DisclaimerSection'
import { getPersonalityTitle, getMemeQuotes, getMainMemeQuote, getCharacterMatch, getMBTIMatch } from '../utils/memeContent'
import { getFactorAnalyses, getOverallAnalysis, type FactorAnalysis as LocalFactorAnalysis } from '../utils/personalityAnalysis'

interface AIAnalysisFactor {
  factor: string
  overview: string
  strengths: string[]
  risks: string[]
  growth: string
}

interface AIAnalysisResponse {
  summary: string
  factors: AIAnalysisFactor[]
}

const factorNamesKo: Record<Factor, string> = {
  H: '정직-겸손', E: '정서성', X: '외향성', A: '원만성', C: '성실성', O: '개방성',
}
const factorNamesEn: Record<Factor, string> = {
  H: 'Honesty-Humility', E: 'Emotionality', X: 'Extraversion', A: 'Agreeableness', C: 'Conscientiousness', O: 'Openness',
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
      <motion.div
        className="relative w-32 h-32 mb-12"
        animate={{ scale: [1, 1.1, 1] }}
        transition={{ duration: 1.5, repeat: Infinity, ease: 'easeInOut' }}
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
          transition={{ duration: 1.5, repeat: Infinity, ease: 'easeInOut' }}
        />
      </motion.div>

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

      <div className="w-48 h-1.5 bg-dark-card rounded-full overflow-hidden">
        <motion.div
          className="h-full bg-gradient-to-r from-purple-500 to-pink-500 rounded-full"
          animate={{ width: `${progress}%` }}
          transition={{ duration: 0.3 }}
        />
      </div>

      <p className="text-gray-400 text-sm mt-4">
        {Math.round(progress)}%
      </p>
    </div>
  )
}

// Flip card for factor analysis
function FlipCard({
  analysis,
  isKo,
  delay,
}: {
  analysis: LocalFactorAnalysis
  isKo: boolean
  delay: number
}) {
  const [flipped, setFlipped] = useState(false)
  const color = factorColors[analysis.factor as keyof typeof factorColors]

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay }}
      className="cursor-pointer perspective-1000"
      style={{ minHeight: '200px' }}
      onClick={() => setFlipped(!flipped)}
    >
      <motion.div
        className="relative w-full h-full"
        style={{ transformStyle: 'preserve-3d', minHeight: '200px' }}
        animate={{ rotateY: flipped ? 180 : 0 }}
        transition={{ duration: 0.4 }}
      >
        {/* Front */}
        <div
          className="absolute inset-0 rounded-xl border border-dark-border p-4 backface-hidden"
          style={{
            background: `linear-gradient(135deg, ${color}15 0%, transparent 60%)`,
            backfaceVisibility: 'hidden',
          }}
        >
          <div className="flex items-center gap-2 mb-2">
            <span className="text-2xl">{analysis.emoji}</span>
            <span className="text-lg font-bold" style={{ color }}>{analysis.factor}</span>
            <span className="text-xs text-gray-500">{isKo ? analysis.nameKo : analysis.nameEn}</span>
          </div>
          <div className="text-xl font-bold text-white mb-2">{analysis.score.toFixed(1)}%</div>
          <div className="h-1.5 bg-dark-bg rounded-full overflow-hidden mb-3">
            <motion.div
              initial={{ width: 0 }}
              animate={{ width: `${analysis.score}%` }}
              transition={{ delay: delay + 0.2, duration: 0.8 }}
              className="h-full rounded-full"
              style={{ backgroundColor: color }}
            />
          </div>
          <p className="text-sm text-gray-300 leading-relaxed">
            {isKo ? analysis.summaryKo : analysis.summaryEn}
          </p>
          <p className="text-xs text-gray-500 mt-3 text-center">
            {isKo ? '탭하여 자세히 보기' : 'Tap for details'}
          </p>
        </div>

        {/* Back */}
        <div
          className="absolute inset-0 rounded-xl border border-dark-border p-4 backface-hidden overflow-y-auto"
          style={{
            background: `linear-gradient(135deg, ${color}10 0%, #1a1a2e 60%)`,
            backfaceVisibility: 'hidden',
            transform: 'rotateY(180deg)',
          }}
        >
          <div className="flex items-center gap-2 mb-3">
            <span className="text-lg font-bold" style={{ color }}>{analysis.factor}</span>
            <span className="text-xs text-gray-400">{isKo ? analysis.nameKo : analysis.nameEn}</span>
          </div>
          <p className="text-sm text-gray-300 leading-relaxed">
            {isKo ? analysis.detailKo : analysis.detailEn}
          </p>
          <p className="text-xs text-gray-500 mt-3 text-center">
            {isKo ? '탭하여 돌아가기' : 'Tap to go back'}
          </p>
        </div>
      </motion.div>
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
      <div className="relative flex-shrink-0">
        <div className="w-14 h-14 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center">
          <span className="text-xl font-bold text-white">{name[0]}</span>
        </div>
        <div className="absolute -top-1 -right-1 w-6 h-6 rounded-full bg-dark-card border border-dark-border flex items-center justify-center">
          <span className="text-xs font-bold text-gray-400">#{rank}</span>
        </div>
      </div>
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2 mb-1">
          <h3 className="font-bold text-white truncate">{name}</h3>
          <span
            className="text-xs px-2 py-0.5 rounded-full flex-shrink-0"
            style={{ backgroundColor: categoryColors[match.persona.category], color: 'white' }}
          >
            {t(`result.category.${match.persona.category}`)}
          </span>
        </div>
        <p className="text-sm text-gray-400 line-clamp-2">{description}</p>
      </div>
      <div className="flex-shrink-0 text-right">
        <div className="text-lg font-bold text-purple-400">{match.similarity}%</div>
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
  const shareCardRef = useRef<HTMLDivElement>(null)
  const [copied, setCopied] = useState(false)
  const [summaryCopied, setSummaryCopied] = useState(false)
  const [topMatches, setTopMatches] = useState<MatchResult[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [aiAnalysis, setAiAnalysis] = useState<AIAnalysisResponse | null>(null)
  const [aiLoading, setAiLoading] = useState(false)
  const [showShareModal, setShowShareModal] = useState(false)
  const [selectedFactors, setSelectedFactors] = useState<Set<string>>(new Set())
  const [shareMode, setShareMode] = useState<'download' | 'share'>('download')
  const [isCapturing, setIsCapturing] = useState(false)

  const storeScores = useTestStore(state => state.scores)
  const reset = useTestStore(state => state.reset)

  const encodedResult = searchParams.get('r')
  const scores = useMemo(
    () => encodedResult ? decodeResults(encodedResult) : storeScores,
    [encodedResult, storeScores]
  )
  const match = topMatches[0]

  // Meme content (computed from scores)
  const personalityTitle = scores ? getPersonalityTitle(scores) : null
  const memeQuotes = scores ? getMemeQuotes(scores) : []
  const mainMeme = scores ? getMainMemeQuote(scores) : null
  const characterMatch = scores ? getCharacterMatch(scores) : null
  const mbtiMatch = scores ? getMBTIMatch(scores) : null
  const localAnalyses = scores ? getFactorAnalyses(scores) : []
  const overallText = scores ? getOverallAnalysis(scores, i18n.language === 'ko') : ''

  useEffect(() => {
    if (!scores) {
      setIsLoading(false)
      return
    }

    let cancelled = false
    setIsLoading(true)

    // 로딩 애니메이션 후 매칭 결과 표시
    const timer = setTimeout(() => {
      if (cancelled) return
      try {
        setTopMatches(findTopMatches(scores, 5))
      } catch (e) {
        console.error('Failed to find matches:', e)
      }
      setIsLoading(false)
    }, 4000)

    return () => { cancelled = true; clearTimeout(timer) }
  }, [scores])

  // AI 분석 (백그라운드에서 로드)
  useEffect(() => {
    if (!scores || isLoading) return
    let cancelled = false
    setAiLoading(true)

    fetch('/api/analyze', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ scores, language: i18n.language }),
    })
      .then(res => res.ok ? res.json() : Promise.reject(new Error(`API ${res.status}`)))
      .then(data => { if (!cancelled) setAiAnalysis(data) })
      .catch(err => console.error('AI analysis failed:', err))
      .finally(() => { if (!cancelled) setAiLoading(false) })

    return () => { cancelled = true }
  }, [scores, isLoading, i18n.language])

  const chartData = scores
    ? factors.map(factor => ({ factor, value: scores[factor], fullMark: 100 }))
    : []

  const isKo = i18n.language === 'ko'

  // Build summary text (matching mobile's _summaryText)
  const getSummaryText = (): string => {
    if (!scores || !personalityTitle || !mainMeme || !mbtiMatch) return ''
    const topName = match?.persona.name[isKo ? 'ko' : 'en'] ?? ''
    const topSim = match?.similarity ?? 0

    return isKo
      ? `${personalityTitle.emoji} ${personalityTitle.titleKo}\n` +
        `${mainMeme.emoji} ${mainMeme.quoteKo}\n\n` +
        `🔮 MBTI 추정: ${mbtiMatch.mbti}\n` +
        `👤 닮은 유명인: ${topName} (${topSim}%)\n\n` +
        `나도 테스트하기 👉 hexacotest.vercel.app`
      : `${personalityTitle.emoji} ${personalityTitle.titleEn}\n` +
        `${mainMeme.emoji} ${mainMeme.quoteEn}\n\n` +
        `🔮 MBTI guess: ${mbtiMatch.mbti}\n` +
        `👤 Similar to: ${topName} (${topSim}%)\n\n` +
        `Try the test 👉 hexacotest.vercel.app`
  }

  const copySummary = async () => {
    const text = getSummaryText()
    if (!text) return
    await navigator.clipboard.writeText(text)
    setSummaryCopied(true)
    setTimeout(() => setSummaryCopied(false), 2000)
  }

  const copyLink = async () => {
    await navigator.clipboard.writeText(window.location.href)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  const shareTwitter = () => {
    const text = isKo
      ? `나의 HEXACO 성격 테스트 결과! ${personalityTitle?.emoji} ${personalityTitle?.titleKo} - ${match?.persona.name.ko}와(과) ${match?.similarity}% 유사합니다.`
      : `My HEXACO Personality Test Results! ${personalityTitle?.emoji} ${personalityTitle?.titleEn} - ${match?.similarity}% similar to ${match?.persona.name.en}.`
    const url = encodeURIComponent(window.location.href)
    window.open(`https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}&url=${url}`, '_blank')
  }

  const openShareModal = (mode: 'download' | 'share') => {
    setShareMode(mode)
    setSelectedFactors(new Set())
    setShowShareModal(true)
  }

  const toggleFactor = (f: string) => {
    setSelectedFactors(prev => {
      const next = new Set(prev)
      if (next.has(f)) next.delete(f)
      else next.add(f)
      return next
    })
  }

  const toggleAllFactors = () => {
    if (selectedFactors.size === factors.length) {
      setSelectedFactors(new Set())
    } else {
      setSelectedFactors(new Set(factors))
    }
  }

  const captureShareCard = useCallback(async () => {
    setShowShareModal(false)
    setIsCapturing(true)

    // Wait for share card to render
    await new Promise(r => setTimeout(r, 300))

    if (!shareCardRef.current) {
      setIsCapturing(false)
      return
    }

    try {
      const canvas = await html2canvas(shareCardRef.current, {
        backgroundColor: null,
        scale: 3,
        useCORS: true,
        logging: false,
      })

      if (shareMode === 'share' && navigator.share && navigator.canShare?.()) {
        canvas.toBlob(async (blob) => {
          if (!blob) { setIsCapturing(false); return }
          const file = new File([blob], 'hexaco-result.png', { type: 'image/png' })
          try {
            await navigator.share({
              title: 'HEXACO Personality Test',
              text: getSummaryText(),
              files: [file],
            })
          } catch {
            // User cancelled or share failed - download instead
            const link = document.createElement('a')
            link.download = 'hexaco-result.png'
            link.href = canvas.toDataURL()
            link.click()
          }
          setIsCapturing(false)
        }, 'image/png')
      } else {
        const link = document.createElement('a')
        link.download = 'hexaco-result.png'
        link.href = canvas.toDataURL()
        link.click()
        setIsCapturing(false)
      }
    } catch (error) {
      console.error('Failed to capture share card:', error)
      setIsCapturing(false)
    }
  }, [shareMode, selectedFactors, scores, isKo])

  if (isLoading) return <LoadingScreen language={i18n.language} />

  if (!scores) {
    return (
      <div className="min-h-screen pt-24 flex flex-col items-center justify-center text-center px-4">
        <h2 className="text-2xl font-bold text-white mb-4">
          {isKo ? '결과를 찾을 수 없습니다' : 'Results not found'}
        </h2>
        <p className="text-gray-400 mb-8">
          {isKo ? '테스트를 먼저 완료해주세요' : 'Please complete the test first'}
        </p>
        <Link to="/test" className="btn-primary">{t('common.start')}</Link>
      </div>
    )
  }

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
              {isKo ? '100가지 유형 중 가장 가까운 유형을 추천합니다.' : 'We recommend the closest match among 100 types.'}
            </p>
          </motion.div>

          {/* Personality Title Card */}
          {personalityTitle && (
            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: 0.1 }}
              className="relative overflow-hidden rounded-2xl border border-purple-500/40 p-6 text-center"
              style={{
                background: 'linear-gradient(135deg, rgba(139, 92, 246, 0.2) 0%, rgba(236, 72, 153, 0.2) 100%)',
              }}
            >
              <div className="text-5xl mb-3">{personalityTitle.emoji}</div>
              <h2 className="text-2xl md:text-3xl font-bold text-white mb-2">
                {isKo ? personalityTitle.titleKo : personalityTitle.titleEn}
              </h2>
              <p className="text-gray-400">
                {isKo ? personalityTitle.descriptionKo : personalityTitle.descriptionEn}
              </p>
              {/* Main meme quote */}
              {mainMeme && (
                <div className="mt-4 inline-flex items-center gap-2 px-4 py-2 rounded-full bg-dark-bg/50 border border-dark-border">
                  <span className="text-lg">{mainMeme.emoji}</span>
                  <span className="text-sm text-gray-300 italic">
                    "{isKo ? mainMeme.quoteKo : mainMeme.quoteEn}"
                  </span>
                </div>
              )}
            </motion.div>
          )}

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
                <div className="w-16 h-16 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center flex-shrink-0">
                  <span className="text-2xl font-bold text-white">
                    {match.persona.name[isKo ? 'ko' : 'en'][0]}
                  </span>
                </div>
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
                  <PolarAngleAxis dataKey="factor" tick={{ fill: '#9ca3af', fontSize: 14 }} />
                  <PolarRadiusAxis angle={30} domain={[0, 100]} tick={{ fill: '#6b7280', fontSize: 10 }} />
                  <Radar name="Score" dataKey="value" stroke="#8B5CF6" fill="#8B5CF6" fillOpacity={0.4} strokeWidth={2} />
                </RadarChart>
              </ResponsiveContainer>
            </div>
          </motion.div>

          {/* Factor Scores Grid (matching mobile) */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.35 }}
          >
            <h3 className="text-lg font-bold text-white mb-3">
              {isKo ? '요인 점수' : 'Factor Scores'}
            </h3>
            <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
              {factors.map((factor) => {
                const value = scores[factor]
                const color = factorColors[factor]
                return (
                  <div
                    key={factor}
                    className="rounded-xl border border-dark-border p-4"
                    style={{ background: `linear-gradient(135deg, ${color}08 0%, transparent 60%)` }}
                  >
                    <div className="flex items-center gap-2 mb-2">
                      <span className="text-lg font-bold" style={{ color }}>{factor}</span>
                      <span className="text-xs text-gray-400 truncate">
                        {isKo ? factorNamesKo[factor] : factorNamesEn[factor]}
                      </span>
                    </div>
                    <div className="text-xl font-bold text-white mb-2">{value.toFixed(1)}%</div>
                    <div className="h-1.5 bg-dark-bg rounded-full overflow-hidden">
                      <motion.div
                        initial={{ width: 0 }}
                        animate={{ width: `${value}%` }}
                        transition={{ delay: 0.5, duration: 0.8 }}
                        className="h-full rounded-full"
                        style={{ backgroundColor: color }}
                      />
                    </div>
                  </div>
                )
              })}
            </div>
          </motion.div>

          {/* Factor Analysis Flip Cards */}
          <div>
            <div className="flex items-center gap-3 mb-4">
              <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center">
                <Sparkles className="w-4 h-4 text-white" />
              </div>
              <h3 className="text-lg font-bold text-white">
                {isKo ? '성격 분석' : 'Personality Analysis'}
              </h3>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {localAnalyses.map((item, index) => (
                <FlipCard
                  key={item.factor}
                  analysis={item}
                  isKo={isKo}
                  delay={0.4 + index * 0.1}
                />
              ))}
            </div>
          </div>

          {/* Overall Analysis */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.8 }}
            className="card"
          >
            <div className="flex items-center gap-2 mb-4">
              <span className="text-xl">🌟</span>
              <h3 className="font-bold text-white">
                {isKo ? '종합 분석' : 'Overall Analysis'}
              </h3>
            </div>
            <p className="text-sm text-gray-300 leading-relaxed whitespace-pre-line">
              {overallText}
            </p>
          </motion.div>

          {/* AI Analysis Report */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.9 }}
            className="card"
          >
            <div className="flex items-center gap-3 mb-4">
              <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-blue-500 to-cyan-500 flex items-center justify-center">
                <Brain className="w-4 h-4 text-white" />
              </div>
              <h3 className="text-lg font-bold text-white">
                {isKo ? 'AI 심리 분석 리포트' : 'AI Psychology Report'}
              </h3>
            </div>

            {aiLoading && (
              <div className="flex items-center gap-3 py-8 justify-center">
                <motion.div
                  className="w-5 h-5 border-2 border-blue-500 border-t-transparent rounded-full"
                  animate={{ rotate: 360 }}
                  transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
                />
                <span className="text-gray-400 text-sm">
                  {isKo ? 'AI가 당신의 성격을 깊이 분석하고 있어요...' : 'AI is deeply analyzing your personality...'}
                </span>
              </div>
            )}

            {!aiLoading && !aiAnalysis && (
              <p className="text-gray-500 text-sm text-center py-4">
                {isKo ? 'AI 분석을 불러올 수 없었습니다.' : 'Could not load AI analysis.'}
              </p>
            )}

            {aiAnalysis && (
              <div className="space-y-4">
                <p className="text-sm text-gray-300 leading-relaxed whitespace-pre-line">
                  {aiAnalysis.summary}
                </p>

                {aiAnalysis.factors.length > 0 && (
                  <div className="space-y-3 mt-4">
                    {aiAnalysis.factors.map((af) => {
                      const color = factorColors[af.factor as keyof typeof factorColors] ?? '#8B5CF6'
                      return (
                        <details
                          key={af.factor}
                          className="rounded-xl border border-dark-border overflow-hidden group"
                          style={{ background: `linear-gradient(135deg, ${color}08 0%, transparent 60%)` }}
                        >
                          <summary className="flex items-center gap-2 p-4 cursor-pointer list-none">
                            <span className="text-sm font-bold" style={{ color }}>{af.factor}</span>
                            <span className="text-xs text-gray-400">
                              {isKo ? (factorNamesKo[af.factor as Factor] ?? af.factor) : (factorNamesEn[af.factor as Factor] ?? af.factor)}
                            </span>
                            <svg className="w-4 h-4 text-gray-500 ml-auto transition-transform group-open:rotate-180" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                            </svg>
                          </summary>
                          <div className="px-4 pb-4 space-y-3">
                            <p className="text-sm text-gray-300 leading-relaxed">{af.overview}</p>
                            <div>
                              <p className="text-xs font-medium text-emerald-400 mb-1">{isKo ? '강점' : 'Strengths'}</p>
                              <ul className="space-y-1">
                                {af.strengths.map((s, i) => (
                                  <li key={i} className="text-xs text-gray-400 flex items-start gap-1.5">
                                    <span className="text-emerald-400 mt-0.5">+</span>{s}
                                  </li>
                                ))}
                              </ul>
                            </div>
                            <div>
                              <p className="text-xs font-medium text-amber-400 mb-1">{isKo ? '성장 포인트' : 'Growth Areas'}</p>
                              <ul className="space-y-1">
                                {af.risks.map((r, i) => (
                                  <li key={i} className="text-xs text-gray-400 flex items-start gap-1.5">
                                    <span className="text-amber-400 mt-0.5">~</span>{r}
                                  </li>
                                ))}
                              </ul>
                            </div>
                            <div className="rounded-lg bg-blue-500/10 border border-blue-500/20 p-3">
                              <p className="text-xs text-blue-300 leading-relaxed">{af.growth}</p>
                            </div>
                          </div>
                        </details>
                      )
                    })}
                  </div>
                )}
              </div>
            )}
          </motion.div>

          {/* Meme Quotes Grid */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.5 }}
            className="card"
          >
            <h3 className="text-lg font-bold text-white mb-4">
              {isKo ? '나를 한마디로' : 'In a Nutshell'}
            </h3>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              {memeQuotes.map((quote) => {
                const color = factorColors[quote.factor as keyof typeof factorColors]
                return (
                  <div
                    key={quote.factor}
                    className="rounded-xl p-4 border border-dark-border"
                    style={{ background: `linear-gradient(135deg, ${color}10 0%, transparent 60%)` }}
                  >
                    <div className="flex items-center gap-2 mb-2">
                      <span
                        className="text-xs font-bold px-2 py-0.5 rounded-full"
                        style={{ backgroundColor: `${color}30`, color }}
                      >
                        {quote.factor}
                      </span>
                      <span className="text-lg">{quote.emoji}</span>
                    </div>
                    <p className="text-sm text-gray-300">
                      {isKo ? quote.quoteKo : quote.quoteEn}
                    </p>
                  </div>
                )
              })}
            </div>
          </motion.div>

          {/* Character Match + MBTI */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {/* Character Match */}
            {characterMatch && (
              <motion.div
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: 0.6 }}
                className="card"
              >
                <h3 className="text-sm font-bold text-gray-400 mb-3">
                  {isKo ? '닮은 캐릭터' : 'Similar Character'}
                </h3>
                <div className="text-center">
                  <div className="text-4xl mb-2">{characterMatch.emoji}</div>
                  <h4 className="text-lg font-bold text-white mb-1">
                    {isKo ? characterMatch.nameKo : characterMatch.nameEn}
                  </h4>
                  <span className="text-xs text-purple-400 bg-purple-500/10 px-2 py-0.5 rounded-full">
                    {characterMatch.source}
                  </span>
                  <p className="text-sm text-gray-400 mt-3">
                    {isKo ? characterMatch.reasonKo : characterMatch.reasonEn}
                  </p>
                </div>
              </motion.div>
            )}

            {/* MBTI Estimation */}
            {mbtiMatch && (
              <motion.div
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: 0.7 }}
                className="card"
              >
                <h3 className="text-sm font-bold text-gray-400 mb-3">
                  {isKo ? 'MBTI 추정' : 'MBTI Estimate'}
                </h3>
                <div className="text-center">
                  <div className="text-4xl mb-2">🔮</div>
                  <h4 className="text-3xl font-bold text-white mb-1 tracking-wider">
                    {mbtiMatch.mbti}
                  </h4>
                  <p className="text-sm text-gray-400 mt-2">
                    {isKo ? mbtiMatch.descriptionKo : mbtiMatch.descriptionEn}
                  </p>
                  <p className="text-xs text-gray-500 mt-3">
                    {isKo
                      ? '※ HEXACO 기반 추정이며 실제 MBTI와 다를 수 있습니다'
                      : '※ Estimated from HEXACO, may differ from actual MBTI'}
                  </p>
                </div>
              </motion.div>
            )}
          </div>

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
              <p className="text-gray-400 text-sm mb-4">{t('result.matchDescription')}</p>
              <div className="space-y-3">
                {topMatches.map((item, index) => (
                  <MatchCard key={item.persona.id} match={item} rank={index + 1} language={i18n.language} />
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
              <span className="text-sm font-medium text-gray-400">{isKo ? '법적 고지' : 'Legal Notice'}</span>
            </div>
            <ul className="text-xs text-gray-500 space-y-1.5">
              <li className="flex items-start gap-2">
                <AlertTriangle className="w-3 h-3 mt-0.5 flex-shrink-0" />
                <span>{isKo ? '본 테스트는 비공식이며 HEXACO-PI-R과 무관합니다.' : 'Unofficial test, not affiliated with HEXACO-PI-R.'}</span>
              </li>
              <li className="flex items-start gap-2">
                <AlertTriangle className="w-3 h-3 mt-0.5 flex-shrink-0" />
                <span>{isKo ? '결과는 오락 및 자기이해 목적이며 전문 심리 진단을 대체하지 않습니다.' : 'For entertainment/self-understanding only, not professional diagnosis.'}</span>
              </li>
              <li className="flex items-start gap-2">
                <AlertTriangle className="w-3 h-3 mt-0.5 flex-shrink-0" />
                <span>{isKo ? '테스트 결과는 기기에만 저장되며 수집하지 않습니다.' : 'Results are stored locally and not collected.'}</span>
              </li>
            </ul>
          </motion.div>
        </div>

        {/* Share & Action Buttons */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1 }}
          className="mt-6 space-y-4"
        >
          <div className="flex flex-wrap justify-center gap-3">
            <button onClick={copySummary} className="btn-secondary flex items-center gap-2">
              {summaryCopied ? <Check className="w-4 h-4 text-green-500" /> : <Copy className="w-4 h-4" />}
              {summaryCopied
                ? (isKo ? '복사됨!' : 'Copied!')
                : (isKo ? '결과 복사' : 'Copy Result')}
            </button>
            <button onClick={copyLink} className="btn-secondary flex items-center gap-2">
              {copied ? <Check className="w-4 h-4 text-green-500" /> : <Link2 className="w-4 h-4" />}
              {copied ? t('common.copied') : t('common.copyLink')}
            </button>
            <button onClick={shareTwitter} className="btn-secondary flex items-center gap-2">
              <Twitter className="w-4 h-4" />
              Twitter
            </button>
            <button onClick={() => openShareModal('download')} className="btn-secondary flex items-center gap-2">
              <Download className="w-4 h-4" />
              {isKo ? '이미지 저장' : 'Save Image'}
            </button>
            <button onClick={() => openShareModal('share')} className="btn-secondary flex items-center gap-2">
              <Image className="w-4 h-4" />
              {isKo ? '이미지 공유' : 'Share Image'}
            </button>
          </div>

          {/* Coffee / Donate Button */}
          <div className="flex justify-center">
            <a
              href="https://paypal.me/u2dia"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2 px-6 py-3 rounded-xl text-sm font-medium transition-all hover:scale-105"
              style={{
                background: 'linear-gradient(135deg, rgba(245, 158, 11, 0.15) 0%, rgba(251, 191, 36, 0.15) 100%)',
                border: '1px solid rgba(245, 158, 11, 0.3)',
                color: '#FBBF24',
              }}
            >
              <Coffee className="w-4 h-4" />
              {isKo ? '개발자에게 커피 사주기' : 'Buy me a coffee'}
              <ExternalLink className="w-3 h-3 opacity-60" />
            </a>
          </div>

          {/* Action Buttons */}
          <div className="flex justify-center gap-4">
            <Link to="/test" onClick={() => reset()} className="btn-primary flex items-center gap-2">
              <RotateCcw className="w-4 h-4" />
              {t('common.retry')}
            </Link>
            <Link to="/" className="btn-secondary flex items-center gap-2">
              <Home className="w-4 h-4" />
              {t('common.home')}
            </Link>
          </div>
        </motion.div>
      </div>

      {/* Share Selection Modal */}
      <AnimatePresence>
        {showShareModal && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-50 flex items-center justify-center p-4"
            onClick={() => setShowShareModal(false)}
          >
            <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" />
            <motion.div
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.9, opacity: 0 }}
              onClick={e => e.stopPropagation()}
              className="relative w-full max-w-md rounded-2xl p-5"
              style={{
                background: '#1A1035',
                border: '1px solid rgba(139, 92, 246, 0.5)',
              }}
            >
              <div className="flex items-center justify-between mb-1">
                <div className="flex items-center gap-2">
                  <Share2 className="w-5 h-5 text-purple-400" />
                  <h3 className="text-white font-bold text-lg">
                    {isKo ? '이미지 공유' : 'Share Image'}
                  </h3>
                </div>
                <div className="flex items-center gap-2">
                  <button
                    onClick={toggleAllFactors}
                    className="text-purple-400 text-sm hover:text-purple-300 transition-colors"
                  >
                    {selectedFactors.size === factors.length
                      ? (isKo ? '전체 해제' : 'Deselect All')
                      : (isKo ? '전체 선택' : 'Select All')}
                  </button>
                  <button onClick={() => setShowShareModal(false)} className="text-gray-400 hover:text-white">
                    <X className="w-5 h-5" />
                  </button>
                </div>
              </div>
              <p className="text-gray-400 text-sm mb-4">
                {isKo ? '포함할 성격 분석 카드를 선택하세요' : 'Select personality cards to include'}
              </p>

              <div className="space-y-2">
                {localAnalyses.map(a => {
                  const color = factorColors[a.factor] || '#8B5CF6'
                  const isSelected = selectedFactors.has(a.factor)
                  return (
                    <button
                      key={a.factor}
                      onClick={() => toggleFactor(a.factor)}
                      className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl transition-all"
                      style={{
                        background: isSelected ? `${color}22` : 'rgba(30, 20, 50, 0.8)',
                        border: `1px solid ${isSelected ? `${color}99` : 'rgba(60, 50, 80, 0.5)'}`,
                      }}
                    >
                      <span
                        className="w-7 h-7 rounded-lg flex items-center justify-center text-xs font-bold"
                        style={{
                          background: isSelected ? color : `${color}44`,
                          color: isSelected ? '#fff' : color,
                        }}
                      >
                        {a.factor}
                      </span>
                      <div className="flex-1 text-left">
                        <span className="text-sm font-semibold" style={{ color: isSelected ? '#fff' : '#D1D5DB' }}>
                          {isKo ? a.nameKo : a.nameEn} {a.emoji}
                        </span>
                        <p className="text-xs truncate" style={{ color: '#6B7280' }}>
                          {Math.round(a.score)}% — {isKo ? a.summaryKo : a.summaryEn}
                        </p>
                      </div>
                      {isSelected
                        ? <CheckCircle className="w-5 h-5 flex-shrink-0" style={{ color }} />
                        : <Circle className="w-5 h-5 flex-shrink-0 text-gray-600" />
                      }
                    </button>
                  )
                })}
              </div>

              <div className="flex gap-3 mt-5">
                <button
                  onClick={() => setShowShareModal(false)}
                  className="flex-1 py-2.5 rounded-xl text-gray-400 text-sm hover:bg-white/5 transition-colors"
                >
                  {isKo ? '취소' : 'Cancel'}
                </button>
                <button
                  onClick={captureShareCard}
                  className="flex-[2] py-2.5 rounded-xl text-white text-sm font-medium flex items-center justify-center gap-2 transition-all hover:brightness-110"
                  style={{ background: '#8B5CF6' }}
                >
                  {shareMode === 'download' ? <Download className="w-4 h-4" /> : <Image className="w-4 h-4" />}
                  {selectedFactors.size === 0
                    ? (isKo ? '기본 이미지 저장' : 'Save Basic Image')
                    : (isKo
                      ? `${selectedFactors.size}개 카드 포함 ${shareMode === 'download' ? '저장' : '공유'}`
                      : `${shareMode === 'download' ? 'Save' : 'Share'} with ${selectedFactors.size} cards`)}
                </button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Capturing indicator */}
      {isCapturing && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40">
          <div className="animate-spin w-10 h-10 border-4 border-purple-500 border-t-transparent rounded-full" />
        </div>
      )}

      {/* Hidden Share Card (rendered offscreen for html2canvas capture) */}
      <div style={{ position: 'fixed', left: '-9999px', top: 0 }}>
        <div
          ref={shareCardRef}
          style={{
            width: 350,
            padding: 20,
            background: 'linear-gradient(135deg, #1A1035, #2D1B4E)',
            borderRadius: 24,
            border: '1px solid rgba(139, 92, 246, 0.5)',
            fontFamily: "'Pretendard', -apple-system, BlinkMacSystemFont, sans-serif",
            color: '#fff',
          }}
        >
          {/* HEXACO Logo */}
          <div style={{ textAlign: 'center', marginBottom: 16 }}>
            <span style={{ fontSize: 14, fontWeight: 700, color: '#fff', letterSpacing: 2 }}>
              ⬡ HEXACO
            </span>
          </div>

          {/* Main Title */}
          <div style={{
            background: 'linear-gradient(90deg, #8B5CF6, #EC4899)',
            borderRadius: 16, padding: '10px 16px',
            textAlign: 'center', marginBottom: 12,
          }}>
            <span style={{ fontSize: 24 }}>{personalityTitle?.emoji} </span>
            <span style={{ fontWeight: 700, fontSize: 16 }}>
              {isKo ? personalityTitle?.titleKo : personalityTitle?.titleEn}
            </span>
          </div>

          {/* Main Meme Quote */}
          <div style={{
            background: 'rgba(30, 20, 50, 0.7)',
            border: '1px solid rgba(139, 92, 246, 0.3)',
            borderRadius: 12, padding: '10px 14px',
            textAlign: 'center', marginBottom: 16,
          }}>
            <span style={{ fontSize: 18 }}>{mainMeme?.emoji} </span>
            <span style={{ color: '#D1D5DB', fontStyle: 'italic', fontSize: 13 }}>
              {isKo ? mainMeme?.quoteKo : mainMeme?.quoteEn}
            </span>
          </div>

          {/* MBTI + Character */}
          <div style={{ display: 'flex', gap: 10, marginBottom: 16 }}>
            <div style={{
              flex: 1, background: 'rgba(30, 20, 50, 0.5)',
              borderRadius: 12, padding: 12, textAlign: 'center',
            }}>
              <div style={{ fontSize: 20 }}>🔮</div>
              <div style={{ color: '#EC4899', fontWeight: 700, fontSize: 16, marginTop: 4 }}>
                {mbtiMatch?.mbti}
              </div>
              <div style={{ color: '#9CA3AF', fontSize: 10 }}>
                {isKo ? mbtiMatch?.descriptionKo : mbtiMatch?.descriptionEn}
              </div>
            </div>
            <div style={{
              flex: 1, background: 'rgba(30, 20, 50, 0.5)',
              borderRadius: 12, padding: 12, textAlign: 'center',
            }}>
              <div style={{ fontSize: 20 }}>{characterMatch?.emoji}</div>
              <div style={{ color: '#A78BFA', fontWeight: 700, fontSize: 13, marginTop: 4 }}>
                {isKo ? characterMatch?.nameKo : characterMatch?.nameEn}
              </div>
              <div style={{ color: '#6B7280', fontSize: 10 }}>
                {characterMatch?.source}
              </div>
            </div>
          </div>

          {/* Celebrity Match */}
          {match && (
            <div style={{
              background: 'linear-gradient(90deg, rgba(139,92,246,0.2), rgba(236,72,153,0.2))',
              borderRadius: 12, padding: 12, display: 'flex', alignItems: 'center', gap: 12,
              marginBottom: 14,
            }}>
              <div style={{
                width: 44, height: 44, borderRadius: '50%',
                background: 'linear-gradient(135deg, #8B5CF6, #EC4899)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontSize: 18, fontWeight: 700, flexShrink: 0,
              }}>
                {(isKo ? match.persona.name.ko : match.persona.name.en).charAt(0)}
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ color: '#9CA3AF', fontSize: 10 }}>
                  {isKo ? '닮은 유명인' : 'Similar Celebrity'}
                </div>
                <div style={{ fontWeight: 700, fontSize: 14 }}>
                  {isKo ? match.persona.name.ko : match.persona.name.en}
                </div>
              </div>
              <div style={{
                background: '#8B5CF6', borderRadius: 12,
                padding: '4px 10px', fontWeight: 700, fontSize: 12,
              }}>
                {match.similarity}%
              </div>
            </div>
          )}

          {/* Selected Factor Details (3-column grid) */}
          {selectedFactors.size > 0 && (
            <>
              <div style={{ textAlign: 'center', color: '#9CA3AF', fontSize: 11, fontWeight: 600, marginBottom: 6 }}>
                {isKo ? '성격 분석 상세' : 'Personality Details'}
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 6 }}>
                {localAnalyses
                  .filter(a => selectedFactors.has(a.factor))
                  .map(a => {
                    const color = factorColors[a.factor] || '#8B5CF6'
                    return (
                      <div key={a.factor} style={{
                        background: `linear-gradient(135deg, #1E1432, ${color}26)`,
                        border: `1px solid ${color}66`,
                        borderRadius: 10, padding: 8, textAlign: 'center',
                      }}>
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 4 }}>
                          <span style={{
                            width: 20, height: 20, borderRadius: 5,
                            background: color, display: 'inline-flex',
                            alignItems: 'center', justifyContent: 'center',
                            fontSize: 10, fontWeight: 700,
                          }}>
                            {a.factor}
                          </span>
                          <span style={{ color, fontWeight: 700, fontSize: 12 }}>
                            {Math.round(a.score)}%
                          </span>
                        </div>
                        <div style={{
                          color: `${color}ee`, fontWeight: 600, fontSize: 9,
                          whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis',
                          marginBottom: 4,
                        }}>
                          {isKo ? a.nameKo : a.nameEn} {a.emoji}
                        </div>
                        <div style={{
                          height: 4, borderRadius: 3, overflow: 'hidden',
                          background: `${color}26`,
                        }}>
                          <div style={{
                            width: `${Math.round(a.score)}%`, height: '100%',
                            background: color, borderRadius: 3,
                          }} />
                        </div>
                      </div>
                    )
                  })
                }
              </div>
            </>
          )}

          {/* AI Psychology Report */}
          {aiAnalysis && selectedFactors.size > 0 && (
            <>
              <div style={{ textAlign: 'center', marginTop: 10, marginBottom: 6, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 4 }}>
                <span style={{ fontSize: 12 }}>🧠</span>
                <span style={{ color: '#A78BFA', fontWeight: 700, fontSize: 11 }}>
                  {isKo ? 'AI 심리분석' : 'AI Psychology Report'}
                </span>
              </div>

              {/* AI Summary */}
              <div style={{
                background: 'rgba(30, 20, 50, 0.6)',
                border: '1px solid rgba(139, 92, 246, 0.2)',
                borderRadius: 10, padding: 10, marginBottom: 8,
              }}>
                <p style={{ color: '#D1D5DB', fontSize: 9, lineHeight: 1.4, margin: 0 }}>
                  {aiAnalysis.summary}
                </p>
              </div>

              {/* Per-factor AI analysis */}
              {aiAnalysis.factors
                .filter(af => selectedFactors.has(af.factor))
                .map(af => {
                  const color = factorColors[af.factor as keyof typeof factorColors] || '#8B5CF6'
                  const factorName = isKo
                    ? ({ H: '정직-겸손', E: '정서성', X: '외향성', A: '원만성', C: '성실성', O: '개방성' }[af.factor] ?? af.factor)
                    : ({ H: 'Honesty-Humility', E: 'Emotionality', X: 'Extraversion', A: 'Agreeableness', C: 'Conscientiousness', O: 'Openness' }[af.factor] ?? af.factor)
                  return (
                    <div key={af.factor} style={{
                      background: `linear-gradient(135deg, #1E1432, ${color}1a)`,
                      border: `1px solid ${color}4d`,
                      borderRadius: 10, padding: 10, marginBottom: 6,
                    }}>
                      {/* Factor header */}
                      <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 6 }}>
                        <span style={{
                          width: 18, height: 18, borderRadius: 4,
                          background: color, display: 'inline-flex',
                          alignItems: 'center', justifyContent: 'center',
                          fontSize: 9, fontWeight: 700,
                        }}>{af.factor}</span>
                        <span style={{ color, fontWeight: 600, fontSize: 10 }}>{factorName}</span>
                      </div>
                      {/* Overview */}
                      <p style={{ color: '#D1D5DB', fontSize: 8, lineHeight: 1.3, margin: '0 0 6px 0' }}>
                        {af.overview}
                      </p>
                      {/* Strengths */}
                      {af.strengths.map((s, i) => (
                        <div key={`s${i}`} style={{ display: 'flex', gap: 4, marginBottom: 2 }}>
                          <span style={{ color: '#4ADE80', fontSize: 8, fontWeight: 700, flexShrink: 0 }}>+</span>
                          <span style={{ color: '#9CA3AF', fontSize: 8, lineHeight: 1.3 }}>{s}</span>
                        </div>
                      ))}
                      <div style={{ height: 4 }} />
                      {/* Risks */}
                      {af.risks.map((r, i) => (
                        <div key={`r${i}`} style={{ display: 'flex', gap: 4, marginBottom: 2 }}>
                          <span style={{ color: '#FBBF24', fontSize: 8, fontWeight: 700, flexShrink: 0 }}>~</span>
                          <span style={{ color: '#9CA3AF', fontSize: 8, lineHeight: 1.3 }}>{r}</span>
                        </div>
                      ))}
                      <div style={{ height: 4 }} />
                      {/* Growth */}
                      <div style={{ display: 'flex', gap: 4 }}>
                        <span style={{ fontSize: 8, flexShrink: 0 }}>💡</span>
                        <span style={{ color: '#A78BFA', fontSize: 8, lineHeight: 1.3 }}>{af.growth}</span>
                      </div>
                    </div>
                  )
                })
              }
            </>
          )}

          {/* Footer */}
          <div style={{
            textAlign: 'center', marginTop: 6,
            background: 'rgba(30, 20, 50, 0.5)',
            borderRadius: 8, padding: '6px 12px',
          }}>
            <span style={{ color: '#6B7280', fontSize: 12 }}>hexacotest.vercel.app</span>
          </div>
        </div>
      </div>
    </div>
  )
}
