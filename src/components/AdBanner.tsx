import { useEffect, useRef } from 'react'

declare global {
  interface Window {
    adsbygoogle: unknown[]
  }
}

interface AdBannerProps {
  adSlot?: string
  format?: string
  className?: string
}

export default function AdBanner({
  adSlot = 'auto',
  format = 'auto',
  className = '',
}: AdBannerProps) {
  const adRef = useRef<HTMLModElement>(null)
  const pushed = useRef(false)

  useEffect(() => {
    if (pushed.current) return
    pushed.current = true

    try {
      ;(window.adsbygoogle = window.adsbygoogle || []).push({})
    } catch {
      // AdSense not loaded or blocked by ad blocker
    }
  }, [])

  return (
    <div
      className={`ad-banner-container ${className}`}
      style={{ minHeight: '100px', width: '100%', overflow: 'hidden' }}
    >
      <ins
        ref={adRef}
        className="adsbygoogle"
        style={{ display: 'block' }}
        data-ad-client="ca-pub-2988937021017804"
        data-ad-slot={adSlot}
        data-ad-format={format}
        data-full-width-responsive="true"
      />
    </div>
  )
}
