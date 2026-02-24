import { AbsoluteFill, useCurrentFrame, interpolate, spring, useVideoConfig } from 'remotion';
import { WireframeHexagon } from '../components/WireframeIcon';

interface Props {
  orientation: 'portrait' | 'landscape';
}

export const IntroScene: React.FC<Props> = ({ orientation }) => {
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

  return (
    <AbsoluteFill
      style={{
        justifyContent: 'center',
        alignItems: 'center',
        background: 'radial-gradient(ellipse at center, #1a1a2e 0%, #0f0f23 100%)',
      }}
    >
      {/* 배경 파티클 효과 */}
      {[...Array(20)].map((_, i) => {
        const particleProgress = (frame + i * 20) % 120;
        const particleY = interpolate(particleProgress, [0, 120], [height + 50, -50]);
        const particleX = (i * 137) % width;
        const particleOpacity = interpolate(particleProgress, [0, 60, 120], [0, 0.5, 0]);

        return (
          <div
            key={i}
            style={{
              position: 'absolute',
              left: particleX,
              top: particleY,
              width: 4,
              height: 4,
              borderRadius: '50%',
              background: '#8B5CF6',
              opacity: particleOpacity,
              boxShadow: '0 0 10px #8B5CF6',
            }}
          />
        );
      })}

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
            filter: `drop-shadow(0 0 ${30 * glowIntensity}px #8B5CF6)`,
          }}
        >
          <WireframeHexagon size={isPortrait ? 200 : 150} />
        </div>

        <div
          style={{
            marginTop: isPortrait ? 60 : 40,
            opacity: titleOpacity,
            transform: `translateY(${(1 - titleY) * 30}px)`,
          }}
        >
          <h1
            style={{
              fontFamily: 'Pretendard, system-ui, sans-serif',
              fontSize: isPortrait ? 72 : 56,
              fontWeight: 900,
              background: 'linear-gradient(135deg, #8B5CF6, #EC4899)',
              WebkitBackgroundClip: 'text',
              WebkitTextFillColor: 'transparent',
              textAlign: 'center',
              margin: 0,
              letterSpacing: '-0.02em',
            }}
          >
            6가지 심리 유형
          </h1>
        </div>

        <div
          style={{
            marginTop: isPortrait ? 20 : 15,
            opacity: subtitleOpacity,
          }}
        >
          <p
            style={{
              fontFamily: 'Pretendard, system-ui, sans-serif',
              fontSize: isPortrait ? 28 : 22,
              fontWeight: 500,
              color: 'rgba(255, 255, 255, 0.8)',
              textAlign: 'center',
              margin: 0,
              letterSpacing: '0.1em',
            }}
          >
            PERSONALITY TEST
          </p>
        </div>
      </div>
    </AbsoluteFill>
  );
};
