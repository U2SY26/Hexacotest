import 'ui/app_tokens.dart';

const factorOrder = ['H', 'E', 'X', 'A', 'C', 'O'];

const factorNamesKo = {
  'H': '정직-겸손',
  'E': '정서성',
  'X': '외향성',
  'A': '우호성',
  'C': '성실성',
  'O': '개방성',
};

const factorNamesEn = {
  'H': 'Honesty-Humility',
  'E': 'Emotionality',
  'X': 'Extraversion',
  'A': 'Agreeableness',
  'C': 'Conscientiousness',
  'O': 'Openness',
};

const factorColors = {
  'H': AppColors.purple500,
  'E': AppColors.pink500,
  'X': AppColors.amber500,
  'A': AppColors.emerald500,
  'C': AppColors.blue500,
  'O': AppColors.red500,
};

const scaleLabelsKo = {
  1: '전혀 아니다',
  2: '아니다',
  3: '보통이다',
  4: '그렇다',
  5: '매우 그렇다',
};

const scaleLabelsEn = {
  1: 'Strongly disagree',
  2: 'Disagree',
  3: 'Neutral',
  4: 'Agree',
  5: 'Strongly agree',
};

// Slider labels for percentage-based UI
const sliderLabelsKo = {
  'agree': '매우 그렇다',
  'disagree': '절대 아니다',
  'neutral': '중립',
};

const sliderLabelsEn = {
  'agree': 'Strongly Agree',
  'disagree': 'Strongly Disagree',
  'neutral': 'Neutral',
};

const testVersions = [60, 120, 180];

String versionLabelKo(int version) {
  switch (version) {
    case 60:
      return '빠른 테스트 (약 5분)';
    case 120:
      return '표준 테스트 (약 10분)';
    case 180:
      return '정밀 테스트 (약 15분)';
    default:
      return '$version 문항';
  }
}

String versionLabelEn(int version) {
  switch (version) {
    case 60:
      return 'Quick (about 5 min)';
    case 120:
      return 'Standard (about 10 min)';
    case 180:
      return 'Detailed (about 15 min)';
    default:
      return '$version items';
  }
}
