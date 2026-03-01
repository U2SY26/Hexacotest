import { AbsoluteFill, Sequence, useCurrentFrame, interpolate, spring, useVideoConfig } from 'remotion';
import { MessageScene } from './scenes/MessageScene';
import { IntroScene } from './scenes/IntroScene';
import { OutroScene } from './scenes/OutroScene';

export type Locale = 'ko' | 'en';

interface Props {
  orientation: 'portrait' | 'landscape';
  locale?: Locale;
}

const messagesByLocale = {
  ko: [
    { text: '나를\n알아가는 여정', subText: 'Journey to Self', align: 'left' as const },
    { text: '진짜 나는\n누구일까?', subText: 'Who Am I Really?', align: 'right' as const },
    { text: '숨겨진\n가능성 발견', subText: 'Hidden Potential', align: 'left' as const },
    { text: '자존감\n회복의 시작', subText: 'Self-Worth Recovery', align: 'right' as const },
    { text: '당신의 강점을\n찾아보세요', subText: 'Find Your Strengths', align: 'left' as const },
    { text: '오늘, 진정한\n나를 만나다', subText: 'Meet the Real You', align: 'center' as const },
  ],
  en: [
    { text: 'A Journey\nTo Know Yourself', subText: 'Self-Discovery', align: 'left' as const },
    { text: 'Who Are\nYou Really?', subText: 'Deeper Understanding', align: 'right' as const },
    { text: 'Unlock Your\nHidden Potential', subText: 'Beyond The Surface', align: 'left' as const },
    { text: 'Rebuild Your\nSelf-Worth', subText: 'Inner Strength', align: 'right' as const },
    { text: 'Discover\nYour Strengths', subText: 'Unique Abilities', align: 'left' as const },
    { text: 'Meet The\nReal You', subText: 'Start Today', align: 'center' as const },
  ],
};

export const HexacoPromoVideo: React.FC<Props> = ({ orientation, locale = 'ko' }) => {
  const frame = useCurrentFrame();
  const { fps, width, height } = useVideoConfig();

  const messages = messagesByLocale[locale];

  // 각 씬의 길이 (프레임 단위)
  const introDuration = 120; // 4초
  const sceneDuration = 105; // 3.5초
  const outroDuration = 120; // 4초

  // 전체 배경 그라디언트 애니메이션
  const bgPhase = frame * 0.005;

  return (
    <AbsoluteFill
      style={{
        background: 'linear-gradient(-45deg, #0f0f23, #1a1a2e, #16213e, #0f3460)',
        backgroundSize: '400% 400%',
      }}
    >
      {/* 전체 영상에 걸친 앰비언트 배경 */}
      <div
        style={{
          position: 'absolute',
          width: '100%',
          height: '100%',
          background: `
            radial-gradient(ellipse at ${50 + Math.sin(bgPhase) * 20}% ${50 + Math.cos(bgPhase * 0.7) * 20}%, rgba(139, 92, 246, 0.05) 0%, transparent 50%),
            radial-gradient(ellipse at ${50 + Math.cos(bgPhase * 0.5) * 25}% ${50 + Math.sin(bgPhase * 0.8) * 15}%, rgba(236, 72, 153, 0.04) 0%, transparent 50%)
          `,
          pointerEvents: 'none',
        }}
      />

      {/* 상단/하단 비네팅 */}
      <div
        style={{
          position: 'absolute',
          width: '100%',
          height: '100%',
          background: 'linear-gradient(180deg, rgba(0,0,0,0.15) 0%, transparent 20%, transparent 80%, rgba(0,0,0,0.15) 100%)',
          pointerEvents: 'none',
          zIndex: 10,
        }}
      />

      {/* 인트로 */}
      <Sequence from={0} durationInFrames={introDuration}>
        <IntroScene orientation={orientation} locale={locale} />
      </Sequence>

      {/* 메시지 씬들 */}
      {messages.map((msg, index) => (
        <Sequence
          key={index}
          from={introDuration + index * sceneDuration}
          durationInFrames={sceneDuration}
        >
          <MessageScene
            text={msg.text}
            subText={msg.subText}
            align={msg.align}
            orientation={orientation}
            sceneIndex={index}
          />
        </Sequence>
      ))}

      {/* 아웃트로 */}
      <Sequence from={introDuration + messages.length * sceneDuration} durationInFrames={outroDuration}>
        <OutroScene orientation={orientation} locale={locale} />
      </Sequence>
    </AbsoluteFill>
  );
};
