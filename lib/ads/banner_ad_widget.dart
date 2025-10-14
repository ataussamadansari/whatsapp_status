import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  // ✅ CORRECT Fixed Size Banner Demo Ad Unit ID
  final String _adUnitId = 'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
          print('✅ Banner Ad loaded successfully!');
        },
        onAdFailedToLoad: (ad, error) {
          print('❌ Banner Ad failed to load: $error');
          ad.dispose();
          // 30 seconds baad retry
          Future.delayed(Duration(seconds: 30), _loadBannerAd);
        },
        onAdOpened: (ad) => print('🔓 Banner Ad opened'),
        onAdClosed: (ad) => print('🔒 Banner Ad closed'),
      ),
    );
    _bannerAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded) {
      return Container(
        height: 60,
        color: Colors.grey[100],
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.green, strokeWidth: 2),
              SizedBox(height: 4),
              Text(
                'Loading Ad...',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      color: Colors.grey[100],
      child: AdWidget(ad: _bannerAd!),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}