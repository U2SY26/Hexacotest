import { useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { motion, AnimatePresence } from 'framer-motion'
import { ChevronLeft, ChevronRight } from 'lucide-react'
import { factorColors } from '../data/questions'
import { useTestStore, encodeResults } from '../stores/testStore'

const scaleOptions = [1, 2, 3, 4, 5] as const

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

      <motion.div
        className="absolute top-1/2 right-1/3 w-[300px] h-[300px] rounded-full"
        style={{
          background: 'radial-gradient(circle, rgba(59, 130, 246, 0.05) 0%, transparent 70%)',
        }}
        animate={{
          x: [0, 30, 0],
          y: [0, -40, 0],
        }}
        transition={{
          duration: 30,
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

      {/* Calm wave lines */}
      <svg
        className="absolute bottom-0 left-0 w-full h-32 opacity-10"
        viewBox="0 0 1440 100"
        preserveAspectRatio="none"
      >
        <motion.path
          d="M0,50 C360,100 720,0 1080,50 C1260,75 1380,50 1440,50 L1440,100 L0,100 Z"
          fill="url(#wave-gradient)"
          animate={{
            d: [
              "M0,50 C360,100 720,0 1080,50 C1260,75 1380,50 1440,50 L1440,100 L0,100 Z",
              "M0,50 C360,0 720,100 1080,50 C1260,25 1380,50 1440,50 L1440,100 L0,100 Z",
              "M0,50 C360,100 720,0 1080,50 C1260,75 1380,50 1440,50 L1440,100 L0,100 Z",
            ],
          }}
          transition={{
            duration: 15,
            repeat: Infinity,
            ease: 'easeInOut',
          }}
        />
        <defs>
          <linearGradient id="wave-gradient" x1="0%" y1="0%" x2="100%" y2="0%">
            <stop offset="0%" stopColor="#8B5CF6" />
            <stop offset="50%" stopColor="#EC4899" />
            <stop offset="100%" stopColor="#8B5CF6" />
          </linearGradient>
        </defs>
      </svg>
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
    <div className="mb-8">
      <div className="flex justify-between text-sm text-gray-400 mb-2">
        <span>{t('test.progress', { current: currentIndex + 1, total })}</span>
        <span>{Math.round(progress)}%</span>
      </div>
      <div className="h-2 bg-dark-card rounded-full overflow-hidden relative">
        {/* Background subtle animation */}
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
      <div className="flex justify-center gap-1 mt-3">
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

export default function TestPage() {
  const { t, i18n } = useTranslation()
  const navigate = useNavigate()
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

  const handleAnswer = (value: number) => {
    setAnswer(currentQuestion.id, value)
  }

  const handleNext = () => {
    if (isLastQuestion && allAnswered) {
      const scores = calculateScores()
      const encoded = encodeResults(scores)
      navigate(`/result?r=${encoded}`)
    } else if (currentAnswer !== undefined) {
      nextQuestion()
    }
  }

  const handleKeyDown = (e: KeyboardEvent) => {
    if (e.key >= '1' && e.key <= '5') {
      handleAnswer(parseInt(e.key))
    } else if (e.key === 'ArrowRight' && currentAnswer !== undefined) {
      handleNext()
    } else if (e.key === 'ArrowLeft' && currentIndex > 0) {
      prevQuestion()
    }
  }

  useEffect(() => {
    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [currentIndex, currentAnswer])

  const scaleLabels = {
    1: { color: 'from-red-500/20 to-red-600/20', borderColor: 'border-red-500', bgColor: 'bg-red-500' },
    2: { color: 'from-orange-500/20 to-orange-600/20', borderColor: 'border-orange-500', bgColor: 'bg-orange-500' },
    3: { color: 'from-gray-500/20 to-gray-600/20', borderColor: 'border-gray-500', bgColor: 'bg-gray-500' },
    4: { color: 'from-blue-500/20 to-blue-600/20', borderColor: 'border-blue-500', bgColor: 'bg-blue-500' },
    5: { color: 'from-green-500/20 to-green-600/20', borderColor: 'border-green-500', bgColor: 'bg-green-500' },
  }

  return (
    <div className="min-h-screen pt-24 pb-12 px-4 relative">
      <AmbientBackground />

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
            className="relative mb-8"
          >
            {/* Card glow effect */}
            <div
              className="absolute -inset-1 rounded-3xl opacity-20 blur-xl"
              style={{ backgroundColor: factorColors[currentQuestion.factor] }}
            />

            <div className="relative bg-dark-card/80 backdrop-blur-xl border border-dark-border rounded-2xl p-6 md:p-8">
              {/* Factor Badge */}
              <motion.div
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ type: 'spring', stiffness: 500 }}
                className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full text-sm mb-6"
                style={{
                  backgroundColor: `${factorColors[currentQuestion.factor]}20`,
                  color: factorColors[currentQuestion.factor],
                  borderColor: factorColors[currentQuestion.factor],
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
                className="text-xl md:text-2xl font-medium text-white mb-8 leading-relaxed"
              >
                {i18n.language === 'ko' ? currentQuestion.ko : currentQuestion.en}
              </motion.h2>

              {/* Answer Scale */}
              <div className="space-y-3">
                {scaleOptions.map((value, idx) => {
                  const isSelected = currentAnswer === value
                  const style = scaleLabels[value]

                  return (
                    <motion.button
                      key={value}
                      onClick={() => handleAnswer(value)}
                      initial={{ opacity: 0, x: -20 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: 0.1 + idx * 0.05 }}
                      whileHover={{ scale: 1.02, x: 5 }}
                      whileTap={{ scale: 0.98 }}
                      className={`w-full p-4 rounded-xl border-2 transition-all flex items-center gap-4 backdrop-blur-sm
                        ${isSelected
                          ? `bg-gradient-to-r ${style.color} ${style.borderColor} text-white`
                          : 'bg-dark-bg/50 border-dark-border text-gray-300 hover:border-gray-600'
                        }`}
                    >
                      <div
                        className={`w-8 h-8 rounded-full border-2 flex items-center justify-center flex-shrink-0 transition-all
                          ${isSelected
                            ? `${style.borderColor} ${style.bgColor}`
                            : 'border-gray-600'
                          }`}
                      >
                        {isSelected && (
                          <motion.div
                            initial={{ scale: 0 }}
                            animate={{ scale: 1 }}
                            className="w-3 h-3 bg-white rounded-full"
                          />
                        )}
                      </div>
                      <span className="flex-1 text-left">{t(`test.scale.${value}`)}</span>
                      <span className={`text-sm font-medium ${isSelected ? 'text-white' : 'text-gray-500'}`}>
                        {value}
                      </span>
                    </motion.button>
                  )
                })}
              </div>
            </div>
          </motion.div>
        </AnimatePresence>

        {/* Navigation */}
        <div className="flex justify-between items-center">
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

        {/* Keyboard hint */}
        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.5 }}
          className="text-center text-gray-500 text-sm mt-8"
        >
          {i18n.language === 'ko'
            ? '키보드 1-5로 응답, ← → 로 이동할 수 있습니다'
            : 'Press 1-5 to answer, ← → to navigate'}
        </motion.p>

        {/* Breathing guide */}
        <motion.div
          className="fixed bottom-8 right-8 hidden md:flex items-center gap-3 text-gray-500 text-sm"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1 }}
        >
          <motion.div
            className="w-3 h-3 rounded-full bg-purple-500/50"
            animate={{
              scale: [1, 1.5, 1],
              opacity: [0.5, 1, 0.5],
            }}
            transition={{
              duration: 4,
              repeat: Infinity,
              ease: 'easeInOut',
            }}
          />
          <span>{i18n.language === 'ko' ? '천천히, 편안하게' : 'Take your time'}</span>
        </motion.div>
      </div>
    </div>
  )
}
