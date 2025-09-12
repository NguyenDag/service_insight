import 'package:flutter/material.dart';
import '../models/app_info.dart';
import '../services/device_info_service.dart';
import '../widgets/device_info_widget.dart';
import '../widgets/app_list_widget.dart';

class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({super.key});

  @override
  DeviceInfoScreenState createState() => DeviceInfoScreenState();
}

class DeviceInfoScreenState extends State<DeviceInfoScreen> {
  // Device info variables
  String deviceName = 'Đang tải...';
  int batteryLevel = 0;
  int brightness = 0;
  int volume = 0;

  // Apps variables
  List<AppInfo> installedApps = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load tất cả dữ liệu
  Future<void> _loadData() async {
    await Future.wait([_getDeviceInfo(), _getInstalledApps()]);
  }

  // Lấy thông tin thiết bị
  Future<void> _getDeviceInfo() async {
    final deviceInfo = await DeviceInfoService.getDeviceInfo();

    if (mounted) {
      setState(() {
        deviceName = deviceInfo['deviceName'];
        batteryLevel = deviceInfo['batteryLevel'];
        brightness = deviceInfo['brightness'];
        volume = deviceInfo['volume'];
      });
    }
  }

  // Lấy danh sách ứng dụng
  Future<void> _getInstalledApps() async {
    final apps = await DeviceInfoService.getInstalledApps();

    if (mounted) {
      setState(() {
        installedApps = apps;
        isLoading = false;
      });
    }
  }

  // Mở ứng dụng
  Future<void> _openApp(String packageName) async {
    final success = await DeviceInfoService.openApp(packageName);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể mở ứng dụng'),
          backgroundColor: Colors.red[400],
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Refresh dữ liệu
  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thông tin thiết bị',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Làm mới dữ liệu',
          ),
        ],
      ),
      body: Column(
        children: [
          // Device Info Section
          DeviceInfoWidget(
            deviceName: deviceName,
            batteryLevel: batteryLevel,
            brightness: brightness,
            volume: volume,
          ),

          // Apps List Section
          AppListWidget(
            installedApps: installedApps,
            isLoading: isLoading,
            onAppTap: _openApp,
          ),
        ],
      ),
    );
  }
}
