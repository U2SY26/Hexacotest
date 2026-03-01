const factors = ['H', 'E', 'X', 'A', 'C', 'O'] as const
type Factor = (typeof factors)[number]
type Scores = Record<Factor, number>

interface CompatibilityResponse {
  overallScore: number
  summary: string
  strengths: string[]
  challenges: string[]
  advice: string
  factorComparison: Array<{
    factor: Factor
    person1: number
    person2: number
    analysis: string
  }>
}

const sanitizeScores = (scores: Record<string, unknown>): Scores => {
  const sanitized = {} as Scores
  for (const factor of factors) {
    const value = Number(scores[factor])
    if (!Number.isFinite(value)) throw new Error(`Invalid score for ${factor}`)
    sanitized[factor] = Math.max(0, Math.min(100, value))
  }
  return sanitized
}

const buildPrompt = (scores1: Scores, scores2: Scores, language: 'ko' | 'en') => {
  const isKo = language === 'ko'

  const schema = JSON.stringify({
    overallScore: '<0-100 compatibility percentage>',
    summary: '<warm 3-4 sentence relationship analysis>',
    strengths: ['<strength 1>', '<strength 2>', '<strength 3>'],
    challenges: ['<challenge 1 framed positively>', '<challenge 2 framed positively>'],
    advice: '<2-3 sentences of encouraging, constructive advice>',
    factorComparison: factors.map(f => ({
      factor: f,
      person1: '<score>',
      person2: '<score>',
      analysis: '<1-2 sentence comparison for this factor>'
    }))
  })

  const lines = [
    `You are a warm, empathetic relationship psychologist analyzing compatibility between two people.`,
    ``,
    `Person 1's personality scores across 6 dimensions (0-100):`,
    ...factors.map(f => `  ${f}: ${scores1[f]}`),
    ``,
    `Person 2's personality scores across 6 dimensions (0-100):`,
    ...factors.map(f => `  ${f}: ${scores2[f]}`),
    ``,
    `Dimensions: H=Honesty-Humility, E=Emotionality, X=Extraversion, A=Agreeableness, C=Conscientiousness, O=Openness to Experience.`,
    ``,
    isKo
      ? `한국어로 답변해주세요. 따뜻하고 긍정적인 톤으로 작성하세요. 존댓말을 사용하세요.`
      : `Respond in English. Use a warm, encouraging, and positive tone.`,
    ``,
    `Guidelines:`,
    `- Focus on how differences COMPLEMENT each other, not just similarities`,
    `- Frame challenges as growth opportunities for the relationship`,
    `- Be specific about which personality dimensions create synergy or tension`,
    `- The overall score should reflect genuine compatibility (don't always give high scores)`,
    `- Advice should be actionable and specific to their personality combination`,
    `- Do NOT make clinical claims or diagnoses`,
    ``,
    `Return JSON only with this schema:`,
    schema,
  ]
  return lines.join('\n')
}

export default async function handler(req: any, res: any) {
  if (req.method !== 'POST') return res.status(405).end()

  try {
    const { scores1, scores2, language = 'ko' } = req.body
    if (!scores1 || !scores2) return res.status(400).json({ error: 'Both scores required' })

    const s1 = sanitizeScores(scores1)
    const s2 = sanitizeScores(scores2)
    const lang = language === 'en' ? 'en' : 'ko'

    const apiKey = process.env.GEMINI_API_KEY
    if (!apiKey) return res.status(500).json({ error: 'API key not configured' })

    const prompt = buildPrompt(s1, s2, lang)

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=${apiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{ parts: [{ text: prompt }] }],
          generationConfig: {
            temperature: 0.7,
            maxOutputTokens: 2500,
            responseMimeType: 'application/json',
          },
        }),
      }
    )

    if (!response.ok) {
      const errText = await response.text()
      return res.status(502).json({ error: 'AI API error', detail: errText })
    }

    const data = await response.json()
    const text = data?.candidates?.[0]?.content?.parts?.[0]?.text
    if (!text) return res.status(502).json({ error: 'Empty AI response' })

    const jsonText = text.replace(/```json\n?|\n?```/g, '').trim()
    const parsed = JSON.parse(jsonText) as CompatibilityResponse

    return res.status(200).json(parsed)
  } catch (err: any) {
    return res.status(500).json({ error: err.message || 'Internal error' })
  }
}
