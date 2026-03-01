import { create } from 'zustand'
import { persist } from 'zustand/middleware'

export type CardRarity = 'r' | 'sr' | 'ssr' | 'legend'

// 랜덤 카드 배경 테마
export const CARD_THEMES = [
  { id: 'aurora', gradient: 'linear-gradient(160deg, #0f0c29 0%, #302b63 50%, #24243e 100%)', accent: '#7c3aed' },
  { id: 'ember', gradient: 'linear-gradient(160deg, #1a0a0a 0%, #4a1515 50%, #1a0a0a 100%)', accent: '#ef4444' },
  { id: 'ocean', gradient: 'linear-gradient(160deg, #0a1628 0%, #1e3a5f 50%, #0a1628 100%)', accent: '#3b82f6' },
  { id: 'forest', gradient: 'linear-gradient(160deg, #0a1a0a 0%, #1a3a2a 50%, #0a1a0a 100%)', accent: '#10b981' },
  { id: 'sunset', gradient: 'linear-gradient(160deg, #1a0f05 0%, #4a2010 50%, #1a0f05 100%)', accent: '#f59e0b' },
  { id: 'cosmic', gradient: 'linear-gradient(160deg, #1A1035 0%, #2D1B4E 50%, #1A1035 100%)', accent: '#8b5cf6' },
  { id: 'cherry', gradient: 'linear-gradient(160deg, #1a0515 0%, #3d1030 50%, #1a0515 100%)', accent: '#ec4899' },
  { id: 'arctic', gradient: 'linear-gradient(160deg, #0a1520 0%, #153045 50%, #0a1520 100%)', accent: '#06b6d4' },
  { id: 'volcanic', gradient: 'linear-gradient(160deg, #150505 0%, #3d1010 50%, #150505 100%)', accent: '#dc2626' },
  { id: 'nebula', gradient: 'linear-gradient(160deg, #150520 0%, #2d1050 50%, #150520 100%)', accent: '#a855f7' },
  { id: 'jade', gradient: 'linear-gradient(160deg, #051510 0%, #103d2d 50%, #051510 100%)', accent: '#059669' },
  { id: 'golden', gradient: 'linear-gradient(160deg, #151005 0%, #3d2d10 50%, #151005 100%)', accent: '#d97706' },
] as const

export type CardThemeId = typeof CARD_THEMES[number]['id']

// 랜덤 홀로그램 패턴
export const HOLO_PATTERNS = [
  'rainbow',     // 무지개 그라디언트
  'prism',       // 프리즘 분산
  'stardust',    // 별가루
  'diamond',     // 다이아몬드 패턴
  'flame',       // 불꽃 패턴
  'wave',        // 파도 패턴
] as const

export type HoloPattern = typeof HOLO_PATTERNS[number]

export interface SavedCard {
  id: string
  createdAt: number
  rarity: CardRarity
  themeId: CardThemeId
  holoPattern: HoloPattern
  cardNumber: string
  // 결과 데이터
  scores: { H: number; E: number; X: number; A: number; C: number; O: number }
  personalityTitle: { emoji: string; titleKo: string; titleEn: string }
  mainQuote: { emoji: string; quoteKo: string; quoteEn: string }
  topMatch: { name: string; similarity: number }
  mbti: string
}

interface CardState {
  cards: SavedCard[]
  addCard: (card: Omit<SavedCard, 'id' | 'createdAt' | 'rarity' | 'themeId' | 'holoPattern' | 'cardNumber'>) => SavedCard
  removeCard: (id: string) => void
  getCard: (id: string) => SavedCard | undefined
}

/** 레어도 결정 — 원신 스타일 확률
 * 기본: R 55%, SR 35%, SSR 8.5%, LEGEND 1.5%
 * 점수 편차가 클수록 확률 보너스 */
function determineRarity(scores: SavedCard['scores']): CardRarity {
  const values = Object.values(scores)
  const avg = values.reduce((a, b) => a + b, 0) / values.length
  const variance = values.reduce((sum, v) => sum + (v - avg) ** 2, 0) / values.length
  const stdDev = Math.sqrt(variance)
  const extremeCount = values.filter(v => v >= 90 || v <= 10).length

  // 편차 보너스 (0~1.0)
  let bonus = 0
  if (stdDev > 25 || extremeCount >= 3) bonus = 1.0
  else if (stdDev > 18 || extremeCount >= 2) bonus = 0.6
  else if (stdDev > 12 || extremeCount >= 1) bonus = 0.3

  const legendRate = 1.5 + bonus * 1.5   // 1.5% ~ 3%
  const ssrRate = 8.5 + bonus * 5.5      // 8.5% ~ 14%
  const srRate = 35.0 + bonus * 3.0      // 35% ~ 38%

  const rand = Math.random() * 100

  if (rand < legendRate) return 'legend'
  if (rand < legendRate + ssrRate) return 'ssr'
  if (rand < legendRate + ssrRate + srRate) return 'sr'
  return 'r'
}

/** 랜덤 카드번호 생성 (예: #A3F7) */
function generateCardNumber(): string {
  const chars = '0123456789ABCDEF'
  let result = '#'
  for (let i = 0; i < 4; i++) {
    result += chars[Math.floor(Math.random() * chars.length)]
  }
  return result
}

export const useCardStore = create<CardState>()(
  persist(
    (set, get) => ({
      cards: [],

      addCard: (cardData) => {
        const rarity = determineRarity(cardData.scores)
        const themeId = CARD_THEMES[Math.floor(Math.random() * CARD_THEMES.length)].id
        const holoPattern = HOLO_PATTERNS[Math.floor(Math.random() * HOLO_PATTERNS.length)]

        const newCard: SavedCard = {
          ...cardData,
          id: `card-${Date.now()}-${Math.random().toString(36).slice(2, 6)}`,
          createdAt: Date.now(),
          rarity,
          themeId,
          holoPattern,
          cardNumber: generateCardNumber(),
        }

        set(state => ({ cards: [newCard, ...state.cards] }))
        return newCard
      },

      removeCard: (id) => {
        set(state => ({ cards: state.cards.filter(c => c.id !== id) }))
      },

      getCard: (id) => {
        return get().cards.find(c => c.id === id)
      },
    }),
    { name: 'hexaco-card-collection' }
  )
)

/** 레어도별 통계 */
export function getCardStats(cards: SavedCard[]) {
  const stats = { r: 0, sr: 0, ssr: 0, legend: 0, total: cards.length }
  for (const card of cards) {
    stats[card.rarity]++
  }
  return stats
}

/** 레어도 라벨 */
export const rarityLabels: Record<CardRarity, { ko: string; en: string; color: string }> = {
  r: { ko: 'R', en: 'R', color: '#9CA3AF' },
  sr: { ko: 'SR', en: 'SR', color: '#3B82F6' },
  ssr: { ko: 'SSR', en: 'SSR', color: '#A855F7' },
  legend: { ko: 'LEGEND', en: 'LEGEND', color: '#F59E0B' },
}
