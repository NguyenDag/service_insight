import 'package:device_insight/bloc/device_info_bloc.dart';
import 'package:device_insight/bloc/device_info_event.dart';
import 'package:device_insight/bloc/device_info_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/device_info_widget.dart';
import '../widgets/app_list_widget.dart';

class DeviceInfoScreen extends StatelessWidget {
  const DeviceInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              DeviceInfoBloc()
                ..add(LoadDeviceInfo())
                ..add(LoadInstalledApps()),
      child: Scaffold(
        appBar: AppBar(
          title: Container(
            alignment: Alignment.center,
            child: Text(
              'Thông tin thiết bị',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
            ),
          ),
          backgroundColor: Colors.lightBlue.shade100,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.lightBlue.shade100, Colors.white],
            ),
          ),
          child: BlocBuilder<DeviceInfoBloc, DeviceInfoState>(
            builder: (context, state) {
              return Column(
                children: [
                  // Device Info Section
                  DeviceInfoWidget(
                    deviceName: state.deviceName,
                    batteryLevel: state.batteryLevel,
                    brightness: state.brightness,
                    volume: state.volume,
                  ),

                  // Apps List Section
                  AppListWidget(
                    installedApps: state.installedApps,
                    isLoading: state.isLoading,
                    onAppTap: (pkg) {
                      context.read<DeviceInfoBloc>().add(OpenAppEvent(pkg));
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
