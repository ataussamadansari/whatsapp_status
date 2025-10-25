// dart
        import 'package:flutter/material.dart';
        import 'package:google_mobile_ads/google_mobile_ads.dart';
        import 'native_ad_manager.dart';

        class NativeAdWidget extends StatefulWidget {
          final double height;
          final double width;
          final NativeAdManager? nativeAdManager;

          const NativeAdWidget({
            super.key,
            this.height = 150,
            this.width = double.infinity,
            this.nativeAdManager,
          });

          @override
          State<NativeAdWidget> createState() => _NativeAdWidgetState();
        }

        class _NativeAdWidgetState extends State<NativeAdWidget> {
          late final NativeAdManager _adManager;
          late final bool _shouldDisposeManager;
          NativeAd? _nativeAd;
          bool _loading = true;

          @override
          void initState() {
            super.initState();
            _adManager = widget.nativeAdManager ?? NativeAdManager();
            _shouldDisposeManager = widget.nativeAdManager == null;

            _adManager.loadAd(
              onAdLoaded: (ad) {
                if (!mounted) return;
                setState(() {
                  _nativeAd = ad;
                  _loading = false;
                });
              },
              onAdFailed: (err) {
                if (!mounted) return;
                setState(() {
                  _nativeAd = null;
                  _loading = false;
                });
              },
            );
          }

          @override
          void dispose() {
            if (_shouldDisposeManager) {
              _adManager.dispose();
            }
            super.dispose();
          }

          @override
          Widget build(BuildContext context) {
            if (_loading) {
              return SizedBox(
                height: widget.height,
                width: widget.width,
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            if (_nativeAd == null) {
              return SizedBox(
                height: widget.height,
                width: widget.width,
                child: const Center(child: Text('Ad unavailable')),
              );
            }

            return SizedBox(
              height: widget.height,
              width: widget.width,
              child: AdWidget(ad: _nativeAd!),
            );
          }
        }