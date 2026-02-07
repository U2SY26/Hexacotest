import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import { Question, Factor, factors, TestVersion, selectRandomQuestions } from '../data/questions'

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
  testVersion: TestVersion
  currentIndex: number
  answers: Answer[]
  scores: Scores | null
  isCompleted: boolean
  selectedQuestions: Question[]

  setTestVersion: (version: TestVersion) => void
  setAnswer: (questionId: number, value: number) => void
  nextQuestion: () => void
  prevQuestion: () => void
  goToQuestion: (index: number) => void
  calculateScores: () => Scores
  reset: () => void
  getAnswer: (questionId: number) => number | undefined
  getQuestions: () => Question[]
}

const calculateFactorScore = (answers: Answer[], factor: Factor, selectedQuestions: Question[]): number => {
  const factorQuestions = selectedQuestions.filter(q => q.factor === factor)
  let total = 0
  let count = 0

  factorQuestions.forEach(question => {
    const answer = answers.find(a => a.questionId === question.id)
    if (answer) {
      // 0-100 스케일 직접 사용, reverse 적용
      const value = question.reverse ? (100 - answer.value) : answer.value
      total += value
      count++
    }
  })

  if (count === 0) return 50

  // 0-100 스케일 평균 계산
  const avgScore = total / count
  return Math.round(avgScore * 10) / 10
}

export const useTestStore = create<TestState>()(
  persist(
    (set, get) => ({
      testVersion: 60 as TestVersion,
      currentIndex: 0,
      answers: [],
      scores: null,
      isCompleted: false,
      selectedQuestions: [] as Question[],

      setTestVersion: (version) => {
        const selected = selectRandomQuestions(version)
        set({
          testVersion: version,
          currentIndex: 0,
          answers: [],
          scores: null,
          isCompleted: false,
          selectedQuestions: selected,
        })
      },

      setAnswer: (questionId, value) => {
        set(state => {
          const newAnswers = state.answers.filter(a => a.questionId !== questionId)
          newAnswers.push({ questionId, value })
          return { answers: newAnswers }
        })
      },

      nextQuestion: () => {
        const { selectedQuestions } = get()
        set(state => ({
          currentIndex: Math.min(state.currentIndex + 1, selectedQuestions.length - 1)
        }))
      },

      prevQuestion: () => {
        set(state => ({
          currentIndex: Math.max(state.currentIndex - 1, 0)
        }))
      },

      goToQuestion: (index) => {
        const { selectedQuestions } = get()
        set({ currentIndex: Math.max(0, Math.min(index, selectedQuestions.length - 1)) })
      },

      calculateScores: () => {
        const { answers, selectedQuestions } = get()
        const scores: Scores = {
          H: calculateFactorScore(answers, 'H', selectedQuestions),
          E: calculateFactorScore(answers, 'E', selectedQuestions),
          X: calculateFactorScore(answers, 'X', selectedQuestions),
          A: calculateFactorScore(answers, 'A', selectedQuestions),
          C: calculateFactorScore(answers, 'C', selectedQuestions),
          O: calculateFactorScore(answers, 'O', selectedQuestions),
        }
        set({ scores, isCompleted: true })
        return scores
      },

      reset: () => {
        const { testVersion } = get()
        set({
          currentIndex: 0,
          answers: [],
          scores: null,
          isCompleted: false,
          selectedQuestions: selectRandomQuestions(testVersion),
        })
      },

      getAnswer: (questionId) => {
        return get().answers.find(a => a.questionId === questionId)?.value
      },

      getQuestions: () => {
        const { selectedQuestions, testVersion } = get()
        // If no questions selected yet (e.g. restored from storage), select new ones
        if (selectedQuestions.length === 0) {
          const selected = selectRandomQuestions(testVersion)
          set({ selectedQuestions: selected })
          return selected
        }
        return selectedQuestions
      },
    }),
    {
      name: 'hexaco-test-storage',
      partialize: (state) => ({
        testVersion: state.testVersion,
        currentIndex: state.currentIndex,
        answers: state.answers,
        selectedQuestions: state.selectedQuestions,
      }),
    }
  )
)

// 결과를 URL로 인코딩
export const encodeResults = (scores: { H: number; E: number; X: number; A: number; C: number; O: number }): string => {
  const data = factors.map(f => scores[f]).join(',')
  return btoa(data)
}

// URL에서 결과 디코딩
export const decodeResults = (encoded: string): { H: number; E: number; X: number; A: number; C: number; O: number } | null => {
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
