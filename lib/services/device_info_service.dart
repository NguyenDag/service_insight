import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/app_info.dart';

class DeviceInfoService {
  static const platform = MethodChannel('device_info_channel');

  // Lấy thông tin thiết bị
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final String deviceName = await platform.invokeMethod('getDeviceName');
      final int batteryLevel = await platform.invokeMethod('getBatteryLevel');
      final int brightness = await platform.invokeMethod('getScreenBrightness');
      final int volume = await platform.invokeMethod('getAudioVolume');

      return {
        'deviceName': deviceName,
        'batteryLevel': batteryLevel,
        'brightness': brightness,
        'volume': volume,
      };
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Failed to get device info: '${e.message}'");
      }
      return {
        'deviceName': 'Unknown',
        'batteryLevel': 0,
        'brightness': 0,
        'volume': 0,
      };
    }
  }

  // Lấy danh sách ứng dụng đã cài đặt
  static Future<List<AppInfo>> getInstalledApps() async {
    try {
      final List<dynamic> apps = await platform.invokeMethod(
        'getInstalledApps',
      );
      List<AppInfo> appList = [];

      for (var app in apps) {
        Map<String, dynamic> appMap = Map<String, dynamic>.from(app);
        appList.add(AppInfo.fromMap(appMap));
      }

      return appList;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Failed to get installed apps: '${e.message}'");
      }
      return [];
    }
  }

  // Mở ứng dụng
  static Future<bool> openApp(String packageName) async {
    try {
      await platform.invokeMethod('openApp', {'packageName': packageName});
      return true;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Failed to open app: '${e.message}'");
      }
      return false;
    }
  }

  // Format thời gian sử dụng
  static String formatUsageTime(int milliseconds) {
    if (milliseconds == 0) return '0 phút';

    int totalMinutes = (milliseconds / (1000 * 60)).round();
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
