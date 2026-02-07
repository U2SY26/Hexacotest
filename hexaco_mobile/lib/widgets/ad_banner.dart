import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/admob_ids.dart';
import '../ui/app_tokens.dart';

class BannerAdWidget extends StatefulWidget {
  final String adUnitId;

  const BannerAdWidget({
    super.key,
    required this.adUnitId,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  AdSize _adSize = AdSize.banner;
  int _retryCount = 0;
  bool _loadRequested = false;
  static const int _maxRetries = 3;

  bool get _isTest => const bool.fromEnvironment('FLUTTER_TEST');
  bool get _useTestAd => kDebugMode || kProfileMode || _isTest;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isTest && !_loadRequested) {
      _loadRequested = true;
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    final width = MediaQuery.of(context).size.width.truncate();

    // 앵커드 적응형 배너 사이즈 (Google 권장)
    final AnchoredAdaptiveBannerAdSize? adaptiveSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);

    if (!mounted) return;

    final adSize = adaptiveSize ?? AdSize.banner;
    setState(() {
      _adSize = adSize;
    });

    final adUnitId = _useTestAd
        ? bannerAdUnitIdForPlatform(test: true)
        : widget.adUnitId;

    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      size: adSize,
      adUnitId: adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          debugPrint('Banner ad loaded successfully');
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load (attempt ${_retryCount + 1}): $error');
          ad.dispose();
          _bannerAd = null;
          // 재시도 (백오프 적용)
          if (mounted && _retryCount < _maxRetries) {
            _retryCount++;
            Future.delayed(Duration(seconds: _retryCount * 5), () {
              if (mounted) _loadAd();
            });
          }
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isTest) {
      return const SizedBox(height: 60);
    }

    final height = _adSize.height.toDouble();

    return SizedBox(
      height: height,
      width: double.infinity,
      child: _bannerAd != null && _isLoaded
          ? AdWidget(ad: _bannerAd!)
          : const SizedBox.shrink(),
    );
  }
}

class BannerAdSection extends StatelessWidget {
  final String adUnitId;

  const BannerAdSection({super.key, required this.adUnitId});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.darkCard.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Center(
        child: BannerAdWidget(adUnitId: adUnitId),
      ),
    );
  }
}
