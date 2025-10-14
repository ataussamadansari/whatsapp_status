import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../ads/native_ad_manager.dart';
import '../ads/native_ad_widget.dart';
import '../utils/file_helper.dart';
import '../utils/permission_helper.dart';
import '../widgets/empty_view.dart';
import '../widgets/status_item.dart';
import 'home_screen.dart';

class WhatsAppTabScreen extends StatefulWidget {
  final WhatsAppType type;
  final VoidCallback? onStatusDownloaded;
  final NativeAdManager nativeAdManager;

  const WhatsAppTabScreen({
    super.key,
    required this.type,
    this.onStatusDownloaded,
    required this.nativeAdManager
  });

  @override
  State<WhatsAppTabScreen> createState() => WhatsAppTabScreenState();
}

class WhatsAppTabScreenState extends State<WhatsAppTabScreen>
    with SingleTickerProviderStateMixin {
  List<FileSystemEntity> _images = [];
  List<FileSystemEntity> _videos = [];
  bool _loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      refresh();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ✅ Refresh function with optional delay for pull-to-refresh
  Future<void> refresh({bool withDelay = false}) async {
    if (withDelay) {
      await Future.delayed(const Duration(seconds: 1));
    }

    final sdk = await _getAndroidSdkInt();
    setState(() => _loading = true);

    bool granted = await PermissionHelper.requestStoragePermission();
    if (!granted) {
      if (await Permission.storage.isDenied && sdk < 33) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission is required")),
        );
      } else if (await Permission.manageExternalStorage.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("External Storage permission is required"),
          ),
        );
      }
      setState(() => _loading = false);
      return;
    }

    _images = [];
    _videos = [];

    try {
      // Use the updated FileHelper to get status files from all possible paths
      List<FileSystemEntity> allFiles = await FileHelper.getStatusFiles();

      // Filter files based on WhatsApp type
      List<FileSystemEntity> filteredFiles = _filterFilesByType(
        allFiles,
        widget.type,
      );

      // Separate images and videos
      _images = filteredFiles
          .where(
            (f) =>
        f.path.toLowerCase().endsWith('.jpg') ||
            f.path.toLowerCase().endsWith('.jpeg') ||
            f.path.toLowerCase().endsWith('.png'),
      )
          .toList();

      _videos = filteredFiles
          .where(
            (f) =>
        f.path.toLowerCase().endsWith('.mp4') ||
            f.path.toLowerCase().endsWith('.mkv'),
      )
          .toList();

      print(
        "Found ${_images.length} images and ${_videos.length} videos for ${widget.type}",
      );
    } catch (e) {
      print("Error loading status files: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading statuses: $e")));
    }

    setState(() => _loading = false);
  }

  // Filter files based on WhatsApp type (regular or business)
  List<FileSystemEntity> _filterFilesByType(
      List<FileSystemEntity> allFiles,
      WhatsAppType type,
      ) {
    if (type == WhatsAppType.whatsapp) {
      return allFiles
          .where(
            (file) =>
        file.path.contains('com.whatsapp') ||
            file.path.contains('WhatsApp/Media') &&
                !file.path.contains('w4b') &&
                !file.path.contains('Business'),
      )
          .toList();
    } else {
      return allFiles
          .where(
            (file) =>
        file.path.contains('com.whatsapp.w4b') ||
            file.path.contains('WhatsApp Business') ||
            file.path.contains('w4b'),
      )
          .toList();
    }
  }

  // Check if specific WhatsApp is installed
  Future<bool> _isWhatsAppInstalled(WhatsAppType type) async {
    List<String> paths = FileHelper.getWhatsAppPaths();

    for (String path in paths) {
      try {
        Directory dir = Directory(path);
        bool exists = await dir.exists();

        if (exists) {
          // Check if this path belongs to the requested WhatsApp type
          if (type == WhatsAppType.whatsapp) {
            if (path.contains('com.whatsapp') && !path.contains('w4b') ||
                path.contains('WhatsApp/Media') && !path.contains('Business')) {
              return true;
            }
          } else {
            if (path.contains('com.whatsapp.w4b') ||
                path.contains('WhatsApp Business') ||
                path.contains('w4b')) {
              return true;
            }
          }
        }
      } catch (e) {
        // Continue checking other paths
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ✅ Tab bar
        Container(
          color: Colors.green.shade600,
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(icon: Icon(Icons.photo), text: 'Images'),
              Tab(icon: Icon(Icons.videocam), text: 'Videos'),
            ],
          ),
        ),

        // ✅ Tab content with pull-to-refresh
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
            controller: _tabController,
            children: [
              _buildImagesTab(),
              _buildVideosTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagesTab() {
    return _buildTabWithAds(
      files: _images,
      emptyMessage: "No images found.",
      icon: Icons.photo_library,
    );
  }

  Widget _buildVideosTab() {
    return _buildTabWithAds(
      files: _videos,
      emptyMessage: "No videos found.",
      icon: Icons.video_library,
    );
  }

  Widget _buildTabWithAds({
    required List<FileSystemEntity> files,
    required String emptyMessage,
    required IconData icon,
  }) {
    // ✅ Calculate total items including ads (har 4 items ke baad 1 ad)
    const int AD_FREQUENCY = 4;
    int totalItems = files.length;
    int adCount = (totalItems / AD_FREQUENCY).floor();
    int totalGridItems = totalItems + adCount;

    return RefreshIndicator(
      onRefresh: () => refresh(withDelay: true),
      child: files.isEmpty
          ? FutureBuilder<bool>(
        future: _isWhatsAppInstalled(widget.type),
        builder: (context, snapshot) {
          bool isInstalled = snapshot.data ?? false;
          String message;

          if (snapshot.connectionState == ConnectionState.waiting) {
            message = "Checking WhatsApp...";
          } else if (!isInstalled) {
            message = widget.type == WhatsAppType.whatsapp
                ? "WhatsApp not installed"
                : "WhatsApp Business not installed";
          } else {
            message = emptyMessage;
          }

          return ListView(
            children: [
              // ✅ Native Ad even when no content
              NativeAdWidget(nativeAdManager: widget.nativeAdManager),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: EmptyView(
                  message: message,
                  icon: icon,
                  onRefresh: () => refresh(withDelay: true),
                ),
              ),
            ],
          );
        },
      )
          : GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.6,
        ),
        itemCount: totalGridItems,
        itemBuilder: (context, index) {
          // ✅ Check if this position should show an ad (har 5th position pe ad)
          if ((index + 1) % (AD_FREQUENCY + 1) == 0) {
            final adPosition = (index ~/ (AD_FREQUENCY + 1));

            // Only show ad if we have files to display
            if (adPosition < adCount) {
              return NativeAdWidget(
                nativeAdManager: widget.nativeAdManager,
                height: 200, // Grid ke liye optimized height
              );
            } else {
              // Agar extra ad positions hain to empty container
              return Container();
            }
          }

          // ✅ Calculate the actual file index
          final fileIndex = index - (index ~/ (AD_FREQUENCY + 1));
          if (fileIndex < files.length) {
            return StatusItem(
              file: files[fileIndex],
              onSaved: () {
                widget.onStatusDownloaded?.call();
              },
              allImages: files == _images ? _images : null,
              allVideos: files == _videos ? _videos : null,
            );
          }

          return Container(); // Fallback
        },
      ),
    );
  }
}

// Helper to get Android SDK version
Future<int> _getAndroidSdkInt() async {
  try {
    if (Platform.isAndroid) {
      AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
      return info.version.sdkInt;
    }
  } catch (_) {}
  return 0;
}

/*import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../ads/native_ad_manager.dart';
import '../ads/native_ad_widget.dart'; // Ye import add karein
import '../utils/file_helper.dart';
import '../utils/permission_helper.dart';
import '../widgets/empty_view.dart';
import '../widgets/status_item.dart';
import 'home_screen.dart';

class WhatsAppTabScreen extends StatefulWidget {
  final WhatsAppType type;
  final VoidCallback? onStatusDownloaded;
  final NativeAdManager nativeAdManager;

  const WhatsAppTabScreen({
    super.key,
    required this.type,
    this.onStatusDownloaded,
    required this.nativeAdManager
  });

  @override
  State<WhatsAppTabScreen> createState() => WhatsAppTabScreenState();
}

class WhatsAppTabScreenState extends State<WhatsAppTabScreen>
    with SingleTickerProviderStateMixin {
  List<FileSystemEntity> _images = [];
  List<FileSystemEntity> _videos = [];
  bool _loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      refresh();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ✅ Refresh function with optional delay for pull-to-refresh
  Future<void> refresh({bool withDelay = false}) async {
    if (withDelay) {
      await Future.delayed(const Duration(seconds: 1));
    }

    final sdk = await _getAndroidSdkInt();
    setState(() => _loading = true);

    bool granted = await PermissionHelper.requestStoragePermission();
    if (!granted) {
      if (await Permission.storage.isDenied && sdk < 33) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission is required")),
        );
      } else if (await Permission.manageExternalStorage.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("External Storage permission is required"),
          ),
        );
      }
      setState(() => _loading = false);
      return;
    }

    _images = [];
    _videos = [];

    try {
      // Use the updated FileHelper to get status files from all possible paths
      List<FileSystemEntity> allFiles = await FileHelper.getStatusFiles();

      // Filter files based on WhatsApp type
      List<FileSystemEntity> filteredFiles = _filterFilesByType(
        allFiles,
        widget.type,
      );

      // Separate images and videos
      _images = filteredFiles
          .where(
            (f) =>
        f.path.toLowerCase().endsWith('.jpg') ||
            f.path.toLowerCase().endsWith('.jpeg') ||
            f.path.toLowerCase().endsWith('.png'),
      )
          .toList();

      _videos = filteredFiles
          .where(
            (f) =>
        f.path.toLowerCase().endsWith('.mp4') ||
            f.path.toLowerCase().endsWith('.mkv'),
      )
          .toList();

      print(
        "Found ${_images.length} images and ${_videos.length} videos for ${widget.type}",
      );
    } catch (e) {
      print("Error loading status files: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading statuses: $e")));
    }

    setState(() => _loading = false);
  }

  // Filter files based on WhatsApp type (regular or business)
  List<FileSystemEntity> _filterFilesByType(
      List<FileSystemEntity> allFiles,
      WhatsAppType type,
      ) {
    if (type == WhatsAppType.whatsapp) {
      return allFiles
          .where(
            (file) =>
        file.path.contains('com.whatsapp') ||
            file.path.contains('WhatsApp/Media') &&
                !file.path.contains('w4b') &&
                !file.path.contains('Business'),
      )
          .toList();
    } else {
      return allFiles
          .where(
            (file) =>
        file.path.contains('com.whatsapp.w4b') ||
            file.path.contains('WhatsApp Business') ||
            file.path.contains('w4b'),
      )
          .toList();
    }
  }

  // Check if specific WhatsApp is installed
  Future<bool> _isWhatsAppInstalled(WhatsAppType type) async {
    List<String> paths = FileHelper.getWhatsAppPaths();

    for (String path in paths) {
      try {
        Directory dir = Directory(path);
        bool exists = await dir.exists();

        if (exists) {
          // Check if this path belongs to the requested WhatsApp type
          if (type == WhatsAppType.whatsapp) {
            if (path.contains('com.whatsapp') && !path.contains('w4b') ||
                path.contains('WhatsApp/Media') && !path.contains('Business')) {
              return true;
            }
          } else {
            if (path.contains('com.whatsapp.w4b') ||
                path.contains('WhatsApp Business') ||
                path.contains('w4b')) {
              return true;
            }
          }
        }
      } catch (e) {
        // Continue checking other paths
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ✅ Tab bar
        Container(
          color: Colors.green.shade600,
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(icon: Icon(Icons.photo), text: 'Images'),
              Tab(icon: Icon(Icons.videocam), text: 'Videos'),
            ],
          ),
        ),

        // ✅ Tab content with pull-to-refresh
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
            controller: _tabController,
            children: [
              _buildImagesTab(),
              _buildVideosTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagesTab() {
    // Calculate total items including ads
    int totalItems = _images.length;
    int adCount = (totalItems / 4).ceil(); // Har 4 items ke baad ad
    int totalGridItems = totalItems + adCount;

    return RefreshIndicator(
      onRefresh: () => refresh(withDelay: true),
      child: _images.isEmpty
          ? FutureBuilder<bool>(
        future: _isWhatsAppInstalled(widget.type),
        builder: (context, snapshot) {
          bool isInstalled = snapshot.data ?? false;
          String message;

          if (snapshot.connectionState == ConnectionState.waiting) {
            message = "Checking WhatsApp...";
          } else if (!isInstalled) {
            message = widget.type == WhatsAppType.whatsapp
                ? "WhatsApp not installed"
                : "WhatsApp Business not installed";
          } else {
            message = "No images found.";
          }

          return ListView(
            children: [
              // ✅ Native Ad even when no content
              NativeAdWidget(nativeAdManager: widget.nativeAdManager),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: EmptyView(
                  message: message,
                  icon: Icons.photo_library,
                  onRefresh: () => refresh(withDelay: true),
                ),
              ),
            ],
          );
        },
      )
          : GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.6,
        ),
        itemCount: totalGridItems,
        itemBuilder: (context, index) {
          // Check if this position should show an ad
          if ((index + 1) % 5 == 0) {
            // This is an ad position (every 5th item)
            final adPosition = (index ~/ 5);
            if (adPosition == 0) {
              // First ad - use the main manager
              return NativeAdWidget(nativeAdManager: widget.nativeAdManager);
            } else {
              // For additional ads, you can create separate managers
              // or show a placeholder
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.ads_click, color: Colors.grey, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Ad Space',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }
          }

          // Calculate the actual image index
          final imageIndex = index - (index ~/ 5);
          if (imageIndex < _images.length) {
            return StatusItem(
              file: _images[imageIndex],
              onSaved: () {
                widget.onStatusDownloaded?.call();
              },
              allImages: _images,
              allVideos: _videos,
            );
          }

          return Container(); // Fallback
        },
      ),
    );
  }

  Widget _buildVideosTab() {
    return CustomScrollView(
      slivers: [
        // ✅ Native Ad at the top of videos tab
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: NativeAdWidget(nativeAdManager: widget.nativeAdManager),
          ),
        ),

        // ✅ Videos grid
        _videos.isEmpty
            ? SliverFillRemaining(
          child: FutureBuilder<bool>(
            future: _isWhatsAppInstalled(widget.type),
            builder: (context, snapshot) {
              bool isInstalled = snapshot.data ?? false;
              String message;

              if (snapshot.connectionState == ConnectionState.waiting) {
                message = "Checking WhatsApp...";
              } else if (!isInstalled) {
                message = widget.type == WhatsAppType.whatsapp
                    ? "WhatsApp not installed"
                    : "WhatsApp Business not installed";
              } else {
                message = "No videos found.";
              }

              return EmptyView(
                message: message,
                icon: Icons.video_library,
                onRefresh: () => refresh(withDelay: true),
              );
            },
          ),
        )
            : SliverPadding(
          padding: const EdgeInsets.all(8),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.6,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) => StatusItem(
                file: _videos[index],
                onSaved: () {
                  widget.onStatusDownloaded?.call();
                },
                allImages: _images,
                allVideos: _videos,
              ),
              childCount: _videos.length,
            ),
          ),
        ),

        // ✅ Native Ad at the bottom of videos tab (if there are videos)
        if (_videos.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: NativeAdWidget(nativeAdManager: widget.nativeAdManager),
            ),
          ),
      ],
    );
  }
}

// Helper to get Android SDK version
Future<int> _getAndroidSdkInt() async {
  try {
    if (Platform.isAndroid) {
      AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
      return info.version.sdkInt;
    }
  } catch (_) {}
  return 0;
}*/

/*
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../ads/native_ad_manager.dart';
import '../utils/file_helper.dart';
import '../utils/permission_helper.dart';
import '../widgets/empty_view.dart';
import '../widgets/status_item.dart';
import 'home_screen.dart';

class WhatsAppTabScreen extends StatefulWidget {
  final WhatsAppType type;
  final VoidCallback? onStatusDownloaded;
  final NativeAdManager nativeAdManager;

  const WhatsAppTabScreen({
    super.key,
    required this.type,
    this.onStatusDownloaded,
    required this.nativeAdManager
  });

  @override
  State<WhatsAppTabScreen> createState() => WhatsAppTabScreenState();
}

class WhatsAppTabScreenState extends State<WhatsAppTabScreen>
    with SingleTickerProviderStateMixin {
  List<FileSystemEntity> _images = [];
  List<FileSystemEntity> _videos = [];
  bool _loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      refresh();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ✅ Refresh function with optional delay for pull-to-refresh
  Future<void> refresh({bool withDelay = false}) async {
    if (withDelay) {
      await Future.delayed(const Duration(seconds: 1));
    }

    final sdk = await _getAndroidSdkInt();
    setState(() => _loading = true);

    bool granted = await PermissionHelper.requestStoragePermission();
    if (!granted) {
      if (await Permission.storage.isDenied && sdk < 33) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission is required")),
        );
      } else if (await Permission.manageExternalStorage.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("External Storage permission is required"),
          ),
        );
      }
      setState(() => _loading = false);
      return;
    }

    _images = [];
    _videos = [];

    try {
      // Use the updated FileHelper to get status files from all possible paths
      List<FileSystemEntity> allFiles = await FileHelper.getStatusFiles();

      // Filter files based on WhatsApp type
      List<FileSystemEntity> filteredFiles = _filterFilesByType(
        allFiles,
        widget.type,
      );

      // Separate images and videos
      _images = filteredFiles
          .where(
            (f) =>
                f.path.toLowerCase().endsWith('.jpg') ||
                f.path.toLowerCase().endsWith('.jpeg') ||
                f.path.toLowerCase().endsWith('.png'),
          )
          .toList();

      _videos = filteredFiles
          .where(
            (f) =>
                f.path.toLowerCase().endsWith('.mp4') ||
                f.path.toLowerCase().endsWith('.mkv'),
          )
          .toList();

      print(
        "Found ${_images.length} images and ${_videos.length} videos for ${widget.type}",
      );
    } catch (e) {
      print("Error loading status files: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading statuses: $e")));
    }

    setState(() => _loading = false);
  }

  // Filter files based on WhatsApp type (regular or business)
  List<FileSystemEntity> _filterFilesByType(
    List<FileSystemEntity> allFiles,
    WhatsAppType type,
  ) {
    if (type == WhatsAppType.whatsapp) {
      return allFiles
          .where(
            (file) =>
                file.path.contains('com.whatsapp') ||
                file.path.contains('WhatsApp/Media') &&
                    !file.path.contains('w4b') &&
                    !file.path.contains('Business'),
          )
          .toList();
    } else {
      return allFiles
          .where(
            (file) =>
                file.path.contains('com.whatsapp.w4b') ||
                file.path.contains('WhatsApp Business') ||
                file.path.contains('w4b'),
          )
          .toList();
    }
  }

  // Check if specific WhatsApp is installed
  Future<bool> _isWhatsAppInstalled(WhatsAppType type) async {
    List<String> paths = FileHelper.getWhatsAppPaths();

    for (String path in paths) {
      try {
        Directory dir = Directory(path);
        bool exists = await dir.exists();

        if (exists) {
          // Check if this path belongs to the requested WhatsApp type
          if (type == WhatsAppType.whatsapp) {
            if (path.contains('com.whatsapp') && !path.contains('w4b') ||
                path.contains('WhatsApp/Media') && !path.contains('Business')) {
              return true;
            }
          } else {
            if (path.contains('com.whatsapp.w4b') ||
                path.contains('WhatsApp Business') ||
                path.contains('w4b')) {
              return true;
            }
          }
        }
      } catch (e) {
        // Continue checking other paths
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ✅ Tab bar
        Container(
          color: Colors.green.shade600,
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(icon: Icon(Icons.photo), text: 'Images'),
              Tab(icon: Icon(Icons.videocam), text: 'Videos'),
            ],
          ),
        ),

        // ✅ Tab content with pull-to-refresh
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRefreshableGrid(_images, "No images found."),
                    _buildRefreshableGrid(_videos, "No videos found."),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildRefreshableGrid(
    List<FileSystemEntity> files,
    String emptyMessage,
  ) {
    return RefreshIndicator(
      onRefresh: () => refresh(withDelay: true),
      child: files.isEmpty
          ? FutureBuilder<bool>(
              future: _isWhatsAppInstalled(widget.type),
              builder: (context, snapshot) {
                bool isInstalled = snapshot.data ?? false;

                String message;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  message = "Checking WhatsApp...";
                } else if (!isInstalled) {
                  message = widget.type == WhatsAppType.whatsapp
                      ? "WhatsApp not installed"
                      : "WhatsApp Business not installed";
                } else {
                  message = emptyMessage;
                }

                return ListView(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: EmptyView(
                        message: message,
                        icon: emptyMessage.contains("images")
                            ? Icons.photo_library
                            : Icons.video_library,
                        onRefresh: () => refresh(withDelay: true),
                      ),
                    ),
                  ],
                );
              },
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.6,
              ),
              itemCount: files.length,
              itemBuilder: (context, i) => StatusItem(
                file: files[i],
                onSaved: () {
                  widget.onStatusDownloaded?.call();
                },
                allImages: emptyMessage.contains("images") ? files : null,
                allVideos: emptyMessage.contains("videos") ? files : null,
              ),
            ),
    );
  }


}

// Helper to get Android SDK version
Future<int> _getAndroidSdkInt() async {
  try {
    if (Platform.isAndroid) {
      AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
      return info.version.sdkInt;
    }
  } catch (_) {}
  return 0;
}


*/
