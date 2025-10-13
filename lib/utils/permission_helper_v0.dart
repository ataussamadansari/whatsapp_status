import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static bool _isRequesting = false; // 🔒 only one request at a time

  static Future<bool> requestStoragePermission() async {
    if (_isRequesting) return false; // already requesting
    _isRequesting = true;

    try {
      if (!Platform.isAndroid) return true;

      final sdk = await _getAndroidSdkInt();

      if (sdk >= 33) {
        // ✅ Android 13+
        // Combine requests to avoid "already running" error
        Map<Permission, PermissionStatus> statuses = await [
          Permission.photos,
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
      }
    } catch (e) {
      return await Permission.storage.request().isGranted;
    } finally {
      _isRequesting = false; // ✅ reset after request completes
    }
  }

  static Future<int> _getAndroidSdkInt() async {
    if (!Platform.isAndroid) return 0;
    try {
      AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
      return info.version.sdkInt;
    } catch (_) {
      return 0;
    }
  }
}
