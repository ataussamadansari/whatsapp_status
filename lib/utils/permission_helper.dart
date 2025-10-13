import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static bool _isRequesting = false;

  static Future<bool> requestStoragePermission() async {
    if (_isRequesting) return false;
    _isRequesting = true;

    try {
      if (!Platform.isAndroid) return true;

      final sdk = await _getAndroidSdkInt();
      print("Android SDK: $sdk");

      if (sdk >= 33) {
        // ✅ Android 13+ - Try multiple permissions for WhatsApp status access
        print("Requesting permissions for Android 13+");

        // Then try manageExternalStorage for hidden folders like .Statuses
        var manageStorageStatus = await Permission.manageExternalStorage
            .request();
        print(
          "Manage External Storage permission: ${manageStorageStatus.isGranted}",
        );

        // Return true if any of these permissions are granted
        return manageStorageStatus.isGranted;
      } else if (sdk >= 29) {
        // ✅ Android 10-12 - Storage permission
        var status = await Permission.storage.request();
        print("Storage permission: ${status.isGranted}");

        if (status.isGranted) {
          return true;
        }

        // Fallback for some devices
        var manageStatus = await Permission.manageExternalStorage.request();
        return manageStatus.isGranted;
      } else {
        // ✅ Android 8-9 - Storage permission
        var status = await Permission.storage.request();
        print("Storage permission (Old Android): ${status.isGranted}");
        return status.isGranted;
      }
    } catch (e) {
      print("Permission error: $e");
      // Final fallback
      var status = await Permission.storage.request();
      return status.isGranted;
    } finally {
      _isRequesting = false;
    }
  }

  // Check which permissions are currently granted
  static Future<Map<String, bool>> checkAllPermissions() async {
    if (!Platform.isAndroid) return {'allGranted': true};

    final sdk = await _getAndroidSdkInt();

    Map<String, bool> permissions = {};

    if (sdk >= 33) {
      permissions['photos'] = await Permission.photos.isGranted;
      permissions['manageExternalStorage'] =
          await Permission.manageExternalStorage.isGranted;
      permissions['storage'] = await Permission.storage.isGranted;
      permissions['allGranted'] =
          permissions['photos']! ||
          permissions['manageExternalStorage']! ||
          permissions['storage']!;
    } else {
      permissions['storage'] = await Permission.storage.isGranted;
      permissions['manageExternalStorage'] =
          await Permission.manageExternalStorage.isGranted;
      permissions['allGranted'] =
          permissions['storage']! || permissions['manageExternalStorage']!;
    }

    print("Current permissions: $permissions");
    return permissions;
  }

  // Check if we have sufficient permissions for WhatsApp status access
  static Future<bool> hasWhatsAppStatusAccess() async {
    if (!Platform.isAndroid) return true;

    final sdk = await _getAndroidSdkInt();
    final permissions = await checkAllPermissions();

    // For Android 15+, manageExternalStorage is crucial for .Statuses folder
    if (sdk >= 34) {
      return permissions['manageExternalStorage'] == true;
    }

    return permissions['allGranted'] == true;
  }

  // Request specific permission for WhatsApp status access
  static Future<bool> requestWhatsAppStatusPermission() async {
    if (_isRequesting) return false;
    _isRequesting = true;

    try {
      final sdk = await _getAndroidSdkInt();
      print("Requesting WhatsApp status permission for Android $sdk");

      if (sdk >= 34) {
        // Android 14+ - Focus on manageExternalStorage for hidden folders
        print("🔐 Requesting Manage External Storage for .Statuses folder");
        var status = await Permission.manageExternalStorage.request();

        if (status.isGranted) {
          print("✅ Manage External Storage granted - can access .Statuses");
          return true;
        } else {
          print("❌ Manage External Storage denied");
          // Try other permissions as fallback
          var photosStatus = await Permission.photos.request();
          return photosStatus.isGranted;
        }
      } else if (sdk >= 33) {
        // Android 13 - Try multiple approaches
        return await requestStoragePermission();
      } else {
        // Older Android - Standard storage permission
        var status = await Permission.storage.request();
        return status.isGranted;
      }
    } catch (e) {
      print("WhatsApp permission error: $e");
      return false;
    } finally {
      _isRequesting = false;
    }
  }

  // Open app settings for manual permission grant
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  // Get detailed Android version info
  static Future<Map<String, dynamic>> getAndroidInfo() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
        return {
          'sdk': info.version.sdkInt,
          'version': info.version.release,
          'model': info.model,
          'brand': info.brand,
        };
      }
    } catch (e) {
      print("Error getting Android info: $e");
    }
    return {'sdk': 0, 'version': 'Unknown'};
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

/*
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static bool _isRequesting = false;

  static Future<bool> requestStoragePermission() async {
    if (_isRequesting) return false;
    _isRequesting = true;

    try {
      if (!Platform.isAndroid) return true;

      final sdk = await _getAndroidSdkInt();
      print("Android SDK: $sdk");

      if (sdk >= 33) {
        // ✅ Android 13+ (API 33) - Only need photos permission
        var status = await Permission.photos.request();
        // var status = await Permission.manageExternalStorage.request();
        print("Photos permission: ${status.isGranted}");

        if (status.isGranted) {
          return true;
        }

        // If photos denied, try storage as fallback
        status = await Permission.storage.request();
        return status.isGranted;
      } else if (sdk >= 29) {
        // ✅ Android 10-12 (API 29-32) - Storage permission
        var status = await Permission.storage.request();
        print("Storage permission: ${status.isGranted}");

        if (status.isGranted) {
          return true;
        }

        // Fallback: try manageExternalStorage for limited cases
        status = await Permission.manageExternalStorage.request();
        return status.isGranted;
      } else {
        // ✅ Android 8-9 (API 26-28) - Storage permission
        var status = await Permission.storage.request();
        print("Storage permission (Old Android): ${status.isGranted}");
        return status.isGranted;
      }
    } catch (e) {
      print("Permission error: $e");
      // Final fallback
      var status = await Permission.storage.request();
      return status.isGranted;
    } finally {
      _isRequesting = false;
    }
  }

  // Check current permission status (without requesting)
  static Future<bool> checkStoragePermission() async {
    if (!Platform.isAndroid) return true;

    final sdk = await _getAndroidSdkInt();

    if (sdk >= 33) {
      return await Permission.photos.status.isGranted ||
          await Permission.storage.status.isGranted;
    } else {
      return await Permission.storage.status.isGranted ||
          await Permission.manageExternalStorage.status.isGranted;
    }
  }

  // ✅ FIXED: Remove recursive call
  static Future<void> openAppSettings() async {
    await openAppSettings(); // This calls the package function, not itself
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
*/
