interface ChatMessage {
  role: 'user' | 'assistant'
  content: string
}

interface CounselRequest {
  model: 'openai' | 'claude'
  messages: ChatMessage[]
  systemPrompt: string
}

export default async function handler(req: any, res: any) {
  // CORS
  res.setHeader('Access-Control-Allow-Origin', '*')
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS')
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type')

  if (req.method === 'OPTIONS') {
    res.status(200).end()
    return
  }

  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' })
    return
  }

  try {
    const { model, messages, systemPrompt } = req.body as CounselRequest

    if (!model || !messages || !systemPrompt) {
      res.status(400).json({ error: 'Missing required fields: model, messages, systemPrompt' })
      return
    }

    if (model === 'openai') {
      const content = await callOpenAI(systemPrompt, messages)
      res.status(200).json({ content })
    } else if (model === 'claude') {
      const content = await callClaude(systemPrompt, messages)
      res.status(200).json({ content })
    } else {
      res.status(400).json({ error: `Unsupported model: ${model}` })
    }
  } catch (error: any) {
    console.error('Counsel API error:', error)
    res.status(500).json({ error: error?.message ?? 'Server error' })
  }
}

async function callOpenAI(systemPrompt: string, messages: ChatMessage[]): Promise<string> {
  const apiKey = process.env.OPENAI_API_KEY
  if (!apiKey) throw new Error('Missing OPENAI_API_KEY')

  const openaiMessages = [
    { role: 'system', content: systemPrompt },
    ...messages.map(m => ({ role: m.role, content: m.content })),
  ]

  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model: 'gpt-4o-mini',
      messages: openaiMessages,
      max_tokens: 500,
      temperature: 0.8,
    }),
  })

  if (!response.ok) {
    const error = await response.json().catch(() => ({}))
    throw new Error(`OpenAI error ${response.status}: ${JSON.stringify(error)}`)
  }

  const data = await response.json() as any
  return data.choices?.[0]?.message?.content ?? ''
}

async function callClaude(systemPrompt: string, messages: ChatMessage[]): Promise<string> {
  const apiKey = process.env.ANTHROPIC_API_KEY
  if (!apiKey) throw new Error('Missing ANTHROPIC_API_KEY')

  const claudeMessages = messages.map(m => ({
    role: m.role,
    content: m.content,
  }))

  const response = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
      'anthropic-version': '2023-06-01',
    },
    body: JSON.stringify({
      model: 'claude-haiku-4-5-20251001',
      system: systemPrompt,
      messages: claudeMessages,
      max_tokens: 500,
      temperature: 0.8,
    }),
  })

  if (!response.ok) {
    const error = await response.json().catch(() => ({}))
    throw new Error(`Claude error ${response.status}: ${JSON.stringify(error)}`)
  }

  const data = await response.json() as any
  return data.content?.[0]?.text ?? ''
}
