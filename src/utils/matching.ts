import { personas, Persona } from '../data/personas'
import { factors } from '../data/questions'

interface Scores {
  H: number
  E: number
  X: number
  A: number
  C: number
  O: number
}

// 유클리드 거리 기반 유사도
function euclideanSimilarity(a: number[], b: number[]): number {
  let sum = 0
  for (let i = 0; i < a.length; i++) {
    sum += Math.pow(a[i] - b[i], 2)
  }
  const distance = Math.sqrt(sum)
  // 최대 거리를 기준으로 유사도 계산 (100점 만점)
  const maxDistance = Math.sqrt(6 * Math.pow(100, 2))
  return Math.round((1 - distance / maxDistance) * 100)
}

export interface MatchResult {
  persona: Persona
  similarity: number
}

export function findBestMatch(scores: Scores): MatchResult {
  const userVector = factors.map(f => scores[f])

  let bestMatch: MatchResult = {
    persona: personas[0],
    similarity: 0
  }

  personas.forEach(persona => {
    const personaVector = factors.map(f => persona.scores[f])
    const similarity = euclideanSimilarity(userVector, personaVector)

    if (similarity > bestMatch.similarity) {
      bestMatch = { persona, similarity }
    }
  })

  return bestMatch
}

export function findTopMatches(scores: Scores, count: number = 3): MatchResult[] {
  const userVector = factors.map(f => scores[f])

  const matches = personas.map(persona => {
    const personaVector = factors.map(f => persona.scores[f])
    const similarity = euclideanSimilarity(userVector, personaVector)
    return { persona, similarity }
  })

  return matches
    .sort((a, b) => b.similarity - a.similarity)
    .slice(0, count)
}
