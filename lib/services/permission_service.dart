import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  PermissionService._internal();
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;

  Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<bool> requestSensorPermission() async {
    final status = await Permission.sensors.request();
    return status.isGranted;
  }

  Future<Map<String, bool>> requestAllPermissions() async {
    return {
      'location': await requestLocationPermission(),
      'notification': await requestNotificationPermission(),
      'sensor': await requestSensorPermission(),
    };
  }

  Future<bool> hasLocationPermission() async {
    final status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  Future<bool> hasNotificationPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }
}
