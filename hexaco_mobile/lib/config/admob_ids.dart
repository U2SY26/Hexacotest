import 'package:flutter/foundation.dart';

// AdMob App ID
const String admobAppId = 'ca-app-pub-3715008468517611~1225705615';

// Production Ad Unit IDs
const String bannerAdUnitId = 'ca-app-pub-3715008468517611/2406091191';
const String nativeAdUnitId = 'ca-app-pub-3715008468517611/4554141769';
const String rewardedInterstitialAdUnitId = 'ca-app-pub-3715008468517611/1927978422';

// Test Ad Unit IDs
const String testBannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
const String testBannerAdUnitIdIos = 'ca-app-pub-3940256099942544/2934735716';
const String testNativeAdUnitIdAndroid = 'ca-app-pub-3940256099942544/2247696110';
const String testNativeAdUnitIdIos = 'ca-app-pub-3940256099942544/3986624511';
const String testRewardedInterstitialAdUnitIdAndroid = 'ca-app-pub-3940256099942544/5354046379';
const String testRewardedInterstitialAdUnitIdIos = 'ca-app-pub-3940256099942544/6978759866';

String bannerAdUnitIdForPlatform({required bool test}) {
  if (!test) {
    return bannerAdUnitId;
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return testBannerAdUnitIdIos;
    case TargetPlatform.android:
      return testBannerAdUnitIdAndroid;
    default:
      return testBannerAdUnitIdAndroid;
  }
}

String nativeAdUnitIdForPlatform({required bool test}) {
  if (!test) {
    return nativeAdUnitId;
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return testNativeAdUnitIdIos;
    case TargetPlatform.android:
      return testNativeAdUnitIdAndroid;
    default:
      return testNativeAdUnitIdAndroid;
  }
}

String rewardedInterstitialAdUnitIdForPlatform({required bool test}) {
  if (!test) {
    return rewardedInterstitialAdUnitId;
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return testRewardedInterstitialAdUnitIdIos;
    case TargetPlatform.android:
      return testRewardedInterstitialAdUnitIdAndroid;
    default:
      return testRewardedInterstitialAdUnitIdAndroid;
  }
}
