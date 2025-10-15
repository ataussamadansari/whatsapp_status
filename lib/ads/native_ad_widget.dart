import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'native_ad_manager.dart';

class NativeAdWidget extends StatefulWidget {
  final NativeAdManager nativeAdManager;
  final double height;

  const NativeAdWidget({
    super.key,
    required this.nativeAdManager,
    this.height = 200,
  });

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _ad;
  bool _isLoaded = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    // Agar ad pehle se load hai, use kar lo
    if (widget.nativeAdManager.nativeAd != null) {
      _ad = widget.nativeAdManager.nativeAd;
      _isLoaded = true;
    } else {
      _loadNativeAd();
    }
  }

  void _loadNativeAd() {
    widget.nativeAdManager.loadAd(
      onAdLoaded: (ad) {
        if (mounted) {
          setState(() {
            _ad = ad;
            _isLoaded = true;
            _hasError = false;
          });
        }
      },
      onAdFailed: (error) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _isLoaded = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return SizedBox(
        height: widget.height,
        child: Center(child: Text('Ad not available')),
      );
    }

    if (!_isLoaded || _ad == null) {
      return SizedBox(
        height: widget.height,
        child: Center(child: Text('Loading Ad...')),
      );
    }

    return Container(
      height: widget.height,
      margin: const EdgeInsets.all(4),
      child: AdWidget(ad: _ad!),
    );
  }

  @override
  void dispose() {
    // Yahan dispose mat karo, ad Manager me dispose hoga globally
    super.dispose();
  }
}
