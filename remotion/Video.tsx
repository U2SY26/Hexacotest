import { AbsoluteFill, Sequence, useCurrentFrame, interpolate, spring, useVideoConfig } from 'remotion';
import { MessageScene } from './scenes/MessageScene';
import { IntroScene } from './scenes/IntroScene';
import { OutroScene } from './scenes/OutroScene';

interface Props {
  orientation: 'portrait' | 'landscape';
}

// 자존감 회복 메시지 (5-6개)
const messages = [
  {
    text: '나를\n알아가는 여정',
    subText: 'Journey to Self',
    align: 'left' as const,
  },
  {
    text: '진짜 나는\n누구일까?',
    subText: 'Who Am I Really?',
    align: 'right' as const,
  },
  {
    text: '숨겨진\n가능성 발견',
    subText: 'Hidden Potential',
    align: 'left' as const,
  },
  {
    text: '자존감\n회복의 시작',
    subText: 'Self-Worth Recovery',
    align: 'right' as const,
  },
  {
    text: '당신의 강점을\n찾아보세요',
    subText: 'Find Your Strengths',
    align: 'left' as const,
  },
  {
    text: '오늘, 진정한\n나를 만나다',
    subText: 'Meet the Real You',
    align: 'center' as const,
  },
];

export const HexacoPromoVideo: React.FC<Props> = ({ orientation }) => {
  const { fps } = useVideoConfig();

  // 각 씬의 길이 (프레임 단위) - 약 4초씩 (120프레임)
  const introDuration = 120; // 4초
  const sceneDuration = 105; // 3.5초
  const outroDuration = 120; // 4초

  return (
    <AbsoluteFill
      style={{
        background: 'linear-gradient(-45deg, #0f0f23, #1a1a2e, #16213e, #0f3460)',
        backgroundSize: '400% 400%',
      }}
    >
      {/* 인트로 - 0~4초 */}
      <Sequence from={0} durationInFrames={introDuration}>
        <IntroScene orientation={orientation} />
      </Sequence>

      {/* 메시지 씬들 - 각 3.5초씩 */}
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

      {/* 아웃트로 - 마지막 4초 */}
      <Sequence from={introDuration + messages.length * sceneDuration} durationInFrames={outroDuration}>
        <OutroScene orientation={orientation} />
      </Sequence>
    </AbsoluteFill>
  );
};
