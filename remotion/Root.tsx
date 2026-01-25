import { Composition } from 'remotion';
import { HexacoPromoVideo } from './Video';

export const RemotionRoot: React.FC = () => {
  return (
    <>
      {/* 모바일 세로 (9:16) - 30초 @ 30fps = 900 frames */}
      <Composition
        id="HexacoPromo-Portrait"
        component={HexacoPromoVideo}
        durationInFrames={900}
        fps={30}
        width={1080}
        height={1920}
        defaultProps={{
          orientation: 'portrait' as const,
        }}
      />
      {/* 모바일 가로 (16:9) - 30초 @ 30fps = 900 frames */}
      <Composition
        id="HexacoPromo-Landscape"
        component={HexacoPromoVideo}
        durationInFrames={900}
        fps={30}
        width={1920}
        height={1080}
        defaultProps={{
          orientation: 'landscape' as const,
        }}
      />
    </>
  );
};
