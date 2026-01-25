import { AbsoluteFill, useCurrentFrame, interpolate, spring, useVideoConfig } from 'remotion';
import { WireframeHexagon } from '../components/WireframeIcon';

interface Props {
  orientation: 'portrait' | 'landscape';
}

export const OutroScene: React.FC<Props> = ({ orientation }) => {
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
    [1, 1.05]
  );

  const glowIntensity = interpolate(
    Math.sin(frame * 0.1),
    [-1, 1],
    [0.5, 1]
  );

  // 로고 회전
  const logoRotation = interpolate(frame, [0, 120], [0, 360]);

  return (
    <AbsoluteFill
      style={{
        background: 'radial-gradient(ellipse at center, #1a1a2e 0%, #0f0f23 100%)',
        justifyContent: 'center',
        alignItems: 'center',
      }}
    >
      {/* 빛나는 원형 배경 */}
      <div
        style={{
          position: 'absolute',
          width: isPortrait ? 600 : 500,
          height: isPortrait ? 600 : 500,
          borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(139, 92, 246, 0.2) 0%, transparent 70%)',
          opacity: scaleIn * glowIntensity,
          filter: 'blur(40px)',
        }}
      />

      {/* 메인 컨텐츠 */}
      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          transform: `scale(${scaleIn})`,
        }}
      >
        {/* 회전하는 헥사곤 */}
        <div
          style={{
            transform: `rotate(${logoRotation}deg)`,
            filter: `drop-shadow(0 0 ${30 * glowIntensity}px #8B5CF6)`,
            marginBottom: isPortrait ? 50 : 30,
          }}
        >
          <WireframeHexagon size={isPortrait ? 150 : 100} />
        </div>

        {/* 슬로건 */}
        <h2
          style={{
            fontFamily: 'Pretendard, system-ui, sans-serif',
            fontSize: isPortrait ? 56 : 44,
            fontWeight: 900,
            background: 'linear-gradient(135deg, #FFFFFF, #8B5CF6)',
            WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent',
            textAlign: 'center',
            margin: 0,
            marginBottom: isPortrait ? 20 : 15,
            opacity: interpolate(frame, [20, 40], [0, 1], {
              extrapolateLeft: 'clamp',
              extrapolateRight: 'clamp',
            }),
          }}
        >
          지금 시작하세요
        </h2>

        {/* 서브텍스트 */}
        <p
          style={{
            fontFamily: 'Pretendard, system-ui, sans-serif',
            fontSize: isPortrait ? 24 : 20,
            fontWeight: 400,
            color: 'rgba(255, 255, 255, 0.7)',
            textAlign: 'center',
            margin: 0,
            marginBottom: isPortrait ? 50 : 35,
            opacity: interpolate(frame, [30, 50], [0, 1], {
              extrapolateLeft: 'clamp',
              extrapolateRight: 'clamp',
            }),
          }}
        >
          180개 질문으로 진정한 나를 발견하세요
        </p>

        {/* CTA 버튼 */}
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
              padding: isPortrait ? '24px 64px' : '18px 48px',
              background: 'linear-gradient(135deg, #8B5CF6, #EC4899)',
              borderRadius: 16,
              boxShadow: `0 0 ${40 * glowIntensity}px rgba(139, 92, 246, 0.5)`,
              border: '2px solid rgba(255, 255, 255, 0.2)',
            }}
          >
            <span
              style={{
                fontFamily: 'Pretendard, system-ui, sans-serif',
                fontSize: isPortrait ? 28 : 22,
                fontWeight: 700,
                color: 'white',
                letterSpacing: '0.05em',
              }}
            >
              무료 테스트 시작
            </span>
          </div>
        </div>

        {/* 웹사이트 URL */}
        <p
          style={{
            fontFamily: 'Pretendard, system-ui, sans-serif',
            fontSize: isPortrait ? 20 : 16,
            fontWeight: 500,
            color: '#8B5CF6',
            textAlign: 'center',
            marginTop: isPortrait ? 40 : 25,
            opacity: interpolate(frame, [60, 80], [0, 1], {
              extrapolateLeft: 'clamp',
              extrapolateRight: 'clamp',
            }),
            letterSpacing: '0.1em',
          }}
        >
          hexacotest.com
        </p>
      </div>

      {/* 하단 통계 */}
      <div
        style={{
          position: 'absolute',
          bottom: isPortrait ? 100 : 60,
          display: 'flex',
          gap: isPortrait ? 60 : 80,
          opacity: interpolate(frame, [70, 90], [0, 1], {
            extrapolateLeft: 'clamp',
            extrapolateRight: 'clamp',
          }),
        }}
      >
        {[
          { value: '50K+', label: '테스트 완료' },
          { value: '4.8', label: '평점' },
          { value: '97%', label: '정확도' },
        ].map((stat, i) => (
          <div key={i} style={{ textAlign: 'center' }}>
            <div
              style={{
                fontFamily: 'Pretendard, system-ui, sans-serif',
                fontSize: isPortrait ? 32 : 24,
                fontWeight: 800,
                color: '#EC4899',
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
                marginTop: 4,
              }}
            >
              {stat.label}
            </div>
          </div>
        ))}
      </div>
    </AbsoluteFill>
  );
};
