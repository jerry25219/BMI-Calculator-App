import 'package:flutter/services.dart';
import 'package:package_info_plus_platform_interface/package_info_data.dart';

import 'package_info_platform_interface.dart';

const MethodChannel _channel =
    MethodChannel('dev.fluttercommunity.plus/package_info');

/// An implementation of [PackageInfoPlatform] that uses method channels.
class MethodChannelPackageInfo extends PackageInfoPlatform {
  @override
  Future<PackageInfoData> getAll() async {
    final map = await _channel.invokeMapMethod<String, dynamic>('getAll');
    return PackageInfoData(
      appName: map!['appName'] as String? ?? '',
      packageName: map['packageName'] as String? ?? '',
      version: map['version'] as String? ?? '',
      buildNumber: map['buildNumber'] as String? ?? '',
      buildSignature: map['buildSignature'] as String? ?? '',
      installerStore: map['installerStore'] as String?,
    );
  }
}
