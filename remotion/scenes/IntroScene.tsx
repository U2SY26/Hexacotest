import { AbsoluteFill, useCurrentFrame, interpolate, spring, useVideoConfig } from 'remotion';
import { WireframeHexagon } from '../components/WireframeIcon';

import type { Locale } from '../Video';

interface Props {
  orientation: 'portrait' | 'landscape';
  locale?: Locale;
}

const i18n = {
  ko: { title: '6가지 심리 유형', subtitle: 'PERSONALITY TEST' },
  en: { title: '6 Personality\nDimensions', subtitle: 'HEXACO PERSONALITY TEST' },
};

export const IntroScene: React.FC<Props> = ({ orientation, locale = 'ko' }) => {
  const t = i18n[locale];
  const frame = useCurrentFrame();
  const { fps, width, height } = useVideoConfig();

  const isPortrait = orientation === 'portrait';

  // 애니메이션 값들
  const logoScale = spring({
    frame,
    fps,
    config: { damping: 12, stiffness: 100 },
  });

  const logoRotation = interpolate(frame, [0, 120], [0, 360], {
    extrapolateRight: 'clamp',
  });

  const titleOpacity = interpolate(frame, [20, 50], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const titleY = spring({
    frame: frame - 20,
    fps,
    config: { damping: 15, stiffness: 80 },
  });

  const subtitleOpacity = interpolate(frame, [40, 70], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  // 글로우 효과
  const glowIntensity = interpolate(
    Math.sin(frame * 0.1),
    [-1, 1],
    [0.3, 0.7]
  );

  // 오로라 색상 시프트
  const auroraHue1 = interpolate(frame, [0, 120], [250, 330], {
    extrapolateRight: 'clamp',
  });
  const auroraHue2 = interpolate(frame, [0, 120], [280, 200], {
    extrapolateRight: 'clamp',
  });

  // 오비탈 링 회전
  const orbitRotation1 = interpolate(frame, [0, 120], [0, 180]);
  const orbitRotation2 = interpolate(frame, [0, 120], [90, -90]);
  const orbitRotation3 = interpolate(frame, [0, 120], [45, 225]);

  const orbitOpacity = spring({
    frame: frame - 5,
    fps,
    config: { damping: 20, stiffness: 80 },
  });

  // 펄스 링 확장
  const pulseRing1 = interpolate((frame % 60), [0, 60], [0.3, 1.5]);
  const pulseOpacity1 = interpolate((frame % 60), [0, 60], [0.6, 0]);
  const pulseRing2 = interpolate(((frame + 30) % 60), [0, 60], [0.3, 1.5]);
  const pulseOpacity2 = interpolate(((frame + 30) % 60), [0, 60], [0.6, 0]);

  // 타이틀 shimmer 효과
  const shimmerX = interpolate(frame, [20, 80], [-100, 200], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        justifyContent: 'center',
        alignItems: 'center',
        background: 'radial-gradient(ellipse at center, #1a1a2e 0%, #0f0f23 100%)',
        overflow: 'hidden',
      }}
    >
      {/* 오로라 배경 효과 */}
      <div
        style={{
          position: 'absolute',
          width: '140%',
          height: '140%',
          top: '-20%',
          left: '-20%',
          background: `
            radial-gradient(ellipse at 30% 20%, hsla(${auroraHue1}, 80%, 50%, 0.15) 0%, transparent 50%),
            radial-gradient(ellipse at 70% 80%, hsla(${auroraHue2}, 80%, 50%, 0.12) 0%, transparent 50%),
            radial-gradient(ellipse at 50% 50%, hsla(270, 60%, 40%, 0.1) 0%, transparent 60%)
          `,
          filter: 'blur(60px)',
        }}
      />

      {/* 성운 노이즈 레이어 */}
      <div
        style={{
          position: 'absolute',
          width: '100%',
          height: '100%',
          background: `
            radial-gradient(circle at ${30 + Math.sin(frame * 0.02) * 15}% ${40 + Math.cos(frame * 0.03) * 10}%, rgba(139, 92, 246, 0.08) 0%, transparent 40%),
            radial-gradient(circle at ${70 + Math.cos(frame * 0.025) * 15}% ${60 + Math.sin(frame * 0.02) * 10}%, rgba(236, 72, 153, 0.06) 0%, transparent 40%)
          `,
          filter: 'blur(30px)',
        }}
      />

      {/* 배경 파티클 효과 - 다양한 크기와 색상 */}
      {[...Array(40)].map((_, i) => {
        const speed = 0.8 + (i % 5) * 0.3;
        const particleProgress = ((frame * speed) + i * 20) % 150;
        const particleY = interpolate(particleProgress, [0, 150], [height + 50, -50]);
        const particleX = (i * 137 + Math.sin(frame * 0.02 + i) * 30) % width;
        const particleOpacity = interpolate(particleProgress, [0, 75, 150], [0, 0.7, 0]);
        const particleSize = 2 + (i % 4) * 2;
        const isAccent = i % 3 === 0;

        return (
          <div
            key={i}
            style={{
              position: 'absolute',
              left: particleX,
              top: particleY,
              width: particleSize,
              height: particleSize,
              borderRadius: '50%',
              background: isAccent ? '#EC4899' : '#8B5CF6',
              opacity: particleOpacity,
              boxShadow: `0 0 ${particleSize * 3}px ${isAccent ? '#EC4899' : '#8B5CF6'}`,
            }}
          />
        );
      })}

      {/* 오비탈 링들 */}
      <div
        style={{
          position: 'absolute',
          width: isPortrait ? 500 : 400,
          height: isPortrait ? 500 : 400,
          opacity: orbitOpacity * 0.35,
        }}
      >
        {/* 링 1 */}
        <div
          style={{
            position: 'absolute',
            width: '100%',
            height: '100%',
            border: '1.5px solid rgba(139, 92, 246, 0.4)',
            borderRadius: '50%',
            transform: `rotateX(70deg) rotateZ(${orbitRotation1}deg)`,
          }}
        />
        {/* 링 2 */}
        <div
          style={{
            position: 'absolute',
            width: '85%',
            height: '85%',
            top: '7.5%',
            left: '7.5%',
            border: '1px solid rgba(236, 72, 153, 0.3)',
            borderRadius: '50%',
            transform: `rotateX(60deg) rotateZ(${orbitRotation2}deg)`,
          }}
        />
        {/* 링 3 */}
        <div
          style={{
            position: 'absolute',
            width: '115%',
            height: '115%',
            top: '-7.5%',
            left: '-7.5%',
            border: '1px solid rgba(139, 92, 246, 0.2)',
            borderRadius: '50%',
            transform: `rotateX(80deg) rotateZ(${orbitRotation3}deg)`,
          }}
        />
      </div>

      {/* 펄스 링 효과 */}
      <div
        style={{
          position: 'absolute',
          width: isPortrait ? 200 : 150,
          height: isPortrait ? 200 : 150,
          border: '2px solid rgba(139, 92, 246, 0.5)',
          borderRadius: '50%',
          transform: `scale(${pulseRing1})`,
          opacity: pulseOpacity1 * logoScale,
        }}
      />
      <div
        style={{
          position: 'absolute',
          width: isPortrait ? 200 : 150,
          height: isPortrait ? 200 : 150,
          border: '2px solid rgba(236, 72, 153, 0.4)',
          borderRadius: '50%',
          transform: `scale(${pulseRing2})`,
          opacity: pulseOpacity2 * logoScale,
        }}
      />

      {/* 메인 로고 */}
      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          transform: `scale(${logoScale})`,
        }}
      >
        <div
          style={{
            transform: `rotate(${logoRotation}deg)`,
            filter: `drop-shadow(0 0 ${40 * glowIntensity}px #8B5CF6) drop-shadow(0 0 ${80 * glowIntensity}px rgba(139, 92, 246, 0.3))`,
          }}
        >
          <WireframeHexagon size={isPortrait ? 220 : 170} />
        </div>

        <div
          style={{
            marginTop: isPortrait ? 60 : 40,
            opacity: titleOpacity,
            transform: `translateY(${(1 - titleY) * 30}px)`,
            position: 'relative',
          }}
        >
          <h1
            style={{
              fontFamily: 'Pretendard, system-ui, sans-serif',
              fontSize: isPortrait ? 80 : 60,
              fontWeight: 900,
              background: 'linear-gradient(135deg, #FFFFFF 0%, #C4B5FD 30%, #8B5CF6 60%, #EC4899 100%)',
              WebkitBackgroundClip: 'text',
              WebkitTextFillColor: 'transparent',
              textAlign: 'center',
              margin: 0,
              letterSpacing: '-0.02em',
              filter: `drop-shadow(0 0 20px rgba(139, 92, 246, ${glowIntensity * 0.5}))`,
            }}
          >
            {t.title}
          </h1>
          {/* Shimmer 오버레이 */}
          <div
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              background: `linear-gradient(90deg, transparent ${shimmerX - 30}%, rgba(255,255,255,0.15) ${shimmerX}%, transparent ${shimmerX + 30}%)`,
              pointerEvents: 'none',
            }}
          />
        </div>

        <div
          style={{
            marginTop: isPortrait ? 24 : 18,
            opacity: subtitleOpacity,
          }}
        >
          <p
            style={{
              fontFamily: 'Pretendard, system-ui, sans-serif',
              fontSize: isPortrait ? 30 : 24,
              fontWeight: 600,
              background: 'linear-gradient(90deg, rgba(255,255,255,0.6), rgba(255,255,255,0.9), rgba(255,255,255,0.6))',
              WebkitBackgroundClip: 'text',
              WebkitTextFillColor: 'transparent',
              textAlign: 'center',
              margin: 0,
              letterSpacing: '0.2em',
            }}
          >
            {t.subtitle}
          </p>
        </div>
      </div>

      {/* 하단 장식 라인 */}
      <div
        style={{
          position: 'absolute',
          bottom: isPortrait ? 120 : 80,
          width: isPortrait ? 200 : 160,
          height: 2,
          background: 'linear-gradient(90deg, transparent, #8B5CF6, #EC4899, transparent)',
          opacity: subtitleOpacity * 0.6,
        }}
      />
    </AbsoluteFill>
  );
};
