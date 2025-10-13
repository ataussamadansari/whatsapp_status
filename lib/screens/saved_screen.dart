import 'dart:io';
import 'package:flutter/material.dart';
import 'package:whatsapp_status_downloader/widgets/saved_status_item.dart';
import '../utils/file_helper.dart';
import '../widgets/empty_view.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => SavedScreenState();
}

class SavedScreenState extends State<SavedScreen> with SingleTickerProviderStateMixin {

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

  // ✅ Refresh function
  Future<void> refresh() async {
    setState(() => _loading = true);

    // Add 1 sec delay
    await Future.delayed(const Duration(seconds: 1));

    final path = FileHelper.downloadFolder;
    final dir = Directory(path);

    if (await dir.exists()) {
      final allFiles = await dir
          .list()
          .where((e) =>
      e.path.endsWith('.jpg') ||
          e.path.endsWith('.png') ||
          e.path.endsWith('.mp4'))
          .toList();

      allFiles.sort((a, b) =>
          b.statSync().modified.compareTo(a.statSync().modified));

      _images = allFiles
          .where((f) => f.path.endsWith('.jpg') || f.path.endsWith('.png'))
          .toList();

      _videos = allFiles.where((f) => f.path.endsWith('.mp4')).toList();
    }

    setState(() => _loading = false);
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
              _buildRefreshableGrid(_images, "No saved images found."),
              _buildRefreshableGrid(_videos, "No saved videos found."),
            ],
          ),
        ),
      ],
    );
  }

  // Wrap GridView with RefreshIndicator
  Widget _buildRefreshableGrid(List<FileSystemEntity> files, String emptyMessage) {
    return RefreshIndicator(
      onRefresh: refresh, // drag down triggers refresh
      child: files.isEmpty
          ? ListView(
        // Required for RefreshIndicator to work even with empty grid
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: EmptyView(
              message: emptyMessage,
              icon: emptyMessage.contains("images")
                  ? Icons.photo_library
                  : Icons.video_library,
              onRefresh: refresh,
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
          childAspectRatio: 0.7,
        ),
        itemCount: files.length,
        itemBuilder: (context, i) => SavedStatusItem(file: files[i], onDeleted: refresh,),
      ),
    );
  }
}



/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:whatsapp_status_downloader/widgets/saved_status_item.dart';
import '../utils/file_helper.dart';
import '../widgets/empty_view.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> with SingleTickerProviderStateMixin{

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
  void dispose()
  {
    _tabController.dispose();
    super.dispose();
  }

  // ✅ Public refresh function (called from HomeScreen)
  Future<void> refresh() async
  {

    setState(() => _loading = true);

    final path = FileHelper.downloadFolder;

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

      allFiles.sort((a, b) =>
          b.statSync().modified.compareTo(a.statSync().modified));

      _images = allFiles
          .where((f) => f.path.endsWith('.jpg') || f.path.endsWith('.png'))
          .toList();

      _videos =
          allFiles.where((f) => f.path.endsWith('.mp4')).toList();
    }
    setState(() => _loading = false);
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
                  tabs: const[
                    Tab(icon: Icon(Icons.photo), text: 'Images'),
                    Tab(icon: Icon(Icons.videocam), text: 'Videos')
                  ]
              )
          ),

          // ✅ Tab content
          Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGrid(_images, "No images found."),
                    _buildGrid(_videos, "No videos found.")
                  ]
              )
          )
        ]
    );
  }

  Widget _buildGrid(List<FileSystemEntity> files, String emptyMessage)
  {
    if (files.isEmpty) {
      return EmptyView(
        message: emptyMessage,
        icon: emptyMessage.contains("images")
            ? Icons.photo_library
            : Icons.video_library,
        onRefresh: (){},
      );
    }

    return GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.7
        ),
        itemCount: files.length,
        itemBuilder: (context, i) => SavedStatusItem(file: files[i])
    );
  }
}
*/
