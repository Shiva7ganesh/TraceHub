import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  static Future<void> checkForUpdate() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: Duration(seconds: 10),
        minimumFetchInterval: Duration(hours: 1),
      ));
      await remoteConfig.fetchAndActivate();

      // Get current app version
      int currentVersion = await getCurrentVersion();

      // Fetch update JSON from remote config
      final updateInfoJson = remoteConfig.getString('update_info');
      final updateInfo = UpdateInfo.fromJson(jsonDecode(updateInfoJson));

      // Determine update priority
      int updatePriority = getUpdatePriority(currentVersion, updateInfo);

      // Perform update based on priority
      if (updatePriority >= 5) {
        _performImmediateUpdate();
      } else if (updatePriority >= 3) {
        _startFlexibleUpdate();
      } else {
        print('No update required');
      }
    } catch (e) {
      print('Remote Config fetch failed: $e');
    }
  }

  static Future<int> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return int.parse(packageInfo.buildNumber);
  }

  static int getUpdatePriority(int currentVersion, UpdateInfo info) {
    final updates = info.updates.where((update) => update.version > currentVersion);
    if (updates.isNotEmpty) {
      final highestPriorityUpdate = updates.reduce((curr, next) => curr.updatePriority > next.updatePriority ? curr : next);
      return highestPriorityUpdate.updatePriority;
    }
    return 0;
  }

  static Future<void> _performImmediateUpdate() async {
    try {
      AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable && updateInfo.immediateUpdateAllowed) {
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (e) {
      print('Error performing immediate update: $e');
    }
  }

  static Future<void> _startFlexibleUpdate() async {
    try {
      AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable && updateInfo.flexibleUpdateAllowed) {
        await InAppUpdate.startFlexibleUpdate().then((_) {
          // Optionally, complete the update later
          // InAppUpdate.completeFlexibleUpdate();
        });
      }
    } catch (e) {
      print('Error starting flexible update: $e');
    }
  }
}

class UpdateInfo {
  final List<Update> updates;

  UpdateInfo({required this.updates});

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      updates: (json['updates'] as List).map((i) => Update.fromJson(i)).toList(),
    );
  }
}

class Update {
  final int version;
  final int updatePriority;

  Update({required this.version, required this.updatePriority});

  factory Update.fromJson(Map<String, dynamic> json) {
    return Update(
      version: json['version'],
      updatePriority: json['updatePriority'],
    );
  }
}
