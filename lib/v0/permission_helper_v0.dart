/*import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {

  static Future<bool> requestStoragePermission() async {
    try {
      if (!Platform.isAndroid) return true;

      final sdk = await _getAndroidSdkInt();

      if (sdk >= 33) {
        // ✅ Android 13+
        // Combine requests to avoid "already running" error
        Map<Permission, PermissionStatus> statuses = await [
          Permission.photos,
          Permission.videos,
          Permission.storage,
          Permission.manageExternalStorage,
        ].request();

        // If any granted → true
        return statuses.values.any((status) => status.isGranted);
      } else {
        Map<Permission, PermissionStatus> status = await [
          Permission.storage,
          Permission.manageExternalStorage,
        ].request();
        return status.values.any((status) => status.isGranted);
        // final status = await Permission.storage.request();
        // return status.isGranted;
      }
    } catch (e) {
      return await Permission.storage.request().isGranted;
    }
  }

  static Future<int> _getAndroidSdkInt() async {
    try {
      if(Platform.isAndroid) {
        AndroidDeviceInfo info = await DeviceInfoPlugin()
            .androidInfo;
        return info.version.sdkInt;
      }
    } catch (_) {}
    return 0;
  }
}*/




/*
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
*/
