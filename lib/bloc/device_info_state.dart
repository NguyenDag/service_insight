import 'package:equatable/equatable.dart';

import '../models/app_info.dart';

class DeviceInfoState extends Equatable {
  final String deviceName;
  final int batteryLevel;
  final int brightness;
  final int volume;
  final List<AppInfo> installedApps;
  final bool isLoading;

  const DeviceInfoState({
    this.deviceName = 'Đang tải...',
    this.batteryLevel = 0,
    this.brightness = 0,
    this.volume = 0,
    this.installedApps = const [],
    this.isLoading = true,
  });

  DeviceInfoState copyWith({
    String? deviceName,
    int? batteryLevel,
    int? brightness,
    int? volume,
    List<AppInfo>? installedApps,
    bool? isLoading,
  }) {
    return DeviceInfoState(
      deviceName: deviceName ?? this.deviceName,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      brightness: brightness ?? this.brightness,
      volume: volume ?? this.volume,
      installedApps: installedApps ?? this.installedApps,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
    deviceName,
    batteryLevel,
    brightness,
    volume,
    installedApps,
    isLoading,
  ];
}
