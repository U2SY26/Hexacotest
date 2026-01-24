# AdMob Release Checklist

## Current Configuration
- App ID: `ca-app-pub-3715008468517611~7590886146`
- Banner Ad Unit: `ca-app-pub-3715008468517611/5799114717`
- Debug/Profile builds use Google test IDs (see `lib/widgets/ad_banner.dart`).

## Pre-release Checklist
- [ ] Build a release APK/IPA and verify real ads load.
- [ ] Confirm test IDs are not used in release (`kReleaseMode`).
- [ ] Review AdMob policy compliance for content and placement.
- [ ] Validate privacy policy includes ad/analytics disclosure.

## On-device Checks
- [ ] Banner position: bottom only, not covering buttons.
- [ ] Touch targets remain accessible.
- [ ] No ad shown on loading/transition screens.
