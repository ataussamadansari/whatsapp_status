import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/permission_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _checkingPermission = false;

  Future<void> _requestPermissions() async {
    setState(() => _checkingPermission = true);
    bool granted = await PermissionHelper.requestStoragePermission();
    setState(() => _checkingPermission = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          granted
              ? 'Storage permission granted ✅'
              : 'Storage permission denied ❌',
        ),
      ),
    );
  }

  Future<void> _openAppSettings() async {
    bool opened = await openAppSettings(); // permission_handler ka function
    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot open App Settings')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader('Permissions'),
          _buildPermissionCard(),

          const SizedBox(height: 20),
          _buildHeader('App Information'),
          _buildAboutCard(),

          const SizedBox(height: 20),
          _buildHeader('Support'),
          _buildSupportCard(),

          const SizedBox(height: 20),
          _buildHeader('Legal'),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              ActionChip(
                backgroundColor: Colors.green.shade50,
                label: const Text('Privacy Policy'),
                avatar: const Icon(Icons.privacy_tip, color: Colors.green),
                onPressed: () => launchUrl(Uri.parse('https://ataussamadansari.github.io/whatsapp_status/privacy.html')),
              ),
              ActionChip(
                backgroundColor: Colors.green.shade50,
                label: const Text('Terms & Conditions'),
                avatar: const Icon(Icons.article, color: Colors.green),
                onPressed: () => launchUrl(Uri.parse('https://ataussamadansari.github.io/whatsapp_status/terms.html')),
              ),
              ActionChip(
                backgroundColor: Colors.green.shade50,
                label: const Text('Disclaimer'),
                avatar: const Icon(Icons.warning, color: Colors.green),
                onPressed: () => launchUrl(Uri.parse('https://ataussamadansari.github.io/whatsapp_status/disclaimer.html')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGETS BELOW ---

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildPermissionCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.folder_outlined, color: Colors.green, size: 26),
                SizedBox(width: 10),
                Text(
                  'Storage Permissions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'This app needs storage permission to access and save WhatsApp & WhatsApp Business statuses.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ActionChip(
                    backgroundColor: Colors.green.shade50,
                    avatar: _checkingPermission
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                          ),
                    label: const Text('Grant Permission'),
                    onPressed: _checkingPermission ? null : _requestPermissions,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ActionChip(
                    avatar: const Icon(Icons.settings, color: Colors.green),
                    label: const Text('App Settings'),
                    onPressed:_openAppSettings,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.green, size: 26),
                SizedBox(width: 10),
                Text(
                  'Status Downloader',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text('Version: 1.0.0', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 5),
            Text(
              'Download and save WhatsApp and WhatsApp Business statuses with one tap.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.support_agent, color: Colors.green, size: 26),
                SizedBox(width: 10),
                Text(
                  'Need Help?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'If statuses are not visible:\n• Ensure WhatsApp/Business is installed.\n• View statuses once in WhatsApp.\n• Allow storage permission.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                ActionChip(
                  backgroundColor: Colors.green.shade50,
                  label: const Text('Refresh App'),
                  avatar: const Icon(Icons.refresh, color: Colors.green),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Refreshing data...')),
                    );
                  },
                ),
                ActionChip(
                  backgroundColor: Colors.green.shade50,
                  label: const Text('Check Permission'),
                  avatar: const Icon(Icons.verified_user, color: Colors.green),
                  onPressed: _requestPermissions,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
