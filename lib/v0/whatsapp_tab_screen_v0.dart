/*
import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/file_helper.dart';
import '../utils/permission_helper.dart';
import '../widgets/status_item.dart';
import '../widgets/empty_view.dart';
import 'home_screen.dart';

class WhatsAppTabScreen extends StatefulWidget {
  final WhatsAppType type;
  const WhatsAppTabScreen({super.key, required this.type});

  @override
  State<WhatsAppTabScreen> createState() => _WhatsAppTabScreenState();
}

class _WhatsAppTabScreenState extends State<WhatsAppTabScreen>
    with SingleTickerProviderStateMixin {
  List<FileSystemEntity> _allStatuses = [];
  List<FileSystemEntity> _images = [];
  List<FileSystemEntity> _videos = [];
  bool _loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStatuses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStatuses() async {
    setState(() => _loading = true);

    bool granted = await PermissionHelper.requestStoragePermission();
    if (granted) {
      List<FileSystemEntity> files = [];

      if (widget.type == WhatsAppType.whatsapp) {
        files = await _getWhatsAppFiles(FileHelper.whatsappPath);
      } else {
        files = await _getWhatsAppFiles(FileHelper.whatsappBusinessPath);
      }

      _categorizeFiles(files);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission is required")),
      );
    }

    setState(() => _loading = false);
  }

  Future<List<FileSystemEntity>> _getWhatsAppFiles(String path) async {
    try {
      Directory dir = Directory(path);
      if (await dir.exists()) {
        var files = await dir
            .list()
            .where((item) => item.path.endsWith('.jpg') ||
            item.path.endsWith('.mp4') ||
            item.path.endsWith('.png'))
            .toList();

        files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
        return files;
      }
    } catch (e) {
      print("Error reading directory: $e");
    }
    return [];
  }

  void _categorizeFiles(List<FileSystemEntity> files) {
    _allStatuses = files;
    _images = files.where((file) =>
    file.path.toLowerCase().endsWith('.jpg') ||
        file.path.toLowerCase().endsWith('.png')
    ).toList();

    _videos = files.where((file) =>
    file.path.toLowerCase().endsWith('.mp4') ||
        file.path.toLowerCase().endsWith('.mkv') ||
        file.path.toLowerCase().endsWith('.webm')
    ).toList();
  }

  List<FileSystemEntity> _getCurrentTabFiles() {
    switch (_tabController.index) {
      case 0: return _images;
      case 1: return _videos;
      default: return [];
    }
  }

  String _getTabTitle() {
    switch (_tabController.index) {
      case 0: return 'Images (${_images.length})';
      case 1: return 'Videos (${_videos.length})';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tabs
        Container(
          color: Colors.green,
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            onTap: (_) => setState(() {}),
            tabs: const [
              Tab(icon: Icon(Icons.photo), text: 'Images'),
              Tab(icon: Icon(Icons.videocam), text: 'Videos'),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _buildTabContent(),
        ),
      ],
    );
  }

  Widget _buildTabContent() {
    final currentFiles = _getCurrentTabFiles();

    if (currentFiles.isEmpty) {
      return EmptyView(
        message: _getEmptyMessage(),
        icon: _getEmptyIcon(),
      );
    }

    return Column(
      children: [
        // Tab Info
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.grey[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getTabTitle(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              // Text(
              //   'Total: ${_allStatuses.length}',
              //   style: TextStyle(
              //     color: Colors.grey[600],
              //     fontSize: 14,
              //   ),
              // ),
            ],
          ),
        ),

        // Grid View
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemCount: currentFiles.length,
            itemBuilder: (context, index) {
              final file = currentFiles[index];
              return StatusItem(file: file);
            },
          ),
        ),
      ],
    );
  }

  String _getEmptyMessage() {
    if (_tabController.index == 0) {
      return "No images found.\nView some image statuses in WhatsApp first!";
    } else {
      return "No videos found.\nView some video statuses in WhatsApp first!";
    }
  }

  IconData _getEmptyIcon() {
    if (_tabController.index == 0) {
      return Icons.photo_library;
    } else {
      return Icons.video_library;
    }
  }
}*/
