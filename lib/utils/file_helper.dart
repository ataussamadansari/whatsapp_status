import 'dart:io';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'permission_helper.dart';

class FileHelper {
  static const String whatsappPath =
      "/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses";
  static const String whatsappBusinessPath =
      "/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses";

  static Future<List<FileSystemEntity>> getStatusFiles() async {
    List<FileSystemEntity> allFiles = [];
    List<FileSystemEntity> videoFiles = [];
    List<FileSystemEntity> imageFiles = [];
    List<String> paths = [whatsappPath, whatsappBusinessPath];

    for (String path in paths) {
      Directory dir = Directory(path);
      if (await dir.exists()) {
        var files = await dir
            .list()
            .where((item) => item.path.endsWith('.jpg') || item.path.endsWith('.mp4'))
            .toList();
        var images = await dir.list().where((item) => item.path.endsWith('.jpg') ).toList();
        var videos = await dir.list().where((item) => item.path.endsWith('.mp4')).toList();
        
        imageFiles.addAll(images);
        videoFiles.addAll(videos);

        allFiles.addAll(files);
      }
    }

    allFiles.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    return allFiles;
  }

  static Future<String> saveFile(File sourceFile) async {
    if (!await PermissionHelper.requestStoragePermission()) {
      return "Permission denied";
    }

    final result = await ImageGallerySaverPlus.saveFile(
      sourceFile.path,
      name: "status_${DateTime.now().millisecondsSinceEpoch}",
    );

    return result['filePath'] ?? '';
  }
}
