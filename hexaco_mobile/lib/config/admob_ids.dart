import 'package:flutter/foundation.dart';

const String admobAppId = 'ca-app-pub-2988937021017804~9158623849';
const String bannerAdUnitId = 'ca-app-pub-2988937021017804/4976987632';

const String testBannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
const String testBannerAdUnitIdIos = 'ca-app-pub-3940256099942544/2934735716';

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
