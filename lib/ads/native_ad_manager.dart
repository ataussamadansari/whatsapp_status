import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class NativeAdManager {
  NativeAd? _nativeAd;
  bool _isLoading = false;
  int _retryCount = 0;
  final int _maxRetries = 3;

  // ✅ CORRECT Native Advanced Demo Ad Unit ID
  static const String adUnitId = 'ca-app-pub-3940256099942544/2247696110';

  void loadAd({Function(NativeAd)? onAdLoaded, Function(String)? onAdFailed}) {
    if (_isLoading || _retryCount >= _maxRetries) return;

    _isLoading = true;

    // Purane ad ko dispose karein
    _nativeAd?.dispose();

    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      request: AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _isLoading = false;
          _retryCount = 0; // Reset retry count on success
          print('✅ Native Advanced Ad loaded successfully!');
          if (onAdLoaded != null) {
            onAdLoaded(ad as NativeAd);
          }
        },
        onAdFailedToLoad: (ad, error) {
          _isLoading = false;
          _retryCount++;

          print('❌ Native Advanced Ad failed to load (Attempt $_retryCount/$_maxRetries): $error');

          // Retry after delay
          if (_retryCount < _maxRetries) {
            print('🔄 Retrying Native Ad in ${_retryCount * 2} seconds...');
            Future.delayed(Duration(seconds: _retryCount * 2), () {
              loadAd(onAdLoaded: onAdLoaded, onAdFailed: onAdFailed);
            });
          } else {
            print('🚫 Max retries reached for Native Ad');
            if (onAdFailed != null) {
              onAdFailed('Failed to load ad after $_maxRetries attempts');
            }
          }

          ad.dispose();
        },
        onAdClicked: (ad) => print('🖱️ Native Ad clicked'),
        onAdImpression: (ad) => print('👁️ Native Ad impression'),
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        cornerRadius: 12.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: Colors.green,
          style: NativeTemplateFontStyle.monospace,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.normal,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.grey,
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.normal,
          size: 14.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.grey,
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
      ),
    );

    _nativeAd!.load();
  }

  NativeAd? get nativeAd => _nativeAd;
  bool get isLoading => _isLoading;
  bool get hasMaxRetries => _retryCount >= _maxRetries;

  void resetRetries() {
    _retryCount = 0;
  }

  void dispose() {
    _nativeAd?.dispose();
    _nativeAd = null;
    _retryCount = 0;
  }
}