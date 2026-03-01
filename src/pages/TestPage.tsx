import { useEffect, useState, useRef, useCallback } from 'react'
import { useNavigate } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { motion, AnimatePresence } from 'framer-motion'
import { ChevronLeft, ChevronRight, Lightbulb, Circle, Sparkles, Eye, Coffee } from 'lucide-react'
import { factorColors } from '../data/questions'
import { useTestStore, encodeResults } from '../stores/testStore'
import AdBanner from '../components/AdBanner'

// Test completion popup with rewarded ad before results
function CompletionPopup({
  isKo,
  onViewResults,
}: {
  isKo: boolean
  onViewResults: () => void
}) {
  const [adWatched, setAdWatched] = useState(false)

  // Enable "결과 보기" button after ad display time (5 seconds)
  useEffect(() => {
    const timer = setTimeout(() => {
      setAdWatched(true)
    }, 5000)
    return () => clearTimeout(timer)
  }, [])

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm px-4"
    >
      <motion.div
        initial={{ scale: 0.8, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        exit={{ scale: 0.8, opacity: 0 }}
        transition={{ type: 'spring', stiffness: 300, damping: 25 }}
        className="relative rounded-3xl p-6 max-w-sm w-full text-center border border-purple-500/30"
        style={{
          background: 'linear-gradient(135deg, #1A1035 0%, #2D1B4E 100%)',
        }}
      >
        {/* Icon */}
        <motion.div
          className="w-16 h-16 mx-auto mb-4 rounded-full flex items-center justify-center"
          style={{
            background: 'linear-gradient(135deg, #8B5CF6, #EC4899)',
          }}
          animate={{
            boxShadow: [
              '0 0 30px rgba(139, 92, 246, 0.3), 0 0 60px rgba(236, 72, 153, 0.2)',
              '0 0 50px rgba(139, 92, 246, 0.5), 0 0 80px rgba(236, 72, 153, 0.4)',
              '0 0 30px rgba(139, 92, 246, 0.3), 0 0 60px rgba(236, 72, 153, 0.2)',
            ],
          }}
          transition={{ duration: 1.5, repeat: Infinity }}
        >
          <Sparkles className="w-8 h-8 text-white" />
        </motion.div>

        {/* Title */}
        <h2 className="text-xl font-bold text-white mb-2">
          {isKo ? '테스트 완료!' : 'Test Complete!'}
        </h2>
        <p className="text-gray-400 text-sm mb-4">
          {isKo
            ? '당신의 성격 분석 결과가 준비되었습니다.'
            : 'Your personality analysis is ready.'}
        </p>

        {/* Rewarded Ad Area */}
        <div className="mb-4 rounded-xl overflow-hidden bg-dark-bg/50 border border-dark-border">
          <AdBanner />
        </div>

        {/* View Results Button - enabled after ad */}
        {adWatched ? (
          <motion.button
            initial={{ opacity: 0, y: 10 }}
            onClick={onViewResults}
            className="relative inline-flex items-center gap-3 px-10 py-4 rounded-2xl text-white font-bold text-lg border-2"
            style={{
              background: 'linear-gradient(135deg, #8B5CF6, #EC4899)',
            }}
            animate={{
              opacity: 1,
              y: 0,
              scale: [1, 1.05, 1],
              borderColor: [
                'rgba(255,255,255,0.3)',
                'rgba(255,255,255,0.6)',
                'rgba(255,255,255,0.3)',
              ],
              boxShadow: [
                '0 0 20px rgba(139, 92, 246, 0.4), 0 0 40px rgba(236, 72, 153, 0.3)',
                '0 0 35px rgba(139, 92, 246, 0.7), 0 0 60px rgba(236, 72, 153, 0.5)',
                '0 0 20px rgba(139, 92, 246, 0.4), 0 0 40px rgba(236, 72, 153, 0.3)',
              ],
            }}
            transition={{ duration: 1.5, repeat: Infinity }}
            whileTap={{ scale: 0.95 }}
          >
            <Eye className="w-6 h-6" />
            {isKo ? '결과 보기' : 'View Results'}
          </motion.button>
        ) : (
          <div className="flex flex-col items-center gap-2">
            <motion.div
              className="w-6 h-6 border-2 border-purple-400 border-t-transparent rounded-full"
              animate={{ rotate: 360 }}
              transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
            />
            <p className="text-gray-500 text-xs">
              {isKo ? '잠시만 기다려주세요...' : 'Please wait a moment...'}
            </p>
          </div>
        )}
      </motion.div>
    </motion.div>
  )
}

// Ad break overlay shown every 15 questions (native banner + 3s loading bar)
function AdBreakOverlay({
  isKo,
  onContinue,
}: {
  isKo: boolean
  onContinue: () => void
}) {
  const [canContinue, setCanContinue] = useState(false)
  const [progress, setProgress] = useState(0)

  useEffect(() => {
    const startTime = Date.now()
    const duration = 3000
    let raf: number
    const tick = () => {
      const elapsed = Date.now() - startTime
      const p = Math.min(elapsed / duration, 1)
      setProgress(p)
      if (p < 1) {
        raf = requestAnimationFrame(tick)
      } else {
        setCanContinue(true)
      }
    }
    raf = requestAnimationFrame(tick)
    return () => cancelAnimationFrame(raf)
  }, [])

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 backdrop-blur-sm px-4"
    >
      <motion.div
        initial={{ scale: 0.9, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        exit={{ scale: 0.9, opacity: 0 }}
        transition={{ type: 'spring', stiffness: 300, damping: 25 }}
        className="relative rounded-3xl p-6 max-w-md w-full text-center border border-purple-500/30"
        style={{
          background: 'linear-gradient(135deg, #1A1035 0%, #2D1B4E 100%)',
        }}
      >
        {/* Icon */}
        <div className="w-12 h-12 mx-auto mb-3 rounded-full flex items-center justify-center"
          style={{ background: 'linear-gradient(135deg, #8B5CF6, #6366F1)' }}
        >
          <Coffee className="w-6 h-6 text-white" />
        </div>

        {/* Title */}
        <h2 className="text-lg font-bold text-white mb-1">
          {isKo ? '잠시 쉬어가세요' : 'Take a Short Break'}
        </h2>
        <p className="text-gray-400 text-xs mb-4">
          {isKo
            ? '잠시 눈을 쉬고, 다음 질문을 준비해보세요.'
            : 'Rest your eyes for a moment before continuing.'}
        </p>

        {/* Native Ad Banner */}
        <div className="mb-4 rounded-xl overflow-hidden bg-dark-bg/50 border border-dark-border">
          <AdBanner />
        </div>

        {/* 3-second progress bar + continue button */}
        {canContinue ? (
          <motion.button
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            onClick={onContinue}
            className="inline-flex items-center gap-2 px-8 py-3 rounded-xl text-white font-bold border border-purple-500/50"
            style={{
              background: 'linear-gradient(135deg, #8B5CF6, #EC4899)',
            }}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            {isKo ? '계속하기' : 'Continue'}
          </motion.button>
        ) : (
          <div className="flex flex-col items-center gap-2">
            <div className="w-full h-1.5 bg-dark-card rounded-full overflow-hidden">
              <div
                className="h-full rounded-full transition-none"
                style={{
                  width: `${progress * 100}%`,
                  background: 'linear-gradient(90deg, #8B5CF6, #EC4899)',
                }}
              />
            </div>
            <p className="text-gray-500 text-xs">
              {isKo ? '잠시만 기다려주세요...' : 'Please wait...'}
            </p>
          </div>
        )}
      </motion.div>
    </motion.div>
  )
}

// Ambient background with calming animated elements
function AmbientBackground() {
  return (
    <div className="fixed inset-0 overflow-hidden pointer-events-none -z-10">
      {/* Gradient overlay */}
      <div className="absolute inset-0 bg-gradient-to-b from-dark-bg via-dark-bg to-purple-900/10" />

      {/* Slow moving orbs */}
      <motion.div
        className="absolute top-1/4 left-1/4 w-[500px] h-[500px] rounded-full"
        style={{
          background: 'radial-gradient(circle, rgba(139, 92, 246, 0.08) 0%, transparent 70%)',
        }}
        animate={{
          x: [0, 50, 0],
          y: [0, 30, 0],
          scale: [1, 1.1, 1],
        }}
        transition={{
          duration: 20,
          repeat: Infinity,
          ease: 'easeInOut',
        }}
      />

      <motion.div
        className="absolute bottom-1/4 right-1/4 w-[400px] h-[400px] rounded-full"
        style={{
          background: 'radial-gradient(circle, rgba(236, 72, 153, 0.06) 0%, transparent 70%)',
        }}
        animate={{
          x: [0, -40, 0],
          y: [0, -20, 0],
          scale: [1.1, 1, 1.1],
        }}
        transition={{
          duration: 25,
          repeat: Infinity,
          ease: 'easeInOut',
        }}
      />

      {/* Subtle floating particles */}
      {[...Array(15)].map((_, i) => (
        <motion.div
          key={i}
          className="absolute w-1 h-1 bg-purple-400/20 rounded-full"
          style={{
            left: `${Math.random() * 100}%`,
            top: `${Math.random() * 100}%`,
          }}
          animate={{
            y: [0, -100, 0],
            opacity: [0, 0.5, 0],
          }}
          transition={{
            duration: 10 + Math.random() * 10,
            repeat: Infinity,
            delay: Math.random() * 5,
          }}
        />
      ))}
    </div>
  )
}

// Progress indicator with factor colors
function ProgressIndicator({
  currentIndex,
  total,
  progress,
  currentFactor
}: {
  currentIndex: number
  total: number
  progress: number
  currentFactor: string
}) {
  const { t } = useTranslation()

  return (
    <div className="mb-6">
      <div className="flex justify-between text-sm text-gray-400 mb-2">
        <span>{t('test.progress', { current: currentIndex + 1, total })}</span>
        <span>{Math.round(progress)}%</span>
      </div>
      <div className="h-2 bg-dark-card rounded-full overflow-hidden relative">
        <motion.div
          className="absolute inset-0 opacity-20"
          style={{
            background: `linear-gradient(90deg, transparent, ${factorColors[currentFactor as keyof typeof factorColors]}, transparent)`,
          }}
          animate={{
            x: ['-100%', '100%'],
          }}
          transition={{
            duration: 2,
            repeat: Infinity,
            ease: 'linear',
          }}
        />
        <motion.div
          className="h-full relative"
          style={{
            background: `linear-gradient(90deg, #8B5CF6, ${factorColors[currentFactor as keyof typeof factorColors]})`,
          }}
          initial={{ width: 0 }}
          animate={{ width: `${progress}%` }}
          transition={{ duration: 0.3 }}
        />
      </div>

      {/* Mini factor progress dots */}
      <div className="flex justify-center gap-1.5 mt-3">
        {['H', 'E', 'X', 'A', 'C', 'O'].map((factor) => (
          <motion.div
            key={factor}
            className="w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold"
            style={{
              backgroundColor: currentFactor === factor
                ? factorColors[factor as keyof typeof factorColors]
                : `${factorColors[factor as keyof typeof factorColors]}30`,
              color: currentFactor === factor ? 'white' : factorColors[factor as keyof typeof factorColors],
            }}
            animate={currentFactor === factor ? {
              scale: [1, 1.1, 1],
            } : {}}
            transition={{ duration: 1, repeat: Infinity }}
          >
            {factor}
          </motion.div>
        ))}
      </div>
    </div>
  )
}

// Percentage Slider Component (matching mobile app design)
function PercentageSlider({
  currentAnswer,
  onSelect,
  factorColor: _factorColor,
}: {
  currentAnswer: number | undefined
  onSelect: (value: number) => void
  factorColor: string
}) {
  const { t } = useTranslation()
  const trackRef = useRef<HTMLDivElement>(null)
  const [isDragging, setIsDragging] = useState(false)

  // Internal position: -100 (left/agree) to +100 (right/disagree)
  const storageToPosition = (value: number | undefined): number => {
    if (value === undefined) return 0
    return 100 - value * 2 // storage 0-100 → position -100 to +100
  }

  const [sliderPosition, setSliderPosition] = useState(() => storageToPosition(currentAnswer))

  // Convert slider position to score: left(-100)=100, center(0)=50, right(+100)=0
  const positionToStorage = (pos: number): number => Math.round((100 - pos) / 2)

  const isLeftSide = sliderPosition < 0
  const isRightSide = sliderPosition > 0
  const percentage = Math.abs(sliderPosition)

  // Update position when question changes
  useEffect(() => {
    const newPos = storageToPosition(currentAnswer)
    setSliderPosition(newPos)
  }, [currentAnswer])

  // Auto-select neutral when question changes (matching mobile behavior)
  useEffect(() => {
    if (currentAnswer === undefined) {
      onSelect(50) // neutral
    }
  }, [currentAnswer])

  const getPositionColor = useCallback(() => {
    if (sliderPosition === 0) return '#6B7280' // gray-500
    if (isLeftSide) {
      // Agree side - purple to pink
      const t = percentage / 100
      return `color-mix(in srgb, #8B5CF6 ${100 - t * 100}%, #EC4899)`
    } else {
      // Disagree side - blue to cyan
      const t = percentage / 100
      return `color-mix(in srgb, #3B82F6 ${100 - t * 100}%, #06B6D4)`
    }
  }, [sliderPosition, isLeftSide, percentage])

  const handleInteraction = (clientX: number) => {
    if (!trackRef.current) return
    const rect = trackRef.current.getBoundingClientRect()
    const center = rect.left + rect.width / 2
    const offset = clientX - center
    const normalized = Math.max(-1, Math.min(1, offset / (rect.width / 2)))
    const newPosition = Math.round(normalized * 100)
    setSliderPosition(newPosition)
    onSelect(positionToStorage(newPosition))
  }

  const handleMouseDown = (e: React.MouseEvent) => {
    e.preventDefault()
    setIsDragging(true)
    handleInteraction(e.clientX)
  }

  const handleTouchStart = (e: React.TouchEvent) => {
    setIsDragging(true)
    handleInteraction(e.touches[0].clientX)
  }

  useEffect(() => {
    const handleMove = (e: MouseEvent | TouchEvent) => {
      if (!isDragging) return
      const clientX = 'touches' in e ? e.touches[0].clientX : e.clientX
      handleInteraction(clientX)
    }

    const handleEnd = () => {
      setIsDragging(false)
    }

    if (isDragging) {
      window.addEventListener('mousemove', handleMove)
      window.addEventListener('mouseup', handleEnd)
      window.addEventListener('touchmove', handleMove)
      window.addEventListener('touchend', handleEnd)
    }

    return () => {
      window.removeEventListener('mousemove', handleMove)
      window.removeEventListener('mouseup', handleEnd)
      window.removeEventListener('touchmove', handleMove)
      window.removeEventListener('touchend', handleEnd)
    }
  }, [isDragging])

  const positionColor = getPositionColor()

  return (
    <div className="flex flex-col items-center w-full">
      {/* Percentage display */}
      <motion.div
        className="px-6 py-3 rounded-xl border mb-4"
        style={{
          backgroundColor: '#1F2937',
          borderColor: `${positionColor}80`,
        }}
        animate={percentage > 50 ? {
          boxShadow: [
            `0 0 20px ${positionColor}40`,
            `0 0 30px ${positionColor}60`,
            `0 0 20px ${positionColor}40`,
          ],
        } : {}}
        transition={{ duration: 1.2, repeat: Infinity }}
      >
        <div className="flex items-center gap-2">
          <Circle
            className="w-5 h-5"
            style={{ color: positionColor }}
            fill={sliderPosition === 0 ? 'none' : positionColor}
          />
          <span className="text-2xl font-bold text-white">{percentage}%</span>
        </div>
      </motion.div>

      {/* Labels */}
      <div className="flex justify-between w-full px-2 mb-2">
        <span
          className={`text-sm transition-all ${isLeftSide ? 'text-purple-400 font-bold' : 'text-gray-500'}`}
        >
          {t('test.slider.agree')}
        </span>
        <span
          className={`text-sm transition-all ${sliderPosition === 0 ? 'text-white font-bold' : 'text-gray-500'}`}
        >
          {t('test.slider.neutral')}
        </span>
        <span
          className={`text-sm transition-all ${isRightSide ? 'text-cyan-400 font-bold' : 'text-gray-500'}`}
        >
          {t('test.slider.disagree')}
        </span>
      </div>

      {/* Slider track */}
      <div className="w-full px-6 py-4">
        <div
          ref={trackRef}
          className="relative h-20 cursor-pointer select-none"
          onMouseDown={handleMouseDown}
          onTouchStart={handleTouchStart}
        >
          {/* Track background with gradient */}
          <div className="absolute top-1/2 -translate-y-1/2 left-0 right-0 h-4 rounded-full overflow-hidden">
            <div
              className="absolute inset-0"
              style={{
                background: 'linear-gradient(90deg, #8B5CF6, #EC4899, #4B5563, #3B82F6, #06B6D4)',
              }}
            />
            <div className="absolute inset-0 bg-dark-bg/60" />
          </div>

          {/* Active fill from center */}
          <div
            className="absolute top-1/2 -translate-y-1/2 h-4 rounded-full transition-all duration-75"
            style={{
              left: isLeftSide ? `${50 + sliderPosition / 2}%` : '50%',
              right: isRightSide ? `${50 - sliderPosition / 2}%` : '50%',
              background: isLeftSide
                ? 'linear-gradient(90deg, #8B5CF6, #EC4899)'
                : 'linear-gradient(90deg, #3B82F6, #06B6D4)',
              boxShadow: `0 0 10px ${positionColor}80`,
            }}
          />

          {/* Center marker */}
          <div
            className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-1 h-6 bg-white rounded-full shadow-lg z-10"
          />

          {/* Tick marks at 25%, 50%, 75% */}
          {[-75, -50, -25, 25, 50, 75].map((tick) => (
            <div
              key={tick}
              className="absolute top-1/2 -translate-y-1/2 w-0.5 h-2 bg-gray-500/50 rounded"
              style={{ left: `${50 + tick / 2}%` }}
            />
          ))}

          {/* Thumb */}
          <motion.div
            className="absolute top-1/2 -translate-y-1/2 w-10 h-10 rounded-full border-[3px] border-white flex items-center justify-center z-20"
            style={{
              left: `calc(${50 + sliderPosition / 2}% - 20px)`,
              background: `linear-gradient(135deg, ${positionColor}, ${positionColor}CC)`,
              boxShadow: percentage > 50
                ? `0 0 20px ${positionColor}99, 0 0 40px ${positionColor}66`
                : `0 0 10px ${positionColor}66`,
            }}
            animate={percentage > 50 ? {
              boxShadow: [
                `0 0 20px ${positionColor}99, 0 0 40px ${positionColor}66`,
                `0 0 30px ${positionColor}BB, 0 0 50px ${positionColor}88`,
                `0 0 20px ${positionColor}99, 0 0 40px ${positionColor}66`,
              ],
            } : {}}
            transition={{ duration: 1.2, repeat: Infinity }}
          >
            <span className="text-white text-xs font-bold">{percentage}</span>
          </motion.div>
        </div>
      </div>

      {/* 100% labels at ends */}
      <div className="flex justify-between w-full px-2 text-xs">
        <span className={isLeftSide && percentage > 80 ? 'text-purple-400' : 'text-gray-600'}>
          100%
        </span>
        <span className={sliderPosition === 0 ? 'text-white' : 'text-gray-600'}>
          0%
        </span>
        <span className={isRightSide && percentage > 80 ? 'text-cyan-400' : 'text-gray-600'}>
          100%
        </span>
      </div>
    </div>
  )
}

export default function TestPage() {
  const { t, i18n } = useTranslation()
  const navigate = useNavigate()
  const [showPopup, setShowPopup] = useState(false)
  const [showAdBreak, setShowAdBreak] = useState(false)
  const {
    currentIndex,
    answers,
    setAnswer,
    nextQuestion,
    prevQuestion,
    calculateScores,
    getAnswer,
    getQuestions
  } = useTestStore()

  const questions = getQuestions()
  const currentQuestion = questions[currentIndex]
  const currentAnswer = getAnswer(currentQuestion.id)
  const progress = ((currentIndex + 1) / questions.length) * 100
  const isLastQuestion = currentIndex === questions.length - 1
  const allAnswered = answers.length === questions.length
  const isKo = i18n.language === 'ko'

  const handleAnswer = (value: number) => {
    setAnswer(currentQuestion.id, value)
  }

  const handleNext = () => {
    if (isLastQuestion && allAnswered) {
      setShowPopup(true)
    } else if (currentAnswer !== undefined) {
      // Show ad break every 15 questions (after question 15, 30, 45, etc.)
      if ((currentIndex + 1) % 15 === 0 && !isLastQuestion) {
        setShowAdBreak(true)
      } else {
        nextQuestion()
      }
    }
  }

  const handleAdBreakContinue = () => {
    setShowAdBreak(false)
    nextQuestion()
  }

  const handleViewResults = () => {
    const scores = calculateScores()
    const encoded = encodeResults(scores)
    navigate(`/result?r=${encoded}`)
  }

  const handleKeyDown = (e: KeyboardEvent) => {
    if (e.key === 'ArrowRight' && currentAnswer !== undefined) {
      handleNext()
    } else if (e.key === 'ArrowLeft' && currentIndex > 0) {
      prevQuestion()
    } else if (e.key === 'Enter' || e.key === ' ') {
      handleNext()
    }
  }

  useEffect(() => {
    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [currentIndex, currentAnswer])

  const factorColor = factorColors[currentQuestion.factor as keyof typeof factorColors]

  return (
    <div className="min-h-screen pt-20 pb-8 px-4 relative">
      <AmbientBackground />

      {/* Completion Popup */}
      <AnimatePresence>
        {showPopup && (
          <CompletionPopup
            isKo={isKo}
            onViewResults={handleViewResults}
          />
        )}
      </AnimatePresence>

      {/* Ad Break Overlay */}
      <AnimatePresence>
        {showAdBreak && (
          <AdBreakOverlay
            isKo={isKo}
            onContinue={handleAdBreakContinue}
          />
        )}
      </AnimatePresence>

      <div className="max-w-2xl mx-auto relative z-10">
        {/* Progress Indicator */}
        <ProgressIndicator
          currentIndex={currentIndex}
          total={questions.length}
          progress={progress}
          currentFactor={currentQuestion.factor}
        />

        {/* Question Card */}
        <AnimatePresence mode="wait">
          <motion.div
            key={currentQuestion.id}
            initial={{ opacity: 0, x: 50 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -50 }}
            transition={{ duration: 0.3 }}
            className="relative mb-6"
          >
            {/* Card glow effect */}
            <div
              className="absolute -inset-1 rounded-3xl opacity-20 blur-xl"
              style={{ backgroundColor: factorColor }}
            />

            <div className="relative bg-dark-card/80 backdrop-blur-xl border border-dark-border rounded-2xl p-5 md:p-6">
              {/* Factor Badge */}
              <motion.div
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ type: 'spring', stiffness: 500 }}
                className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full text-sm mb-4"
                style={{
                  backgroundColor: `${factorColor}20`,
                  color: factorColor,
                  borderColor: factorColor,
                  borderWidth: 1,
                }}
              >
                <span className="font-bold text-lg">{currentQuestion.factor}</span>
                <span className="opacity-50">|</span>
                <span>{t('test.question', { number: currentIndex + 1 })}</span>
              </motion.div>

              {/* Question Text */}
              <motion.h2
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.1 }}
                className="text-lg md:text-xl font-medium text-white mb-4 leading-relaxed"
              >
                {i18n.language === 'ko' ? currentQuestion.ko : currentQuestion.en}
              </motion.h2>

              {/* Example (if available) */}
              {(i18n.language === 'ko' ? currentQuestion.koExample : currentQuestion.enExample) && (
                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ delay: 0.2 }}
                  className="p-3 rounded-lg bg-dark-bg/50 border border-dark-border"
                >
                  <div className="flex items-start gap-2">
                    <Lightbulb className="w-4 h-4 mt-0.5" style={{ color: `${factorColor}B0` }} />
                    <span className="text-sm text-gray-400 leading-relaxed">
                      {i18n.language === 'ko' ? currentQuestion.koExample : currentQuestion.enExample}
                    </span>
                  </div>
                </motion.div>
              )}
            </div>
          </motion.div>
        </AnimatePresence>

        {/* Percentage Slider */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="bg-dark-card/60 backdrop-blur-xl border border-dark-border rounded-2xl p-4 mb-6"
        >
          <PercentageSlider
            currentAnswer={currentAnswer}
            onSelect={handleAnswer}
            factorColor={factorColor}
          />
        </motion.div>

        {/* Navigation */}
        <div className="flex justify-between items-center mb-4">
          <motion.button
            onClick={prevQuestion}
            disabled={currentIndex === 0}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            className={`btn-secondary flex items-center gap-2
              ${currentIndex === 0 ? 'opacity-50 cursor-not-allowed' : ''}`}
          >
            <ChevronLeft className="w-5 h-5" />
            {t('common.prev')}
          </motion.button>

          <motion.button
            onClick={handleNext}
            disabled={currentAnswer === undefined}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            className={`btn-primary flex items-center gap-2
              ${currentAnswer === undefined ? 'opacity-50 cursor-not-allowed' : ''}`}
          >
            {isLastQuestion && allAnswered ? t('common.submit') : t('common.next')}
            <ChevronRight className="w-5 h-5" />
          </motion.button>
        </div>

        {/* Hint */}
        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.5 }}
          className="text-center text-gray-500 text-sm"
        >
          {t('test.slider.hint')}
        </motion.p>

        {/* Take time message */}
        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.6 }}
          className="text-center text-gray-500 text-sm mt-2"
        >
          {t('test.slider.takeTime')}
        </motion.p>
      </div>
    </div>
  )
}
