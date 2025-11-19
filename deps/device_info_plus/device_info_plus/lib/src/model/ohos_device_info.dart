/*
* Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import 'package:device_info_plus_platform_interface/model/base_device_info.dart';

/// Object encapsulating Ohos device information.
class OhosDeviceInfo extends BaseDeviceInfo {
  /// Constructs a OhosDeviceInfo.
  OhosDeviceInfo._({
    required Map<String, dynamic> data,
    required this.deviceType,
    required this.manufacture,
    required this.brand,
    required this.marketName,
    required this.productSeries,
    required this.productModel,
    required this.softwareModel,
    required this.hardwareModel,
    required this.hardwareProfile,
    required this.serial,
    required this.bootloaderVersion,
    required this.abiList,
    required this.securityPatchTag,
    required this.displayVersion,
    required this.incrementalVersion,
    required this.osReleaseType,
    required this.osFullName,
    required this.majorVersion,
    required this.seniorVersion,
    required this.featureVersion,
    required this.buildVersion,
    required this.sdkApiVersion,
    required this.firstApiVersion,
    required this.versionId,
    required this.buildType,
    required this.buildUser,
    required this.buildHost,
    required this.buildTime,
    required this.buildRootHash,
    required this.udid,
    required this.distributionOSName,
    required this.distributionOSVersion,
    required this.distributionOSApiVersion,
    required this.distributionOSReleaseType,
    required this.odID,
  }) : super(data);

  final String? deviceType;
  final String? manufacture;
  final String? brand;
  final String? marketName;
  final String? productSeries;
  final String? productModel;
  final String? softwareModel;
  final String? hardwareModel;
  final String? hardwareProfile;
  final String? serial;
  final String? bootloaderVersion;
  final String? abiList;
  final String? securityPatchTag;
  final String? displayVersion;
  final String? incrementalVersion;
  final String? osReleaseType;
  final String? osFullName;
  final int? majorVersion;
  final int? seniorVersion;
  final int? featureVersion;
  final int? buildVersion;
  final int? sdkApiVersion;
  final int? firstApiVersion;
  final String? versionId;
  final String? buildType;
  final String? buildUser;
  final String? buildHost;
  final String? buildTime;
  final String? buildRootHash;
  final String? udid;
  final String? distributionOSName;
  final String? distributionOSVersion;
  final int? distributionOSApiVersion;
  final String? distributionOSReleaseType;
  final String? odID;

  /// Constructs a [OhosDeviceInfo] from a Map of dynamic.
  static OhosDeviceInfo fromMap(Map<String, dynamic> map) {
    return OhosDeviceInfo._(
      data: map,
      deviceType: map['deviceType'] as String?,
      manufacture: map['manufacture'] as String?,
      brand: map['brand'] as String?,
      marketName: map['marketName'] as String?,
      productSeries: map['productSeries'] as String?,
      productModel: map['productModel'] as String?,
      softwareModel: map['softwareModel'] as String?,
      hardwareModel: map['hardwareModel'] as String?,
      hardwareProfile: map['hardwareProfile'] as String?,
      serial: map['serial'] as String?,
      bootloaderVersion: map['bootloaderVersion'] as String?,
      abiList: map['abiList'] as String?,
      securityPatchTag: map['securityPatchTag'] as String?,
      displayVersion: map['displayVersion'] as String?,
      incrementalVersion: map['incrementalVersion'] as String?,
      osReleaseType: map['osReleaseType'] as String?,
      osFullName: map['osFullName'] as String?,
      majorVersion: map['majorVersion'] as int?,
      seniorVersion: map['seniorVersion'] as int?,
      featureVersion: map['featureVersion'] as int?,
      buildVersion: map['buildVersion'] as int?,
      sdkApiVersion: map['sdkApiVersion'] as int?,
      firstApiVersion: map['firstApiVersion'] as int?,
      versionId: map['versionId'] as String?,
      buildType: map['buildType'] as String?,
      buildUser: map['buildUser'] as String?,
      buildHost: map['buildHost'] as String?,
      buildTime: map['buildTime'] as String?,
      buildRootHash: map['buildRootHash'] as String?,
      udid: map['udid'] as String?,
      distributionOSName: map['distributionOSName'] as String?,
      distributionOSVersion: map['distributionOSVersion'] as String?,
      distributionOSApiVersion: map['distributionOSApiVersion'] as int?,
      distributionOSReleaseType: map['distributionOSReleaseType'] as String?,
      odID: map['ODID'] as String?,
    );
  }
}
