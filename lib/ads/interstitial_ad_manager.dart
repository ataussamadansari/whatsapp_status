import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdManager {
  InterstitialAd? _interstitialAd;
  bool _isLoading = false;

  // ✅ CORRECT Interstitial Demo Ad Unit ID
  static const String adUnitId = 'ca-app-pub-3940256099942544/1033173712';

  void loadAd() {
    if (_isLoading) return;

    _isLoading = true;
    print('🚀 Loading Interstitial Ad with ID: $adUnitId');

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoading = false;
          print('✅ Interstitial Ad loaded successfully!');

          // Ad dismiss hone par naya ad load karein
          _setUpFullScreenContentCallback(ad);
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          print('❌ Interstitial Ad failed to load: $error');
          // 30 seconds baad retry
          Future.delayed(Duration(seconds: 30), () => loadAd());
        },
      ),
    );
  }

  void _setUpFullScreenContentCallback(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('🎬 Interstitial Ad showed full screen content');
      },
      onAdDismissedFullScreenContent: (ad) {
        print('👋 Interstitial Ad dismissed');
        ad.dispose();
        _interstitialAd = null;
        // Naya ad load karein
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('❌ Interstitial Ad failed to show: $error');
        ad.dispose();
        _interstitialAd = null;
        loadAd();
      },
    );
  }

  void showAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      print('🔄 Interstitial Ad show method called');
    } else {
      print('⚠️ No Interstitial Ad available. Loading new ad...');
      loadAd();
    }
  }

  bool get isAdAvailable => _interstitialAd != null;
  bool get isLoading => _isLoading;
}