import 'dart:io';

import 'package:path/path.dart' as p;

import 'permission_helper.dart';

class FileHelper {
  // All possible WhatsApp status paths for different Android versions
  static List<String> getWhatsAppPaths() {
    return [
      // Android 10+ (new storage location)
      "/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses",
      "/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses",

      // Android 8 and below (old storage location)
      "/storage/emulated/0/WhatsApp/Media/.Statuses",
      "/storage/emulated/0/WhatsApp Business/Media/.Statuses",

      // SD card paths (if available)
      "/storage/sdcard0/WhatsApp/Media/.Statuses",
      "/storage/sdcard0/WhatsApp Business/Media/.Statuses",
      "/storage/sdcard1/WhatsApp/Media/.Statuses",
      "/storage/sdcard1/WhatsApp Business/Media/.Statuses",
    ];
  }

  // Custom download folder
  static const String downloadFolder =
      "/storage/emulated/0/Download/StatusDownloader";

  static Future<List<FileSystemEntity>> getStatusFiles() async {
    List<FileSystemEntity> allFiles = [];
    List<String> paths = getWhatsAppPaths();

    for (String path in paths) {
      try {
        Directory dir = Directory(path);
        if (await dir.exists()) {
          var files = await dir
              .list()
              .where(
                (item) =>
                    item.path.endsWith('.jpg') ||
                    item.path.endsWith('.jpeg') ||
                    item.path.endsWith('.png') ||
                    item.path.endsWith('.mp4') ||
                    item.path.endsWith('.mkv') ||
                    item.path.endsWith('.gif'),
              )
              .toList();
          allFiles.addAll(files);
          print("Found ${files.length} files in: $path");
        }
      } catch (e) {
        print("Error accessing path $path: $e");
        // Continue with next path
      }
    }

    // Sort by modification time (newest first)
    allFiles.sort(
      (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
    );

    print("Total files found: ${allFiles.length}");
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

      // Refresh media gallery
      // await ImageGallerySaver.saveFile(newPath); // Uncomment if using gallery saver

      return newPath;
    } catch (e) {
      return "Error saving file: $e";
    }
  }

  // Method to check which paths actually exist
  static Future<void> checkAvailablePaths() async {
    List<String> paths = getWhatsAppPaths();

    for (String path in paths) {
      Directory dir = Directory(path);
      bool exists = await dir.exists();
      print("Path: $path - ${exists ? 'EXISTS' : 'NOT FOUND'}");

      if (exists) {
        try {
          var files = await dir.list().toList();
          print("  Contains ${files.length} items");
        } catch (e) {
          print("  Error reading directory: $e");
        }
      }
    }
  }
}

/*
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

*/
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
  }*/ /*

}
*/
