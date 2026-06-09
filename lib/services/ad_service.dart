import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static BannerAd? _bannerAd;
  static bool _isLoaded = false;

  // Test ID (baad mein real AdMob ID se replace karna)
  static const String _bannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  static void initialize() {
    MobileAds.instance.initialize();
  }

  static void loadBannerAd({required VoidCallback onLoaded}) {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isLoaded = true;
          onLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isLoaded = false;
        },
      ),
    )..load();
  }

  static Widget getBannerWidget() {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  static void dispose() {
    _bannerAd?.dispose();
  }
}
