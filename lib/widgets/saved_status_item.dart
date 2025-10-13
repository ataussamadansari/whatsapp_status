import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:share_plus/share_plus.dart';
import '../screens/image_viewer_screen.dart';
import '../screens/video_player_screen.dart';
import '../utils/file_helper.dart';

class SavedStatusItem extends StatefulWidget {
  final FileSystemEntity file;
  final VoidCallback? onRefresh;
  final List<FileSystemEntity>? allImages;
  final List<FileSystemEntity>? allVideos;

  const SavedStatusItem({
    super.key,
    required this.file,
    this.onRefresh,
    this.allImages,
    this.allVideos,
  });

  @override
  State<SavedStatusItem> createState() => _SavedStatusItemState();
}

class _SavedStatusItemState extends State<SavedStatusItem> {
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

  void _openMediaViewer() {
    if (isVideo) {
      final allVideos = widget.allVideos ?? [];
      final currentIndex = allVideos.indexWhere(
              (element) => element.path == widget.file.path
      );

      if (currentIndex != -1) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoPlayerScreen(
              initialVideoPath: widget.file.path,
              allVideos: allVideos,
              initialIndex: currentIndex,
            ),
          ),
        );
      } else {
        // Fallback to single video player
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoPlayerScreen(
              initialVideoPath: widget.file.path,
              allVideos: [widget.file],
              initialIndex: 0,
            ),
          ),
        );
      }
    } else {
      final allImages = widget.allImages ?? [];
      final currentIndex = allImages.indexWhere(
              (element) => element.path == widget.file.path
      );

      if (currentIndex != -1) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageViewerScreen(
              initialImagePath: widget.file.path,
              allImages: allImages,
              initialIndex: currentIndex,
            ),
          ),
        );
      } else {
        // Fallback to single image viewer
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageViewerScreen(
              initialImagePath: widget.file.path,
              allImages: [widget.file],
              initialIndex: 0,
            ),
          ),
        );
      }
    }
  }

  Future<void> _shareFile() async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(widget.file.path)]
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /*Future<void> _shareFile() async {
    try {
      await SharePlus.shareXFiles([XFile(widget.file.path)]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }*/

  Future<void> _downloadFile() async {
    try {
      // Since it's already saved, we can save it again or show message
      final result = await FileHelper.saveFile(File(widget.file.path));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.contains('Error') ? result : 'File saved again successfully!',
          ),
          backgroundColor: result.contains('Error') ? Colors.red : Colors.green,
        ),
      );
      if (widget.onRefresh != null) {
        widget.onRefresh!();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteFile() async {
    bool? confirm = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete File'),
        content: const Text('Are you sure you want to delete this file?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, true),
            isDestructiveAction: true,
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final file = File(widget.file.path);
        if (await file.exists()) {
          await file.delete();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          if (widget.onRefresh != null) {
            widget.onRefresh!();
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /*Future<void> _deleteFile() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: const Text('Are you sure you want to delete this file?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final file = File(widget.file.path);
        if (await file.exists()) {
          await file.delete();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          if (widget.onRefresh != null) {
            widget.onRefresh!();
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }*/

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                _shareFile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Save Again'),
              onTap: () {
                Navigator.pop(context);
                _downloadFile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openMediaViewer,
      onLongPress: _showOptionsBottomSheet,
      child: Stack(
        children: [
          Positioned.fill(child: _buildThumb()),

          // Video Play Icon
          if (isVideo)
            const Align(
              alignment: Alignment.center,
              child: Icon(Icons.play_circle_outline, size: 50, color: Colors.white),
            ),

          // Top-right Options Button
          Positioned(
            top: 4,
            right: 4,
            child: PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.more_vert, color: Colors.white, size: 18),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share, size: 20),
                      SizedBox(width: 8),
                      Text('Share'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'download',
                  child: Row(
                    children: [
                      Icon(Icons.download, size: 20),
                      SizedBox(width: 8),
                      Text('Save Again'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'share':
                    _shareFile();
                    break;
                  case 'download':
                    _downloadFile();
                    break;
                  case 'delete':
                    _deleteFile();
                    break;
                }
              },
            ),
          ),

          // File Type Badge
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isVideo ? 'VIDEO' : 'IMAGE',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // File Name (Bottom)
          Positioned(
            bottom: 4,
            left: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _getFileName(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFileName() {
    final path = widget.file.path;
    final fileName = path.split('/').last;
    return fileName.length > 20 ? '${fileName.substring(0, 20)}...' : fileName;
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
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.black12,
              child: const Center(
                child: Icon(Icons.broken_image, size: 42, color: Colors.black45),
              ),
            );
          },
        ),
      );
    }
  }
}

/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../screens/image_viewer_screen.dart';
import '../screens/video_player_screen.dart';
import '../utils/file_helper.dart';

class SavedStatusItem extends StatefulWidget {
  final FileSystemEntity file;
  final VoidCallback? onDeleted; // Optional callback to refresh UI after delete

  const SavedStatusItem({super.key, required this.file, this.onDeleted});

  @override
  State<SavedStatusItem> createState() => _StatusItemState();
}

class _StatusItemState extends State<SavedStatusItem> {
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
              saved == 'Permission denied' ? 'Permission denied' : 'Saved: $saved',
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Positioned.fill(child: _buildThumb()),
          if (isVideo)
            const Align(
              alignment: Alignment.center,
              child: Icon(Icons.play_circle_outline, size: 50, color: Colors.white),
            ),
          Positioned(
            bottom: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black45,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                try {
                  final file = File(widget.file.path);
                  if (await file.exists()) {
                    await file.delete();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Deleted successfully')),
                    );
                    if (widget.onDeleted != null) {
                      widget.onDeleted!();
                    }
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting file: $e')),
                  );
                }
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
}
*/
