import 'package:device_insight/bloc/device_info_event.dart';
import 'package:device_insight/bloc/device_info_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/device_info_service.dart';

class DeviceInfoBloc extends Bloc<DeviceInfoEvent, DeviceInfoState> {
  DeviceInfoBloc() : super(const DeviceInfoState()) {
    on<LoadDeviceInfo>(_onLoadDeviceInfo);
    on<LoadInstalledApps>(_onLoadInstalledApps);
    on<OpenAppEvent>(_onOpenApp);
  }

  Future<void> _onLoadDeviceInfo(
    LoadDeviceInfo event,
    Emitter<DeviceInfoState> emit,
  ) async {
    final deviceInfo = await DeviceInfoService.getDeviceInfo();
    emit(
      state.copyWith(
        deviceName: deviceInfo['deviceName'],
        batteryLevel: deviceInfo['batteryLevel'],
        brightness: deviceInfo['brightness'],
        volume: deviceInfo['volume'],
      ),
    );
  }

  Future<void> _onLoadInstalledApps(
    LoadInstalledApps event,
    Emitter<DeviceInfoState> emit,
  ) async {
    final apps = await DeviceInfoService.getInstalledApps();
    emit(state.copyWith(installedApps: apps, isLoading: false));
  }

  Future<void> _onOpenApp(
    OpenAppEvent event,
    Emitter<DeviceInfoState> emit,
  ) async {
    final success = await DeviceInfoService.openApp(event.packageName);
    if (!success) {
      // ở đây không hiển thị SnackBar trực tiếp, mà có thể emit state báo lỗi
    }
  }
}
