import { useState, useEffect, useRef } from 'react'

interface IntroVideoProps {
  onComplete: () => void
}

export default function IntroVideo({ onComplete }: IntroVideoProps) {
  const [showSkip, setShowSkip] = useState(false)
  const [isPortrait, setIsPortrait] = useState(window.innerHeight > window.innerWidth)
  const videoRef = useRef<HTMLVideoElement>(null)

  useEffect(() => {
    // Show skip button after 2 seconds
    const timer = setTimeout(() => setShowSkip(true), 2000)

    // Handle orientation change
    const handleResize = () => {
      setIsPortrait(window.innerHeight > window.innerWidth)
    }
    window.addEventListener('resize', handleResize)

    return () => {
      clearTimeout(timer)
      window.removeEventListener('resize', handleResize)
    }
  }, [])

  const handleVideoEnd = () => {
    onComplete()
  }

  const handleSkip = () => {
    if (videoRef.current) {
      videoRef.current.pause()
    }
    onComplete()
  }

  return (
    <div
      style={{
        position: 'fixed',
        top: 0,
        left: 0,
        width: '100vw',
        height: '100vh',
        backgroundColor: '#1a1625',
        zIndex: 9999,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        overflow: 'hidden',
      }}
    >
      <video
        ref={videoRef}
        src={isPortrait ? '/video/promo-portrait.mp4' : '/video/promo-landscape.mp4'}
        autoPlay
        muted
        playsInline
        onEnded={handleVideoEnd}
        style={{
          width: '100%',
          height: '100%',
          objectFit: 'cover',
        }}
      />

      {showSkip && (
        <button
          onClick={handleSkip}
          style={{
            position: 'absolute',
            top: '24px',
            right: '24px',
            padding: '10px 20px',
            backgroundColor: 'rgba(0, 0, 0, 0.6)',
            color: 'rgba(255, 255, 255, 0.9)',
            border: '1px solid rgba(255, 255, 255, 0.3)',
            borderRadius: '24px',
            cursor: 'pointer',
            fontSize: '14px',
            fontWeight: 500,
            display: 'flex',
            alignItems: 'center',
            gap: '6px',
            backdropFilter: 'blur(8px)',
            transition: 'all 0.2s ease',
          }}
          onMouseOver={(e) => {
            e.currentTarget.style.backgroundColor = 'rgba(0, 0, 0, 0.8)'
          }}
          onMouseOut={(e) => {
            e.currentTarget.style.backgroundColor = 'rgba(0, 0, 0, 0.6)'
          }}
        >
          건너뛰기
          <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
            <path d="M6 18l8.5-6L6 6v12zM16 6v12h2V6h-2z" />
          </svg>
        </button>
      )}

      {/* Progress bar */}
      <div
        style={{
          position: 'absolute',
          bottom: '24px',
          left: '24px',
          right: '24px',
          height: '4px',
          backgroundColor: 'rgba(255, 255, 255, 0.2)',
          borderRadius: '2px',
          overflow: 'hidden',
        }}
      >
        <div
          style={{
            height: '100%',
            backgroundColor: '#8B5CF6',
            animation: 'progress 30s linear forwards',
          }}
        />
      </div>

      <style>{`
        @keyframes progress {
          from { width: 0%; }
          to { width: 100%; }
        }
      `}</style>
    </div>
  )
}
