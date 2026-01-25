import sharp from 'sharp';
import fs from 'fs';

// Screenshot dimensions for Play Store (phone: 1080x1920)
const PHONE_WIDTH = 1080;
const PHONE_HEIGHT = 1920;

// Read the icon
const iconSvg = fs.readFileSync('hexaco-icon-wire.svg', 'utf8');

// Create store directory if not exists
if (!fs.existsSync('hexaco_mobile/assets/store')) {
  fs.mkdirSync('hexaco_mobile/assets/store', { recursive: true });
}

// Screenshot 1: Home/Landing screen
async function createScreenshot1() {
  const svg = `
    <svg width="${PHONE_WIDTH}" height="${PHONE_HEIGHT}" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <linearGradient id="bgGrad" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" style="stop-color:#1a1625;stop-opacity:1" />
          <stop offset="50%" style="stop-color:#2d1b4e;stop-opacity:1" />
          <stop offset="100%" style="stop-color:#1a1625;stop-opacity:1" />
        </linearGradient>
        <linearGradient id="purpleGrad" x1="0%" y1="0%" x2="100%" y2="0%">
          <stop offset="0%" style="stop-color:#8B5CF6;stop-opacity:1" />
          <stop offset="100%" style="stop-color:#EC4899;stop-opacity:1" />
        </linearGradient>
        <linearGradient id="cardGrad" x1="0%" y1="0%" x2="0%" y2="100%">
          <stop offset="0%" style="stop-color:#2a2438;stop-opacity:1" />
          <stop offset="100%" style="stop-color:#1f1a2e;stop-opacity:1" />
        </linearGradient>
      </defs>

      <!-- Background -->
      <rect width="100%" height="100%" fill="url(#bgGrad)"/>

      <!-- Status bar area -->
      <rect x="0" y="0" width="${PHONE_WIDTH}" height="80" fill="#1a1625"/>

      <!-- Header -->
      <rect x="40" y="120" width="200" height="50" rx="25" fill="url(#purpleGrad)" opacity="0.2"/>
      <text x="70" y="155" font-family="Arial" font-size="24" fill="#C9A8E0">✨ 과학적 성격 분석</text>

      <!-- Title -->
      <text x="40" y="250" font-family="Arial" font-size="72" font-weight="bold" fill="url(#purpleGrad)">HEXACO</text>
      <text x="40" y="320" font-family="Arial" font-size="48" fill="#ffffff">성격 테스트</text>

      <!-- Subtitle with animation hint -->
      <text x="40" y="400" font-family="Arial" font-size="28" fill="#8B5CF6">진짜 나를 발견하세요</text>

      <!-- Description -->
      <text x="40" y="480" font-family="Arial" font-size="22" fill="#9CA3AF">세계적으로 권위 있는 심리학 연구를 기반으로</text>
      <text x="40" y="515" font-family="Arial" font-size="22" fill="#9CA3AF">당신의 성격을 6가지 요인으로 분석합니다.</text>

      <!-- Version selector chips -->
      <rect x="40" y="580" width="120" height="50" rx="25" fill="url(#purpleGrad)" opacity="0.3" stroke="#8B5CF6" stroke-width="2"/>
      <text x="65" y="615" font-family="Arial" font-size="20" fill="#ffffff">60 문항</text>

      <rect x="180" y="580" width="130" height="50" rx="25" fill="#2a2438" stroke="#4a4458" stroke-width="1"/>
      <text x="200" y="615" font-family="Arial" font-size="20" fill="#9CA3AF">120 문항</text>

      <rect x="330" y="580" width="130" height="50" rx="25" fill="#2a2438" stroke="#4a4458" stroke-width="1"/>
      <text x="350" y="615" font-family="Arial" font-size="20" fill="#9CA3AF">180 문항</text>

      <!-- CTA Button -->
      <rect x="40" y="680" width="${PHONE_WIDTH - 80}" height="70" rx="16" fill="url(#purpleGrad)"/>
      <text x="${PHONE_WIDTH/2}" y="725" font-family="Arial" font-size="28" fill="#ffffff" text-anchor="middle">✨ 테스트 시작</text>

      <!-- Stats section -->
      <text x="40" y="850" font-family="Arial" font-size="24" font-weight="bold" fill="#ffffff">통계</text>

      <!-- Stats cards -->
      <rect x="40" y="880" width="235" height="140" rx="20" fill="url(#cardGrad)" stroke="#3a3448" stroke-width="1"/>
      <rect x="50" y="900" width="50" height="50" rx="12" fill="url(#purpleGrad)"/>
      <text x="110" y="940" font-family="Arial" font-size="32" font-weight="bold" fill="#ffffff">50K+</text>
      <text x="52" y="1000" font-family="Arial" font-size="18" fill="#9CA3AF">테스트 완료</text>

      <rect x="295" y="880" width="235" height="140" rx="20" fill="url(#cardGrad)" stroke="#3a3448" stroke-width="1"/>
      <rect x="305" y="900" width="50" height="50" rx="12" fill="url(#purpleGrad)"/>
      <text x="365" y="940" font-family="Arial" font-size="32" font-weight="bold" fill="#ffffff">180</text>
      <text x="307" y="1000" font-family="Arial" font-size="18" fill="#9CA3AF">심리 질문</text>

      <rect x="550" y="880" width="235" height="140" rx="20" fill="url(#cardGrad)" stroke="#3a3448" stroke-width="1"/>
      <rect x="560" y="900" width="50" height="50" rx="12" fill="url(#purpleGrad)"/>
      <text x="620" y="940" font-family="Arial" font-size="32" font-weight="bold" fill="#ffffff">4.8</text>
      <text x="562" y="1000" font-family="Arial" font-size="18" fill="#9CA3AF">평균 평점</text>

      <rect x="805" y="880" width="235" height="140" rx="20" fill="url(#cardGrad)" stroke="#3a3448" stroke-width="1"/>
      <rect x="815" y="900" width="50" height="50" rx="12" fill="url(#purpleGrad)"/>
      <text x="875" y="940" font-family="Arial" font-size="32" font-weight="bold" fill="#ffffff">97%</text>
      <text x="817" y="1000" font-family="Arial" font-size="18" fill="#9CA3AF">정확도</text>

      <!-- HEXACO Factors section -->
      <text x="40" y="1120" font-family="Arial" font-size="24" font-weight="bold" fill="#ffffff">HEXACO 6가지 요인</text>

      <!-- Factor cards -->
      <rect x="40" y="1160" width="490" height="130" rx="16" fill="url(#cardGrad)" stroke="#3a3448" stroke-width="1"/>
      <text x="70" y="1210" font-family="Arial" font-size="40" font-weight="bold" fill="#F59E0B">H</text>
      <text x="120" y="1210" font-family="Arial" font-size="22" fill="#ffffff">정직-겸손</text>
      <text x="70" y="1260" font-family="Arial" font-size="18" fill="#9CA3AF">진솔함, 공정성, 겸손을 중시</text>

      <rect x="550" y="1160" width="490" height="130" rx="16" fill="url(#cardGrad)" stroke="#3a3448" stroke-width="1"/>
      <text x="580" y="1210" font-family="Arial" font-size="40" font-weight="bold" fill="#EF4444">E</text>
      <text x="630" y="1210" font-family="Arial" font-size="22" fill="#ffffff">정서성</text>
      <text x="580" y="1260" font-family="Arial" font-size="18" fill="#9CA3AF">감정 민감성과 불안</text>

      <rect x="40" y="1310" width="490" height="130" rx="16" fill="url(#cardGrad)" stroke="#3a3448" stroke-width="1"/>
      <text x="70" y="1360" font-family="Arial" font-size="40" font-weight="bold" fill="#F97316">X</text>
      <text x="120" y="1360" font-family="Arial" font-size="22" fill="#ffffff">외향성</text>
      <text x="70" y="1410" font-family="Arial" font-size="18" fill="#9CA3AF">사회적 자신감과 활력</text>

      <rect x="550" y="1310" width="490" height="130" rx="16" fill="url(#cardGrad)" stroke="#3a3448" stroke-width="1"/>
      <text x="580" y="1360" font-family="Arial" font-size="40" font-weight="bold" fill="#22C55E">A</text>
      <text x="630" y="1360" font-family="Arial" font-size="22" fill="#ffffff">원만성</text>
      <text x="580" y="1410" font-family="Arial" font-size="18" fill="#9CA3AF">관용과 협력적 태도</text>

      <rect x="40" y="1460" width="490" height="130" rx="16" fill="url(#cardGrad)" stroke="#3a3448" stroke-width="1"/>
      <text x="70" y="1510" font-family="Arial" font-size="40" font-weight="bold" fill="#3B82F6">C</text>
      <text x="120" y="1510" font-family="Arial" font-size="22" fill="#ffffff">성실성</text>
      <text x="70" y="1560" font-family="Arial" font-size="18" fill="#9CA3AF">체계성과 완벽주의</text>

      <rect x="550" y="1460" width="490" height="130" rx="16" fill="url(#cardGrad)" stroke="#3a3448" stroke-width="1"/>
      <text x="580" y="1510" font-family="Arial" font-size="40" font-weight="bold" fill="#8B5CF6">O</text>
      <text x="630" y="1510" font-family="Arial" font-size="22" fill="#ffffff">개방성</text>
      <text x="580" y="1560" font-family="Arial" font-size="18" fill="#9CA3AF">창의성과 지적 호기심</text>

      <!-- Bottom navigation hint -->
      <rect x="${PHONE_WIDTH/2 - 70}" y="1850" width="140" height="6" rx="3" fill="#4a4458"/>
    </svg>
  `;

  await sharp(Buffer.from(svg)).png().toFile('hexaco_mobile/assets/store/screenshot_1_home.png');
  console.log('Created screenshot_1_home.png');
}

// Screenshot 2: Test screen
async function createScreenshot2() {
  const svg = `
    <svg width="${PHONE_WIDTH}" height="${PHONE_HEIGHT}" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <linearGradient id="bgGrad" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" style="stop-color:#1a1625;stop-opacity:1" />
          <stop offset="50%" style="stop-color:#2d1b4e;stop-opacity:1" />
          <stop offset="100%" style="stop-color:#1a1625;stop-opacity:1" />
        </linearGradient>
        <linearGradient id="purpleGrad" x1="0%" y1="0%" x2="100%" y2="0%">
          <stop offset="0%" style="stop-color:#8B5CF6;stop-opacity:1" />
          <stop offset="100%" style="stop-color:#EC4899;stop-opacity:1" />
        </linearGradient>
        <linearGradient id="cardGrad" x1="0%" y1="0%" x2="0%" y2="100%">
          <stop offset="0%" style="stop-color:#2a2438;stop-opacity:1" />
          <stop offset="100%" style="stop-color:#1f1a2e;stop-opacity:1" />
        </linearGradient>
      </defs>

      <!-- Background -->
      <rect width="100%" height="100%" fill="url(#bgGrad)"/>

      <!-- Header -->
      <rect x="0" y="0" width="${PHONE_WIDTH}" height="140" fill="#1a1625"/>
      <text x="40" y="100" font-family="Arial" font-size="28" font-weight="bold" fill="#ffffff">질문 15 / 60</text>

      <!-- Progress bar -->
      <rect x="40" y="160" width="${PHONE_WIDTH - 80}" height="12" rx="6" fill="#2a2438"/>
      <rect x="40" y="160" width="${(PHONE_WIDTH - 80) * 0.25}" height="12" rx="6" fill="url(#purpleGrad)"/>

      <!-- Factor badge -->
      <rect x="40" y="220" width="80" height="40" rx="20" fill="#F59E0B" opacity="0.2"/>
      <text x="65" y="248" font-family="Arial" font-size="22" font-weight="bold" fill="#F59E0B">H</text>

      <!-- Question -->
      <text x="40" y="340" font-family="Arial" font-size="32" fill="#ffffff">친구가 새 옷이 어울리지</text>
      <text x="40" y="390" font-family="Arial" font-size="32" fill="#ffffff">않는지 물으면 솔직하게</text>
      <text x="40" y="440" font-family="Arial" font-size="32" fill="#ffffff">말해준다.</text>

      <!-- Answer options -->
      <rect x="40" y="540" width="${PHONE_WIDTH - 80}" height="100" rx="16" fill="url(#cardGrad)" stroke="#3a3448" stroke-width="1"/>
      <text x="${PHONE_WIDTH/2}" y="600" font-family="Arial" font-size="24" fill="#9CA3AF" text-anchor="middle">1 - 전혀 아니다</text>

      <rect x="40" y="660" width="${PHONE_WIDTH - 80}" height="100" rx="16" fill="url(#cardGrad)" stroke="#3a3448" stroke-width="1"/>
      <text x="${PHONE_WIDTH/2}" y="720" font-family="Arial" font-size="24" fill="#9CA3AF" text-anchor="middle">2 - 아니다</text>

      <rect x="40" y="780" width="${PHONE_WIDTH - 80}" height="100" rx="16" fill="url(#cardGrad)" stroke="#3a3448" stroke-width="1"/>
      <text x="${PHONE_WIDTH/2}" y="840" font-family="Arial" font-size="24" fill="#9CA3AF" text-anchor="middle">3 - 보통이다</text>

      <rect x="40" y="900" width="${PHONE_WIDTH - 80}" height="100" rx="16" fill="url(#purpleGrad)" opacity="0.3" stroke="#8B5CF6" stroke-width="2"/>
      <text x="${PHONE_WIDTH/2}" y="960" font-family="Arial" font-size="24" fill="#ffffff" text-anchor="middle">4 - 그렇다</text>

      <rect x="40" y="1020" width="${PHONE_WIDTH - 80}" height="100" rx="16" fill="url(#cardGrad)" stroke="#3a3448" stroke-width="1"/>
      <text x="${PHONE_WIDTH/2}" y="1080" font-family="Arial" font-size="24" fill="#9CA3AF" text-anchor="middle">5 - 매우 그렇다</text>

      <!-- Navigation buttons -->
      <rect x="40" y="1200" width="200" height="70" rx="16" fill="url(#cardGrad)" stroke="#3a3448" stroke-width="1"/>
      <text x="140" y="1245" font-family="Arial" font-size="24" fill="#9CA3AF" text-anchor="middle">← 이전</text>

      <rect x="${PHONE_WIDTH - 240}" y="1200" width="200" height="70" rx="16" fill="url(#purpleGrad)"/>
      <text x="${PHONE_WIDTH - 140}" y="1245" font-family="Arial" font-size="24" fill="#ffffff" text-anchor="middle">다음 →</text>

      <!-- Ad placeholder -->
      <rect x="40" y="1400" width="${PHONE_WIDTH - 80}" height="100" rx="8" fill="#2a2438" stroke="#3a3448" stroke-width="1"/>
      <text x="${PHONE_WIDTH/2}" y="1460" font-family="Arial" font-size="18" fill="#6b7280" text-anchor="middle">테스트 광고</text>

      <!-- Bottom navigation hint -->
      <rect x="${PHONE_WIDTH/2 - 70}" y="1850" width="140" height="6" rx="3" fill="#4a4458"/>
    </svg>
  `;

  await sharp(Buffer.from(svg)).png().toFile('hexaco_mobile/assets/store/screenshot_2_test.png');
  console.log('Created screenshot_2_test.png');
}

// Screenshot 3: Result screen
async function createScreenshot3() {
  const svg = `
    <svg width="${PHONE_WIDTH}" height="${PHONE_HEIGHT}" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <linearGradient id="bgGrad" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" style="stop-color:#1a1625;stop-opacity:1" />
          <stop offset="50%" style="stop-color:#2d1b4e;stop-opacity:1" />
          <stop offset="100%" style="stop-color:#1a1625;stop-opacity:1" />
        </linearGradient>
        <linearGradient id="purpleGrad" x1="0%" y1="0%" x2="100%" y2="0%">
          <stop offset="0%" style="stop-color:#8B5CF6;stop-opacity:1" />
          <stop offset="100%" style="stop-color:#EC4899;stop-opacity:1" />
        </linearGradient>
        <linearGradient id="cardGrad" x1="0%" y1="0%" x2="0%" y2="100%">
          <stop offset="0%" style="stop-color:#2a2438;stop-opacity:1" />
          <stop offset="100%" style="stop-color:#1f1a2e;stop-opacity:1" />
        </linearGradient>
      </defs>

      <!-- Background -->
      <rect width="100%" height="100%" fill="url(#bgGrad)"/>

      <!-- Header -->
      <rect x="0" y="0" width="${PHONE_WIDTH}" height="140" fill="#1a1625"/>
      <text x="${PHONE_WIDTH/2}" y="100" font-family="Arial" font-size="32" font-weight="bold" fill="#ffffff" text-anchor="middle">결과 분석</text>

      <!-- Top Match Card -->
      <rect x="40" y="180" width="${PHONE_WIDTH - 80}" height="180" rx="20" fill="url(#cardGrad)" stroke="url(#purpleGrad)" stroke-width="2"/>
      <circle cx="140" cy="270" r="50" fill="url(#purpleGrad)"/>
      <text x="140" y="285" font-family="Arial" font-size="36" font-weight="bold" fill="#ffffff" text-anchor="middle">A</text>
      <text x="240" y="250" font-family="Arial" font-size="32" font-weight="bold" fill="#ffffff">Albert Einstein</text>
      <text x="240" y="295" font-family="Arial" font-size="20" fill="#9CA3AF">호기심 많은 탐구자, 창의적 천재</text>
      <text x="240" y="340" font-family="Arial" font-size="22" fill="#8B5CF6">유사도 87%</text>

      <!-- Radar Chart placeholder -->
      <rect x="40" y="400" width="${PHONE_WIDTH - 80}" height="340" rx="20" fill="url(#cardGrad)" stroke="#3a3448" stroke-width="1"/>
      <text x="70" y="450" font-family="Arial" font-size="24" font-weight="bold" fill="#ffffff">프로필 지도</text>

      <!-- Hexagon shape for radar -->
      <polygon points="540,520 680,590 680,730 540,800 400,730 400,590" fill="none" stroke="#3a3448" stroke-width="1"/>
      <polygon points="540,560 640,610 640,690 540,740 440,690 440,610" fill="none" stroke="#3a3448" stroke-width="1"/>
      <polygon points="540,600 600,630 600,650 540,680 480,650 480,630" fill="none" stroke="#3a3448" stroke-width="1"/>

      <!-- Radar data (filled area) -->
      <polygon points="540,540 660,600 640,720 540,770 420,680 450,590" fill="#8B5CF6" opacity="0.3" stroke="#8B5CF6" stroke-width="2"/>

      <!-- Factor labels -->
      <text x="540" y="500" font-family="Arial" font-size="18" fill="#F59E0B" text-anchor="middle">H</text>
      <text x="700" y="590" font-family="Arial" font-size="18" fill="#EF4444">E</text>
      <text x="700" y="740" font-family="Arial" font-size="18" fill="#F97316">X</text>
      <text x="540" y="820" font-family="Arial" font-size="18" fill="#22C55E" text-anchor="middle">A</text>
      <text x="380" y="740" font-family="Arial" font-size="18" fill="#3B82F6">C</text>
      <text x="380" y="590" font-family="Arial" font-size="18" fill="#8B5CF6">O</text>

      <!-- Factor Scores -->
      <text x="40" y="800" font-family="Arial" font-size="24" font-weight="bold" fill="#ffffff">요인 점수</text>

      <!-- Score bars -->
      <rect x="40" y="840" width="480" height="80" rx="12" fill="url(#cardGrad)" stroke="#3a3448" stroke-width="1"/>
      <text x="70" y="880" font-family="Arial" font-size="28" font-weight="bold" fill="#F59E0B">H</text>
      <text x="110" y="880" font-family="Arial" font-size="18" fill="#9CA3AF">정직-겸손</text>
      <text x="440" y="885" font-family="Arial" font-size="24" font-weight="bold" fill="#ffffff">4.2</text>
      <rect x="70" y="895" width="380" height="8" rx="4" fill="#2a2438"/>
      <rect x="70" y="895" width="${380 * 0.84}" height="8" rx="4" fill="#F59E0B"/>

      <rect x="560" y="840" width="480" height="80" rx="12" fill="url(#cardGrad)" stroke="#3a3448" stroke-width="1"/>
      <text x="590" y="880" font-family="Arial" font-size="28" font-weight="bold" fill="#EF4444">E</text>
      <text x="630" y="880" font-family="Arial" font-size="18" fill="#9CA3AF">정서성</text>
      <text x="960" y="885" font-family="Arial" font-size="24" font-weight="bold" fill="#ffffff">3.1</text>
      <rect x="590" y="895" width="380" height="8" rx="4" fill="#2a2438"/>
      <rect x="590" y="895" width="${380 * 0.62}" height="8" rx="4" fill="#EF4444"/>

      <rect x="40" y="940" width="480" height="80" rx="12" fill="url(#cardGrad)" stroke="#3a3448" stroke-width="1"/>
      <text x="70" y="980" font-family="Arial" font-size="28" font-weight="bold" fill="#F97316">X</text>
      <text x="110" y="980" font-family="Arial" font-size="18" fill="#9CA3AF">외향성</text>
      <text x="440" y="985" font-family="Arial" font-size="24" font-weight="bold" fill="#ffffff">3.8</text>
      <rect x="70" y="995" width="380" height="8" rx="4" fill="#2a2438"/>
      <rect x="70" y="995" width="${380 * 0.76}" height="8" rx="4" fill="#F97316"/>

      <rect x="560" y="940" width="480" height="80" rx="12" fill="url(#cardGrad)" stroke="#3a3448" stroke-width="1"/>
      <text x="590" y="980" font-family="Arial" font-size="28" font-weight="bold" fill="#22C55E">A</text>
      <text x="630" y="980" font-family="Arial" font-size="18" fill="#9CA3AF">원만성</text>
      <text x="960" y="985" font-family="Arial" font-size="24" font-weight="bold" fill="#ffffff">4.5</text>
      <rect x="590" y="995" width="380" height="8" rx="4" fill="#2a2438"/>
      <rect x="590" y="995" width="${380 * 0.9}" height="8" rx="4" fill="#22C55E"/>

      <!-- Top 5 Matches -->
      <text x="40" y="1100" font-family="Arial" font-size="24" font-weight="bold" fill="#ffffff">추천 유형 TOP 5</text>

      <rect x="40" y="1140" width="${PHONE_WIDTH - 80}" height="300" rx="20" fill="url(#cardGrad)" stroke="#3a3448" stroke-width="1"/>

      <!-- Match rows -->
      <text x="80" y="1200" font-family="Arial" font-size="24" font-weight="bold" fill="url(#purpleGrad)">1</text>
      <text x="130" y="1200" font-family="Arial" font-size="22" fill="#ffffff">Albert Einstein</text>
      <text x="900" y="1200" font-family="Arial" font-size="20" fill="#8B5CF6">87%</text>

      <text x="80" y="1260" font-family="Arial" font-size="24" font-weight="bold" fill="#9CA3AF">2</text>
      <text x="130" y="1260" font-family="Arial" font-size="22" fill="#ffffff">Marie Curie</text>
      <text x="900" y="1260" font-family="Arial" font-size="20" fill="#9CA3AF">82%</text>

      <text x="80" y="1320" font-family="Arial" font-size="24" font-weight="bold" fill="#9CA3AF">3</text>
      <text x="130" y="1320" font-family="Arial" font-size="22" fill="#ffffff">Leonardo da Vinci</text>
      <text x="900" y="1320" font-family="Arial" font-size="20" fill="#9CA3AF">79%</text>

      <text x="80" y="1380" font-family="Arial" font-size="24" font-weight="bold" fill="#9CA3AF">4</text>
      <text x="130" y="1380" font-family="Arial" font-size="22" fill="#ffffff">Nikola Tesla</text>
      <text x="900" y="1380" font-family="Arial" font-size="20" fill="#9CA3AF">76%</text>

      <!-- Share buttons -->
      <rect x="40" y="1500" width="490" height="70" rx="16" fill="url(#cardGrad)" stroke="#3a3448" stroke-width="1"/>
      <text x="285" y="1545" font-family="Arial" font-size="22" fill="#9CA3AF" text-anchor="middle">🔗 결과 복사</text>

      <rect x="550" y="1500" width="490" height="70" rx="16" fill="url(#cardGrad)" stroke="#3a3448" stroke-width="1"/>
      <text x="795" y="1545" font-family="Arial" font-size="22" fill="#9CA3AF" text-anchor="middle">📤 결과 공유</text>

      <!-- Action buttons -->
      <rect x="40" y="1600" width="490" height="70" rx="16" fill="url(#purpleGrad)"/>
      <text x="285" y="1645" font-family="Arial" font-size="24" fill="#ffffff" text-anchor="middle">다시하기</text>

      <rect x="550" y="1600" width="490" height="70" rx="16" fill="url(#cardGrad)" stroke="#3a3448" stroke-width="1"/>
      <text x="795" y="1645" font-family="Arial" font-size="24" fill="#9CA3AF" text-anchor="middle">홈으로</text>

      <!-- Legal notice -->
      <rect x="40" y="1700" width="${PHONE_WIDTH - 80}" height="80" rx="12" fill="url(#cardGrad)" opacity="0.7"/>
      <text x="80" y="1745" font-family="Arial" font-size="16" fill="#6b7280">ℹ️ 결과는 참고용이며 전문 심리 진단을 대체하지 않습니다.</text>

      <!-- Bottom navigation hint -->
      <rect x="${PHONE_WIDTH/2 - 70}" y="1850" width="140" height="6" rx="3" fill="#4a4458"/>
    </svg>
  `;

  await sharp(Buffer.from(svg)).png().toFile('hexaco_mobile/assets/store/screenshot_3_result.png');
  console.log('Created screenshot_3_result.png');
}

// Run all
await createScreenshot1();
await createScreenshot2();
await createScreenshot3();

console.log('\n✅ All screenshots created successfully!');
console.log('📁 Location: hexaco_mobile/assets/store/');
