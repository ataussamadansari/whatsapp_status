import 'dart:io';
import 'permission_helper.dart';
import 'package:path/path.dart' as p;

class FileHelper {
  static const String whatsappPath =
      "/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses";
  static const String whatsappBusinessPath =
      "/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses";

  // Custom download folder
  static const String downloadFolder =
      "/storage/emulated/0/Download/StatusDownloader";

  static Future<List<FileSystemEntity>> getStatusFiles() async {
    List<FileSystemEntity> allFiles = [];
    List<String> paths = [whatsappPath, whatsappBusinessPath];

    for (String path in paths) {
      Directory dir = Directory(path);
      if (await dir.exists()) {
        var files = await dir
            .list()
            .where((item) => item.path.endsWith('.jpg') || item.path.endsWith('.mp4'))
            .toList();
        allFiles.addAll(files);
      }
    }

    allFiles.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    return allFiles;
  }


  // Save file to custom folder
  static Future<String> saveFile(File sourceFile) async {
    // Request storage permission
    if (!await PermissionHelper.requestStoragePermission()) {
      return "Permission denied";
    }

    // Create custom folder if not exists
    final dir = Directory(downloadFolder);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // Custom file name with same extension
    final fileName =
        "status_${DateTime.now().millisecondsSinceEpoch}${p.extension(sourceFile.path)}";
    final newPath = p.join(downloadFolder, fileName);

    // Copy file to custom folder
    try {
      await sourceFile.copy(newPath);
      return newPath;
    } catch (e) {
      return "Error saving file: $e";
    }
  }

/*
  static Future<String> saveFile(File sourceFile) async {
    if (!await PermissionHelper.requestStoragePermission()) {
      return "Permission denied";
    }

    final result = await ImageGallerySaverPlus.saveFile(
      sourceFile.path,
      name: "status_${DateTime.now().millisecondsSinceEpoch}",
    );

    return result['filePath'] ?? '';
  }*/
}
