import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/file_helper.dart';
import '../utils/permission_helper.dart';
import '../widgets/status_item.dart';
import '../widgets/empty_view.dart';
import 'home_screen.dart';

class WhatsAppTabScreen extends StatefulWidget
{
    final WhatsAppType type;
    final VoidCallback? onStatusDownloaded;
    const WhatsAppTabScreen({super.key, required this.type, this.onStatusDownloaded});

    @override
    State<WhatsAppTabScreen> createState() => WhatsAppTabScreenState();
}

class WhatsAppTabScreenState extends State<WhatsAppTabScreen>
    with SingleTickerProviderStateMixin
{
    List<FileSystemEntity> _images = [];
    List<FileSystemEntity> _videos = [];
    bool _loading = true;
    late TabController _tabController;

    @override
    void initState() 
    {
        super.initState();
        _tabController = TabController(length: 2, vsync: this);

        WidgetsBinding.instance.addPostFrameCallback((_)
            {
                refresh();
            }
        );
    }

    @override
    void dispose() 
    {
        _tabController.dispose();
        super.dispose();
    }

    // ✅ Refresh function with optional 1s delay for pull-to-refresh
    Future<void> refresh({bool withDelay = false}) async
    {
        if (withDelay) 
        {
            await Future.delayed(const Duration(seconds: 1));
        }

        final sdk = await _getAndroidSdkInt();
        setState(() => _loading = true);

        bool granted = await PermissionHelper.requestStoragePermission();
        if (!granted) 
        {
            if (await Permission.storage.isDenied && sdk < 33) 
            {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Storage permission is required"))
                );
            }
            else if (await Permission.manageExternalStorage.isDenied) 
            {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("External Storage permission is required"))
                );
            }
            else if (await Permission.photos.isDenied && sdk >= 33) 
            {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Photos and media permission is required"))
                );
            }
            setState(() => _loading = false);
            return;
        }

        // Check if WhatsApp folder exists
        final whatsappDir = Directory(FileHelper.whatsappPath);
        final wbDir = Directory(FileHelper.whatsappBusinessPath);

        _images = [];
        _videos = [];

        if (widget.type == WhatsAppType.whatsapp && !await whatsappDir.exists()) 
        {
            setState(() => _loading = false);
            return; // WhatsApp not installed
        }

        if (widget.type == WhatsAppType.whatsappBusiness && !await wbDir.exists()) 
        {
            setState(() => _loading = false);
            return; // WhatsApp Business not installed
        }

        final path = widget.type == WhatsAppType.whatsapp
            ? FileHelper.whatsappPath
            : FileHelper.whatsappBusinessPath;

        final dir = Directory(path);
        if (await dir.exists()) 
        {
            final allFiles = await dir
                .list()
                .where((e) =>
                    e.path.endsWith('.jpg') ||
                        e.path.endsWith('.png') ||
                        e.path.endsWith('.mp4'))
                .toList();

            allFiles.sort(
                (a, b) => b.statSync().modified.compareTo(a.statSync().modified));

            _images = allFiles
                .where((f) => f.path.endsWith('.jpg') || f.path.endsWith('.png'))
                .toList();

            _videos = allFiles.where((f) => f.path.endsWith('.mp4')).toList();
        }

        setState(() => _loading = false);
    }

    @override
    Widget build(BuildContext context) 
    {
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
                        tabs: const[
                            Tab(icon: Icon(Icons.photo), text: 'Images'),
                            Tab(icon: Icon(Icons.videocam), text: 'Videos')
                        ]
                    )
                ),

                // ✅ Tab content with pull-to-refresh
                Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : TabBarView(
                            controller: _tabController,
                            children: [
                                _buildRefreshableGrid(_images, "No images found."),
                                _buildRefreshableGrid(_videos, "No videos found.")
                            ]
                        )
                )
            ]
        );
    }

    // Wrap GridView with RefreshIndicator
    /*Widget _buildRefreshableGrid(List<FileSystemEntity> files, String emptyMessage)
    {
        return RefreshIndicator(
            onRefresh: () => refresh(withDelay: true), // drag down triggers refresh with 3s delay
            child: files.isEmpty
                ? ListView(
                    children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: EmptyView(
                                message: widget.type == WhatsAppType.whatsapp
                                    ? "WhatsApp not installed or $emptyMessage"
                                    : "WhatsApp Business not installed or $emptyMessage",
                                icon: emptyMessage.contains("images")
                                    ? Icons.photo_library
                                    : Icons.video_library,
                                onRefresh: () => refresh(withDelay: true)
                            )
                        )
                    ]
                )
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.7
                    ),
                    itemCount: files.length,
                    itemBuilder: (context, i) => StatusItem(
                        file: files[i], 
                        onSaved: ()
                        {
                            widget.onStatusDownloaded?.call();
                        }
                    )
                )
        );
    }*/

    Widget _buildRefreshableGrid(List<FileSystemEntity> files, String emptyMessage) {
        return RefreshIndicator(
            onRefresh: () => refresh(withDelay: true),
            child: files.isEmpty
                ? ListView(
                children: [
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: EmptyView(
                            message: widget.type == WhatsAppType.whatsapp
                                ? "WhatsApp not installed or $emptyMessage"
                                : "WhatsApp Business not installed or $emptyMessage",
                            icon: emptyMessage.contains("images")
                                ? Icons.photo_library
                                : Icons.video_library,
                            onRefresh: () => refresh(withDelay: true),
                        ),
                    ),
                ],
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
Future<int> _getAndroidSdkInt() async
{
    try
    {
        if (Platform.isAndroid) 
        {
            AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
            return info.version.sdkInt;
        }
    }
    catch (_)
    {
    }
    return 0;
}

