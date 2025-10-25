import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'banner_ad_manager.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  final BannerAdManager _manager = BannerAdManager();

  @override
  void initState() {
    super.initState();
    _manager.loadAd(onAdLoaded: () {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final banner = _manager.bannerAd;

    if (banner == null || !_manager.isLoaded) {
      return const SizedBox(
        height: 50,
        child: Center(child: Text('Ad loading...')),
      );
    }

    return Container(
      width: banner.size.width.toDouble(),
      height: banner.size.height.toDouble(),
      child: AdWidget(ad: banner),
    );
  }

  @override
  void dispose() {
    // Yahan dispose mat karo, taaki ad reuse ho sake
    super.dispose();
  }
}
