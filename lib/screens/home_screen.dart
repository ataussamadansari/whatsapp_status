import 'package:flutter/material.dart';
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

  final List<String> _titles = [
    'WhatsApp Status',
    'WhatsApp Business',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final screens = [
      WhatsAppTabScreen(key: _whatsappKey, type: WhatsAppType.whatsapp),
      WhatsAppTabScreen(
          key: _whatsappBusinessKey, type: WhatsAppType.whatsappBusiness),
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
          leading: _currentIndex != 0
              ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _currentIndex = 0),
          )
              : null,
          actions: [
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
          ],
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


/*
import 'package:flutter/material.dart';
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
  final List<DateTime> _backStack = [];

  final List<Widget> _screens = [
    const WhatsAppTabScreen(type: WhatsAppType.whatsapp),
    const WhatsAppTabScreen(type: WhatsAppType.whatsappBusiness),
    const SettingsScreen(),
  ];

  final List<String> _titles = [
    'WhatsApp Status',
    'WhatsApp Business',
    'Settings'
  ];

  // Back stack manage karo
  void _addToBackStack(int index) {
    if (_backStack.length > 5) {
      _backStack.removeAt(0); // Purane entries remove karo
    }
    _backStack.add(DateTime.now());
  }

  Future<bool> _onWillPop() async {
    // Agar back stack mein kuch hai aur first tab par nahi hai
    if (_backStack.isNotEmpty && _currentIndex != 0) {
      // Pichle tab par jao
      int previousIndex = _backStack.length > 1 ? 1 : 0;
      setState(() => _currentIndex = 0); // Hamesha first tab par jao
      _backStack.removeLast();
      return false;
    }

    // Agar first tab par hai, to exit logic
    DateTime now = DateTime.now();
    if (_currentBackPressTime == null ||
        now.difference(_currentBackPressTime!) > const Duration(seconds: 2)) {
      _currentBackPressTime = now;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit app'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }

    return true;
  }

  void _onTabTapped(int index) {
    _addToBackStack(_currentIndex);
    setState(() => _currentIndex = index);
  }

  // Custom back button widget
  Widget _buildBackButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        } else {
          _onWillPop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titles[_currentIndex]),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          leading: _currentIndex != 0 ? _buildBackButton() : null,
          actions: [
            // Refresh button for WhatsApp tabs
            if (_currentIndex == 0 || _currentIndex == 1)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  // Refresh current tab
                  if (_screens[_currentIndex] is WhatsAppTabScreen) {
                    // You can add refresh logic here
                  }
                },
              ),
          ],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey[600],
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.whatshot_outlined),
          activeIcon: Icon(Icons.whatshot),
          label: 'WhatsApp',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business_center_outlined),
          activeIcon: Icon(Icons.business_center),
          label: 'Business',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}

enum WhatsAppType {
  whatsapp,
  whatsappBusiness,
}*/
