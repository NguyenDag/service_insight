import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Info App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DeviceInfoScreen(),
    );
  }
}

class DeviceInfoScreen extends StatefulWidget {
  @override
  _DeviceInfoScreenState createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  static const platform = MethodChannel('device_info_channel');

  String deviceName = 'Loading...';
  int batteryLevel = 0;
  int brightness = 0;
  int volume = 0;
  List<AppInfo> installedApps = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getDeviceInfo();
    _getInstalledApps();
  }

  Future<void> _getDeviceInfo() async {
    try {
      final String result = await platform.invokeMethod('getDeviceName');
      final int battery = await platform.invokeMethod('getBatteryLevel');
      final int screenBrightness = await platform.invokeMethod(
        'getScreenBrightness',
      );
      final int audioVolume = await platform.invokeMethod('getAudioVolume');

      setState(() {
        deviceName = result;
        batteryLevel = battery;
        brightness = screenBrightness;
        volume = audioVolume;
      });
    } on PlatformException catch (e) {
      print("Failed to get device info: '${e.message}'");
    }
  }

  Future<void> _getInstalledApps() async {
    try {
      final List<dynamic> apps = await platform.invokeMethod(
        'getInstalledApps',
      );
      List<AppInfo> appList = [];

      for (var app in apps) {
        Map<String, dynamic> appMap = Map<String, dynamic>.from(app);
        appList.add(AppInfo.fromMap(appMap));
      }

      setState(() {
        installedApps = appList;
        isLoading = false;
      });
    } on PlatformException catch (e) {
      print("Failed to get installed apps: '${e.message}'");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _openApp(String packageName) async {
    try {
      await platform.invokeMethod('openApp', {'packageName': packageName});
    } on PlatformException catch (e) {
      print("Failed to open app: '${e.message}'");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể mở ứng dụng: ${e.message}')),
      );
    }
  }

  String _formatUsageTime(int milliseconds) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Info'),
        backgroundColor: Colors.blue[600],
      ),
      body: Column(
        children: [
          // Device Info Section
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thông tin thiết bị',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.phone_android, color: Colors.blue[600]),
                    SizedBox(width: 8),
                    Expanded(child: Text('Tên thiết bị: $deviceName')),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.battery_full, color: Colors.green[600]),
                    SizedBox(width: 8),
                    Expanded(child: Text('Pin: $batteryLevel%')),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.brightness_6, color: Colors.orange[600]),
                    SizedBox(width: 8),
                    Expanded(child: Text('Độ sáng: $brightness%')),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.volume_up, color: Colors.purple[600]),
                    SizedBox(width: 8),
                    Expanded(child: Text('Âm lượng: $volume%')),
                  ],
                ),
              ],
            ),
          ),

          // Apps List Section
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Ứng dụng đã cài đặt',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                        isLoading
                            ? Center(child: CircularProgressIndicator())
                            : ListView.builder(
                              itemCount: installedApps.length,
                              itemBuilder: (context, index) {
                                final app = installedApps[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  child: ListTile(
                                    leading:
                                        app.icon != null
                                            ? Image.memory(
                                              app.icon!,
                                              width: 40,
                                              height: 40,
                                            )
                                            : Icon(Icons.android, size: 40),
                                    title: Text(
                                      app.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Thời gian sử dụng hôm nay: ${_formatUsageTime(app.usageTime)}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                    ),
                                    onTap: () => _openApp(app.packageName),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppInfo {
  final String name;
  final String packageName;
  final Uint8List? icon;
  final int usageTime;

  AppInfo({
    required this.name,
    required this.packageName,
    this.icon,
    required this.usageTime,
  });

  factory AppInfo.fromMap(Map<String, dynamic> map) {
    return AppInfo(
      name: map['name'] ?? '',
      packageName: map['packageName'] ?? '',
      icon:
          map['icon'] != null
              ? Uint8List.fromList(List<int>.from(map['icon']))
              : null,
      usageTime: map['usageTime'] ?? 0,
    );
  }
}
