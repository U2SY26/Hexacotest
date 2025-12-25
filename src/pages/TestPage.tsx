import { useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { motion, AnimatePresence } from 'framer-motion'
import { ChevronLeft, ChevronRight } from 'lucide-react'
import { questions, factorColors } from '../data/questions'
import { useTestStore, encodeResults } from '../stores/testStore'

const scaleOptions = [1, 2, 3, 4, 5] as const

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
    getAnswer
  } = useTestStore()

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

  return (
    <div className="min-h-screen pt-24 pb-12 px-4">
      <div className="max-w-2xl mx-auto">
        {/* Progress Bar */}
        <div className="mb-8">
          <div className="flex justify-between text-sm text-gray-400 mb-2">
            <span>{t('test.progress', { current: currentIndex + 1, total: questions.length })}</span>
            <span>{Math.round(progress)}%</span>
          </div>
          <div className="h-2 bg-dark-card rounded-full overflow-hidden">
            <motion.div
              className="h-full bg-gradient-to-r from-purple-500 to-pink-500"
              initial={{ width: 0 }}
              animate={{ width: `${progress}%` }}
              transition={{ duration: 0.3 }}
            />
          </div>
        </div>

        {/* Question Card */}
        <AnimatePresence mode="wait">
          <motion.div
            key={currentQuestion.id}
            initial={{ opacity: 0, x: 50 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -50 }}
            transition={{ duration: 0.3 }}
            className="card mb-8"
          >
            {/* Factor Badge */}
            <div
              className="inline-flex items-center gap-2 px-3 py-1 rounded-full text-sm mb-4"
              style={{
                backgroundColor: `${factorColors[currentQuestion.factor]}20`,
                color: factorColors[currentQuestion.factor]
              }}
            >
              <span className="font-bold">{currentQuestion.factor}</span>
              <span className="text-gray-400">|</span>
              <span>{t('test.question', { number: currentIndex + 1 })}</span>
            </div>

            {/* Question Text */}
            <h2 className="text-xl md:text-2xl font-medium text-white mb-8 leading-relaxed">
              {i18n.language === 'ko' ? currentQuestion.ko : currentQuestion.en}
            </h2>

            {/* Answer Scale */}
            <div className="space-y-3">
              {scaleOptions.map((value) => (
                <motion.button
                  key={value}
                  onClick={() => handleAnswer(value)}
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  className={`w-full p-4 rounded-xl border transition-all flex items-center gap-4
                    ${currentAnswer === value
                      ? 'bg-purple-500/20 border-purple-500 text-white'
                      : 'bg-dark-bg border-dark-border text-gray-300 hover:border-gray-600'
                    }`}
                >
                  <div
                    className={`w-8 h-8 rounded-full border-2 flex items-center justify-center flex-shrink-0
                      ${currentAnswer === value
                        ? 'border-purple-500 bg-purple-500'
                        : 'border-gray-600'
                      }`}
                  >
                    {currentAnswer === value && (
                      <motion.div
                        initial={{ scale: 0 }}
                        animate={{ scale: 1 }}
                        className="w-3 h-3 bg-white rounded-full"
                      />
                    )}
                  </div>
                  <span className="flex-1 text-left">{t(`test.scale.${value}`)}</span>
                  <span className="text-gray-500 text-sm">{value}</span>
                </motion.button>
              ))}
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
        <p className="text-center text-gray-500 text-sm mt-8">
          {i18n.language === 'ko'
            ? '키보드 1-5로 응답, ← → 로 이동할 수 있습니다'
            : 'Press 1-5 to answer, ← → to navigate'}
        </p>
      </div>
    </div>
  )
}
