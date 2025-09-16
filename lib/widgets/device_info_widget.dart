import 'package:flutter/material.dart';

class DeviceInfoWidget extends StatefulWidget {
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
  State<StatefulWidget> createState() => _DeviceInfoWidgetState();
}

class _DeviceInfoWidgetState extends State<DeviceInfoWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Tên thiết bị: ', widget.deviceName),

          SizedBox(height: 8),
          Divider(thickness: 1, color: Colors.grey),
          SizedBox(height: 8),

          _buildInfoRow('Phần trăm PIN: ', '${widget.batteryLevel}%'),

          Slider(
            value: widget.batteryLevel.toDouble(),
            min: 0,
            max: 100,
            divisions: 100,
            label: '${widget.batteryLevel}%',
            onChanged: null,
          ),

          Divider(thickness: 1, color: Colors.grey),
          SizedBox(height: 8),

          _buildInfoRow('Độ sáng màn hình: ', '${widget.brightness}%'),

          SizedBox(height: 8),
          Divider(thickness: 1, color: Colors.grey),

          _buildInfoRow('Âm lượng: ', '${widget.volume}'),

          SizedBox(height: 8),

          LinearProgressIndicator(
            value: widget.volume.toDouble() / 100, // từ 0.0 đến 1.0
            minHeight: 4,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[500]!),
          ),

          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label), Text(text)],
    );
  }
}
