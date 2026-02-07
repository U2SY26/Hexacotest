import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/admob_ids.dart';

class RewardedAdService {
  static RewardedInterstitialAd? _rewardedInterstitialAd;
  static bool _isLoading = false;

  static bool get isTest => kDebugMode || kProfileMode;

  static Future<void> loadAd() async {
    if (_isLoading || _rewardedInterstitialAd != null) return;

    _isLoading = true;
    final adUnitId = rewardedInterstitialAdUnitIdForPlatform(test: isTest);

    await RewardedInterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedInterstitialAd = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedInterstitialAd failed to load: $error');
          _isLoading = false;
        },
      ),
    );
  }

  static Future<bool> showAd({
    required VoidCallback onAdDismissed,
    VoidCallback? onUserEarnedReward,
  }) async {
    if (_rewardedInterstitialAd == null) {
      onAdDismissed();
      return false;
    }

    _rewardedInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedInterstitialAd = null;
        onAdDismissed();
        loadAd(); // Preload next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('RewardedInterstitialAd failed to show: $error');
        ad.dispose();
        _rewardedInterstitialAd = null;
        onAdDismissed();
        loadAd();
      },
    );

    await _rewardedInterstitialAd!.show(
      onUserEarnedReward: (ad, reward) {
        onUserEarnedReward?.call();
      },
    );

    return true;
  }

  static bool get isAdReady => _rewardedInterstitialAd != null;

  static void dispose() {
    _rewardedInterstitialAd?.dispose();
    _rewardedInterstitialAd = null;
  }
}
