import sharp from 'sharp';
import fs from 'fs';

// Create feature graphic (1024x500) for Play Store
async function createFeatureGraphic() {
  const width = 1024;
  const height = 500;

  // Read the icon SVG
  const iconSvg = fs.readFileSync('hexaco-icon-wire.svg', 'utf8');

  // Create icon at 280px (fitting nicely in the graphic)
  const iconBuffer = await sharp(Buffer.from(iconSvg))
    .resize(280, 280)
    .png()
    .toBuffer();

  // Create the background with gradient
  const backgroundSvg = `
    <svg width="${width}" height="${height}" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <linearGradient id="bgGrad" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" style="stop-color:#1a1625;stop-opacity:1" />
          <stop offset="50%" style="stop-color:#2d1b4e;stop-opacity:1" />
          <stop offset="100%" style="stop-color:#1a1625;stop-opacity:1" />
        </linearGradient>
        <linearGradient id="textGrad" x1="0%" y1="0%" x2="100%" y2="0%">
          <stop offset="0%" style="stop-color:#8B5CF6;stop-opacity:1" />
          <stop offset="100%" style="stop-color:#EC4899;stop-opacity:1" />
        </linearGradient>
        <!-- Glow effect -->
        <filter id="glow" x="-50%" y="-50%" width="200%" height="200%">
          <feGaussianBlur stdDeviation="20" result="coloredBlur"/>
          <feMerge>
            <feMergeNode in="coloredBlur"/>
            <feMergeNode in="SourceGraphic"/>
          </feMerge>
        </filter>
      </defs>

      <!-- Background -->
      <rect width="100%" height="100%" fill="url(#bgGrad)"/>

      <!-- Decorative circles -->
      <circle cx="100" cy="100" r="150" fill="#8B5CF6" opacity="0.1"/>
      <circle cx="924" cy="400" r="200" fill="#EC4899" opacity="0.1"/>

      <!-- Decorative lines -->
      <line x1="0" y1="250" x2="200" y2="250" stroke="#8B5CF6" stroke-width="2" opacity="0.3"/>
      <line x1="824" y1="250" x2="1024" y2="250" stroke="#EC4899" stroke-width="2" opacity="0.3"/>
    </svg>
  `;

  // Create text overlay SVG
  const textSvg = `
    <svg width="${width}" height="${height}" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <linearGradient id="textGrad" x1="0%" y1="0%" x2="100%" y2="0%">
          <stop offset="0%" style="stop-color:#8B5CF6;stop-opacity:1" />
          <stop offset="100%" style="stop-color:#EC4899;stop-opacity:1" />
        </linearGradient>
      </defs>

      <!-- App Name -->
      <text x="580" y="200" font-family="Arial, sans-serif" font-size="48" font-weight="bold" fill="url(#textGrad)">HEXACO</text>
      <text x="580" y="260" font-family="Arial, sans-serif" font-size="36" fill="#ffffff">성격 테스트</text>

      <!-- Tagline -->
      <text x="580" y="320" font-family="Arial, sans-serif" font-size="22" fill="#9CA3AF">5분 - 나를 알아보는 시간</text>

      <!-- Features -->
      <text x="580" y="380" font-family="Arial, sans-serif" font-size="18" fill="#C9A8E0">✓ 과학적 HEXACO 모델 기반</text>
      <text x="580" y="410" font-family="Arial, sans-serif" font-size="18" fill="#C9A8E0">✓ 6가지 성격 요인 분석</text>
      <text x="580" y="440" font-family="Arial, sans-serif" font-size="18" fill="#C9A8E0">✓ 무료 즉시 결과 확인</text>
    </svg>
  `;

  // Compose the final image
  const background = await sharp(Buffer.from(backgroundSvg))
    .png()
    .toBuffer();

  const textOverlay = await sharp(Buffer.from(textSvg))
    .png()
    .toBuffer();

  // Composite all layers
  await sharp(background)
    .composite([
      {
        input: iconBuffer,
        left: 150,
        top: 110,
      },
      {
        input: textOverlay,
        left: 0,
        top: 0,
      }
    ])
    .png()
    .toFile('hexaco_mobile/assets/store/feature_graphic.png');

  console.log('Created feature_graphic.png (1024x500)');
}

// Create store directory if not exists
if (!fs.existsSync('hexaco_mobile/assets/store')) {
  fs.mkdirSync('hexaco_mobile/assets/store', { recursive: true });
}

await createFeatureGraphic();
console.log('Store assets created successfully!');
