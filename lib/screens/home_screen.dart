import 'package:flutter/material.dart';
import 'package:whatsapp_status_downloader/ads/native_ad_manager.dart';
import 'package:whatsapp_status_downloader/screens/saved_screen.dart';
import '../ads/app_open_ad_manager.dart';
import '../ads/banner_ad_widget.dart';
import '../ads/interstitial_ad_manager.dart';
import 'whatsapp_tab_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget
{
    final AppOpenAdManager appOpenAdManager;
    final InterstitialAdManager interstitialAdManager;
    final NativeAdManager nativeAdManager;

    const HomeScreen({
        super.key,
        required this.appOpenAdManager,
        required this.interstitialAdManager,
        required this.nativeAdManager,
    });

    @override
    State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
{
    int _currentIndex = 0;
    DateTime? _currentBackPressTime;

    // ✅ Global keys for refresh access
    final GlobalKey<WhatsAppTabScreenState> _whatsappKey =
        GlobalKey<WhatsAppTabScreenState>();
    final GlobalKey<WhatsAppTabScreenState> _whatsappBusinessKey =
        GlobalKey<WhatsAppTabScreenState>();
    final GlobalKey<SavedScreenState> savedScreenKey =
        GlobalKey<SavedScreenState>();

    // ✅ Callback function that will be passed to children
    void onStatusDownloaded() 
    {
        savedScreenKey.currentState?.refresh();

        // ✅ Jab bhi status download ho to INTERSTITIAL ad show karein
        widget.interstitialAdManager.showAd();
    }

    final List<String> _titles = [
        'WhatsApp Status',
        'WhatsApp Business',
        'Saved',
        'Settings'
    ];

    @override
    void initState() 
    {
        super.initState();

        // App open hote hi ad load karein
        WidgetsBinding.instance.addPostFrameCallback((_)
            {
                widget.appOpenAdManager.loadAd();
                widget.interstitialAdManager.loadAd();
                widget.nativeAdManager.loadAd();
            }
        );
    }

    @override
    Widget build(BuildContext context) 
    {
        final screens = [
            WhatsAppTabScreen(key: _whatsappKey, type: WhatsAppType.whatsapp,
                onStatusDownloaded: onStatusDownloaded, nativeAdManager: widget.nativeAdManager),
            WhatsAppTabScreen(
                key: _whatsappBusinessKey, type: WhatsAppType.whatsappBusiness,
                onStatusDownloaded: onStatusDownloaded, nativeAdManager: widget.nativeAdManager,),
            SavedScreen(key: savedScreenKey),
            const SettingsScreen()
        ];

        return WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
                appBar: AppBar(
                    title: Text(
                        _titles[_currentIndex],
                        style: const TextStyle(fontWeight: FontWeight.w600)
                    ),
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    surfaceTintColor: Colors.transparent
          /*leading: _currentIndex != 0
              ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _currentIndex = 0),
          )
              : null,*/
          /*actions: [
            if (_currentIndex == 0)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _whatsappKey.currentState?.refresh(),
              ),
            if (_currentIndex == 1)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _whatsappBusinessKey.currentState?.refresh(),
              ),
          ],*/
                ),
                body: Column(
                    children: [
                        // Main content
                        Expanded(
                            child: IndexedStack(
                                index: _currentIndex,
                                children: screens
                            )
                        ),

                        // ✅ Banner Ad - Sab screens ke neeche show hoga except Settings
                        if (_currentIndex != 3)
                        const BannerAdWidget()
                    ]
                ),
                // body: IndexedStack(index: _currentIndex, children: screens),
                bottomNavigationBar: NavigationBar(
                    selectedIndex: _currentIndex,
                    onDestinationSelected: (index) =>
                    setState(() => _currentIndex = index),
                    indicatorColor: Colors.green.shade100,
                    destinations: const[
                        NavigationDestination(
                            icon: Icon(Icons.whatshot_outlined),
                            selectedIcon: Icon(Icons.whatshot),
                            label: 'WhatsApp'
                        ),
                        NavigationDestination(
                            icon: Icon(Icons.business_center_outlined),
                            selectedIcon: Icon(Icons.business_center),
                            label: 'Business'
                        ),
                        NavigationDestination(
                            icon: Icon(Icons.download_outlined),
                            selectedIcon: Icon(Icons.download),
                            label: 'Saved'
                        ),
                        NavigationDestination(
                            icon: Icon(Icons.settings_outlined),
                            selectedIcon: Icon(Icons.settings),
                            label: 'Settings'
                        )
                    ]
                )
            )
        );
    }

    Future<bool> _onWillPop() async
    {
        DateTime now = DateTime.now();
        if (_currentIndex != 0) 
        {
            setState(() => _currentIndex = 0);
            return false;
        }
        if (_currentBackPressTime == null ||
            now.difference(_currentBackPressTime!) > const Duration(seconds: 2)) 
        {
            _currentBackPressTime = now;
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Press back again to exit'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating
                )
            );
            return false;
        }

        // ✅ App exit hone se pehle ek ad show karein
        widget.appOpenAdManager.showAd();
        return true;
    }
}

enum WhatsAppType
{
    whatsapp, whatsappBusiness
}
