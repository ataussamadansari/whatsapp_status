import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'native_ad_manager.dart';

class NativeAdWidget extends StatefulWidget {
  final NativeAdManager nativeAdManager;
  final double? height;

  const NativeAdWidget({
    super.key,
    required this.nativeAdManager,
    this.height = 200,
  });

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  void _loadNativeAd() {
    widget.nativeAdManager.loadAd(
      onAdLoaded: (ad) {
        if (mounted) {
          setState(() {
            _nativeAd = ad;
            _isAdLoaded = true;
            _hasError = false;
          });
        }
      },
      onAdFailed: (error) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = error;
            _isAdLoaded = false;
          });
        }
      },
    );
  }

  void _retryAd() {
    if (mounted) {
      setState(() {
        _hasError = false;
        _errorMessage = '';
      });
      widget.nativeAdManager.resetRetries();
      _loadNativeAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Agar error hai aur max retries ho gayi hain
    if (_hasError && widget.nativeAdManager.hasMaxRetries) {
      return Container(
        height: widget.height,
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.orange, size: 32),
              SizedBox(height: 8),
              Text(
                'Ad Not Available',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              SizedBox(height: 4),
              Text(
                'Try again later',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ),
      );
    }

    // Agar loading ho raha hai ya error hai
    if (!_isAdLoaded || _hasError) {
      return Container(
        height: widget.height,
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_hasError) ...[
                Icon(Icons.warning_amber, color: Colors.orange, size: 24),
                SizedBox(height: 6),
                Text(
                  'Retrying...',
                  style: TextStyle(color: Colors.orange, fontSize: 10),
                ),
              ] else ...[
                CircularProgressIndicator(
                  color: Colors.green,
                  strokeWidth: 2,
                ),
                SizedBox(height: 6),
                Text(
                  'Loading Ad...',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
              SizedBox(height: 4),
              if (_hasError)
                TextButton(
                  onPressed: _retryAd,
                  child: Text(
                    'Retry',
                    style: TextStyle(fontSize: 10),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Agar ad loaded hai
    return Container(
      height: widget.height,
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AdWidget(ad: _nativeAd!),
      ),
    );
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }
}