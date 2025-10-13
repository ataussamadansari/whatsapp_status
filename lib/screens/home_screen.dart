import 'package:flutter/material.dart';
import 'package:whatsapp_status_downloader/screens/saved_screen.dart';
import 'whatsapp_tab_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
  void onStatusDownloaded() {
    savedScreenKey.currentState?.refresh();
  }

  final List<String> _titles = [
    'WhatsApp Status',
    'WhatsApp Business',
    'Saved',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final screens = [
      WhatsAppTabScreen(key: _whatsappKey, type: WhatsAppType.whatsapp,
        onStatusDownloaded: onStatusDownloaded),
      WhatsAppTabScreen(
          key: _whatsappBusinessKey, type: WhatsAppType.whatsappBusiness,
        onStatusDownloaded: onStatusDownloaded),
      SavedScreen(key: savedScreenKey),
      const SettingsScreen(),
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _titles[_currentIndex],
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          elevation: 3,
          surfaceTintColor: Colors.transparent,
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
        body: IndexedStack(index: _currentIndex, children: screens),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          indicatorColor: Colors.green.shade100,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.whatshot_outlined),
              selectedIcon: Icon(Icons.whatshot),
              label: 'WhatsApp',
            ),
            NavigationDestination(
              icon: Icon(Icons.business_center_outlined),
              selectedIcon: Icon(Icons.business_center),
              label: 'Business',
            ),
            NavigationDestination(
              icon: Icon(Icons.download_outlined),
              selectedIcon: Icon(Icons.download),
              label: 'Saved',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return false;
    }
    if (_currentBackPressTime == null ||
        now.difference(_currentBackPressTime!) > const Duration(seconds: 2)) {
      _currentBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    return true;
  }
}

enum WhatsAppType { whatsapp, whatsappBusiness }
