# QA Report (2026-01-24)

## 1) UI/UX 99% Similarity Check (Web vs App)
- 적용됨: 그라디언트 배경, 카드 톤, 그라디언트 텍스트, 버튼 스타일, 스탯 카드, 샘플 질문 프리뷰, 혜택 리스트, 기능 카드, HEXACO 요인 그리드, 버전 선택 카드, 법적 고지/푸터.
- 적용됨: 테스트 화면 진행률 바 + 요인 도트, 질문 카드 글로우, 1~5 스케일 스타일.
- 적용됨: 결과 화면 레이더 차트, 요인 점수 그리드, TOP 5 매칭 카드, 법적 고지, 공유 영역.
- 차이점/리스크:
  - 웹의 LLM 분석 섹션은 앱에서 “준비중(비활성화)” 안내로 대체됨.
  - 웹의 인물 카테고리/출처 뱃지는 앱 데이터에 없음(유형 데이터 기반).
  - 웹의 트위터/이미지 다운로드 공유는 앱에서 “복사/공유”로 축소됨.

## 2) 반응형/접근성 QA
- 최소 터치 영역: Primary/Secondary 버튼 min-height 48 적용.
- reduce-motion 대응: 홈의 타이핑/샘플 질문/헥사곤 회전은 reduce-motion에서 자동 정지.
- 작은 화면 줄바꿈: 버튼 텍스트 maxLines 처리, 카드 내 긴 문장은 ellipsis 적용.

## 3) 테스트 플로우 보완
- 키보드: 1~5 입력, ←/→ 이동, Enter/Space 다음 이동 지원.
- 진행 UI: 퍼센트/요인 도트/그라디언트 진행바 복원.

## 4) 스토어 출시 준비
- 아이콘/스플래시 원본 생성: `assets/branding/app_icon.png`, `assets/branding/splash.png`.
- 실행 필요:
  - `flutter pub run flutter_launcher_icons`
  - `flutter pub run flutter_native_splash`
- 스토어 문구 초안: `docs/store_listing.md`.
- 개인정보처리방침 링크: 앱 푸터에 추가.

## 5) AdMob 실광고 점검
- 체크리스트: `docs/admob_checklist.md`.
- Debug/Profile은 테스트 ID 사용(정상). Release에서 실광고 확인 필요.

## 6) 성능/회귀
- flutter analyze/test 통과.
- 애니메이션 감소 옵션에서 CPU 점유 감소 확인 필요(실기기).

## 남은 확인(수동)
- 실제 웹 스크린샷 vs 앱 스크린샷 픽셀 비교(폰트/여백/아이콘).
- 스토어 스크린샷 캡처 및 업로드 규격 확인.
- 실기기(저사양) 스크롤/애니메이션 체감 확인.
