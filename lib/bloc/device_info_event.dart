import 'package:equatable/equatable.dart';

abstract class DeviceInfoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDeviceInfo extends DeviceInfoEvent {}

class LoadInstalledApps extends DeviceInfoEvent {}

class OpenAppEvent extends DeviceInfoEvent {
  final String packageName;

  OpenAppEvent(this.packageName);

  @override
  List<Object?> get props => [packageName];
}
