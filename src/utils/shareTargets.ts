/**
 * SNS 공유 타겟 유틸리티
 * 인스타그램, 틱톡, 페이스북, 카카오톡, 트위터 공유 지원
 * 디바이스 언어 기반 자동 번역
 */

// 지원 언어
type ShareLang = 'ko' | 'en' | 'ja' | 'zh' | 'es' | 'fr' | 'de' | 'pt' | 'ru' | 'vi'

// 공유 텍스트 템플릿
const shareTemplates: Record<ShareLang, {
  result: string      // "{emoji} {title}" 뒤에 붙는 문구
  tryTest: string     // "나도 테스트하기" 류
  similarity: string  // "유사도 {n}%"
  mbti: string        // "MBTI 추정:"
}> = {
  ko: {
    result: '나의 성격 유형 결과!',
    tryTest: '나도 테스트하기 👉',
    similarity: '유사도',
    mbti: 'MBTI 추정',
  },
  en: {
    result: 'My personality type result!',
    tryTest: 'Try the test 👉',
    similarity: 'Similarity',
    mbti: 'Estimated MBTI',
  },
  ja: {
    result: '私の性格タイプの結果！',
    tryTest: 'テストしてみる 👉',
    similarity: '類似度',
    mbti: 'MBTI推定',
  },
  zh: {
    result: '我的性格类型结果！',
    tryTest: '我也来测试 👉',
    similarity: '相似度',
    mbti: 'MBTI预测',
  },
  es: {
    result: '¡Mi resultado de tipo de personalidad!',
    tryTest: 'Haz el test 👉',
    similarity: 'Similitud',
    mbti: 'MBTI estimado',
  },
  fr: {
    result: 'Mon résultat de type de personnalité !',
    tryTest: 'Fais le test 👉',
    similarity: 'Similarité',
    mbti: 'MBTI estimé',
  },
  de: {
    result: 'Mein Persönlichkeitstyp-Ergebnis!',
    tryTest: 'Mach den Test 👉',
    similarity: 'Ähnlichkeit',
    mbti: 'Geschätzter MBTI',
  },
  pt: {
    result: 'Meu resultado de tipo de personalidade!',
    tryTest: 'Faça o teste 👉',
    similarity: 'Similaridade',
    mbti: 'MBTI estimado',
  },
  ru: {
    result: 'Мой результат типа личности!',
    tryTest: 'Пройди тест 👉',
    similarity: 'Сходство',
    mbti: 'Предполагаемый MBTI',
  },
  vi: {
    result: 'Kết quả loại tính cách của tôi!',
    tryTest: 'Làm bài test 👉',
    similarity: 'Tương đồng',
    mbti: 'MBTI dự đoán',
  },
}

/** 브라우저 언어에서 ShareLang 추출 */
export function detectShareLang(): ShareLang {
  const nav = navigator.language?.toLowerCase() || 'ko'
  const prefix = nav.split('-')[0]
  if (prefix in shareTemplates) return prefix as ShareLang
  return 'en'
}

/** 공유 텍스트 생성 */
export interface ShareContent {
  emoji: string
  title: string
  quote: string
  mbti: string
  matchName: string
  matchSimilarity: number
  url: string
}

export function buildShareText(content: ShareContent, lang?: ShareLang): string {
  const l = lang || detectShareLang()
  const t = shareTemplates[l]
  return [
    `${content.emoji} ${content.title}`,
    t.result,
    '',
    `🔮 ${t.mbti}: ${content.mbti}`,
    `👤 ${content.matchName} (${t.similarity} ${content.matchSimilarity}%)`,
    '',
    `${t.tryTest} ${content.url}`,
  ].join('\n')
}

// === SNS 공유 함수 ===

/** 카카오톡 공유 (카카오 SDK 필요) */
export function shareKakao(content: ShareContent, imageUrl?: string) {
  const w = window as any
  if (!w.Kakao?.Share) {
    // SDK 미로드 시 URL 복사 fallback
    navigator.clipboard.writeText(content.url)
    return false
  }
  w.Kakao.Share.sendDefault({
    objectType: 'feed',
    content: {
      title: `${content.emoji} ${content.title}`,
      description: content.quote,
      imageUrl: imageUrl || `${window.location.origin}/og-image.png`,
      link: { mobileWebUrl: content.url, webUrl: content.url },
    },
    buttons: [
      {
        title: shareTemplates[detectShareLang()].tryTest.replace(' 👉', ''),
        link: { mobileWebUrl: content.url, webUrl: content.url },
      },
    ],
  })
  return true
}

/** 페이스북 공유 */
export function shareFacebook(url: string) {
  window.open(
    `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(url)}`,
    '_blank',
    'width=600,height=400'
  )
}

/** 트위터/X 공유 */
export function shareTwitter(content: ShareContent) {
  const text = `${content.emoji} ${content.title}\n${shareTemplates[detectShareLang()].result}`
  window.open(
    `https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}&url=${encodeURIComponent(content.url)}`,
    '_blank'
  )
}

/** 인스타그램 스토리 (모바일 딥링크) */
export function shareInstagram(url: string) {
  // 인스타그램은 URL 직접 공유 불가, 클립보드 복사 후 앱 열기
  navigator.clipboard.writeText(url)
  // 모바일에서 인스타 앱 열기 시도
  window.open('instagram://camera', '_blank')
  return true
}

/** 틱톡 공유 (URL 복사 + 앱 열기) */
export function shareTikTok(url: string) {
  navigator.clipboard.writeText(url)
  return true
}

/** 네이티브 공유 API (모바일 브라우저) */
export async function shareNative(content: ShareContent, imageBlob?: Blob): Promise<boolean> {
  if (!navigator.share) return false

  const shareData: ShareData = {
    title: `${content.emoji} ${content.title}`,
    text: buildShareText(content),
    url: content.url,
  }

  // 이미지가 있으면 파일로 첨부
  if (imageBlob && navigator.canShare) {
    const file = new File([imageBlob], 'personality-card.png', { type: 'image/png' })
    const withFile = { ...shareData, files: [file] }
    if (navigator.canShare(withFile)) {
      await navigator.share(withFile)
      return true
    }
  }

  await navigator.share(shareData)
  return true
}

/** 공유 플랫폼 목록 (UI 렌더용) */
export const sharePlatforms = [
  { id: 'kakao', label: '카카오톡', labelEn: 'KakaoTalk', icon: '💬', color: '#FEE500' },
  { id: 'instagram', label: '인스타그램', labelEn: 'Instagram', icon: '📸', color: '#E4405F' },
  { id: 'facebook', label: '페이스북', labelEn: 'Facebook', icon: '👤', color: '#1877F2' },
  { id: 'twitter', label: 'X (트위터)', labelEn: 'X (Twitter)', icon: '🐦', color: '#000000' },
  { id: 'tiktok', label: '틱톡', labelEn: 'TikTok', icon: '🎵', color: '#000000' },
] as const

export type SharePlatformId = typeof sharePlatforms[number]['id']
