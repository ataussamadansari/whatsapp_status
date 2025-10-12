// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../screens/image_viewer_screen.dart';
import '../screens/video_player_screen.dart';
import '../utils/file_helper.dart';

class StatusItem extends StatefulWidget {
  final FileSystemEntity file;

  const StatusItem({super.key, required this.file});

  @override
  State<StatusItem> createState() => _StatusItemState();
}

class _StatusItemState extends State<StatusItem> {

  String? _thumbPath;

  bool get isVideo {
    final p = widget.file.path.toLowerCase();
    return p.endsWith('.mp4') || p.endsWith('.mkv') || p.endsWith('.webm');
  }

  @override
  void initState() {
    super.initState();
    if (isVideo) {
      _generateThumbnail();
    }
  }

  Future<void> _generateThumbnail() async {
    final tempDir = await getTemporaryDirectory();
    final thumb = await VideoThumbnail.thumbnailFile(
      video: widget.file.path,
      thumbnailPath: tempDir.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 200,
      quality: 75,
    );

    if (thumb != null) {
      setState(() => _thumbPath = thumb);
    }
  }

  // bool get isVideo {
  //   final p = widget.file.path.toLowerCase();
  //   return p.endsWith('.mp4') || p.endsWith('.mkv') || p.endsWith('.webm');
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isVideo) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlayerScreen(videoPath: widget.file.path),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageViewerScreen(imagePath: widget.file.path),
            ),
          );
        }
      },
      onLongPress: () async {
        final saved = await FileHelper.saveFile(File(widget.file.path));
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
          // if (isVideo)
          //   const Align(
          //     alignment: Alignment.center,
          //     child: Icon(Icons.play_circle_outline, size: 50, color: Colors.white),
          //   ),
          Positioned(
            bottom: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black45,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final saved = await FileHelper.saveFile(File(widget.file.path));
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
        ],
      ),
    );
  }

  Widget _buildThumb() {
    if (isVideo) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _thumbPath != null
            ? Image.file(File(_thumbPath!), fit: BoxFit.cover)
            : Container(
          color: Colors.black12,
          child: const Center(
            child: Icon(Icons.videocam, size: 42, color: Colors.black45),
          ),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(widget.file.path),
          fit: BoxFit.cover,
        ),
      );
    }
  }


/*Widget _buildThumb() {
    if (isVideo) {
      return FutureBuilder<String?>(
        future: VideoThumbnail.thumbnailFile(
          video: widget.file.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 200, // thumbnail width
          quality: 75,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(snapshot.data!),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            );
          }
          // Loading placeholder
          return Container(
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.videocam, size: 42, color: Colors.black45),
            ),
          );
        },
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(widget.file.path),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }
  }*/
}
