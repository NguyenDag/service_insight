import 'package:flutter/material.dart';
import '../models/app_info.dart';
import '../services/device_info_service.dart';

class AppListWidget extends StatelessWidget {
  final List<AppInfo> installedApps;
  final bool isLoading;
  final Function(String) onAppTap;

  const AppListWidget({
    super.key,
    required this.installedApps,
    required this.isLoading,
    required this.onAppTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
                      : installedApps.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.apps, size: 64, color: Colors.grey[400]),
                            SizedBox(height: 16),
                            Text(
                              'Không tìm thấy ứng dụng nào',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Hãy cấp quyền Usage Access trong Settings',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: installedApps.length,
                        itemBuilder: (context, index) {
                          final app = installedApps[index];
                          return _buildAppListItem(context, app);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppListItem(BuildContext context, AppInfo app) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      child: ListTile(
        leading:
            app.icon != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    app.icon!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                )
                : Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.android, size: 24, color: Colors.grey[600]),
                ),
        title: Text(
          app.name,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Thời gian sử dụng hôm nay: ${DeviceInfoService.formatUsageTime(app.usageTime)}',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: () => onAppTap(app.packageName),
      ),
    );
  }
}
