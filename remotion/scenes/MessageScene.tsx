import { AbsoluteFill, useCurrentFrame, interpolate, spring, useVideoConfig } from 'remotion';
import { WireframeBrain, WireframeHeart, WireframeStar, WireframeSparkles, WireframeTarget, WireframeDiamond } from '../components/WireframeIcon';

interface Props {
  text: string;
  subText: string;
  align: 'left' | 'right' | 'center';
  orientation: 'portrait' | 'landscape';
  sceneIndex: number;
}

const icons = [
  WireframeBrain,
  WireframeHeart,
  WireframeStar,
  WireframeSparkles,
  WireframeTarget,
  WireframeDiamond,
];

export const MessageScene: React.FC<Props> = ({ text, subText, align, orientation, sceneIndex }) => {
  const frame = useCurrentFrame();
  const { fps, width, height } = useVideoConfig();

  const isPortrait = orientation === 'portrait';
  const IconComponent = icons[sceneIndex % icons.length];

  // 모핑 애니메이션 - 빠른 등장
  const morphProgress = spring({
    frame,
    fps,
    config: { damping: 12, stiffness: 150 },
  });

  // 텍스트 라인별 애니메이션
  const lines = text.split('\n');

  // 글로우 펄스 효과
  const glowPulse = interpolate(
    Math.sin(frame * 0.15),
    [-1, 1],
    [0.4, 1]
  );

  // 아이콘 플로팅 효과
  const iconFloat = interpolate(
    Math.sin(frame * 0.08),
    [-1, 1],
    [-15, 15]
  );

  // 배경 그라디언트 시프트
  const bgShift = interpolate(frame, [0, 105], [0, 100], {
    extrapolateRight: 'clamp',
  });

  // 좌/우 정렬에 따른 위치
  const getAlignment = () => {
    if (align === 'left') return { justifyContent: 'flex-start', textAlign: 'left' as const, paddingLeft: isPortrait ? 60 : 100 };
    if (align === 'right') return { justifyContent: 'flex-end', textAlign: 'right' as const, paddingRight: isPortrait ? 60 : 100 };
    return { justifyContent: 'center', textAlign: 'center' as const, paddingLeft: 0, paddingRight: 0 };
  };

  const alignment = getAlignment();

  // 페이드 아웃 애니메이션
  const fadeOut = interpolate(frame, [85, 105], [1, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        background: `radial-gradient(ellipse at ${bgShift}% 50%, #1a1a2e 0%, #0f0f23 100%)`,
      }}
    >
      {/* 데코레이션 라인 */}
      <div
        style={{
          position: 'absolute',
          left: align === 'right' ? 'auto' : isPortrait ? 40 : 80,
          right: align === 'right' ? (isPortrait ? 40 : 80) : 'auto',
          top: '50%',
          transform: 'translateY(-50%)',
          width: 4,
          height: isPortrait ? 400 : 250,
          background: 'linear-gradient(180deg, transparent, #8B5CF6, #EC4899, transparent)',
          opacity: morphProgress * fadeOut * 0.6,
          borderRadius: 2,
        }}
      />

      {/* 아이콘 */}
      <div
        style={{
          position: 'absolute',
          left: align === 'right' ? (isPortrait ? 80 : 150) : 'auto',
          right: align === 'left' ? (isPortrait ? 80 : 150) : (align === 'center' ? 'auto' : undefined),
          top: align === 'center' ? (isPortrait ? '20%' : '25%') : '50%',
          transform: `translateY(${align === 'center' ? 0 : -50}%) translateY(${iconFloat}px)`,
          opacity: morphProgress * fadeOut,
          filter: `drop-shadow(0 0 ${20 * glowPulse}px #8B5CF6)`,
        }}
      >
        <IconComponent size={isPortrait ? 120 : 80} />
      </div>

      {/* 메인 텍스트 영역 - 60% 화면 차지 */}
      <AbsoluteFill
        style={{
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          alignItems: alignment.justifyContent as any,
          paddingLeft: alignment.paddingLeft,
          paddingRight: alignment.paddingRight,
          opacity: fadeOut,
        }}
      >
        <div
          style={{
            width: isPortrait ? '80%' : '60%',
            maxWidth: isPortrait ? 900 : 1000,
          }}
        >
          {lines.map((line, lineIndex) => {
            const lineDelay = lineIndex * 8;
            const lineProgress = spring({
              frame: frame - lineDelay,
              fps,
              config: { damping: 15, stiffness: 120 },
            });

            const lineY = interpolate(lineProgress, [0, 1], [50, 0]);
            const lineOpacity = interpolate(lineProgress, [0, 1], [0, 1]);

            // 글자별 애니메이션
            const chars = line.split('');

            return (
              <div
                key={lineIndex}
                style={{
                  overflow: 'hidden',
                  marginBottom: isPortrait ? 10 : 5,
                }}
              >
                <div
                  style={{
                    display: 'flex',
                    flexWrap: 'wrap',
                    justifyContent: alignment.textAlign === 'center' ? 'center' : alignment.textAlign === 'right' ? 'flex-end' : 'flex-start',
                    transform: `translateY(${lineY}px)`,
                    opacity: lineOpacity,
                  }}
                >
                  {chars.map((char, charIndex) => {
                    const charDelay = lineDelay + charIndex * 1.5;
                    const charProgress = spring({
                      frame: frame - charDelay,
                      fps,
                      config: { damping: 20, stiffness: 200 },
                    });

                    const charScale = interpolate(charProgress, [0, 1], [0.5, 1]);
                    const charOpacity = interpolate(charProgress, [0, 1], [0, 1]);

                    return (
                      <span
                        key={charIndex}
                        style={{
                          fontFamily: 'Pretendard, system-ui, sans-serif',
                          fontSize: isPortrait ? 96 : 72,
                          fontWeight: 900,
                          background: 'linear-gradient(135deg, #FFFFFF 0%, #E0E0E0 50%, #8B5CF6 100%)',
                          WebkitBackgroundClip: 'text',
                          WebkitTextFillColor: 'transparent',
                          letterSpacing: '-0.02em',
                          lineHeight: 1.1,
                          transform: `scale(${charScale})`,
                          opacity: charOpacity,
                          display: 'inline-block',
                          textShadow: `0 0 ${40 * glowPulse}px rgba(139, 92, 246, 0.5)`,
                          filter: `drop-shadow(0 0 ${10 * glowPulse}px rgba(139, 92, 246, 0.3))`,
                        }}
                      >
                        {char === ' ' ? '\u00A0' : char}
                      </span>
                    );
                  })}
                </div>
              </div>
            );
          })}

          {/* 서브 텍스트 */}
          <div
            style={{
              marginTop: isPortrait ? 30 : 20,
              opacity: interpolate(frame, [30, 50], [0, 1], {
                extrapolateLeft: 'clamp',
                extrapolateRight: 'clamp',
              }) * fadeOut,
              transform: `translateY(${interpolate(frame, [30, 50], [20, 0], {
                extrapolateLeft: 'clamp',
                extrapolateRight: 'clamp',
              })}px)`,
              textAlign: alignment.textAlign,
            }}
          >
            <span
              style={{
                fontFamily: 'Pretendard, system-ui, sans-serif',
                fontSize: isPortrait ? 28 : 24,
                fontWeight: 500,
                color: '#EC4899',
                letterSpacing: '0.15em',
                textTransform: 'uppercase',
              }}
            >
              {subText}
            </span>
          </div>
        </div>
      </AbsoluteFill>

      {/* 하단 진행 인디케이터 */}
      <div
        style={{
          position: 'absolute',
          bottom: isPortrait ? 80 : 50,
          left: '50%',
          transform: 'translateX(-50%)',
          display: 'flex',
          gap: 12,
          opacity: fadeOut * 0.8,
        }}
      >
        {[0, 1, 2, 3, 4, 5].map((i) => (
          <div
            key={i}
            style={{
              width: i === sceneIndex ? 32 : 8,
              height: 8,
              borderRadius: 4,
              background: i === sceneIndex
                ? 'linear-gradient(90deg, #8B5CF6, #EC4899)'
                : 'rgba(255, 255, 255, 0.3)',
              transition: 'width 0.3s ease',
            }}
          />
        ))}
      </div>
    </AbsoluteFill>
  );
};
