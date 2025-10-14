import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:upgrader/upgrader.dart';
import 'ads/app_open_ad_manager.dart';
import 'ads/interstitial_ad_manager.dart';
import 'ads/native_ad_manager.dart';
import 'screens/home_screen.dart';

void main() async
{
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
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

    runApp(MyApp(
        appOpenAdManager: appOpenAdManager,
        interstitialAdManager: interstitialAdManager,
        nativeAdManager: nativeAdManager,
    ));
}

class MyApp extends StatelessWidget
{
    final AppOpenAdManager appOpenAdManager;
    final InterstitialAdManager interstitialAdManager;
    final NativeAdManager nativeAdManager;

    const MyApp({
        super.key,
        required this.appOpenAdManager,
        required this.interstitialAdManager,
        required this.nativeAdManager,
    });

    @override
    Widget build(BuildContext context)
    {
        return MaterialApp(
            title: 'Status Downloader',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(primarySwatch: Colors.green),
            home: UpgradeAlert(
                /*upgrader: Upgrader(
                    messages: UpdateMsg(),
                    debugLogging: true,
                    debugDisplayAlways: true,
                    minAppVersion: "2.0.0"
                ),*/
                dialogStyle: UpgradeDialogStyle.cupertino,
                child: HomeScreen(
                    appOpenAdManager: appOpenAdManager,
                    interstitialAdManager: interstitialAdManager,
                    nativeAdManager: nativeAdManager,
                )
            )
        );
    }
}

class UpdateMsg extends UpgraderMessages
{
    @override
    String get title => 'Update Required';

    @override
    String get body => 'Please update this app to continue using it.';

    @override
    String get prompt => 'Update Now';
}
