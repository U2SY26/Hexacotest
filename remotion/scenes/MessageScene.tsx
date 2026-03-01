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

// 씬별 고유 색상 팔레트
const scenePalettes = [
  { primary: '#8B5CF6', secondary: '#6366F1', accent: '#A78BFA' }, // Indigo-Violet
  { primary: '#EC4899', secondary: '#F43F5E', accent: '#FB7185' }, // Pink-Rose
  { primary: '#06B6D4', secondary: '#8B5CF6', accent: '#67E8F9' }, // Cyan-Violet
  { primary: '#F59E0B', secondary: '#EC4899', accent: '#FCD34D' }, // Amber-Pink
  { primary: '#10B981', secondary: '#06B6D4', accent: '#6EE7B7' }, // Emerald-Cyan
  { primary: '#8B5CF6', secondary: '#EC4899', accent: '#C4B5FD' }, // Violet-Pink (finale)
];

export const MessageScene: React.FC<Props> = ({ text, subText, align, orientation, sceneIndex }) => {
  const frame = useCurrentFrame();
  const { fps, width, height } = useVideoConfig();

  const isPortrait = orientation === 'portrait';
  const IconComponent = icons[sceneIndex % icons.length];
  const palette = scenePalettes[sceneIndex % scenePalettes.length];

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

  // 씬 전환 줌 효과
  const zoomIn = spring({
    frame,
    fps,
    config: { damping: 18, stiffness: 80 },
  });
  const sceneScale = interpolate(zoomIn, [0, 1], [1.1, 1]);

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

  // 텍스트 shimmer
  const shimmerX = interpolate(frame, [10, 70], [-100, 250], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        background: `radial-gradient(ellipse at ${bgShift}% 50%, #1a1a2e 0%, #0f0f23 100%)`,
        overflow: 'hidden',
        transform: `scale(${sceneScale})`,
      }}
    >
      {/* 네뷸라 배경 */}
      <div
        style={{
          position: 'absolute',
          width: '100%',
          height: '100%',
          background: `
            radial-gradient(ellipse at ${align === 'left' ? '30%' : align === 'right' ? '70%' : '50%'} 50%, ${palette.primary}15 0%, transparent 50%),
            radial-gradient(ellipse at ${align === 'left' ? '70%' : align === 'right' ? '30%' : '50%'} 30%, ${palette.secondary}10 0%, transparent 40%)
          `,
          filter: 'blur(40px)',
          opacity: morphProgress,
        }}
      />

      {/* 플로팅 오브 (글로우 구체) */}
      {[...Array(8)].map((_, i) => {
        const orbPhase = (frame * 0.03 + i * Math.PI * 0.4);
        const orbX = width * (0.2 + 0.6 * ((Math.sin(orbPhase + i) + 1) / 2));
        const orbY = height * (0.2 + 0.6 * ((Math.cos(orbPhase * 0.7 + i * 2) + 1) / 2));
        const orbSize = 60 + (i % 4) * 40;
        const orbOpacity = interpolate(
          Math.sin(frame * 0.05 + i * 1.5),
          [-1, 1],
          [0.02, 0.08]
        ) * morphProgress * fadeOut;

        return (
          <div
            key={i}
            style={{
              position: 'absolute',
              left: orbX - orbSize / 2,
              top: orbY - orbSize / 2,
              width: orbSize,
              height: orbSize,
              borderRadius: '50%',
              background: i % 2 === 0 ? palette.primary : palette.secondary,
              opacity: orbOpacity,
              filter: `blur(${orbSize * 0.4}px)`,
            }}
          />
        );
      })}

      {/* 미세 파티클 */}
      {[...Array(15)].map((_, i) => {
        const speed = 0.6 + (i % 3) * 0.4;
        const pProgress = ((frame * speed) + i * 25) % 120;
        const pY = interpolate(pProgress, [0, 120], [height + 20, -20]);
        const pX = (i * 97 + Math.sin(frame * 0.03 + i) * 20) % width;
        const pOpacity = interpolate(pProgress, [0, 60, 120], [0, 0.5, 0]) * morphProgress * fadeOut;
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
              background: i % 3 === 0 ? palette.accent : palette.primary,
              opacity: pOpacity,
              boxShadow: `0 0 ${pSize * 3}px ${palette.primary}`,
            }}
          />
        );
      })}

      {/* 데코레이션 라인 - 향상 */}
      <div
        style={{
          position: 'absolute',
          left: align === 'right' ? 'auto' : isPortrait ? 40 : 80,
          right: align === 'right' ? (isPortrait ? 40 : 80) : 'auto',
          top: '50%',
          transform: 'translateY(-50%)',
          width: 3,
          height: isPortrait ? 500 : 300,
          background: `linear-gradient(180deg, transparent, ${palette.primary}, ${palette.secondary}, transparent)`,
          opacity: morphProgress * fadeOut * 0.5,
          borderRadius: 2,
          boxShadow: `0 0 15px ${palette.primary}40`,
        }}
      />
      {/* 보조 라인 */}
      <div
        style={{
          position: 'absolute',
          left: align === 'right' ? 'auto' : isPortrait ? 48 : 88,
          right: align === 'right' ? (isPortrait ? 48 : 88) : 'auto',
          top: '50%',
          transform: 'translateY(-50%)',
          width: 1,
          height: isPortrait ? 350 : 200,
          background: `linear-gradient(180deg, transparent, ${palette.accent}60, transparent)`,
          opacity: morphProgress * fadeOut * 0.3,
          borderRadius: 1,
        }}
      />

      {/* 아이콘 - 향상된 글로우 */}
      <div
        style={{
          position: 'absolute',
          left: align === 'right' ? (isPortrait ? 80 : 150) : 'auto',
          right: align === 'left' ? (isPortrait ? 80 : 150) : (align === 'center' ? 'auto' : undefined),
          top: align === 'center' ? (isPortrait ? '20%' : '25%') : '50%',
          transform: `translateY(${align === 'center' ? 0 : -50}%) translateY(${iconFloat}px)`,
          opacity: morphProgress * fadeOut,
          filter: `drop-shadow(0 0 ${25 * glowPulse}px ${palette.primary}) drop-shadow(0 0 ${50 * glowPulse}px ${palette.primary}40)`,
        }}
      >
        <IconComponent size={isPortrait ? 130 : 90} />
      </div>

      {/* 메인 텍스트 영역 */}
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
            position: 'relative',
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
                          fontSize: isPortrait ? 100 : 76,
                          fontWeight: 900,
                          background: `linear-gradient(135deg, #FFFFFF 0%, #F0F0F0 40%, ${palette.accent} 80%, ${palette.primary} 100%)`,
                          WebkitBackgroundClip: 'text',
                          WebkitTextFillColor: 'transparent',
                          letterSpacing: '-0.02em',
                          lineHeight: 1.1,
                          transform: `scale(${charScale})`,
                          opacity: charOpacity,
                          display: 'inline-block',
                          filter: `drop-shadow(0 0 ${12 * glowPulse}px ${palette.primary}50)`,
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

          {/* Shimmer 오버레이 */}
          <div
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              background: `linear-gradient(90deg, transparent ${shimmerX - 20}%, rgba(255,255,255,0.08) ${shimmerX}%, transparent ${shimmerX + 20}%)`,
              pointerEvents: 'none',
            }}
          />

          {/* 서브 텍스트 */}
          <div
            style={{
              marginTop: isPortrait ? 35 : 24,
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
                fontSize: isPortrait ? 30 : 26,
                fontWeight: 600,
                background: `linear-gradient(90deg, ${palette.secondary}, ${palette.accent})`,
                WebkitBackgroundClip: 'text',
                WebkitTextFillColor: 'transparent',
                letterSpacing: '0.15em',
                textTransform: 'uppercase',
              }}
            >
              {subText}
            </span>
          </div>
        </div>
      </AbsoluteFill>

      {/* 하단 진행 인디케이터 - 향상 */}
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
              width: i === sceneIndex ? 36 : 8,
              height: 8,
              borderRadius: 4,
              background: i === sceneIndex
                ? `linear-gradient(90deg, ${palette.primary}, ${palette.secondary})`
                : 'rgba(255, 255, 255, 0.25)',
              boxShadow: i === sceneIndex ? `0 0 12px ${palette.primary}60` : 'none',
            }}
          />
        ))}
      </div>
    </AbsoluteFill>
  );
};
