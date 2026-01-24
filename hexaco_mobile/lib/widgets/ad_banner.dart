import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/admob_ids.dart';
import '../ui/app_tokens.dart';

class BannerAdWidget extends StatefulWidget {
  final String adUnitId;
  final AdSize size;

  const BannerAdWidget({
    super.key,
    required this.adUnitId,
    this.size = AdSize.banner,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  bool get _isTest => const bool.fromEnvironment('FLUTTER_TEST');

  bool get _useTestAd => kDebugMode || kProfileMode || _isTest;

  @override
  void initState() {
    super.initState();
    if (_isTest) return;

    final adUnitId = bannerAdUnitIdForPlatform(test: _useTestAd);
    _bannerAd = BannerAd(
      size: widget.size,
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

    final height = widget.size.height.toDouble();
    final width = widget.size.width.toDouble();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _isLoaded ? 1 : 0,
      child: SizedBox(
        height: height,
        width: width,
        child: _bannerAd == null
            ? const SizedBox.shrink()
            : AdWidget(ad: _bannerAd!),
      ),
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
