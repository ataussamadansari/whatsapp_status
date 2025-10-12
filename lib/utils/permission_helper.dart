import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Android 11+ (SDK 30+)
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      // Request MANAGE_EXTERNAL_STORAGE for Android 11+
      if (await Permission.manageExternalStorage.request().isGranted) {
        return true;
      }

      // Android 13+ fallback (Photos & Videos)
      var statuses = await [
        Permission.photos,
        Permission.videos,
        Permission.storage, // Android 10 & 11 fallback
      ].request();

      return statuses.values.every((status) => status.isGranted);
    }

    // iOS (optional)
    return true;
  }
}
