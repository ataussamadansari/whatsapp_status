// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:whatsapp_status_downloader/ads/app_open_ad_manager.dart';
import 'package:whatsapp_status_downloader/ads/interstitial_ad_manager.dart';
import 'package:whatsapp_status_downloader/ads/native_ad_manager.dart';

import 'package:whatsapp_status_downloader/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    WidgetsFlutterBinding.ensureInitialized();
    await MobileAds.instance.initialize();

    // App Open Ad Manager create karein
    final AppOpenAdManager appOpenAdManager = AppOpenAdManager();
    final InterstitialAdManager interstitialAdManager = InterstitialAdManager();
    final NativeAdManager nativeAdManager = NativeAdManager();

    // App start hote hi ad load karein
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appOpenAdManager.loadAd();
      interstitialAdManager.loadAd();
      nativeAdManager.loadAd();
    });

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
        appOpenAdManager: appOpenAdManager,
        interstitialAdManager: interstitialAdManager,
        nativeAdManager: nativeAdManager
    ));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
