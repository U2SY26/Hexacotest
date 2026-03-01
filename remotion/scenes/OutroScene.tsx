import { AbsoluteFill, useCurrentFrame, interpolate, spring, useVideoConfig } from 'remotion';
import { WireframeHexagon } from '../components/WireframeIcon';

import type { Locale } from '../Video';

interface Props {
  orientation: 'portrait' | 'landscape';
  locale?: Locale;
}

const i18n = {
  ko: {
    slogan: '지금 시작하세요',
    subtext: '180개 질문으로 진정한 나를 발견하세요',
    cta: '무료 테스트 시작',
    stats: [
      { value: '50K+', label: '테스트 완료' },
      { value: '4.8', label: '평점' },
      { value: '97%', label: '정확도' },
    ],
  },
  en: {
    slogan: 'Start Now',
    subtext: 'Discover the real you with 180 questions',
    cta: 'Free Test',
    stats: [
      { value: '50K+', label: 'Tests Taken' },
      { value: '4.8', label: 'Rating' },
      { value: '97%', label: 'Accuracy' },
    ],
  },
};

export const OutroScene: React.FC<Props> = ({ orientation, locale = 'ko' }) => {
  const t = i18n[locale];
  const frame = useCurrentFrame();
  const { fps, width, height } = useVideoConfig();

  const isPortrait = orientation === 'portrait';

  // 애니메이션
  const scaleIn = spring({
    frame,
    fps,
    config: { damping: 15, stiffness: 100 },
  });

  const ctaScale = spring({
    frame: frame - 30,
    fps,
    config: { damping: 12, stiffness: 150 },
  });

  const ctaPulse = interpolate(
    Math.sin((frame - 40) * 0.12),
    [-1, 1],
    [1, 1.06]
  );

  const glowIntensity = interpolate(
    Math.sin(frame * 0.1),
    [-1, 1],
    [0.5, 1]
  );

  // 로고 회전
  const logoRotation = interpolate(frame, [0, 120], [0, 360]);

  // 방사형 펄스 링들
  const pulseRings = [0, 20, 40].map((delay) => {
    const progress = ((frame - delay + 120) % 60) / 60;
    return {
      scale: interpolate(progress, [0, 1], [0.5, 2.5]),
      opacity: interpolate(progress, [0, 0.2, 1], [0, 0.4, 0]),
    };
  });

  // 컨페티 파티클
  const confettiColors = ['#8B5CF6', '#EC4899', '#06B6D4', '#F59E0B', '#10B981', '#F43F5E'];

  // 배경 오로라
  const auroraPhase = frame * 0.03;

  // 통계 카운트업 애니메이션
  const statsDelay = 70;
  const countProgress = interpolate(frame - statsDelay, [0, 30], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        background: 'radial-gradient(ellipse at center, #1a1a2e 0%, #0f0f23 100%)',
        justifyContent: 'center',
        alignItems: 'center',
        overflow: 'hidden',
      }}
    >
      {/* 오로라 배경 */}
      <div
        style={{
          position: 'absolute',
          width: '150%',
          height: '150%',
          top: '-25%',
          left: '-25%',
          background: `
            radial-gradient(ellipse at ${30 + Math.sin(auroraPhase) * 20}% ${40 + Math.cos(auroraPhase * 0.7) * 15}%, rgba(139, 92, 246, 0.12) 0%, transparent 45%),
            radial-gradient(ellipse at ${70 + Math.cos(auroraPhase * 0.8) * 20}% ${60 + Math.sin(auroraPhase * 0.6) * 15}%, rgba(236, 72, 153, 0.1) 0%, transparent 45%),
            radial-gradient(ellipse at ${50 + Math.sin(auroraPhase * 1.2) * 15}% ${30 + Math.cos(auroraPhase) * 10}%, rgba(6, 182, 212, 0.08) 0%, transparent 40%)
          `,
          filter: 'blur(50px)',
          opacity: scaleIn,
        }}
      />

      {/* 방사형 펄스 링 */}
      {pulseRings.map((ring, i) => (
        <div
          key={i}
          style={{
            position: 'absolute',
            width: isPortrait ? 200 : 150,
            height: isPortrait ? 200 : 150,
            border: `2px solid ${i % 2 === 0 ? '#8B5CF6' : '#EC4899'}`,
            borderRadius: '50%',
            transform: `scale(${ring.scale})`,
            opacity: ring.opacity * scaleIn,
          }}
        />
      ))}

      {/* 빛나는 원형 배경 - 강화 */}
      <div
        style={{
          position: 'absolute',
          width: isPortrait ? 700 : 550,
          height: isPortrait ? 700 : 550,
          borderRadius: '50%',
          background: `
            radial-gradient(circle, rgba(139, 92, 246, 0.15) 0%, rgba(236, 72, 153, 0.08) 40%, transparent 70%)
          `,
          opacity: scaleIn * glowIntensity,
          filter: 'blur(50px)',
        }}
      />

      {/* 컨페티 파티클 */}
      {[...Array(25)].map((_, i) => {
        const confettiDelay = 40 + i * 2;
        const confettiProgress = spring({
          frame: frame - confettiDelay,
          fps,
          config: { damping: 30, stiffness: 50, mass: 0.5 },
        });

        const angle = (i / 25) * Math.PI * 2;
        const radius = 200 + (i % 5) * 60;
        const confettiX = width / 2 + Math.cos(angle + frame * 0.01) * radius * confettiProgress;
        const confettiY = height / 2 + Math.sin(angle + frame * 0.01) * radius * confettiProgress - (frame - confettiDelay) * 0.3;
        const confettiSize = 3 + (i % 4) * 2;
        const confettiRotation = (frame - confettiDelay) * (3 + i % 5);
        const confettiOpacity = interpolate(confettiProgress, [0, 0.3, 0.8, 1], [0, 1, 0.8, 0.3]);

        return (
          <div
            key={`confetti-${i}`}
            style={{
              position: 'absolute',
              left: confettiX,
              top: confettiY,
              width: confettiSize,
              height: confettiSize * (i % 2 === 0 ? 1 : 2.5),
              borderRadius: i % 3 === 0 ? '50%' : 1,
              background: confettiColors[i % confettiColors.length],
              opacity: confettiOpacity,
              transform: `rotate(${confettiRotation}deg)`,
              boxShadow: `0 0 ${confettiSize * 2}px ${confettiColors[i % confettiColors.length]}60`,
            }}
          />
        );
      })}

      {/* 미세 파티클 */}
      {[...Array(20)].map((_, i) => {
        const speed = 0.5 + (i % 4) * 0.3;
        const pProgress = ((frame * speed) + i * 18) % 130;
        const pY = interpolate(pProgress, [0, 130], [height + 30, -30]);
        const pX = (i * 113 + Math.sin(frame * 0.02 + i) * 25) % width;
        const pOpacity = interpolate(pProgress, [0, 65, 130], [0, 0.5, 0]);
        const pSize = 2 + (i % 3);

        return (
          <div
            key={`p-${i}`}
            style={{
              position: 'absolute',
              left: pX,
              top: pY,
              width: pSize,
              height: pSize,
              borderRadius: '50%',
              background: i % 2 === 0 ? '#8B5CF6' : '#EC4899',
              opacity: pOpacity,
              boxShadow: `0 0 ${pSize * 3}px ${i % 2 === 0 ? '#8B5CF6' : '#EC4899'}`,
            }}
          />
        );
      })}

      {/* 메인 컨텐츠 */}
      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          transform: `scale(${scaleIn})`,
          zIndex: 1,
        }}
      >
        {/* 회전하는 헥사곤 - 강화 글로우 */}
        <div
          style={{
            transform: `rotate(${logoRotation}deg)`,
            filter: `drop-shadow(0 0 ${40 * glowIntensity}px #8B5CF6) drop-shadow(0 0 ${80 * glowIntensity}px rgba(139, 92, 246, 0.3))`,
            marginBottom: isPortrait ? 50 : 30,
          }}
        >
          <WireframeHexagon size={isPortrait ? 170 : 120} />
        </div>

        {/* 슬로건 - 강화 */}
        <h2
          style={{
            fontFamily: 'Pretendard, system-ui, sans-serif',
            fontSize: isPortrait ? 64 : 48,
            fontWeight: 900,
            background: 'linear-gradient(135deg, #FFFFFF 0%, #C4B5FD 40%, #8B5CF6 80%, #EC4899 100%)',
            WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent',
            textAlign: 'center',
            margin: 0,
            marginBottom: isPortrait ? 20 : 15,
            opacity: interpolate(frame, [20, 40], [0, 1], {
              extrapolateLeft: 'clamp',
              extrapolateRight: 'clamp',
            }),
            filter: `drop-shadow(0 0 15px rgba(139, 92, 246, ${glowIntensity * 0.4}))`,
          }}
        >
          {t.slogan}
        </h2>

        {/* 서브텍스트 */}
        <p
          style={{
            fontFamily: 'Pretendard, system-ui, sans-serif',
            fontSize: isPortrait ? 26 : 22,
            fontWeight: 500,
            background: 'linear-gradient(90deg, rgba(255,255,255,0.5), rgba(255,255,255,0.8), rgba(255,255,255,0.5))',
            WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent',
            textAlign: 'center',
            margin: 0,
            marginBottom: isPortrait ? 50 : 35,
            opacity: interpolate(frame, [30, 50], [0, 1], {
              extrapolateLeft: 'clamp',
              extrapolateRight: 'clamp',
            }),
          }}
        >
          {t.subtext}
        </p>

        {/* CTA 버튼 - 프리미엄 */}
        <div
          style={{
            transform: `scale(${ctaScale * ctaPulse})`,
            opacity: interpolate(frame, [40, 60], [0, 1], {
              extrapolateLeft: 'clamp',
              extrapolateRight: 'clamp',
            }),
          }}
        >
          <div
            style={{
              position: 'relative',
              padding: isPortrait ? '28px 72px' : '20px 56px',
              background: 'linear-gradient(135deg, #8B5CF6, #7C3AED, #EC4899)',
              borderRadius: 20,
              boxShadow: `
                0 0 ${50 * glowIntensity}px rgba(139, 92, 246, 0.4),
                0 0 ${100 * glowIntensity}px rgba(139, 92, 246, 0.2),
                inset 0 1px 0 rgba(255,255,255,0.2)
              `,
              border: '1px solid rgba(255, 255, 255, 0.15)',
            }}
          >
            {/* 버튼 shimmer */}
            <div
              style={{
                position: 'absolute',
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                borderRadius: 20,
                background: `linear-gradient(90deg, transparent ${interpolate(frame, [40, 90], [-50, 150], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' }) - 20}%, rgba(255,255,255,0.15) ${interpolate(frame, [40, 90], [-50, 150], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' })}%, transparent ${interpolate(frame, [40, 90], [-50, 150], { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' }) + 20}%)`,
                pointerEvents: 'none',
              }}
            />
            <span
              style={{
                fontFamily: 'Pretendard, system-ui, sans-serif',
                fontSize: isPortrait ? 30 : 24,
                fontWeight: 800,
                color: 'white',
                letterSpacing: '0.08em',
                textShadow: '0 1px 2px rgba(0,0,0,0.3)',
              }}
            >
              {t.cta}
            </span>
          </div>
        </div>

        {/* 웹사이트 URL - 강화 */}
        <p
          style={{
            fontFamily: 'Pretendard, system-ui, sans-serif',
            fontSize: isPortrait ? 22 : 18,
            fontWeight: 600,
            background: 'linear-gradient(90deg, #8B5CF6, #EC4899)',
            WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent',
            textAlign: 'center',
            marginTop: isPortrait ? 40 : 25,
            opacity: interpolate(frame, [60, 80], [0, 1], {
              extrapolateLeft: 'clamp',
              extrapolateRight: 'clamp',
            }),
            letterSpacing: '0.15em',
          }}
        >
          hexacotest.com
        </p>
      </div>

      {/* 하단 통계 - 프리미엄 카드 스타일 */}
      <div
        style={{
          position: 'absolute',
          bottom: isPortrait ? 100 : 60,
          display: 'flex',
          gap: isPortrait ? 30 : 40,
          opacity: interpolate(frame, [70, 90], [0, 1], {
            extrapolateLeft: 'clamp',
            extrapolateRight: 'clamp',
          }),
          zIndex: 1,
        }}
      >
        {t.stats.map((stat, i) => {
          const statSpring = spring({
            frame: frame - (statsDelay + i * 8),
            fps,
            config: { damping: 15, stiffness: 120 },
          });

          return (
            <div
              key={i}
              style={{
                textAlign: 'center',
                background: 'rgba(255, 255, 255, 0.04)',
                backdropFilter: 'blur(10px)',
                border: '1px solid rgba(255, 255, 255, 0.08)',
                borderRadius: 16,
                padding: isPortrait ? '20px 28px' : '14px 22px',
                transform: `scale(${statSpring}) translateY(${(1 - statSpring) * 20}px)`,
              }}
            >
              <div
                style={{
                  fontFamily: 'Pretendard, system-ui, sans-serif',
                  fontSize: isPortrait ? 36 : 28,
                  fontWeight: 900,
                  background: 'linear-gradient(135deg, #EC4899, #F43F5E)',
                  WebkitBackgroundClip: 'text',
                  WebkitTextFillColor: 'transparent',
                }}
              >
                {stat.value}
              </div>
              <div
                style={{
                  fontFamily: 'Pretendard, system-ui, sans-serif',
                  fontSize: isPortrait ? 14 : 12,
                  fontWeight: 500,
                  color: 'rgba(255, 255, 255, 0.6)',
                  marginTop: 6,
                  letterSpacing: '0.05em',
                }}
              >
                {stat.label}
              </div>
            </div>
          );
        })}
      </div>
    </AbsoluteFill>
  );
};
