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
  AdSize? _adSize;

  bool get _isTest => const bool.fromEnvironment('FLUTTER_TEST');

  bool get _useTestAd => kDebugMode || kProfileMode || _isTest;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bannerAd == null && !_isTest) {
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    final screenWidth = MediaQuery.of(context).size.width.truncate();
    final adSize = AdSize.getInlineAdaptiveBannerAdSize(screenWidth, 60);

    _adSize = adSize;

    final adUnitId = bannerAdUnitIdForPlatform(test: _useTestAd);
    _bannerAd = BannerAd(
      size: adSize,
      adUnitId: _useTestAd ? adUnitId : widget.adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Ad failed to load: $error');
          ad.dispose();
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
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: _isLoaded ? (_adSize?.height.toDouble() ?? 60) : 0,
      width: double.infinity,
      child: _bannerAd == null || !_isLoaded
          ? const SizedBox.shrink()
          : AdWidget(ad: _bannerAd!),
    );
  }
}

class BannerAdSection extends StatelessWidget {
  final String adUnitId;

  const BannerAdSection({super.key, required this.adUnitId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
