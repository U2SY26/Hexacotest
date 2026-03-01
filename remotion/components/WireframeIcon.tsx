import React from 'react';

interface IconProps {
  size?: number;
  strokeWidth?: number;
  color?: string;
}

const defaultColor = '#8B5CF6';
const defaultStrokeWidth = 2;

// 와이어프레임 헥사곤 아이콘 - 이중 레이어 + 글로우
export const WireframeHexagon: React.FC<IconProps> = ({
  size = 100,
  strokeWidth = defaultStrokeWidth,
  color = defaultColor,
}) => (
  <svg
    width={size}
    height={size}
    viewBox="0 0 100 100"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
  >
    <defs>
      <linearGradient id="hexGradient" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" stopColor="#8B5CF6" />
        <stop offset="50%" stopColor="#A78BFA" />
        <stop offset="100%" stopColor="#EC4899" />
      </linearGradient>
      <filter id="hexGlow">
        <feGaussianBlur stdDeviation="3" result="blur" />
        <feComposite in="SourceGraphic" in2="blur" operator="over" />
      </filter>
      <linearGradient id="hexFill" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" stopColor="#8B5CF6" stopOpacity="0.08" />
        <stop offset="100%" stopColor="#EC4899" stopOpacity="0.05" />
      </linearGradient>
    </defs>
    {/* 외부 글로우 */}
    <path
      d="M50 5L93.3 27.5V72.5L50 95L6.7 72.5V27.5L50 5Z"
      stroke="url(#hexGradient)"
      strokeWidth={strokeWidth * 1.5}
      strokeLinecap="round"
      strokeLinejoin="round"
      opacity="0.3"
      filter="url(#hexGlow)"
    />
    {/* 외부 헥사곤 */}
    <path
      d="M50 5L93.3 27.5V72.5L50 95L6.7 72.5V27.5L50 5Z"
      fill="url(#hexFill)"
      stroke="url(#hexGradient)"
      strokeWidth={strokeWidth}
      strokeLinecap="round"
      strokeLinejoin="round"
    />
    {/* 내부 헥사곤 */}
    <path
      d="M50 25L72.5 37.5V62.5L50 75L27.5 62.5V37.5L50 25Z"
      stroke="url(#hexGradient)"
      strokeWidth={strokeWidth * 0.8}
      strokeLinecap="round"
      strokeLinejoin="round"
      opacity="0.6"
    />
    {/* 중심 점 */}
    <circle cx="50" cy="50" r="3" fill="url(#hexGradient)" opacity="0.8" />
    {/* 연결선 */}
    <path
      d="M50 25V5M72.5 37.5L93.3 27.5M72.5 62.5L93.3 72.5M50 75V95M27.5 62.5L6.7 72.5M27.5 37.5L6.7 27.5"
      stroke="url(#hexGradient)"
      strokeWidth={strokeWidth * 0.4}
      strokeLinecap="round"
      opacity="0.3"
    />
  </svg>
);

// 와이어프레임 뇌 아이콘 - 강화
export const WireframeBrain: React.FC<IconProps> = ({
  size = 100,
  strokeWidth = defaultStrokeWidth,
  color = defaultColor,
}) => (
  <svg
    width={size}
    height={size}
    viewBox="0 0 100 100"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
  >
    <defs>
      <linearGradient id="brainGradient" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" stopColor="#8B5CF6" />
        <stop offset="50%" stopColor="#A78BFA" />
        <stop offset="100%" stopColor="#EC4899" />
      </linearGradient>
      <filter id="brainGlow">
        <feGaussianBlur stdDeviation="2.5" result="blur" />
        <feComposite in="SourceGraphic" in2="blur" operator="over" />
      </filter>
    </defs>
    {/* 외부 글로우 */}
    <path
      d="M30 75C18 75 10 65 10 55C10 48 14 42 20 39C18 36 17 32 17 28C17 18 25 10 35 10C38 10 41 11 44 12C47 8 52 5 58 5"
      stroke="url(#brainGradient)"
      strokeWidth={strokeWidth * 1.5}
      strokeLinecap="round"
      opacity="0.2"
      filter="url(#brainGlow)"
    />
    {/* 왼쪽 뇌 */}
    <path
      d="M30 75C18 75 10 65 10 55C10 48 14 42 20 39C18 36 17 32 17 28C17 18 25 10 35 10C38 10 41 11 44 12C47 8 52 5 58 5"
      stroke="url(#brainGradient)"
      strokeWidth={strokeWidth}
      strokeLinecap="round"
    />
    {/* 오른쪽 뇌 */}
    <path
      d="M70 75C82 75 90 65 90 55C90 48 86 42 80 39C82 36 83 32 83 28C83 18 75 10 65 10C62 10 59 11 56 12C53 8 48 5 42 5"
      stroke="url(#brainGradient)"
      strokeWidth={strokeWidth}
      strokeLinecap="round"
    />
    {/* 중앙 연결 */}
    <path
      d="M50 5V95"
      stroke="url(#brainGradient)"
      strokeWidth={strokeWidth * 0.5}
      strokeLinecap="round"
      strokeDasharray="4 4"
    />
    {/* 뇌 주름 */}
    <path
      d="M25 45C30 42 35 45 35 50M75 45C70 42 65 45 65 50"
      stroke="url(#brainGradient)"
      strokeWidth={strokeWidth * 0.8}
      strokeLinecap="round"
    />
    <path
      d="M30 60C35 58 40 62 38 67M70 60C65 58 60 62 62 67"
      stroke="url(#brainGradient)"
      strokeWidth={strokeWidth * 0.8}
      strokeLinecap="round"
    />
    {/* 뉴런 포인트 */}
    <circle cx="35" cy="30" r="2" fill="url(#brainGradient)" opacity="0.6" />
    <circle cx="65" cy="30" r="2" fill="url(#brainGradient)" opacity="0.6" />
    <circle cx="25" cy="50" r="1.5" fill="url(#brainGradient)" opacity="0.4" />
    <circle cx="75" cy="50" r="1.5" fill="url(#brainGradient)" opacity="0.4" />
    <circle cx="38" cy="67" r="1.5" fill="url(#brainGradient)" opacity="0.4" />
    <circle cx="62" cy="67" r="1.5" fill="url(#brainGradient)" opacity="0.4" />
  </svg>
);

// 와이어프레임 하트 아이콘 - 강화
export const WireframeHeart: React.FC<IconProps> = ({
  size = 100,
  strokeWidth = defaultStrokeWidth,
  color = defaultColor,
}) => (
  <svg
    width={size}
    height={size}
    viewBox="0 0 100 100"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
  >
    <defs>
      <linearGradient id="heartGradient" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" stopColor="#EC4899" />
        <stop offset="50%" stopColor="#F43F5E" />
        <stop offset="100%" stopColor="#8B5CF6" />
      </linearGradient>
      <linearGradient id="heartFill" x1="50%" y1="0%" x2="50%" y2="100%">
        <stop offset="0%" stopColor="#EC4899" stopOpacity="0.1" />
        <stop offset="100%" stopColor="#8B5CF6" stopOpacity="0.03" />
      </linearGradient>
      <filter id="heartGlow">
        <feGaussianBlur stdDeviation="2.5" result="blur" />
        <feComposite in="SourceGraphic" in2="blur" operator="over" />
      </filter>
    </defs>
    {/* 글로우 */}
    <path
      d="M50 88L14.6 49.6C5.5 39.6 5.5 24.3 14.6 14.4C23.7 4.5 38.5 4.5 47.6 14.4L50 17L52.4 14.4C61.5 4.5 76.3 4.5 85.4 14.4C94.5 24.3 94.5 39.6 85.4 49.6L50 88Z"
      stroke="url(#heartGradient)"
      strokeWidth={strokeWidth * 1.5}
      opacity="0.2"
      filter="url(#heartGlow)"
    />
    <path
      d="M50 88L14.6 49.6C5.5 39.6 5.5 24.3 14.6 14.4C23.7 4.5 38.5 4.5 47.6 14.4L50 17L52.4 14.4C61.5 4.5 76.3 4.5 85.4 14.4C94.5 24.3 94.5 39.6 85.4 49.6L50 88Z"
      fill="url(#heartFill)"
      stroke="url(#heartGradient)"
      strokeWidth={strokeWidth}
      strokeLinecap="round"
      strokeLinejoin="round"
    />
    {/* 내부 라인 */}
    <path
      d="M50 70L28 46C23 40 23 32 28 26M50 70L72 46C77 40 77 32 72 26"
      stroke="url(#heartGradient)"
      strokeWidth={strokeWidth * 0.6}
      strokeLinecap="round"
      strokeLinejoin="round"
      opacity="0.4"
    />
    {/* 하이라이트 */}
    <circle cx="30" cy="28" r="4" fill="url(#heartGradient)" opacity="0.15" />
  </svg>
);

// 와이어프레임 별 아이콘 - 강화
export const WireframeStar: React.FC<IconProps> = ({
  size = 100,
  strokeWidth = defaultStrokeWidth,
  color = defaultColor,
}) => (
  <svg
    width={size}
    height={size}
    viewBox="0 0 100 100"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
  >
    <defs>
      <linearGradient id="starGradient" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" stopColor="#F59E0B" />
        <stop offset="50%" stopColor="#EC4899" />
        <stop offset="100%" stopColor="#8B5CF6" />
      </linearGradient>
      <linearGradient id="starFill" x1="50%" y1="0%" x2="50%" y2="100%">
        <stop offset="0%" stopColor="#F59E0B" stopOpacity="0.08" />
        <stop offset="100%" stopColor="#EC4899" stopOpacity="0.03" />
      </linearGradient>
      <filter id="starGlow">
        <feGaussianBlur stdDeviation="2" result="blur" />
        <feComposite in="SourceGraphic" in2="blur" operator="over" />
      </filter>
    </defs>
    <path
      d="M50 5L61.2 38.2H96.1L68.4 58.8L79.6 92L50 71.4L20.4 92L31.6 58.8L3.9 38.2H38.8L50 5Z"
      stroke="url(#starGradient)"
      strokeWidth={strokeWidth * 1.5}
      opacity="0.2"
      filter="url(#starGlow)"
    />
    <path
      d="M50 5L61.2 38.2H96.1L68.4 58.8L79.6 92L50 71.4L20.4 92L31.6 58.8L3.9 38.2H38.8L50 5Z"
      fill="url(#starFill)"
      stroke="url(#starGradient)"
      strokeWidth={strokeWidth}
      strokeLinecap="round"
      strokeLinejoin="round"
    />
    {/* 내부 별 */}
    <path
      d="M50 25L56.5 44H77L60 56L67 75L50 63L33 75L40 56L23 44H43.5L50 25Z"
      stroke="url(#starGradient)"
      strokeWidth={strokeWidth * 0.6}
      strokeLinecap="round"
      strokeLinejoin="round"
      opacity="0.35"
    />
    {/* 중심 */}
    <circle cx="50" cy="50" r="3" fill="url(#starGradient)" opacity="0.5" />
  </svg>
);

// 와이어프레임 스파클 아이콘 - 강화
export const WireframeSparkles: React.FC<IconProps> = ({
  size = 100,
  strokeWidth = defaultStrokeWidth,
  color = defaultColor,
}) => (
  <svg
    width={size}
    height={size}
    viewBox="0 0 100 100"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
  >
    <defs>
      <linearGradient id="sparkleGradient" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" stopColor="#06B6D4" />
        <stop offset="50%" stopColor="#8B5CF6" />
        <stop offset="100%" stopColor="#EC4899" />
      </linearGradient>
      <filter id="sparkleGlow">
        <feGaussianBlur stdDeviation="2" result="blur" />
        <feComposite in="SourceGraphic" in2="blur" operator="over" />
      </filter>
    </defs>
    {/* 메인 스파클 글로우 */}
    <path
      d="M50 10L55 40L85 50L55 60L50 90L45 60L15 50L45 40L50 10Z"
      stroke="url(#sparkleGradient)"
      strokeWidth={strokeWidth * 1.5}
      opacity="0.2"
      filter="url(#sparkleGlow)"
    />
    {/* 메인 스파클 */}
    <path
      d="M50 10L55 40L85 50L55 60L50 90L45 60L15 50L45 40L50 10Z"
      stroke="url(#sparkleGradient)"
      strokeWidth={strokeWidth}
      strokeLinecap="round"
      strokeLinejoin="round"
      fill="url(#sparkleGradient)"
      fillOpacity="0.05"
    />
    {/* 작은 스파클 1 */}
    <path
      d="M20 20L23 28L31 31L23 34L20 42L17 34L9 31L17 28L20 20Z"
      stroke="url(#sparkleGradient)"
      strokeWidth={strokeWidth * 0.7}
      strokeLinecap="round"
      strokeLinejoin="round"
      opacity="0.7"
    />
    {/* 작은 스파클 2 */}
    <path
      d="M80 65L82 71L88 73L82 75L80 81L78 75L72 73L78 71L80 65Z"
      stroke="url(#sparkleGradient)"
      strokeWidth={strokeWidth * 0.7}
      strokeLinecap="round"
      strokeLinejoin="round"
      opacity="0.7"
    />
    {/* 추가 미니 스파클 */}
    <path
      d="M78 18L79 22L83 23L79 24L78 28L77 24L73 23L77 22L78 18Z"
      stroke="url(#sparkleGradient)"
      strokeWidth={strokeWidth * 0.5}
      strokeLinecap="round"
      opacity="0.5"
    />
    {/* 중심 글로우 */}
    <circle cx="50" cy="50" r="4" fill="url(#sparkleGradient)" opacity="0.3" />
  </svg>
);

// 와이어프레임 타겟 아이콘 - 강화
export const WireframeTarget: React.FC<IconProps> = ({
  size = 100,
  strokeWidth = defaultStrokeWidth,
  color = defaultColor,
}) => (
  <svg
    width={size}
    height={size}
    viewBox="0 0 100 100"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
  >
    <defs>
      <linearGradient id="targetGradient" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" stopColor="#10B981" />
        <stop offset="50%" stopColor="#06B6D4" />
        <stop offset="100%" stopColor="#8B5CF6" />
      </linearGradient>
      <radialGradient id="targetRadial" cx="50%" cy="50%" r="50%">
        <stop offset="0%" stopColor="#10B981" stopOpacity="0.1" />
        <stop offset="100%" stopColor="transparent" stopOpacity="0" />
      </radialGradient>
      <filter id="targetGlow">
        <feGaussianBlur stdDeviation="2" result="blur" />
        <feComposite in="SourceGraphic" in2="blur" operator="over" />
      </filter>
    </defs>
    {/* 배경 글로우 */}
    <circle cx="50" cy="50" r="45" fill="url(#targetRadial)" />
    {/* 외부 원 */}
    <circle
      cx="50"
      cy="50"
      r="42"
      stroke="url(#targetGradient)"
      strokeWidth={strokeWidth}
    />
    {/* 중간 원 */}
    <circle
      cx="50"
      cy="50"
      r="28"
      stroke="url(#targetGradient)"
      strokeWidth={strokeWidth * 0.8}
      opacity="0.7"
    />
    {/* 내부 원 */}
    <circle
      cx="50"
      cy="50"
      r="14"
      stroke="url(#targetGradient)"
      strokeWidth={strokeWidth * 0.6}
      opacity="0.5"
    />
    {/* 중심점 - 글로우 */}
    <circle
      cx="50"
      cy="50"
      r="5"
      fill="url(#targetGradient)"
      filter="url(#targetGlow)"
    />
    <circle
      cx="50"
      cy="50"
      r="3"
      fill="url(#targetGradient)"
    />
    {/* 십자선 */}
    <path
      d="M50 5V20M50 80V95M5 50H20M80 50H95"
      stroke="url(#targetGradient)"
      strokeWidth={strokeWidth * 0.5}
      strokeLinecap="round"
      opacity="0.5"
    />
    {/* 대각선 마커 */}
    <path
      d="M22 22L28 28M72 22L66 28M22 78L28 72M72 78L66 72"
      stroke="url(#targetGradient)"
      strokeWidth={strokeWidth * 0.4}
      strokeLinecap="round"
      opacity="0.3"
    />
  </svg>
);

// 와이어프레임 다이아몬드 아이콘 - 강화
export const WireframeDiamond: React.FC<IconProps> = ({
  size = 100,
  strokeWidth = defaultStrokeWidth,
  color = defaultColor,
}) => (
  <svg
    width={size}
    height={size}
    viewBox="0 0 100 100"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
  >
    <defs>
      <linearGradient id="diamondGradient" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" stopColor="#8B5CF6" />
        <stop offset="40%" stopColor="#C4B5FD" />
        <stop offset="100%" stopColor="#EC4899" />
      </linearGradient>
      <linearGradient id="diamondFill" x1="50%" y1="0%" x2="50%" y2="100%">
        <stop offset="0%" stopColor="#C4B5FD" stopOpacity="0.1" />
        <stop offset="50%" stopColor="#8B5CF6" stopOpacity="0.05" />
        <stop offset="100%" stopColor="#EC4899" stopOpacity="0.02" />
      </linearGradient>
      <filter id="diamondGlow">
        <feGaussianBlur stdDeviation="2.5" result="blur" />
        <feComposite in="SourceGraphic" in2="blur" operator="over" />
      </filter>
    </defs>
    {/* 글로우 */}
    <path
      d="M50 5L90 35L50 95L10 35L50 5Z"
      stroke="url(#diamondGradient)"
      strokeWidth={strokeWidth * 1.5}
      opacity="0.2"
      filter="url(#diamondGlow)"
    />
    {/* 다이아몬드 외곽 */}
    <path
      d="M50 5L90 35L50 95L10 35L50 5Z"
      fill="url(#diamondFill)"
      stroke="url(#diamondGradient)"
      strokeWidth={strokeWidth}
      strokeLinecap="round"
      strokeLinejoin="round"
    />
    {/* 상단 라인 */}
    <path
      d="M10 35H90"
      stroke="url(#diamondGradient)"
      strokeWidth={strokeWidth}
      strokeLinecap="round"
    />
    {/* 내부 라인들 */}
    <path
      d="M50 5L35 35L50 95M50 5L65 35L50 95"
      stroke="url(#diamondGradient)"
      strokeWidth={strokeWidth * 0.6}
      strokeLinecap="round"
      strokeLinejoin="round"
      opacity="0.4"
    />
    {/* 빛나는 하이라이트 */}
    <path
      d="M30 20L35 35M70 20L65 35"
      stroke="url(#diamondGradient)"
      strokeWidth={strokeWidth * 0.4}
      strokeLinecap="round"
      opacity="0.35"
    />
    {/* 상단 면 하이라이트 */}
    <path
      d="M50 5L35 35H65L50 5Z"
      fill="url(#diamondGradient)"
      opacity="0.06"
    />
  </svg>
);
