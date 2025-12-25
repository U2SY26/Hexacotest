const GEMINI_API_URL =
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent'

const factors = ['H', 'E', 'X', 'A', 'C', 'O'] as const

type Factor = typeof factors[number]

type Scores = Record<Factor, number>

type AnalysisFactor = {
  factor: Factor
  overview: string
  strengths: string[]
  risks: string[]
  growth: string
}

type AnalysisResponse = {
  summary: string
  factors: AnalysisFactor[]
}

const sanitizeScores = (scores: Record<string, unknown>): Scores => {
  const sanitized = {} as Scores
  for (const factor of factors) {
    const value = Number(scores[factor])
    if (!Number.isFinite(value)) {
      throw new Error(`Invalid score for ${factor}`)
    }
    sanitized[factor] = Math.max(0, Math.min(100, value))
  }
  return sanitized
}

const buildPrompt = (scores: Scores, language: 'ko' | 'en') => {
  const isKo = language === 'ko'

  return [
    'You are a HEXACO personality analyst.',
    isKo ? '언어: 한국어로 작성하세요.' : 'Language: English',
    'Use the continuous scores (0-100) to write a nuanced, non-clinical analysis.',
    'Avoid diagnoses, mental health claims, and MBTI references.',
    '',
    'IMPORTANT: Write a detailed, comprehensive analysis. Total response should be around 2500-3000 characters.',
    '',
    'Return JSON only with this schema:',
    '{"summary":"<detailed 3-4 sentence overall personality summary>", "factors":[{"factor":"H","overview":"<detailed 4-5 sentence analysis>","strengths":["<detailed phrase>","<detailed phrase>","<detailed phrase>"],"risks":["<detailed phrase>","<detailed phrase>"],"growth":"<2 actionable sentences>"}]}',
    '',
    'Requirements:',
    '- Include all six factors exactly once: H, E, X, A, C, O',
    '- summary: Comprehensive personality portrait (3-4 sentences)',
    '- overview: In-depth analysis of each factor (4-5 sentences each)',
    '- strengths: 3 detailed strengths per factor',
    '- risks: 2 potential challenges per factor',
    '- growth: 2 sentences with specific, actionable advice',
    '',
    `Scores: H=${scores.H.toFixed(1)}, E=${scores.E.toFixed(1)}, X=${scores.X.toFixed(1)}, A=${scores.A.toFixed(1)}, C=${scores.C.toFixed(1)}, O=${scores.O.toFixed(1)}`
  ].join('\n')
}

const extractJson = (text: string) => {
  const cleaned = text.replace(/```json|```/g, '').trim()
  const start = cleaned.indexOf('{')
  const end = cleaned.lastIndexOf('}')
  if (start === -1 || end === -1 || end <= start) return null
  return cleaned.slice(start, end + 1)
}

const parseAnalysis = (text: string): AnalysisResponse | null => {
  const jsonText = extractJson(text)
  if (!jsonText) return null
  try {
    const parsed = JSON.parse(jsonText) as AnalysisResponse
    if (!parsed || typeof parsed.summary !== 'string' || !Array.isArray(parsed.factors)) {
      return null
    }
    return parsed
  } catch {
    return null
  }
}

export default async function handler(req: any, res: any) {
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' })
    return
  }

  const apiKey = process.env.GEMINI_API_KEY
  if (!apiKey) {
    res.status(500).json({ error: 'Missing GEMINI_API_KEY' })
    return
  }

  try {
    const { scores, language } = req.body ?? {}
    if (!scores || typeof scores !== 'object') {
      res.status(400).json({ error: 'Invalid scores payload' })
      return
    }

    const sanitizedScores = sanitizeScores(scores)
    const lang = language === 'en' ? 'en' : 'ko'
    const prompt = buildPrompt(sanitizedScores, lang)

    const response = await fetch(`${GEMINI_API_URL}?key=${apiKey}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ role: 'user', parts: [{ text: prompt }] }],
        generationConfig: {
          temperature: 0.7,
          topP: 0.9,
          maxOutputTokens: 2500
        }
      })
    })

    const payload = await response.json()
    if (!response.ok) {
      res.status(response.status).json({
        error: payload?.error?.message ?? 'Gemini request failed'
      })
      return
    }

    const text = payload?.candidates?.[0]?.content?.parts?.[0]?.text
    if (!text) {
      res.status(502).json({ error: 'No response text from Gemini' })
      return
    }

    const parsed = parseAnalysis(text)
    if (parsed) {
      res.status(200).json(parsed)
      return
    }

    res.status(200).json({
      summary: text,
      factors: []
    })
  } catch (error: any) {
    res.status(500).json({ error: error?.message ?? 'Server error' })
  }
}
