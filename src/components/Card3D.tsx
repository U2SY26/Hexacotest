import { useState, useRef, useCallback, useMemo, useEffect } from 'react'
import { motion, useMotionValue, useSpring, useTransform, type MotionValue } from 'framer-motion'

// ─── Types ──────────────────────────────────────────────────────────────────────

type Rarity = 'common' | 'rare' | 'epic' | 'legendary'

interface Card3DProps {
  personalityTitle: { emoji: string; titleKo: string; titleEn: string }
  mainQuote: { emoji: string; quoteKo: string; quoteEn: string }
  topMatch: { name: string; similarity: number }
  scores: { H: number; E: number; X: number; A: number; C: number; O: number }
  rarity: Rarity
  cardNumber: string
  isKo: boolean
  onCapture?: () => void
}

// ─── Constants ──────────────────────────────────────────────────────────────────

const FACTOR_COLORS: Record<string, string> = {
  H: '#8B5CF6',
  E: '#EC4899',
  X: '#F59E0B',
  A: '#10B981',
  C: '#3B82F6',
  O: '#EF4444',
}

const FACTOR_LABELS_KO: Record<string, string> = {
  H: '정직-겸손',
  E: '정서성',
  X: '외향성',
  A: '원만성',
  C: '성실성',
  O: '개방성',
}

const FACTOR_LABELS_EN: Record<string, string> = {
  H: 'Honesty',
  E: 'Emotion',
  X: 'Extraversion',
  A: 'Agreeableness',
  C: 'Conscientiousness',
  O: 'Openness',
}

const RARITY_CONFIG: Record<Rarity, {
  label: string
  icon: string
  borderColor: string
  glowColor: string
  shadowColor: string
  badgeBg: string
}> = {
  common: {
    label: 'Common',
    icon: '\u26AA',
    borderColor: 'rgba(148, 163, 184, 0.3)',
    glowColor: 'rgba(148, 163, 184, 0.0)',
    shadowColor: 'rgba(148, 163, 184, 0.1)',
    badgeBg: 'rgba(148, 163, 184, 0.2)',
  },
  rare: {
    label: 'Rare',
    icon: '\uD83D\uDD35',
    borderColor: 'rgba(59, 130, 246, 0.6)',
    glowColor: 'rgba(59, 130, 246, 0.3)',
    shadowColor: 'rgba(59, 130, 246, 0.25)',
    badgeBg: 'rgba(59, 130, 246, 0.25)',
  },
  epic: {
    label: 'Epic',
    icon: '\uD83D\uDC9C',
    borderColor: 'rgba(168, 85, 247, 0.7)',
    glowColor: 'rgba(168, 85, 247, 0.4)',
    shadowColor: 'rgba(168, 85, 247, 0.3)',
    badgeBg: 'rgba(168, 85, 247, 0.3)',
  },
  legendary: {
    label: 'Legendary',
    icon: '\u2728',
    borderColor: 'rgba(251, 191, 36, 0.8)',
    glowColor: 'rgba(251, 191, 36, 0.5)',
    shadowColor: 'rgba(251, 191, 36, 0.35)',
    badgeBg: 'linear-gradient(135deg, rgba(251,191,36,0.4), rgba(245,158,11,0.4))',
  },
}

// ─── Sparkle Particle for Legendary ─────────────────────────────────────────────

function SparkleParticles() {
  const particles = useMemo(() => {
    return Array.from({ length: 20 }, (_, i) => ({
      id: i,
      x: Math.random() * 100,
      y: Math.random() * 100,
      size: Math.random() * 3 + 1,
      delay: Math.random() * 3,
      duration: Math.random() * 2 + 1.5,
    }))
  }, [])

  return (
    <div style={{ position: 'absolute', inset: 0, overflow: 'hidden', borderRadius: 16, pointerEvents: 'none', zIndex: 10 }}>
      {particles.map((p) => (
        <motion.div
          key={p.id}
          style={{
            position: 'absolute',
            left: `${p.x}%`,
            top: `${p.y}%`,
            width: p.size,
            height: p.size,
            borderRadius: '50%',
            background: 'white',
            boxShadow: '0 0 4px 1px rgba(251,191,36,0.8), 0 0 8px 2px rgba(251,191,36,0.4)',
          }}
          animate={{
            opacity: [0, 1, 0.8, 0],
            scale: [0, 1.2, 1, 0],
          }}
          transition={{
            duration: p.duration,
            delay: p.delay,
            repeat: Infinity,
            repeatDelay: Math.random() * 2 + 1,
            ease: 'easeInOut',
          }}
        />
      ))}
    </div>
  )
}

// ─── Hexagon SVG for the back ───────────────────────────────────────────────────

function HexagonGraphic({ scores }: { scores: Card3DProps['scores'] }) {
  const factors = ['H', 'E', 'X', 'A', 'C', 'O'] as const
  const cx = 60
  const cy = 60
  const maxR = 50

  const getPoint = (index: number, value: number) => {
    const angle = (Math.PI * 2 * index) / 6 - Math.PI / 2
    const r = (value / 100) * maxR
    return { x: cx + r * Math.cos(angle), y: cy + r * Math.sin(angle) }
  }

  const outerPoints = factors.map((_, i) => getPoint(i, 100))
  const outerPath = outerPoints.map((p, i) => `${i === 0 ? 'M' : 'L'} ${p.x} ${p.y}`).join(' ') + ' Z'

  const gridLevels = [25, 50, 75, 100]
  const gridPaths = gridLevels.map((level) => {
    const pts = factors.map((_, i) => getPoint(i, level))
    return pts.map((p, i) => `${i === 0 ? 'M' : 'L'} ${p.x} ${p.y}`).join(' ') + ' Z'
  })

  const dataPoints = factors.map((f, i) => getPoint(i, scores[f]))
  const dataPath = dataPoints.map((p, i) => `${i === 0 ? 'M' : 'L'} ${p.x} ${p.y}`).join(' ') + ' Z'

  return (
    <svg width="120" height="120" viewBox="0 0 120 120" style={{ opacity: 0.9 }}>
      <defs>
        <linearGradient id="hexFill" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#8B5CF6" stopOpacity="0.4" />
          <stop offset="50%" stopColor="#EC4899" stopOpacity="0.3" />
          <stop offset="100%" stopColor="#3B82F6" stopOpacity="0.4" />
        </linearGradient>
        <filter id="hexGlow">
          <feGaussianBlur stdDeviation="2" result="blur" />
          <feMerge>
            <feMergeNode in="blur" />
            <feMergeNode in="SourceGraphic" />
          </feMerge>
        </filter>
      </defs>

      {/* Grid lines */}
      {gridPaths.map((d, i) => (
        <path key={i} d={d} fill="none" stroke="rgba(255,255,255,0.08)" strokeWidth="0.5" />
      ))}

      {/* Axis lines */}
      {outerPoints.map((p, i) => (
        <line key={i} x1={cx} y1={cy} x2={p.x} y2={p.y} stroke="rgba(255,255,255,0.1)" strokeWidth="0.5" />
      ))}

      {/* Outer hexagon */}
      <path d={outerPath} fill="none" stroke="rgba(255,255,255,0.15)" strokeWidth="0.8" />

      {/* Data polygon */}
      <path d={dataPath} fill="url(#hexFill)" stroke="rgba(139,92,246,0.8)" strokeWidth="1.5" filter="url(#hexGlow)" />

      {/* Data points */}
      {dataPoints.map((p, i) => (
        <circle key={i} cx={p.x} cy={p.y} r="2.5" fill={FACTOR_COLORS[factors[i]]} stroke="white" strokeWidth="0.5" />
      ))}

      {/* Factor labels */}
      {factors.map((f, i) => {
        const labelP = getPoint(i, 125)
        return (
          <text
            key={f}
            x={labelP.x}
            y={labelP.y}
            textAnchor="middle"
            dominantBaseline="central"
            fill={FACTOR_COLORS[f]}
            fontSize="8"
            fontWeight="bold"
            style={{ fontFamily: 'Pretendard, system-ui, sans-serif' }}
          >
            {f}
          </text>
        )
      })}
    </svg>
  )
}

// ─── Front Side ─────────────────────────────────────────────────────────────────

function CardFront({
  personalityTitle,
  mainQuote,
  topMatch,
  rarity,
  cardNumber,
  isKo,
}: Omit<Card3DProps, 'scores' | 'onCapture'>) {
  const config = RARITY_CONFIG[rarity]

  return (
    <div
      style={{
        position: 'absolute',
        inset: 0,
        backfaceVisibility: 'hidden',
        WebkitBackfaceVisibility: 'hidden',
        borderRadius: 16,
        overflow: 'hidden',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
      }}
    >
      {/* Background gradient */}
      <div
        style={{
          position: 'absolute',
          inset: 0,
          background: 'linear-gradient(160deg, #1A1035 0%, #2D1B4E 50%, #1A1035 100%)',
          borderRadius: 16,
        }}
      />

      {/* Subtle texture overlay */}
      <div
        style={{
          position: 'absolute',
          inset: 0,
          backgroundImage: `radial-gradient(ellipse at 30% 20%, rgba(139,92,246,0.08) 0%, transparent 60%),
                            radial-gradient(ellipse at 70% 80%, rgba(236,72,153,0.06) 0%, transparent 60%)`,
          borderRadius: 16,
        }}
      />

      {/* Content */}
      <div style={{ position: 'relative', zIndex: 5, display: 'flex', flexDirection: 'column', alignItems: 'center', width: '100%', height: '100%', padding: '20px 16px 16px' }}>

        {/* Top row: rarity badge + card number */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', width: '100%', marginBottom: 8 }}>
          <div
            style={{
              background: typeof config.badgeBg === 'string' && config.badgeBg.includes('gradient') ? config.badgeBg : config.badgeBg,
              borderRadius: 999,
              padding: '3px 10px',
              display: 'flex',
              alignItems: 'center',
              gap: 4,
              backdropFilter: 'blur(8px)',
              border: `1px solid ${config.borderColor}`,
            }}
          >
            <span style={{ fontSize: 11 }}>{config.icon}</span>
            <span style={{ fontSize: 10, fontWeight: 700, color: 'rgba(255,255,255,0.85)', letterSpacing: 1, textTransform: 'uppercase', fontFamily: 'Pretendard, system-ui, sans-serif' }}>
              {config.label}
            </span>
          </div>
          <span style={{ fontSize: 11, color: 'rgba(255,255,255,0.35)', fontWeight: 600, fontFamily: 'monospace', letterSpacing: 1 }}>
            {cardNumber}
          </span>
        </div>

        {/* Hexagon logo mark */}
        <div style={{ marginTop: 4, marginBottom: 2 }}>
          <svg width="28" height="28" viewBox="0 0 32 32" fill="none">
            <path
              d="M16 2L28.66 9.5V24.5L16 32L3.34 24.5V9.5L16 2Z"
              stroke="rgba(139,92,246,0.5)"
              strokeWidth="1.5"
              fill="rgba(139,92,246,0.08)"
            />
          </svg>
        </div>

        {/* Large emoji */}
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', minHeight: 0 }}>
          <motion.div
            style={{ fontSize: 72, lineHeight: 1, marginBottom: 12, filter: 'drop-shadow(0 4px 20px rgba(139,92,246,0.4))' }}
            animate={{
              y: [0, -4, 0],
            }}
            transition={{
              duration: 3,
              repeat: Infinity,
              ease: 'easeInOut',
            }}
          >
            {personalityTitle.emoji}
          </motion.div>

          {/* Title */}
          <h2 style={{
            fontSize: 22,
            fontWeight: 800,
            color: 'white',
            textAlign: 'center',
            lineHeight: 1.3,
            margin: '0 0 4px',
            fontFamily: 'Pretendard, system-ui, sans-serif',
            textShadow: '0 2px 12px rgba(139,92,246,0.4)',
          }}>
            {isKo ? personalityTitle.titleKo : personalityTitle.titleEn}
          </h2>

          {/* Celebrity match */}
          <div style={{
            display: 'flex',
            alignItems: 'center',
            gap: 6,
            marginTop: 6,
            marginBottom: 10,
            padding: '4px 12px',
            background: 'rgba(255,255,255,0.06)',
            borderRadius: 999,
            border: '1px solid rgba(255,255,255,0.08)',
          }}>
            <span style={{ fontSize: 12, color: 'rgba(255,255,255,0.5)', fontFamily: 'Pretendard, system-ui, sans-serif' }}>
              {isKo ? '\uD83C\uDFAD \uB2EE\uC740 \uC720\uBA85\uC778' : '\uD83C\uDFAD Match'}
            </span>
            <span style={{ fontSize: 13, fontWeight: 700, color: 'white', fontFamily: 'Pretendard, system-ui, sans-serif' }}>
              {topMatch.name}
            </span>
            <span style={{
              fontSize: 11,
              fontWeight: 700,
              color: '#F59E0B',
              background: 'rgba(245,158,11,0.15)',
              borderRadius: 4,
              padding: '1px 5px',
            }}>
              {topMatch.similarity}%
            </span>
          </div>

          {/* Meme quote */}
          <p style={{
            fontSize: 13,
            color: 'rgba(255,255,255,0.6)',
            textAlign: 'center',
            lineHeight: 1.5,
            margin: 0,
            padding: '0 8px',
            fontFamily: 'Pretendard, system-ui, sans-serif',
            fontStyle: 'italic',
          }}>
            {mainQuote.emoji} {isKo ? `"${mainQuote.quoteKo}"` : `"${mainQuote.quoteEn}"`}
          </p>
        </div>

        {/* Bottom brand */}
        <div style={{
          display: 'flex',
          alignItems: 'center',
          gap: 6,
          marginTop: 'auto',
          paddingTop: 8,
          opacity: 0.4,
        }}>
          <svg width="14" height="14" viewBox="0 0 32 32" fill="none">
            <path d="M16 2L28.66 9.5V24.5L16 32L3.34 24.5V9.5L16 2Z" stroke="rgba(255,255,255,0.6)" strokeWidth="1.5" fill="none" />
          </svg>
          <span style={{ fontSize: 9, color: 'rgba(255,255,255,0.6)', fontWeight: 600, letterSpacing: 2, textTransform: 'uppercase', fontFamily: 'Pretendard, system-ui, sans-serif' }}>
            6{isKo ? '\uAC00\uC9C0 \uC2EC\uB9AC \uC720\uD615' : ' Psyche Types'}
          </span>
        </div>
      </div>
    </div>
  )
}

// ─── Back Side ──────────────────────────────────────────────────────────────────

function CardBack({ scores, isKo }: { scores: Card3DProps['scores']; isKo: boolean }) {
  const factors = ['H', 'E', 'X', 'A', 'C', 'O'] as const
  const labels = isKo ? FACTOR_LABELS_KO : FACTOR_LABELS_EN

  return (
    <div
      style={{
        position: 'absolute',
        inset: 0,
        backfaceVisibility: 'hidden',
        WebkitBackfaceVisibility: 'hidden',
        transform: 'rotateY(180deg)',
        borderRadius: 16,
        overflow: 'hidden',
      }}
    >
      {/* Background */}
      <div
        style={{
          position: 'absolute',
          inset: 0,
          background: 'linear-gradient(160deg, #1A1035 0%, #2D1B4E 50%, #1A1035 100%)',
          borderRadius: 16,
        }}
      />

      {/* Content */}
      <div style={{ position: 'relative', zIndex: 5, display: 'flex', flexDirection: 'column', alignItems: 'center', width: '100%', height: '100%', padding: '20px 20px 16px' }}>

        {/* Title */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 12 }}>
          <svg width="18" height="18" viewBox="0 0 32 32" fill="none">
            <path d="M16 2L28.66 9.5V24.5L16 32L3.34 24.5V9.5L16 2Z" stroke="#8B5CF6" strokeWidth="2" fill="rgba(139,92,246,0.15)" />
          </svg>
          <span style={{
            fontSize: 15,
            fontWeight: 800,
            color: 'white',
            letterSpacing: 1,
            fontFamily: 'Pretendard, system-ui, sans-serif',
          }}>
            {isKo ? '6\uAC00\uC9C0 \uC2EC\uB9AC \uC720\uD615' : '6 Psyche Types'}
          </span>
        </div>

        {/* Hexagon radar */}
        <div style={{ marginBottom: 12 }}>
          <HexagonGraphic scores={scores} />
        </div>

        {/* Factor bars */}
        <div style={{ width: '100%', display: 'flex', flexDirection: 'column', gap: 7, flex: 1 }}>
          {factors.map((f) => {
            const value = scores[f]
            const color = FACTOR_COLORS[f]
            return (
              <div key={f} style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                {/* Factor letter */}
                <div style={{
                  width: 22,
                  height: 22,
                  borderRadius: 6,
                  background: `${color}22`,
                  border: `1px solid ${color}44`,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  flexShrink: 0,
                }}>
                  <span style={{ fontSize: 11, fontWeight: 800, color, fontFamily: 'monospace' }}>{f}</span>
                </div>

                {/* Label + bar */}
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 2 }}>
                    <span style={{ fontSize: 10, color: 'rgba(255,255,255,0.55)', fontFamily: 'Pretendard, system-ui, sans-serif', fontWeight: 500 }}>
                      {labels[f]}
                    </span>
                    <span style={{ fontSize: 11, color: 'rgba(255,255,255,0.8)', fontWeight: 700, fontFamily: 'monospace' }}>
                      {value.toFixed(0)}%
                    </span>
                  </div>
                  <div style={{
                    height: 5,
                    background: 'rgba(255,255,255,0.06)',
                    borderRadius: 999,
                    overflow: 'hidden',
                  }}>
                    <motion.div
                      style={{
                        height: '100%',
                        borderRadius: 999,
                        background: `linear-gradient(90deg, ${color}cc, ${color})`,
                        boxShadow: `0 0 8px ${color}66`,
                      }}
                      initial={{ width: 0 }}
                      animate={{ width: `${value}%` }}
                      transition={{ duration: 0.8, delay: 0.1, ease: 'easeOut' }}
                    />
                  </div>
                </div>
              </div>
            )
          })}
        </div>

        {/* Bottom brand */}
        <div style={{
          display: 'flex',
          alignItems: 'center',
          gap: 6,
          marginTop: 'auto',
          paddingTop: 10,
          opacity: 0.35,
        }}>
          <span style={{ fontSize: 9, color: 'rgba(255,255,255,0.6)', fontWeight: 500, letterSpacing: 1, fontFamily: 'Pretendard, system-ui, sans-serif' }}>
            hexacotest.com
          </span>
        </div>
      </div>
    </div>
  )
}

// ─── Main Card3D Component ──────────────────────────────────────────────────────

const Card3D = ({
  personalityTitle,
  mainQuote,
  topMatch,
  scores,
  rarity,
  cardNumber,
  isKo,
}: Card3DProps) => {
  const containerRef = useRef<HTMLDivElement>(null)
  const [isFlipped, setIsFlipped] = useState(false)

  // Mouse position (normalized -0.5 to 0.5)
  const mouseX = useMotionValue(0)
  const mouseY = useMotionValue(0)

  // Hologram position (normalized 0 to 100)
  const holoX = useMotionValue(50)
  const holoY = useMotionValue(50)

  // Spring physics for tilt
  const springConfig = { stiffness: 150, damping: 20, mass: 0.5 }
  const rotateX = useSpring(useTransform(mouseY, [-0.5, 0.5], [15, -15]), springConfig)
  const rotateY = useSpring(useTransform(mouseX, [-0.5, 0.5], [-15, 15]), springConfig)

  // Hologram gradient angle derived from mouse
  const holoAngle = useTransform(mouseX, [-0.5, 0.5], [0, 360])
  const springHoloAngle = useSpring(holoAngle, { stiffness: 100, damping: 20 })

  const handlePointerMove = useCallback((e: React.PointerEvent<HTMLDivElement> | React.TouchEvent<HTMLDivElement>) => {
    if (!containerRef.current) return
    const rect = containerRef.current.getBoundingClientRect()
    let clientX: number, clientY: number

    if ('touches' in e) {
      clientX = e.touches[0].clientX
      clientY = e.touches[0].clientY
    } else {
      clientX = e.clientX
      clientY = e.clientY
    }

    const x = (clientX - rect.left) / rect.width - 0.5
    const y = (clientY - rect.top) / rect.height - 0.5

    mouseX.set(x)
    mouseY.set(y)
    holoX.set((x + 0.5) * 100)
    holoY.set((y + 0.5) * 100)
  }, [mouseX, mouseY, holoX, holoY])

  const handlePointerLeave = useCallback(() => {
    mouseX.set(0)
    mouseY.set(0)
    holoX.set(50)
    holoY.set(50)
  }, [mouseX, mouseY, holoX, holoY])

  const handleClick = useCallback(() => {
    setIsFlipped((prev) => !prev)
  }, [])

  const config = RARITY_CONFIG[rarity]

  // Animated border for epic/legendary
  const [borderAngle, setBorderAngle] = useState(0)
  useEffect(() => {
    if (rarity !== 'epic' && rarity !== 'legendary') return
    let frame: number
    const animate = () => {
      setBorderAngle((prev) => (prev + 0.8) % 360)
      frame = requestAnimationFrame(animate)
    }
    frame = requestAnimationFrame(animate)
    return () => cancelAnimationFrame(frame)
  }, [rarity])

  // Build animated border gradient
  const borderGradient = useMemo(() => {
    if (rarity === 'legendary') {
      return `conic-gradient(from ${borderAngle}deg, #fbbf24, #f59e0b, #ec4899, #8b5cf6, #3b82f6, #10b981, #f59e0b, #fbbf24)`
    }
    if (rarity === 'epic') {
      return `conic-gradient(from ${borderAngle}deg, #a855f7, #7c3aed, #ec4899, #8b5cf6, #a855f7)`
    }
    return 'none'
  }, [rarity, borderAngle])

  return (
    <div
      style={{
        perspective: 1000,
        width: 300,
        height: 420,
        cursor: 'pointer',
        userSelect: 'none',
        WebkitUserSelect: 'none',
      }}
    >
      <motion.div
        ref={containerRef}
        style={{
          width: '100%',
          height: '100%',
          position: 'relative',
          transformStyle: 'preserve-3d',
          rotateX,
          rotateY,
        }}
        animate={{
          rotateY: isFlipped ? 180 : 0,
        }}
        transition={{
          rotateY: { duration: 0.6, ease: [0.4, 0, 0.2, 1] },
        }}
        onPointerMove={handlePointerMove}
        onPointerLeave={handlePointerLeave}
        onTouchMove={handlePointerMove as unknown as React.TouchEventHandler}
        onTouchEnd={handlePointerLeave}
        onClick={handleClick}
      >
        {/* ── Animated Border (Epic / Legendary) ── */}
        {(rarity === 'epic' || rarity === 'legendary') && (
          <div
            style={{
              position: 'absolute',
              inset: -2,
              borderRadius: 18,
              background: borderGradient,
              zIndex: 0,
            }}
          />
        )}

        {/* ── Card Shell ── */}
        <div
          style={{
            position: 'absolute',
            inset: rarity === 'epic' || rarity === 'legendary' ? 2 : 0,
            borderRadius: 16,
            border: rarity === 'epic' || rarity === 'legendary' ? 'none' : `1.5px solid ${config.borderColor}`,
            boxShadow: `
              0 0 20px ${config.shadowColor},
              0 0 60px ${config.glowColor},
              0 25px 50px rgba(0,0,0,0.5)
            `,
            overflow: 'hidden',
            transformStyle: 'preserve-3d',
          }}
        >
          {/* ── Front Face ── */}
          <CardFront
            personalityTitle={personalityTitle}
            mainQuote={mainQuote}
            topMatch={topMatch}
            rarity={rarity}
            cardNumber={cardNumber}
            isKo={isKo}
          />

          {/* ── Back Face ── */}
          <CardBack scores={scores} isKo={isKo} />

          {/* ── Holographic Overlay (mouse-reactive) ── */}
          <HologramLayer holoX={holoX} holoY={holoY} holoAngle={springHoloAngle} rarity={rarity} />

          {/* Sweep / glare layer */}
          <SweepLayer holoAngle={springHoloAngle} rarity={rarity} />

          {/* ── Legendary sparkles ── */}
          {rarity === 'legendary' && <SparkleParticles />}

          {/* ── Legendary pulsing glow ── */}
          {rarity === 'legendary' && (
            <motion.div
              style={{
                position: 'absolute',
                inset: -4,
                borderRadius: 20,
                pointerEvents: 'none',
                zIndex: -1,
                background: 'radial-gradient(ellipse at center, rgba(251,191,36,0.15), transparent 70%)',
              }}
              animate={{
                opacity: [0.4, 0.8, 0.4],
                scale: [1, 1.02, 1],
              }}
              transition={{
                duration: 2,
                repeat: Infinity,
                ease: 'easeInOut',
              }}
            />
          )}
        </div>
      </motion.div>
    </div>
  )
}

// ─── Hologram Layer (uses useTransform for live CSS updates) ────────────────────

function HologramLayer({
  holoX,
  holoY,
  holoAngle: _holoAngle,
  rarity,
}: {
  holoX: MotionValue<number>
  holoY: MotionValue<number>
  holoAngle: MotionValue<number>
  rarity: Rarity
}) {
  const ref = useRef<HTMLDivElement>(null)

  const intensity = rarity === 'legendary' ? 0.35 : rarity === 'epic' ? 0.25 : rarity === 'rare' ? 0.18 : 0.1

  useEffect(() => {
    const el = ref.current
    if (!el) return

    const unsubX = holoX.on('change', (x) => {
      el.style.setProperty('--hx', `${x}%`)
    })
    const unsubY = holoY.on('change', (y) => {
      el.style.setProperty('--hy', `${y}%`)
    })

    return () => { unsubX(); unsubY() }
  }, [holoX, holoY])

  return (
    <motion.div
      ref={ref}
      style={{
        position: 'absolute',
        inset: 0,
        borderRadius: 16,
        pointerEvents: 'none',
        zIndex: 21,
        mixBlendMode: 'color-dodge',
        opacity: 0.6,
        background: `radial-gradient(
          ellipse at var(--hx, 50%) var(--hy, 50%),
          rgba(0,255,255,${intensity}) 0%,
          rgba(255,0,255,${intensity * 0.8}) 20%,
          rgba(255,255,0,${intensity * 0.6}) 40%,
          rgba(0,255,128,${intensity * 0.5}) 60%,
          rgba(128,0,255,${intensity * 0.3}) 80%,
          transparent 100%
        )`,
      }}
    />
  )
}

// ─── Sweep / Glare Layer ────────────────────────────────────────────────────────

function SweepLayer({
  holoAngle,
  rarity,
}: {
  holoAngle: MotionValue<number>
  rarity: Rarity
}) {
  const ref = useRef<HTMLDivElement>(null)

  const intensity = rarity === 'legendary' ? 0.3 : rarity === 'epic' ? 0.2 : rarity === 'rare' ? 0.12 : 0.06

  useEffect(() => {
    const el = ref.current
    if (!el) return

    const unsub = holoAngle.on('change', (angle) => {
      el.style.setProperty('--sweep-angle', `${angle}deg`)
    })

    return () => unsub()
  }, [holoAngle])

  return (
    <div
      ref={ref}
      style={{
        position: 'absolute',
        inset: 0,
        borderRadius: 16,
        pointerEvents: 'none',
        zIndex: 22,
        mixBlendMode: 'overlay',
        opacity: 0.7,
        background: `linear-gradient(
          var(--sweep-angle, 0deg),
          transparent 0%,
          rgba(255,255,255,${intensity}) 25%,
          rgba(0,255,255,${intensity * 0.7}) 35%,
          rgba(255,0,255,${intensity * 0.5}) 50%,
          rgba(255,255,0,${intensity * 0.6}) 65%,
          rgba(255,255,255,${intensity}) 75%,
          transparent 100%
        )`,
      }}
    />
  )
}

export default Card3D
