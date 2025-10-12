import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/file_helper.dart';
import '../utils/permission_helper.dart';
import '../widgets/status_item.dart';
import '../widgets/empty_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<FileSystemEntity> statuses = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadStatuses();
  }

  Future<void> _loadStatuses() async {
    setState(() => loading = true);
    bool granted = await PermissionHelper.requestStoragePermission();
    if (granted) {
      var files = await FileHelper.getStatusFiles();
      setState(() {
        statuses = files;
        loading = false;
      });
    } else {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission is required")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WhatsApp Status Downloader"),
        backgroundColor: Colors.green,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : statuses.isEmpty
          ? const EmptyView()
          : GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final file = statuses[index];
          return StatusItem(file: file);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadStatuses,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
