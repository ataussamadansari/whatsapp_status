import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppOpenAdManager {
  AppOpenAd? _appOpenAd;
  bool _isLoading = false;

  // ✅ CORRECT App Open Demo Ad Unit ID
  static const String adUnitId = 'ca-app-pub-3940256099942544/9257395921';

  void loadAd() {
    if (_isLoading || _appOpenAd != null) return;

    _isLoading = true;
    print('🚀 Loading App Open Ad with ID: $adUnitId');

    AppOpenAd.load(
      adUnitId: adUnitId,
      request: AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          print('✅ App Open Ad loaded successfully!');
          _appOpenAd = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          print('❌ App Open Ad failed to load: $error');
          _isLoading = false;
          // 1 minute baad retry
          Future.delayed(Duration(minutes: 1), () => loadAd());
        },
      )
    );
  }

  void showAd() {
    if (_appOpenAd == null) {
      print('⚠️ No App Open Ad available to show. Loading new ad...');
      loadAd();
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('🎬 App Open Ad showed full screen content');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('❌ App Open Ad failed to show: $error');
        ad.dispose();
        _appOpenAd = null;
        loadAd();
      },
      onAdDismissedFullScreenContent: (ad) {
        print('👋 App Open Ad dismissed');
        ad.dispose();
        _appOpenAd = null;
        loadAd();
      },
    );

    _appOpenAd!.show();
  }

  bool get isAdAvailable => _appOpenAd != null;
}