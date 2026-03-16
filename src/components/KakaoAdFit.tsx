import { useEffect, useRef } from 'react'

interface KakaoAdFitProps {
  adUnit: string
  width: number
  height: number
  className?: string
}

export default function KakaoAdFit({ adUnit, width, height, className = '' }: KakaoAdFitProps) {
  const containerRef = useRef<HTMLDivElement>(null)
  const initialized = useRef(false)

  useEffect(() => {
    if (initialized.current) return
    if (!containerRef.current) return

    const ins = document.createElement('ins')
    ins.className = 'kakao_ad_area'
    ins.style.display = 'none'
    ins.setAttribute('data-ad-unit', adUnit)
    ins.setAttribute('data-ad-width', String(width))
    ins.setAttribute('data-ad-height', String(height))
    containerRef.current.appendChild(ins)

    const script = document.createElement('script')
    script.type = 'text/javascript'
    script.src = '//t1.daumcdn.net/kas/static/ba.min.js'
    script.async = true
    containerRef.current.appendChild(script)

    initialized.current = true

    return () => {
      const el = containerRef.current
      if (el) {
        while (el.firstChild) {
          el.removeChild(el.firstChild)
        }
      }
      initialized.current = false
    }
  }, [adUnit, width, height])

  return <div ref={containerRef} className={className} />
}

// Ad unit IDs
export const KAKAO_AD = {
  BANNER_728x90: 'DAN-uxzw3h9FO8QFZD5C',
  SIDE_160x600: 'DAN-h39p43dtenuL60AL',
  RECT_300x250: 'DAN-MRkQoJb0GkqbAePm',
} as const
