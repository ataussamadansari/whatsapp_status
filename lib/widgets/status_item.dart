import 'dart:io';
import 'package:flutter/material.dart';
import '../screens/image_viewer_screen.dart';
import '../screens/video_player_screen.dart';
import '../utils/file_helper.dart';

class StatusItem extends StatelessWidget {
  final FileSystemEntity file;

  const StatusItem({super.key, required this.file});

  bool get isVideo => file.path.endsWith('.mp4');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isVideo) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlayerScreen(videoPath: file.path),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageViewerScreen(imagePath: file.path),
            ),
          );
        }
      },
      onLongPress: () async {
        String savedPath = await FileHelper.saveFile(File(file.path));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Saved: $savedPath"),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(File(file.path), fit: BoxFit.cover),
            ),
          ),
          if (isVideo)
            const Align(
              alignment: Alignment.center,
              child: Icon(Icons.play_circle_outline, size: 50, color: Colors.white),
            ),
          Positioned(
            bottom: 6,
            right: 6,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(30),
              ),
              child: IconButton(
                icon: const Icon(Icons.download, color: Colors.white, size: 22),
                onPressed: () async {
                  String savedPath = await FileHelper.saveFile(File(file.path));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Saved: $savedPath"),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
