import 'package:flutter/material.dart';

class DeviceInfoWidget extends StatelessWidget {
  final String deviceName;
  final int batteryLevel;
  final int brightness;
  final int volume;

  const DeviceInfoWidget({
    super.key,
    required this.deviceName,
    required this.batteryLevel,
    required this.brightness,
    required this.volume,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          _buildInfoRow(
            Icons.phone_android,
            Colors.blue[600]!,
            'Tên thiết bị: $deviceName',
          ),
          SizedBox(height: 8),
          _buildInfoRow(
            Icons.battery_full,
            Colors.green[600]!,
            'Pin: $batteryLevel%',
          ),
          SizedBox(height: 8),
          _buildInfoRow(
            Icons.brightness_6,
            Colors.orange[600]!,
            'Độ sáng: $brightness%',
          ),
          SizedBox(height: 8),
          _buildInfoRow(
            Icons.volume_up,
            Colors.purple[600]!,
            'Âm lượng: $volume%',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, Color iconColor, String text) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
