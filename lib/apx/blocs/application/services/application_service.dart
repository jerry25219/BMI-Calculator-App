import '../../../constants.dart';
import '../../../model/check_version_response.dart';
import '../../../model/register_result.dart';
import 'mock_application_service.dart';
import 'online_application_service.dart';

abstract class ApplicationService {
  factory ApplicationService() => Constants.isInDebugMode
      ? MockApplicationService()
      : OnlineApplicationService();

  Future<CheckVersionResponse?> checkVersion(
      {required String deviceId,
      required String platform,
      required String host});

  Future<RegisterResult?> register(
      {required String apiUrl,
      String? deviceId,
      String? code,
      required String platform,
      required String host});
}
