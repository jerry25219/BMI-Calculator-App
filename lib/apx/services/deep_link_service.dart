import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

import '../../main.dart';
import '../utilities/debug_print_output.dart';
import 'deep_link_data.dart';
/// 客户端token
String? inviteCode;
/// 平台
String? platform;
/// host
String? host;
/// ？
String? mode;
Map<String, String> deepLinkQueryParams = {};

/// Service to handle deep linking functionality
class DeepLinkService {
  static final DeepLinkService _instance =
      DeepLinkService._internal(AppLinks());
  final _logger = Logger(
      printer: PrettyPrinter(
          methodCount: 0, dateTimeFormat: DateTimeFormat.dateAndTime),
      output: DebugPrintOutput(),
      level: Level.all);
  static final _channel = const BasicMessageChannel<String>(
    'samples.flutter.dev/deeplink_channel',
    StringCodec(),
  );

  /// Factory constructor that returns the singleton instance
  factory DeepLinkService([AppLinks? appLinks]) =>
      appLinks == null ? _instance : DeepLinkService._internal(appLinks);

  /// Instance of AppLinks for handling deep links
  final AppLinks _appLinks;

  /// Private constructor with AppLinks instance
  DeepLinkService._internal(this._appLinks);

  /// Composite subscription for managing all stream subscriptions
  final _subscriptions = CompositeSubscription();

  /// Stream controller for deep link events with backpressure handling
  final _deepLinkStreamController = BehaviorSubject<DeepLinkData>();

  /// Stream of deep link events that can be listened to
  Stream<DeepLinkData> get deepLinkStream => _deepLinkStreamController.stream;

  /// Track initialization state
  bool _isInitialized = false;

  /// Track uri subscription for cleanup verification
  StreamSubscription<Uri?>? _uriSubscription;

  Future<void> initOhos() async {
    try {
      logger.i('Deep link OHOS initialized');
      _channel.setMessageHandler(
        (String? message) async {
          if (message == null || message.isEmpty) {
            return '';
          }
          _logger.i('Deep link OHOS initialized with URI 1-$message');

          /// 去掉message中的空格
          String trimmedMessage = cleanUri(message);
          _logger.i('Deep link OHOS initialized with URI 2-$trimmedMessage');
          try {
            final uri = Uri.parse(trimmedMessage);
            _logger.i(
                'Deep link OHOS initialized with URI 3-${uri.toString()} ${uri.scheme} ${uri.host} ${uri.queryParameters}');
            await _handleDeepLink(uri);
            return '';
          } catch (e) {
            _logger.i('Deep link OHOS initialized with URI 3-$e');
            return '';
          }
        },
      );
      // }
    } catch (e) {
      _logger.i('e---- ${e.toString()}');
    }
  }

  String cleanUri(String uri) {
    // 去除不可见控制字符和空白字符
    // return Uri.parse(uri).toString();
    return uri.replaceAll(RegExp(r'^[^\w]+'), '');
  }

  /// Initializes the deep link service and starts listening for links
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Get initial link if app was opened with it
      final Uri? initialLink = await _appLinks.getInitialLink();

      // Set up stream subscription first to catch any errors
      _uriSubscription = _appLinks.uriLinkStream.listen(
        (Uri? uri) async {
          if (uri != null) {
            try {
              await _handleDeepLink(uri);
            } catch (e, stackTrace) {
              _logger.i('Deep link handling error: $e\n$stackTrace');
              // Only add error to stream if controller is still active
              if (!_deepLinkStreamController.isClosed) {
                _deepLinkStreamController.addError(e, stackTrace);
              }
            }
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          _logger.i('Deep link stream error: $error\n$stackTrace');
          // Only add error to stream if controller is still active
          if (!_deepLinkStreamController.isClosed) {
            _deepLinkStreamController.addError(error, stackTrace);
          }
        },
        cancelOnError: false,
      );

      // Add subscription to composite for management
      _subscriptions.add(_uriSubscription!);

      // Process initial link after stream setup
      if (initialLink != null) {
        await _handleDeepLink(initialLink);
      }

      _isInitialized = true;
    } catch (e, stackTrace) {
      _logger.i('Deep link initialization error: $e\n$stackTrace');
      // Clean up any resources that might have been created
      _subscriptions.dispose();
      _uriSubscription = null;
      if (!_deepLinkStreamController.isClosed) {
        _deepLinkStreamController.addError(e, stackTrace);
      }
      rethrow; // Propagate initialization errors
    }
  }

  /// Handles incoming deep links and processes them
  Future<void> _handleDeepLink(Uri uri) async {
    if (!uri.scheme.contains('dfbmi') && uri.scheme != 'https') {
      return;
    }

    try {
      inviteCode = uri.queryParameters['code'];
      platform = uri.queryParameters['platform'];
      host = uri.queryParameters['host'];
      mode = uri.queryParameters['mode'];
      deepLinkQueryParams = uri.queryParameters;
      eventBus.fire(uri.toString());
      _logger.i('Deep link data: ${uri.toString()}');
    } catch (e, stackTrace) {
      _logger.i('Deep link processing error: $e\n$stackTrace');
      rethrow; // Allow error to be handled by the stream error handler
    }
  }

  /// Disposes of all resources
  void dispose() {
    // Cancel all subscriptions
    _subscriptions.dispose();

    // Close stream controller if still active
    if (!_deepLinkStreamController.isClosed) {
      _deepLinkStreamController.close();
    }

    // Clear initialization state
    _isInitialized = false;

    // Verify cleanup
    assert(_uriSubscription?.isPaused ?? true,
        'URI subscription not properly cancelled');
    _uriSubscription = null;
  }
}
