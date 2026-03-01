import { useState, useCallback, useMemo, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import Card3D from './Card3D'
import type { SavedCard } from '../stores/cardStore'

// ─── Types ──────────────────────────────────────────────────────────────────────

type Phase = 'pack' | 'burst' | 'reveal' | 'interactive'

interface CardRevealModalProps {
  card: SavedCard
  isKo: boolean
  onClose: () => void
}

// ─── Rarity Visual Config ───────────────────────────────────────────────────────

const RARITY_FX: Record<SavedCard['rarity'], {
  burstColor: string
  particleColors: string[]
  glowColor: string
  borderGlow: string
  label: string
}> = {
  r: {
    burstColor: 'rgba(148, 163, 184, 0.6)',
    particleColors: ['#94A3B8', '#CBD5E1', '#E2E8F0'],
    glowColor: 'rgba(148, 163, 184, 0.3)',
    borderGlow: '0 0 30px rgba(148,163,184,0.3)',
    label: '🔷 R',
  },
  sr: {
    burstColor: 'rgba(59, 130, 246, 0.7)',
    particleColors: ['#3B82F6', '#60A5FA', '#93C5FD', '#2563EB'],
    glowColor: 'rgba(59, 130, 246, 0.4)',
    borderGlow: '0 0 40px rgba(59,130,246,0.4), 0 0 80px rgba(59,130,246,0.2)',
    label: '💎 SR',
  },
  ssr: {
    burstColor: 'rgba(168, 85, 247, 0.8)',
    particleColors: ['#A855F7', '#C084FC', '#E879F9', '#7C3AED'],
    glowColor: 'rgba(168, 85, 247, 0.5)',
    borderGlow: '0 0 50px rgba(168,85,247,0.5), 0 0 100px rgba(168,85,247,0.25)',
    label: '🌟 SSR',
  },
  legend: {
    burstColor: 'rgba(251, 191, 36, 0.9)',
    particleColors: ['#FBBF24', '#F59E0B', '#FDE68A', '#EF4444', '#A855F7', '#3B82F6'],
    glowColor: 'rgba(251, 191, 36, 0.6)',
    borderGlow: '0 0 60px rgba(251,191,36,0.6), 0 0 120px rgba(251,191,36,0.3), 0 0 200px rgba(251,191,36,0.15)',
    label: '👑 LEGEND 👑',
  },
}

// ─── Particle Components ────────────────────────────────────────────────────────

function BurstParticles({ rarity, active }: { rarity: SavedCard['rarity']; active: boolean }) {
  const fx = RARITY_FX[rarity]
  const particles = useMemo(() => {
    const count = rarity === 'legend' ? 60 : rarity === 'ssr' ? 45 : rarity === 'sr' ? 30 : 20
    return Array.from({ length: count }, (_, i) => {
      const angle = (Math.PI * 2 * i) / count + (Math.random() - 0.5) * 0.5
      const distance = 150 + Math.random() * 250
      const size = Math.random() * 6 + 2
      return {
        id: i,
        x: Math.cos(angle) * distance,
        y: Math.sin(angle) * distance,
        size,
        color: fx.particleColors[i % fx.particleColors.length],
        delay: Math.random() * 0.15,
        duration: 0.6 + Math.random() * 0.4,
      }
    })
  }, [rarity, fx.particleColors])

  if (!active) return null

  return (
    <div style={{ position: 'absolute', inset: 0, pointerEvents: 'none', zIndex: 50 }}>
      {particles.map((p) => (
        <motion.div
          key={p.id}
          style={{
            position: 'absolute',
            left: '50%',
            top: '50%',
            width: p.size,
            height: p.size,
            borderRadius: '50%',
            background: p.color,
            boxShadow: `0 0 ${p.size * 2}px ${p.color}`,
          }}
          initial={{ x: 0, y: 0, opacity: 1, scale: 1 }}
          animate={{
            x: p.x,
            y: p.y,
            opacity: [1, 1, 0],
            scale: [0.5, 1.5, 0],
          }}
          transition={{
            duration: p.duration,
            delay: p.delay,
            ease: 'easeOut',
          }}
        />
      ))}
    </div>
  )
}

function LightRays({ rarity, active }: { rarity: SavedCard['rarity']; active: boolean }) {
  const fx = RARITY_FX[rarity]
  const rays = useMemo(() => {
    const count = rarity === 'legend' ? 16 : rarity === 'ssr' ? 12 : 8
    return Array.from({ length: count }, (_, i) => ({
      id: i,
      rotation: (360 / count) * i,
      width: rarity === 'legend' ? 4 : 3,
      color: fx.particleColors[i % fx.particleColors.length],
    }))
  }, [rarity, fx.particleColors])

  if (!active) return null

  return (
    <div style={{ position: 'absolute', inset: 0, pointerEvents: 'none', zIndex: 45 }}>
      {rays.map((ray) => (
        <motion.div
          key={ray.id}
          style={{
            position: 'absolute',
            left: '50%',
            top: '50%',
            width: ray.width,
            height: '200%',
            background: `linear-gradient(to bottom, transparent 0%, ${ray.color} 30%, ${ray.color} 50%, transparent 100%)`,
            transformOrigin: 'center center',
            transform: `rotate(${ray.rotation}deg)`,
            filter: 'blur(2px)',
          }}
          initial={{ opacity: 0, scaleY: 0 }}
          animate={{
            opacity: [0, 0.8, 0],
            scaleY: [0, 1, 1.2],
          }}
          transition={{
            duration: 0.6,
            ease: 'easeOut',
          }}
        />
      ))}
    </div>
  )
}

function FloatingSparkles({ active }: { active: boolean }) {
  const sparkles = useMemo(() => {
    return Array.from({ length: 30 }, (_, i) => ({
      id: i,
      x: (Math.random() - 0.5) * 400,
      y: (Math.random() - 0.5) * 600,
      size: Math.random() * 4 + 1,
      delay: Math.random() * 2,
      duration: 1.5 + Math.random() * 2,
    }))
  }, [])

  if (!active) return null

  return (
    <div style={{ position: 'absolute', inset: 0, pointerEvents: 'none', zIndex: 55 }}>
      {sparkles.map((s) => (
        <motion.div
          key={s.id}
          style={{
            position: 'absolute',
            left: `calc(50% + ${s.x}px)`,
            top: `calc(50% + ${s.y}px)`,
            width: s.size,
            height: s.size,
            borderRadius: '50%',
            background: 'white',
            boxShadow: '0 0 6px 2px rgba(255,255,255,0.8), 0 0 12px 4px rgba(251,191,36,0.4)',
          }}
          animate={{
            opacity: [0, 1, 0.6, 0],
            scale: [0, 1.3, 1, 0],
            y: [0, -20, -40],
          }}
          transition={{
            duration: s.duration,
            delay: s.delay,
            repeat: Infinity,
            repeatDelay: 1,
            ease: 'easeInOut',
          }}
        />
      ))}
    </div>
  )
}

// ─── Card Pack (Unopened State) ─────────────────────────────────────────────────

function CardPack({ rarity, onOpen }: { rarity: SavedCard['rarity']; onOpen: () => void }) {
  const fx = RARITY_FX[rarity]
  const [borderAngle, setBorderAngle] = useState(0)

  useEffect(() => {
    let frame: number
    const animate = () => {
      setBorderAngle((prev) => (prev + 1.2) % 360)
      frame = requestAnimationFrame(animate)
    }
    frame = requestAnimationFrame(animate)
    return () => cancelAnimationFrame(frame)
  }, [])

  return (
    <motion.div
      style={{
        position: 'relative',
        width: 220,
        height: 310,
        cursor: 'pointer',
      }}
      initial={{ scale: 0, rotateY: -180, opacity: 0 }}
      animate={{
        scale: 1,
        rotateY: 0,
        opacity: 1,
        y: [0, -8, 0],
      }}
      transition={{
        scale: { duration: 0.6, ease: [0.2, 0.8, 0.2, 1] },
        rotateY: { duration: 0.8, ease: 'easeOut' },
        opacity: { duration: 0.4 },
        y: { duration: 2, repeat: Infinity, ease: 'easeInOut', delay: 0.8 },
      }}
      onClick={onOpen}
      whileHover={{ scale: 1.05 }}
      whileTap={{ scale: 0.95 }}
    >
      {/* Animated border glow */}
      <div
        style={{
          position: 'absolute',
          inset: -3,
          borderRadius: 20,
          background: `conic-gradient(from ${borderAngle}deg, ${fx.particleColors.join(', ')}, ${fx.particleColors[0]})`,
          filter: 'blur(1px)',
        }}
      />

      {/* Card back */}
      <div
        style={{
          position: 'absolute',
          inset: 2,
          borderRadius: 18,
          background: 'linear-gradient(160deg, #1A1035 0%, #2D1B4E 50%, #1A1035 100%)',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          gap: 16,
          boxShadow: fx.borderGlow,
          overflow: 'hidden',
        }}
      >
        {/* Shimmer effect */}
        <motion.div
          style={{
            position: 'absolute',
            inset: 0,
            background: 'linear-gradient(105deg, transparent 40%, rgba(255,255,255,0.08) 45%, rgba(255,255,255,0.15) 50%, rgba(255,255,255,0.08) 55%, transparent 60%)',
          }}
          animate={{ x: ['-100%', '200%'] }}
          transition={{ duration: 2, repeat: Infinity, repeatDelay: 1, ease: 'easeInOut' }}
        />

        {/* Hexagon logo */}
        <motion.svg
          width="60"
          height="60"
          viewBox="0 0 32 32"
          fill="none"
          animate={{ rotate: [0, 5, -5, 0] }}
          transition={{ duration: 4, repeat: Infinity, ease: 'easeInOut' }}
        >
          <path
            d="M16 2L28.66 9.5V24.5L16 32L3.34 24.5V9.5L16 2Z"
            stroke={fx.particleColors[0]}
            strokeWidth="1.5"
            fill={`${fx.particleColors[0]}22`}
          />
          <path
            d="M16 8L23.46 12.5V21.5L16 26L8.54 21.5V12.5L16 8Z"
            stroke={`${fx.particleColors[0]}88`}
            strokeWidth="1"
            fill="none"
          />
        </motion.svg>

        {/* Question mark */}
        <motion.span
          style={{
            fontSize: 36,
            fontWeight: 900,
            color: fx.particleColors[0],
            opacity: 0.6,
            textShadow: `0 0 20px ${fx.glowColor}`,
            fontFamily: 'Pretendard, system-ui, sans-serif',
          }}
          animate={{ opacity: [0.4, 0.7, 0.4] }}
          transition={{ duration: 1.5, repeat: Infinity, ease: 'easeInOut' }}
        >
          ?
        </motion.span>
      </div>

      {/* Tap instruction */}
      <motion.div
        style={{
          position: 'absolute',
          bottom: -40,
          left: 0,
          right: 0,
          textAlign: 'center',
          fontSize: 13,
          fontWeight: 600,
          color: 'rgba(255,255,255,0.5)',
          fontFamily: 'Pretendard, system-ui, sans-serif',
        }}
        animate={{ opacity: [0.4, 0.8, 0.4] }}
        transition={{ duration: 1.5, repeat: Infinity, ease: 'easeInOut' }}
      >
        TAP TO OPEN
      </motion.div>
    </motion.div>
  )
}

// ─── Rarity Announcement ────────────────────────────────────────────────────────

function RarityAnnouncement({ rarity, isKo }: { rarity: SavedCard['rarity']; isKo: boolean }) {
  const fx = RARITY_FX[rarity]
  void isKo // used for future localization

  return (
    <motion.div
      style={{
        position: 'absolute',
        bottom: 60,
        left: 0,
        right: 0,
        textAlign: 'center',
        zIndex: 60,
      }}
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: 0.5, duration: 0.5 }}
    >
      <motion.div
        style={{
          display: 'inline-block',
          padding: '8px 24px',
          borderRadius: 999,
          background: `linear-gradient(135deg, ${fx.glowColor}, transparent)`,
          border: `1px solid ${fx.particleColors[0]}66`,
          backdropFilter: 'blur(12px)',
        }}
        animate={rarity === 'legend' ? {
          boxShadow: [
            `0 0 20px ${fx.glowColor}`,
            `0 0 40px ${fx.glowColor}`,
            `0 0 20px ${fx.glowColor}`,
          ],
        } : {}}
        transition={{ duration: 1.5, repeat: Infinity }}
      >
        <span
          style={{
            fontSize: rarity === 'legend' ? 18 : 15,
            fontWeight: 800,
            color: fx.particleColors[0],
            letterSpacing: 3,
            textTransform: 'uppercase',
            fontFamily: 'Pretendard, system-ui, sans-serif',
            textShadow: `0 0 12px ${fx.glowColor}`,
          }}
        >
          {fx.label}
        </span>
      </motion.div>
      <motion.p
        style={{
          marginTop: 8,
          fontSize: 12,
          color: 'rgba(255,255,255,0.4)',
          fontFamily: 'Pretendard, system-ui, sans-serif',
        }}
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1 }}
      >
        {isKo ? '카드를 터치하면 뒤집어집니다 · 움직이면 홀로그램 효과' : 'Tap to flip · Move for hologram effect'}
      </motion.p>
      <motion.p
        style={{
          marginTop: 4,
          fontSize: 11,
          color: 'rgba(255,255,255,0.3)',
          fontFamily: 'Pretendard, system-ui, sans-serif',
        }}
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1.2 }}
      >
        {isKo ? '아래로 밀어서 닫기' : 'Swipe down to close'}
      </motion.p>
    </motion.div>
  )
}

// ─── Main Modal ─────────────────────────────────────────────────────────────────

export default function CardRevealModal({ card, isKo, onClose }: CardRevealModalProps) {
  const [phase, setPhase] = useState<Phase>('pack')
  const fx = RARITY_FX[card.rarity]

  const handleOpen = useCallback(() => {
    setPhase('burst')
    // Burst → reveal transition
    setTimeout(() => setPhase('reveal'), 500)
    // Reveal → interactive transition
    setTimeout(() => setPhase('interactive'), 1400)
  }, [])

  // Swipe down to close
  const [dragY, setDragY] = useState(0)
  const handleDragEnd = useCallback((_: unknown, info: { offset: { y: number }; velocity: { y: number } }) => {
    if (info.offset.y > 100 || info.velocity.y > 500) {
      onClose()
    }
    setDragY(0)
  }, [onClose])

  // ESC to close
  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose()
    }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [onClose])

  return (
    <AnimatePresence>
      <motion.div
        style={{
          position: 'fixed',
          inset: 0,
          zIndex: 9999,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          overflow: 'hidden',
          touchAction: 'none',
        }}
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        transition={{ duration: 0.3 }}
      >
        {/* Dark vignette backdrop */}
        <motion.div
          style={{
            position: 'absolute',
            inset: 0,
            background: 'radial-gradient(ellipse at center, rgba(10,5,20,0.92) 0%, rgba(5,2,10,0.98) 100%)',
          }}
          onClick={phase === 'interactive' ? onClose : undefined}
        />

        {/* Ambient glow behind card */}
        <motion.div
          style={{
            position: 'absolute',
            width: 400,
            height: 500,
            borderRadius: '50%',
            background: `radial-gradient(ellipse, ${fx.glowColor} 0%, transparent 70%)`,
            filter: 'blur(60px)',
            pointerEvents: 'none',
          }}
          animate={{
            opacity: phase === 'burst' || phase === 'reveal' ? [0.3, 1, 0.6] : 0.3,
            scale: phase === 'burst' ? [1, 2, 1.2] : 1,
          }}
          transition={{ duration: 0.6 }}
        />

        {/* Close button (interactive phase) */}
        {phase === 'interactive' && (
          <motion.button
            style={{
              position: 'absolute',
              top: 16,
              right: 16,
              zIndex: 100,
              width: 40,
              height: 40,
              borderRadius: '50%',
              background: 'rgba(255,255,255,0.1)',
              border: '1px solid rgba(255,255,255,0.2)',
              color: 'rgba(255,255,255,0.7)',
              fontSize: 18,
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              backdropFilter: 'blur(8px)',
            }}
            initial={{ opacity: 0, scale: 0 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.3 }}
            onClick={onClose}
          >
            ✕
          </motion.button>
        )}

        {/* Light rays (burst phase) */}
        <LightRays rarity={card.rarity} active={phase === 'burst' || phase === 'reveal'} />

        {/* Burst particles */}
        <BurstParticles rarity={card.rarity} active={phase === 'burst' || phase === 'reveal'} />

        {/* Flash overlay on burst */}
        {phase === 'burst' && (
          <motion.div
            style={{
              position: 'absolute',
              inset: 0,
              background: fx.burstColor,
              pointerEvents: 'none',
              zIndex: 90,
            }}
            initial={{ opacity: 0 }}
            animate={{ opacity: [0, 0.8, 0] }}
            transition={{ duration: 0.4 }}
          />
        )}

        {/* ── Card Pack (before opening) ── */}
        {phase === 'pack' && (
          <CardPack rarity={card.rarity} onOpen={handleOpen} />
        )}

        {/* ── Card Reveal Animation ── */}
        {(phase === 'reveal' || phase === 'interactive') && (
          <motion.div
            drag={phase === 'interactive' ? 'y' : false}
            dragConstraints={{ top: 0, bottom: 200 }}
            onDrag={(_, info) => setDragY(info.offset.y)}
            onDragEnd={handleDragEnd}
            style={{
              zIndex: 60,
              opacity: dragY > 50 ? 1 - (dragY - 50) / 200 : 1,
            }}
            initial={{
              scale: 0.3,
              rotateY: 720,
              opacity: 0,
            }}
            animate={{
              scale: phase === 'interactive' ? 1 : [0.3, 1.1, 1],
              rotateY: 0,
              opacity: 1,
            }}
            transition={{
              scale: { duration: 0.8, ease: [0.2, 0.8, 0.2, 1] },
              rotateY: { duration: 0.8, ease: [0.2, 0.8, 0.2, 1] },
              opacity: { duration: 0.3 },
            }}
          >
            <Card3D
              personalityTitle={card.personalityTitle}
              mainQuote={card.mainQuote}
              topMatch={card.topMatch}
              scores={card.scores}
              rarity={card.rarity}
              cardNumber={card.cardNumber}
              isKo={isKo}
            />
          </motion.div>
        )}

        {/* Floating sparkles (interactive) */}
        <FloatingSparkles active={phase === 'interactive' && (card.rarity === 'legend' || card.rarity === 'ssr')} />

        {/* Rarity announcement */}
        {phase === 'interactive' && (
          <RarityAnnouncement rarity={card.rarity} isKo={isKo} />
        )}
      </motion.div>
    </AnimatePresence>
  )
}
