import { useEffect, useState, useRef } from 'react'
import { Link, useSearchParams } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { motion } from 'framer-motion'
import {
  Radar, RadarChart, PolarGrid, PolarAngleAxis,
  PolarRadiusAxis, ResponsiveContainer
} from 'recharts'
import { Download, Link2, RotateCcw, Home, Check, Twitter } from 'lucide-react'
import html2canvas from 'html2canvas'
import { decodeResults, useTestStore } from '../stores/testStore'
import { factorColors, factors } from '../data/questions'
import { findBestMatch, MatchResult } from '../utils/matching'
import { categoryColors } from '../data/personas'
import LoadingSpinner from '../components/common/LoadingSpinner'

export default function ResultPage() {
  const { t, i18n } = useTranslation()
  const [searchParams] = useSearchParams()
  const resultRef = useRef<HTMLDivElement>(null)
  const [copied, setCopied] = useState(false)
  const [match, setMatch] = useState<MatchResult | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  const storeScores = useTestStore(state => state.scores)
  const reset = useTestStore(state => state.reset)

  // URL에서 결과 가져오기 또는 스토어에서 가져오기
  const encodedResult = searchParams.get('r')
  const scores = encodedResult ? decodeResults(encodedResult) : storeScores

  useEffect(() => {
    if (scores) {
      // 약간의 딜레이로 분석 중 효과
      const timer = setTimeout(() => {
        setMatch(findBestMatch(scores))
        setIsLoading(false)
      }, 1500)
      return () => clearTimeout(timer)
    } else {
      setIsLoading(false)
    }
  }, [scores])

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
                    {scores[factor]}
                  </span>
                  <span className="text-gray-500 text-sm mb-1">/100</span>
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
                <p className="text-xs text-gray-500 mt-2">
                  {scores[factor] >= 50
                    ? t(`result.factorDetail.${factor}.high`)
                    : t(`result.factorDetail.${factor}.low`)}
                </p>
              </motion.div>
            ))}
          </motion.div>

          {/* Persona Match */}
          {match && (
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

              <div className="flex flex-col md:flex-row items-center gap-6">
                {/* Persona Avatar */}
                <div className="relative">
                  <div className="w-32 h-32 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 p-1">
                    <div className="w-full h-full rounded-full bg-dark-card flex items-center justify-center">
                      <span className="text-4xl font-bold gradient-text">
                        {match.persona.name[i18n.language as 'ko' | 'en'][0]}
                      </span>
                    </div>
                  </div>
                  <div
                    className="absolute -bottom-2 left-1/2 -translate-x-1/2 px-3 py-1 rounded-full text-xs font-medium"
                    style={{
                      backgroundColor: categoryColors[match.persona.category],
                      color: 'white'
                    }}
                  >
                    {t(`result.category.${match.persona.category}`)}
                  </div>
                </div>

                {/* Persona Info */}
                <div className="flex-1 text-center md:text-left">
                  <h3 className="text-2xl font-bold text-white mb-1">
                    {match.persona.name[i18n.language as 'ko' | 'en']}
                  </h3>
                  <p className="text-purple-400 font-medium mb-3">
                    {t('result.similarity', { percent: match.similarity })}
                  </p>
                  <p className="text-gray-400">
                    {match.persona.description[i18n.language as 'ko' | 'en']}
                  </p>
                </div>
              </div>
            </motion.div>
          )}
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
