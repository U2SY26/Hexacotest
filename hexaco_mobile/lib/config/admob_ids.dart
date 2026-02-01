import 'package:flutter/foundation.dart';

// AdMob App ID
const String admobAppId = 'ca-app-pub-2988937021017804~9158623849';

// Production Ad Unit IDs
const String bannerAdUnitId = 'ca-app-pub-2988937021017804/6082484468';
const String nativeAdUnitId = 'ca-app-pub-2988937021017804/4976987632';

// Test Ad Unit IDs
const String testBannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
const String testBannerAdUnitIdIos = 'ca-app-pub-3940256099942544/2934735716';
const String testNativeAdUnitIdAndroid = 'ca-app-pub-3940256099942544/2247696110';
const String testNativeAdUnitIdIos = 'ca-app-pub-3940256099942544/3986624511';

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
