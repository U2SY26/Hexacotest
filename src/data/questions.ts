import questionsJson from './questions600.json'

export interface Question {
  id: number
  factor: 'H' | 'E' | 'X' | 'A' | 'C' | 'O'
  facet: number
  reverse: boolean
  ko: string
  en: string
  koExample?: string
  enExample?: string
  tier: 1 | 2 | 3
}

export type TestVersion = 60 | 120 | 180

export const testVersions: { value: TestVersion; labelKey: string; descKey: string; minutes: number }[] = [
  { value: 60, labelKey: 'test.version.quick', descKey: 'test.version.quickDesc', minutes: 5 },
  { value: 120, labelKey: 'test.version.standard', descKey: 'test.version.standardDesc', minutes: 10 },
  { value: 180, labelKey: 'test.version.detailed', descKey: 'test.version.detailedDesc', minutes: 15 },
]

// All 600 questions from JSON (100 per factor)
export const allQuestions: Question[] = questionsJson.map(q => ({
  id: q.id,
  factor: q.factor as Question['factor'],
  facet: q.facet,
  tier: q.tier as 1 | 2 | 3,
  reverse: q.reverse,
  ko: q.ko,
  en: q.en,
  koExample: q.ko_example,
  enExample: q.en_example,
}))

// Backwards-compatible alias
export const questions = allQuestions

// Legacy function (now unused, kept for compatibility)
export const getQuestionsForVersion = (version: TestVersion): Question[] => {
  const maxTier = version === 60 ? 1 : version === 120 ? 2 : 3
  return allQuestions.filter(q => q.tier <= maxTier)
}

// Fisher-Yates shuffle helper
const shuffle = <T>(arr: T[]): T[] => {
  const a = [...arr]
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]]
  }
  return a
}

// Randomly select N questions per factor from the 600-question pool
// version 60 = 10/factor, 120 = 20/factor, 180 = 30/factor
// Ensures no duplicate question text appears in a single test session
export const selectRandomQuestions = (version: TestVersion): Question[] => {
  const perFactor = version === 60 ? 10 : version === 120 ? 20 : 30
  const selected: Question[] = []
  const usedTexts = new Set<string>()

  for (const factor of factors) {
    const factorQuestions = allQuestions.filter(q => q.factor === factor)
    const shuffled = shuffle(factorQuestions)
    let count = 0
    for (const q of shuffled) {
      if (count >= perFactor) break
      // Skip questions with duplicate text (ko or en)
      if (usedTexts.has(q.ko) || usedTexts.has(q.en)) continue
      usedTexts.add(q.ko)
      usedTexts.add(q.en)
      selected.push(q)
      count++
    }
  }

  return shuffle(selected)
}

export const factorColors: Record<string, string> = {
  H: '#8B5CF6', // purple
  E: '#EC4899', // pink
  X: '#F59E0B', // amber
  A: '#10B981', // emerald
  C: '#3B82F6', // blue
  O: '#EF4444', // red
}

export const factors = ['H', 'E', 'X', 'A', 'C', 'O'] as const
export type Factor = typeof factors[number]
