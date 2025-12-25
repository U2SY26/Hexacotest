import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import { questions, Factor, factors } from '../data/questions'

interface Answer {
  questionId: number
  value: number
}

interface Scores {
  H: number
  E: number
  X: number
  A: number
  C: number
  O: number
}

interface TestState {
  currentIndex: number
  answers: Answer[]
  scores: Scores | null
  isCompleted: boolean

  setAnswer: (questionId: number, value: number) => void
  nextQuestion: () => void
  prevQuestion: () => void
  goToQuestion: (index: number) => void
  calculateScores: () => Scores
  reset: () => void
  getAnswer: (questionId: number) => number | undefined
}

const calculateFactorScore = (answers: Answer[], factor: Factor): number => {
  const factorQuestions = questions.filter(q => q.factor === factor)
  let total = 0
  let count = 0

  factorQuestions.forEach(question => {
    const answer = answers.find(a => a.questionId === question.id)
    if (answer) {
      const value = question.reverse ? (6 - answer.value) : answer.value
      total += value
      count++
    }
  })

  if (count === 0) return 50

  // 1-5 스케일을 0-100으로 변환
  const avgScore = total / count
  return Math.round(((avgScore - 1) / 4) * 100)
}

export const useTestStore = create<TestState>()(
  persist(
    (set, get) => ({
      currentIndex: 0,
      answers: [],
      scores: null,
      isCompleted: false,

      setAnswer: (questionId, value) => {
        set(state => {
          const newAnswers = state.answers.filter(a => a.questionId !== questionId)
          newAnswers.push({ questionId, value })
          return { answers: newAnswers }
        })
      },

      nextQuestion: () => {
        set(state => ({
          currentIndex: Math.min(state.currentIndex + 1, questions.length - 1)
        }))
      },

      prevQuestion: () => {
        set(state => ({
          currentIndex: Math.max(state.currentIndex - 1, 0)
        }))
      },

      goToQuestion: (index) => {
        set({ currentIndex: Math.max(0, Math.min(index, questions.length - 1)) })
      },

      calculateScores: () => {
        const { answers } = get()
        const scores: Scores = {
          H: calculateFactorScore(answers, 'H'),
          E: calculateFactorScore(answers, 'E'),
          X: calculateFactorScore(answers, 'X'),
          A: calculateFactorScore(answers, 'A'),
          C: calculateFactorScore(answers, 'C'),
          O: calculateFactorScore(answers, 'O'),
        }
        set({ scores, isCompleted: true })
        return scores
      },

      reset: () => {
        set({
          currentIndex: 0,
          answers: [],
          scores: null,
          isCompleted: false,
        })
      },

      getAnswer: (questionId) => {
        return get().answers.find(a => a.questionId === questionId)?.value
      },
    }),
    {
      name: 'hexaco-test-storage',
      partialize: (state) => ({
        currentIndex: state.currentIndex,
        answers: state.answers,
      }),
    }
  )
)

// 결과를 URL로 인코딩
export const encodeResults = (scores: Scores): string => {
  const data = factors.map(f => scores[f]).join(',')
  return btoa(data)
}

// URL에서 결과 디코딩
export const decodeResults = (encoded: string): Scores | null => {
  try {
    const data = atob(encoded)
    const values = data.split(',').map(Number)
    if (values.length !== 6 || values.some(isNaN)) return null

    return {
      H: values[0],
      E: values[1],
      X: values[2],
      A: values[3],
      C: values[4],
      O: values[5],
    }
  } catch {
    return null
  }
}
