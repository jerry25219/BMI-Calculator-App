import '../../../model/check_version_response.dart';
import '../../../model/register_result.dart';
import 'online_application_service.dart';

abstract class ApplicationService {
  factory ApplicationService() => OnlineApplicationService();

  Future<CheckVersionResponse?> checkVersion(
      {required Map<String, dynamic> queryParameters});

  Future<RegisterResult?> register(
      {required String apiUrl,
      required Map<String, dynamic> queryParameters,
      required String code});
}
