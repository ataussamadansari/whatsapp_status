import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdManager {
  static final BannerAdManager _instance = BannerAdManager._internal();
  factory BannerAdManager() => _instance;
  BannerAdManager._internal();

  BannerAd? _bannerAd;
  bool _isLoaded = false;

  final String adUnitId = 'ca-app-pub-3940256099942544/6300978111'; // test ID

  void loadAd({Function()? onAdLoaded}) {
    if (_isLoaded || _bannerAd != null) return; // already loaded

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isLoaded = true;
          debugPrint('✅ Banner Loaded');
          onAdLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Banner Failed: $error');
          _isLoaded = false;
          _bannerAd = null;
          Future.delayed(const Duration(seconds: 30), loadAd); // retry
        },
      ),
    )..load();
  }

  BannerAd? get bannerAd => _bannerAd;
  bool get isLoaded => _isLoaded;

  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;
  }
}
