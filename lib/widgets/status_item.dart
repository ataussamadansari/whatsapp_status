import 'dart:io';

import 'package:flutter/material.dart';

import '../screens/image_viewer_screen.dart';
import '../screens/video_player_screen.dart';
import '../utils/file_helper.dart';

class StatusItem extends StatelessWidget {
  final FileSystemEntity file;

  const StatusItem({super.key, required this.file});

  bool get isVideo {
    final p = file.path.toLowerCase();
    return p.endsWith('.mp4') || p.endsWith('.mkv') || p.endsWith('.webm');
  }

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
        final saved = await FileHelper.saveFile(File(file.path));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              saved == 'Permission denied'
                  ? 'Permission denied'
                  : 'Saved: $saved',
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Positioned.fill(child: _buildThumb()),
          Positioned(
            bottom: 6,
            right: 6,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle
              ),
              child: IconButton(
                icon: const Icon(Icons.download, color: Colors.white),
                onPressed: () async {
                  final saved = await FileHelper.saveFile(File(file.path));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        saved == 'Permission denied'
                            ? 'Permission denied'
                            : 'Saved: $saved',
                      ),
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

  Widget _buildThumb() {
    if (isVideo) {
      // Avoid trying to render video as image — show safe placeholder
      return Container(
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(Icons.videocam, size: 42, color: Colors.black45),
        ),
      );
    } else {
      // Image file: show directly
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(file.path),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }
  }
}
