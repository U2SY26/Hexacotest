import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/admob_ids.dart';
import '../ui/app_tokens.dart';

class NativeAdWidget extends StatefulWidget {
  final String? adUnitId;

  const NativeAdWidget({
    super.key,
    this.adUnitId,
  });

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  bool get _isTest => const bool.fromEnvironment('FLUTTER_TEST');
  bool get _useTestAd => kDebugMode || kProfileMode || _isTest;

  @override
  void initState() {
    super.initState();
    if (_isTest) return;
    _loadAd();
  }

  void _loadAd() {
    final adUnitId = nativeAdUnitIdForPlatform(test: _useTestAd);

    _nativeAd = NativeAd(
      adUnitId: _useTestAd ? adUnitId : (widget.adUnitId ?? nativeAdUnitId),
      request: const AdRequest(),
      listener: NativeAdListener(
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
          debugPrint('Native ad failed to load: $error');
          ad.dispose();
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: AppColors.darkCard,
        cornerRadius: 16,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: AppColors.purple500,
          style: NativeTemplateFontStyle.bold,
          size: 14,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          style: NativeTemplateFontStyle.bold,
          size: 16,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.gray400,
          style: NativeTemplateFontStyle.normal,
          size: 12,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.gray500,
          style: NativeTemplateFontStyle.normal,
          size: 10,
        ),
      ),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isTest || !_isLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 320,
            minHeight: 250,
            maxHeight: 350,
          ),
          child: AdWidget(ad: _nativeAd!),
        ),
      ),
    );
  }
}

class NativeAdSection extends StatelessWidget {
  final String? adUnitId;
  final String? titleKo;
  final String? titleEn;
  final bool isKo;

  const NativeAdSection({
    super.key,
    this.adUnitId,
    this.titleKo,
    this.titleEn,
    this.isKo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titleKo != null || titleEn != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              isKo ? (titleKo ?? '') : (titleEn ?? ''),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.gray400,
                  ),
            ),
          ),
        NativeAdWidget(adUnitId: adUnitId),
      ],
    );
  }
}
