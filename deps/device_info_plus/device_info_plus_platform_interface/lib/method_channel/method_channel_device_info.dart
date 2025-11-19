import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'package:device_info_plus_platform_interface/device_info_plus_platform_interface.dart';

/// An implementation of [DeviceInfoPlatform] that uses method channels.
class MethodChannelDeviceInfo extends DeviceInfoPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  MethodChannel channel =
      const MethodChannel('dev.fluttercommunity.plus/device_info');

  // Generic method channel for all devices
  @override
  Future<BaseDeviceInfo> deviceInfo() async {
    final Map<String, dynamic> deviceInfoMap = await channel.invokeMethod('getDeviceInfo') as Map<String, dynamic>;
    return BaseDeviceInfo(deviceInfoMap);
  }
}
