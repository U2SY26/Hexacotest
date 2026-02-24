import { useTranslation } from 'react-i18next'
import { AlertTriangle, Info, Scale } from 'lucide-react'

interface DisclaimerSectionProps {
  variant?: 'full' | 'compact' | 'footer'
  showIcon?: boolean
}

export default function DisclaimerSection({
  variant = 'full',
  showIcon = true
}: DisclaimerSectionProps) {
  const { i18n } = useTranslation()
  const isKo = i18n.language === 'ko'

  const disclaimers = {
    unofficial: {
      ko: '본 테스트는 비공식 테스트이며, 오락 및 자기 이해 목적으로 제공됩니다.',
      en: 'This is an unofficial test, provided for entertainment and self-understanding purposes.'
    },
    academic: {
      ko: '본 테스트는 오락 및 자기 이해 목적으로만 제공되며, 학술 연구나 임상 진단용으로 사용할 수 없습니다.',
      en: 'This test is for entertainment and self-understanding purposes only. Not intended for academic research or clinical diagnosis.'
    },
    celebrity: {
      ko: '유명인 매칭은 공개된 정보를 바탕으로 한 추정치이며, 실제 해당 인물의 성격을 대표하지 않습니다.',
      en: 'Celebrity matches are estimates based on public information and do not represent the actual personalities of those individuals.'
    },
    accuracy: {
      ko: '테스트 결과는 참고용이며, 전문적인 심리 평가를 대체할 수 없습니다.',
      en: 'Test results are for reference only and cannot replace professional psychological assessment.'
    },
    hexaco: {
      ko: '본 테스트는 심리학 연구를 기반으로 한 6가지 심리 유형 분석 테스트입니다.',
      en: 'This test is a 6-type personality analysis based on psychological research.'
    },
    copyright: {
      ko: '본 테스트의 질문은 자체 제작된 상황 기반 문항입니다.',
      en: 'Test questions are original situation-based items.'
    }
  }

  if (variant === 'footer') {
    return (
      <div className="text-xs text-gray-500 space-y-1 text-center">
        <p>{disclaimers.unofficial[isKo ? 'ko' : 'en']}</p>
        <p>{disclaimers.academic[isKo ? 'ko' : 'en']}</p>
      </div>
    )
  }

  if (variant === 'compact') {
    return (
      <div className="bg-dark-card/50 border border-gray-700/50 rounded-lg p-3 text-xs text-gray-400">
        <div className="flex items-start gap-2">
          {showIcon && <Info className="w-4 h-4 mt-0.5 flex-shrink-0 text-gray-500" />}
          <div className="space-y-1">
            <p>{disclaimers.unofficial[isKo ? 'ko' : 'en']}</p>
            <p>{disclaimers.celebrity[isKo ? 'ko' : 'en']}</p>
          </div>
        </div>
      </div>
    )
  }

  // Full variant
  return (
    <div className="bg-dark-card border border-gray-700 rounded-xl p-6 space-y-4">
      <div className="flex items-center gap-3 mb-4">
        {showIcon && (
          <div className="w-10 h-10 rounded-lg bg-yellow-500/10 flex items-center justify-center">
            <Scale className="w-5 h-5 text-yellow-500" />
          </div>
        )}
        <div>
          <h3 className="text-lg font-semibold text-white">
            {isKo ? '법적 고지 / Legal Notice' : 'Legal Notice'}
          </h3>
          <p className="text-sm text-gray-500">
            {isKo ? '이용 전 반드시 읽어주세요' : 'Please read before use'}
          </p>
        </div>
      </div>

      <div className="space-y-3 text-sm">
        {/* Unofficial Test Notice */}
        <div className="flex items-start gap-3 p-3 bg-orange-500/5 border border-orange-500/20 rounded-lg">
          <AlertTriangle className="w-5 h-5 text-orange-400 mt-0.5 flex-shrink-0" />
          <div>
            <p className="font-medium text-orange-300 mb-1">
              {isKo ? '비공식 테스트' : 'Unofficial Test'}
            </p>
            <p className="text-gray-400">{disclaimers.unofficial[isKo ? 'ko' : 'en']}</p>
          </div>
        </div>

        {/* Original Questions */}
        <div className="flex items-start gap-3 p-3 bg-dark-bg/50 rounded-lg">
          <Info className="w-5 h-5 text-blue-400 mt-0.5 flex-shrink-0" />
          <div>
            <p className="font-medium text-blue-300 mb-1">
              {isKo ? '자체 제작 문항' : 'Original Questions'}
            </p>
            <p className="text-gray-400">{disclaimers.copyright[isKo ? 'ko' : 'en']}</p>
          </div>
        </div>

        {/* Entertainment Purpose */}
        <div className="flex items-start gap-3 p-3 bg-dark-bg/50 rounded-lg">
          <Info className="w-5 h-5 text-purple-400 mt-0.5 flex-shrink-0" />
          <div>
            <p className="font-medium text-purple-300 mb-1">
              {isKo ? '오락/자기이해 목적' : 'Entertainment Purpose'}
            </p>
            <p className="text-gray-400">{disclaimers.academic[isKo ? 'ko' : 'en']}</p>
          </div>
        </div>

        {/* Celebrity Disclaimer */}
        <div className="flex items-start gap-3 p-3 bg-dark-bg/50 rounded-lg">
          <Info className="w-5 h-5 text-pink-400 mt-0.5 flex-shrink-0" />
          <div>
            <p className="font-medium text-pink-300 mb-1">
              {isKo ? '유명인 성격 추정' : 'Celebrity Personality Estimates'}
            </p>
            <p className="text-gray-400">{disclaimers.celebrity[isKo ? 'ko' : 'en']}</p>
          </div>
        </div>

        {/* Professional Advice */}
        <div className="flex items-start gap-3 p-3 bg-dark-bg/50 rounded-lg">
          <Info className="w-5 h-5 text-green-400 mt-0.5 flex-shrink-0" />
          <div>
            <p className="font-medium text-green-300 mb-1">
              {isKo ? '참고용 결과' : 'Reference Only'}
            </p>
            <p className="text-gray-400">{disclaimers.accuracy[isKo ? 'ko' : 'en']}</p>
          </div>
        </div>
      </div>

      {/* Attribution */}
      <div className="pt-4 border-t border-gray-700 text-xs text-gray-500">
        <p>{disclaimers.hexaco[isKo ? 'ko' : 'en']}</p>
      </div>
    </div>
  )
}

// Export individual disclaimer for flexible use
export function CelebrityDisclaimer() {
  const { i18n } = useTranslation()
  const isKo = i18n.language === 'ko'

  return (
    <div className="text-xs text-gray-500 bg-dark-bg/30 rounded-lg p-3 mt-4 border border-gray-700/50">
      <div className="flex items-start gap-2">
        <AlertTriangle className="w-4 h-4 mt-0.5 flex-shrink-0 text-yellow-500/70" />
        <p>
          {isKo
            ? '※ 유명인 매칭은 공개된 정보 기반 추정치이며, 실제 해당 인물의 성격을 대표하지 않습니다. 오락 목적으로만 제공됩니다.'
            : '※ Celebrity matches are estimates based on public information and do not represent actual personalities. Provided for entertainment purposes only.'
          }
        </p>
      </div>
    </div>
  )
}
