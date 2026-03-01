import { Composition } from 'remotion';
import { HexacoPromoVideo } from './Video';

export const RemotionRoot: React.FC = () => {
  return (
    <>
      {/* 한국어 - 세로 (9:16) */}
      <Composition
        id="HexacoPromo-Portrait"
        component={HexacoPromoVideo}
        durationInFrames={900}
        fps={30}
        width={1080}
        height={1920}
        defaultProps={{
          orientation: 'portrait' as const,
          locale: 'ko' as const,
        }}
      />
      {/* 한국어 - 가로 (16:9) */}
      <Composition
        id="HexacoPromo-Landscape"
        component={HexacoPromoVideo}
        durationInFrames={900}
        fps={30}
        width={1920}
        height={1080}
        defaultProps={{
          orientation: 'landscape' as const,
          locale: 'ko' as const,
        }}
      />
      {/* English - Portrait (9:16) */}
      <Composition
        id="HexacoPromo-Portrait-EN"
        component={HexacoPromoVideo}
        durationInFrames={900}
        fps={30}
        width={1080}
        height={1920}
        defaultProps={{
          orientation: 'portrait' as const,
          locale: 'en' as const,
        }}
      />
      {/* English - Landscape (16:9) */}
      <Composition
        id="HexacoPromo-Landscape-EN"
        component={HexacoPromoVideo}
        durationInFrames={900}
        fps={30}
        width={1920}
        height={1080}
        defaultProps={{
          orientation: 'landscape' as const,
          locale: 'en' as const,
        }}
      />
    </>
  );
};
