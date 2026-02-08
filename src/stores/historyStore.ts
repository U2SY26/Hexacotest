import { create } from 'zustand'
import { persist } from 'zustand/middleware'

export interface SavedResult {
  id: string
  timestamp: number
  scores: { H: number; E: number; X: number; A: number; C: number; O: number }
  topMatchId: string
  similarity: number
  pin: string
  testVersion: number
}

interface HistoryState {
  entries: SavedResult[]
  saveResult: (entry: SavedResult) => void
  deleteResult: (id: string) => void
  clearAll: () => void
}

export const useHistoryStore = create<HistoryState>()(
  persist(
    (set) => ({
      entries: [],
      saveResult: (entry) => {
        set((state) => ({
          entries: [entry, ...state.entries].slice(0, 10),
        }))
      },
      deleteResult: (id) => {
        set((state) => ({
          entries: state.entries.filter((e) => e.id !== id),
        }))
      },
      clearAll: () => set({ entries: [] }),
    }),
    {
      name: 'hexaco-result-history',
    }
  )
)
