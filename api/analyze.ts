const factors = ['H', 'E', 'X', 'A', 'C', 'O'] as const
type Factor = (typeof factors)[number]
type Scores = Record<Factor, number>

interface AnalysisFactor {
  factor: Factor
  overview: string
  strengths: string[]
  risks: string[]
  growth: string
}

interface CompatibleMBTI {
  mbti: string
  reason: string
}

interface CelebrityMatch {
  name: string
  description: string
  similarity: number
  reason: string
}

interface RecommendationItem {
  title: string
  reason: string
}

interface Recommendations {
  books: RecommendationItem[]
  movies: RecommendationItem[]
  activities: RecommendationItem[]
}

interface AnalysisResponse {
  summary: string
  factors: AnalysisFactor[]
  compatibleMBTIs: CompatibleMBTI[]
  celebrityMatches?: CelebrityMatch[]
  recommendations?: Recommendations
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

const buildPrompt = (scores: Scores, language: 'ko' | 'en', country?: string) => {
  const isKo = language === 'ko'
  const includeCelebrities = !isKo && !!country

  const recommendationsSchema = ', "recommendations":{"books":[{"title":"<book title>","reason":"<1 sentence why>"},{"title":"<book title>","reason":"<1 sentence why>"},{"title":"<book title>","reason":"<1 sentence why>"}],"movies":[{"title":"<movie/drama title>","reason":"<1 sentence why>"},{"title":"<movie/drama title>","reason":"<1 sentence why>"},{"title":"<movie/drama title>","reason":"<1 sentence why>"}],"activities":[{"title":"<sport/hobby>","reason":"<1 sentence why>"},{"title":"<sport/hobby>","reason":"<1 sentence why>"},{"title":"<sport/hobby>","reason":"<1 sentence why>"}]}'
  const schemaBase = '{"summary":"<warm 3-4 sentence personality portrait>", "factors":[{"factor":"H","overview":"<warm 4-5 sentence analysis>","strengths":["<encouraging phrase>","<encouraging phrase>","<encouraging phrase>"],"risks":["<gently framed challenge>","<gently framed challenge>"],"growth":"<2 kind, actionable suggestions>"}], "compatibleMBTIs":[{"mbti":"XXXX","reason":"<1 sentence why this type is compatible>"},{"mbti":"XXXX","reason":"<1 sentence why>"},{"mbti":"XXXX","reason":"<1 sentence why>"}]'
  const schema = includeCelebrities
    ? schemaBase + ', "celebrityMatches":[{"name":"<full name>","description":"<brief role/title>","similarity":<70-95>,"reason":"<1 sentence why personality matches>"}]' + recommendationsSchema
    : schemaBase + recommendationsSchema

  const lines = [
    isKo
      ? '당신은 따뜻하고 공감 능력이 뛰어난 성격 심리학 전문가입니다. 마치 오랜 경험을 가진 심리상담사가 내담자에게 이야기하듯, 편안하고 다정한 말투로 분석해주세요.'
      : 'You are a warm, empathetic personality psychologist. Write as if you are a caring counselor speaking gently to a client, making them feel understood and valued.',
    '',
    isKo
      ? '말투 지침: 반말이 아닌 존댓말을 사용하세요. "~하시네요", "~이실 거예요", "~해보시는 건 어떨까요?" 같은 부드러운 표현을 쓰세요. 판단하지 말고, 있는 그대로의 모습을 긍정적으로 바라봐주세요. 단점도 따뜻하게 감싸안는 표현으로 전달하세요.'
      : 'Tone: Use warm, encouraging language. Say "you might find..." instead of "you lack...". Frame challenges as growth opportunities. Make the person feel seen and appreciated.',
    '',
    'Personality scores range from 0-100 across 6 dimensions (H, E, X, A, C, O). Analyze the unique combination holistically.',
    'Avoid clinical diagnoses and mental health claims.',
    '',
    'Return JSON only with this schema:',
    schema,
    '',
    'Requirements:',
    '- Include all six factors exactly once: H, E, X, A, C, O',
    '- summary: Paint a warm, holistic portrait that makes the person feel understood',
    '- overview: Explain each factor with empathy and insight (4-5 sentences)',
    '- strengths: 3 genuine strengths per factor, described encouragingly',
    '- risks: 2 challenges per factor, framed gently as areas for growth',
    '- growth: 2 kind, specific suggestions that feel like a friend\'s advice',
    '- compatibleMBTIs: Based on 6-factor scores, suggest exactly 3 MBTI types that would be most compatible. Estimate the user\'s own MBTI from scores (X→E/I, O→N/S, A→F/T, C→J/P) and pick 3 complementary types. Each reason should be warm and insightful.',
    isKo
      ? '- recommendations: 이 성격 프로필에 맞는 추천을 제공하세요. books: 이 성격에 어울리는 실제 유명한 책 3권 (한국어 제목 사용). movies: 이 성격에 어울리는 실제 유명한 영화/드라마/TV 프로그램 3편 (한국어 제목 사용). activities: 이 성격에 적합한 스포츠/취미/운동 3가지. 각각 성격과 맞는 이유를 따뜻한 한 문장으로 설명하세요.'
      : '- recommendations: Provide personality-based recommendations. books: 3 real, well-known books that match this personality profile. movies: 3 real, well-known movies/dramas/TV shows that match this personality. activities: 3 sports, hobbies, or exercises suited to this personality. Each with a brief, warm reason why it fits their personality.',
  ]

  if (includeCelebrities) {
    const region = country === 'international' ? 'globally recognized' : `from ${country} or internationally recognized`
    lines.push(
      `- celebrityMatches: Suggest exactly 5 well-known public figures ${region} whose personality would closely match this 6-factor profile. Include actors, musicians, athletes, leaders, or entrepreneurs that most people would recognize. Each similarity score should realistically reflect how close their personality is (70-95 range).`
    )
  }

  lines.push(
    '',
    `Scores: H=${scores.H.toFixed(1)}, E=${scores.E.toFixed(1)}, X=${scores.X.toFixed(1)}, A=${scores.A.toFixed(1)}, C=${scores.C.toFixed(1)}, O=${scores.O.toFixed(1)}`,
  )

  return lines.join('\n')
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
    const { scores, language, country } = req.body ?? {}
    if (!scores || typeof scores !== 'object') {
      res.status(400).json({ error: 'Invalid scores payload' })
      return
    }

    const sanitizedScores = sanitizeScores(scores)
    const lang = language === 'en' ? 'en' : 'ko'
    const countryStr = typeof country === 'string' ? country : undefined
    const prompt = buildPrompt(sanitizedScores, lang, countryStr)

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=${apiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{ parts: [{ text: prompt }] }],
          generationConfig: {
            temperature: 0.7,
            topP: 0.9,
            maxOutputTokens: 4500,
            responseMimeType: 'application/json',
          },
        }),
      }
    )

    const payload = await response.json()
    if (!response.ok) {
      res.status(response.status).json({
        error: payload?.error?.message ?? 'Gemini request failed',
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

    res.status(200).json({ summary: text, factors: [] })
  } catch (error: any) {
    res.status(500).json({ error: error?.message ?? 'Server error' })
  }
}
