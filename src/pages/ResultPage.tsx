import { useEffect, useState, useRef } from 'react'
import { Link, useSearchParams } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { motion } from 'framer-motion'
import {
  Radar, RadarChart, PolarGrid, PolarAngleAxis,
  PolarRadiusAxis, ResponsiveContainer
} from 'recharts'
import { Download, Link2, RotateCcw, Home, Check, Twitter, AlertTriangle } from 'lucide-react'
import html2canvas from 'html2canvas'
import { decodeResults, useTestStore } from '../stores/testStore'
import { factorColors, factors, Factor } from '../data/questions'
import { findTopMatches, MatchResult } from '../utils/matching'
import { categoryColors } from '../data/personas'
import LoadingSpinner from '../components/common/LoadingSpinner'
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

  // URL에서 결과 가져오기 또는 스토어에서 가져오기
  const encodedResult = searchParams.get('r')
  const scores = encodedResult ? decodeResults(encodedResult) : storeScores
  const match = topMatches[0]
  const analysisFactors = analysis
    ? factors
        .map(factor => analysis.factors.find(item => item.factor === factor))
        .filter((item): item is AnalysisFactor => Boolean(item))
    : []

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
      setTimeout(resolve, 1500)
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
          ? 'LLM 분석을 불러오지 못했습니다. 잠시 후 다시 시도해주세요.'
          : 'Failed to load LLM analysis. Please try again later.')
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

  const formatPercent = (value: number) => `${value.toFixed(1)}%`

  const toSafeUrl = (url: string) => encodeURI(url)

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
    return (
      <div className="min-h-screen flex flex-col items-center justify-center">
        <LoadingSpinner />
        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.5 }}
          className="text-gray-400 mt-4"
        >
          {t('result.analyzing')}
        </motion.p>
      </div>
    )
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

  return (
    <div className="min-h-screen pt-24 pb-12 px-4">
      <div className="max-w-4xl mx-auto">
        {/* Result Card for Screenshot */}
        <div ref={resultRef} className="space-y-8 p-4">
          {/* Title */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-center"
          >
            <h1 className="text-3xl md:text-4xl font-bold gradient-text mb-2">
              {t('result.title')}
            </h1>
          </motion.div>

          {/* Radar Chart */}
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.2 }}
            className="card"
          >
            <div className="h-80 md:h-96">
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

          {/* Factor Scores */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.4 }}
            className="grid grid-cols-2 md:grid-cols-3 gap-4"
          >
            {factors.map((factor, index) => (
              <motion.div
                key={factor}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.4 + index * 0.1 }}
                className="card p-4"
              >
                <div className="flex items-center gap-2 mb-2">
                  <span
                    className="text-2xl font-bold"
                    style={{ color: factorColors[factor] }}
                  >
                    {factor}
                  </span>
                  <span className="text-gray-400 text-sm">
                    {t(`landing.hexaco.factors.${factor}.name`)}
                  </span>
                </div>
                <div className="flex items-end gap-2">
                  <span className="text-3xl font-bold text-white">
                    {formatPercent(scores[factor])}
                  </span>
                </div>
                <div className="mt-2 h-2 bg-dark-bg rounded-full overflow-hidden">
                  <motion.div
                    initial={{ width: 0 }}
                    animate={{ width: `${scores[factor]}%` }}
                    transition={{ delay: 0.6 + index * 0.1, duration: 0.8 }}
                    className="h-full rounded-full"
                    style={{ backgroundColor: factorColors[factor] }}
                  />
                </div>
              </motion.div>
            ))}
          </motion.div>

          {/* LLM Analysis */}
          {analysis && (
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.6 }}
              className="card"
            >
              <h2 className="text-xl font-bold text-white mb-2">
                {i18n.language === 'ko' ? 'LLM 성격 분석' : 'LLM Personality Analysis'}
              </h2>
              <p className="text-gray-400 text-sm mb-6">
                {analysis.summary}
              </p>
              <div className="space-y-4">
                {analysisFactors.map(item => (
                  <div key={item.factor} className="rounded-lg bg-dark-bg/40 p-4">
                    <div className="flex items-center gap-2 mb-2">
                      <span
                        className="text-lg font-bold"
                        style={{ color: factorColors[item.factor] }}
                      >
                        {item.factor}
                      </span>
                      <span className="text-sm text-gray-400">
                        {t(`landing.hexaco.factors.${item.factor}.name`)}
                      </span>
                    </div>
                    <p className="text-sm text-gray-400">{item.overview}</p>
                    <div className="mt-3 grid grid-cols-1 md:grid-cols-2 gap-3 text-xs text-gray-500">
                      <div>
                        <p className="text-gray-400 font-medium mb-1">
                          {i18n.language === 'ko' ? '강점' : 'Strengths'}
                        </p>
                        <ul className="list-disc list-inside space-y-1">
                          {item.strengths?.map((strength, index) => (
                            <li key={`strength-${item.factor}-${index}`}>{strength}</li>
                          ))}
                        </ul>
                      </div>
                      <div>
                        <p className="text-gray-400 font-medium mb-1">
                          {i18n.language === 'ko' ? '주의점' : 'Risks'}
                        </p>
                        <ul className="list-disc list-inside space-y-1">
                          {item.risks?.map((risk, index) => (
                            <li key={`risk-${item.factor}-${index}`}>{risk}</li>
                          ))}
                        </ul>
                      </div>
                    </div>
                    <p className="text-xs text-gray-500 mt-3">
                      <span className="text-gray-400 font-medium mr-2">
                        {i18n.language === 'ko' ? '제안' : 'Growth'}
                      </span>
                      {item.growth}
                    </p>
                  </div>
                ))}
              </div>
            </motion.div>
          )}
          {analysisError && (
            <div className="card border border-red-500/30 bg-red-500/5 text-red-200 text-sm">
              {analysisError}
            </div>
          )}

          {/* Top Persona Matches */}
          {topMatches.length > 0 && (
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.8 }}
              className="card bg-gradient-to-br from-purple-900/30 to-pink-900/30 border-purple-500/30"
            >
              <h2 className="text-xl font-bold text-white mb-2">
                {t('result.matchTitle')}
              </h2>
              <p className="text-gray-400 text-sm mb-6">
                {t('result.matchDescription')}
              </p>

              <div className="space-y-4">
                {topMatches.map((item, index) => (
                  <div
                    key={item.persona.id}
                    className="flex flex-col md:flex-row items-center gap-4 rounded-lg bg-dark-bg/40 p-4"
                  >
                    <div className="relative">
                      <div className="w-20 h-20 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 p-1">
                        <div className="w-full h-full rounded-full bg-dark-card flex items-center justify-center">
                          <span className="text-2xl font-bold gradient-text">
                            {item.persona.name[i18n.language as 'ko' | 'en'][0]}
                          </span>
                        </div>
                      </div>
                      <div
                        className="absolute -bottom-2 left-1/2 -translate-x-1/2 px-2 py-0.5 rounded-full text-[10px] font-medium"
                        style={{
                          backgroundColor: categoryColors[item.persona.category],
                          color: 'white'
                        }}
                      >
                        {t(`result.category.${item.persona.category}`)}
                      </div>
                      <div className="absolute -top-2 -right-2 px-2 py-0.5 rounded-full text-[10px] font-semibold bg-white/10 text-white">
                        #{index + 1}
                      </div>
                    </div>

                    <div className="flex-1 text-center md:text-left">
                      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-1">
                        <h3 className="text-lg font-bold text-white">
                          {item.persona.name[i18n.language as 'ko' | 'en']}
                        </h3>
                        <p className="text-purple-400 text-sm font-medium">
                          {t('result.similarity', { percent: item.similarity })}
                        </p>
                      </div>
                      <p className="text-gray-400 text-sm mt-2">
                        {item.persona.description[i18n.language as 'ko' | 'en']}
                      </p>
                      <div className="mt-2 text-xs text-gray-500">
                        <span className="mr-2">
                          {i18n.language === 'ko' ? '출처' : 'Source'}:
                        </span>
                        <a
                          href={toSafeUrl(item.persona.sourceUrl)}
                          target="_blank"
                          rel="noreferrer"
                          className="underline hover:text-gray-300"
                        >
                          {i18n.language === 'ko' ? '나무위키' : 'NamuWiki'}
                        </a>
                      </div>
                    </div>
                  </div>
                ))}
              </div>

              {/* Celebrity Disclaimer */}
              <CelebrityDisclaimer />
            </motion.div>
          )}

          {/* Bottom Disclaimer */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 1 }}
            className="mt-6 text-center text-xs text-gray-500 space-y-1"
          >
            <div className="flex items-center justify-center gap-2">
              <AlertTriangle className="w-3 h-3" />
              <span>
                {i18n.language === 'ko'
                  ? '비공식 테스트 | 오락 목적 | 전문 심리 평가를 대체하지 않음'
                  : 'Unofficial Test | Entertainment Purpose | Does not replace professional assessment'
                }
              </span>
            </div>
            <p>
              {i18n.language === 'ko'
                ? 'HEXACO 이론 기반 (Ashton & Lee) - 공식 HEXACO-PI-R과 무관'
                : 'Based on HEXACO theory (Ashton & Lee) - Not affiliated with official HEXACO-PI-R'
              }
            </p>
          </motion.div>
        </div>

        {/* Share Buttons */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1 }}
          className="mt-8 flex flex-wrap justify-center gap-4"
        >
          <button onClick={copyLink} className="btn-secondary flex items-center gap-2">
            {copied ? <Check className="w-5 h-5 text-green-500" /> : <Link2 className="w-5 h-5" />}
            {copied ? t('common.copied') : t('common.copyLink')}
          </button>

          <button onClick={shareTwitter} className="btn-secondary flex items-center gap-2">
            <Twitter className="w-5 h-5" />
            Twitter
          </button>

          <button onClick={downloadImage} className="btn-secondary flex items-center gap-2">
            <Download className="w-5 h-5" />
            {t('common.save')}
          </button>
        </motion.div>

        {/* Action Buttons */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1.2 }}
          className="mt-8 flex justify-center gap-4"
        >
          <Link
            to="/test"
            onClick={() => reset()}
            className="btn-primary flex items-center gap-2"
          >
            <RotateCcw className="w-5 h-5" />
            {t('common.retry')}
          </Link>

          <Link to="/" className="btn-secondary flex items-center gap-2">
            <Home className="w-5 h-5" />
            {t('common.home')}
          </Link>
        </motion.div>
      </div>
    </div>
  )
}
