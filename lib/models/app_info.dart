import 'dart:typed_data';

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
