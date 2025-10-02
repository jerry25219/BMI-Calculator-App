import 'dart:io';
import 'package:flutter/material.dart';

class MyWillPopScope extends StatefulWidget {
  const MyWillPopScope({
    super.key,
    required this.child,
    required this.onWillPop,
  });

  final Widget child;
  final WillPopCallback onWillPop;

  @override
  State<MyWillPopScope> createState() => _WillPopScopeState();
}

class _WillPopScopeState extends State<MyWillPopScope> {
  double startDx = 0;
  double endDx = 0;
  double startDy = 0;
  double endDy = 0;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return Listener(
        onPointerDown: (details) {
          startDx = details.localPosition.dx;
          startDy = details.localPosition.dy;
          endDx = 0;
          endDy = 0;
        },
        onPointerMove: (details) {
          endDx = details.localPosition.dx;
          endDy = details.localPosition.dy;
        },
        onPointerUp: (details) async {
          double dx = endDx - startDx;
          double dy = endDy - startDy;

          bool fromEdge = startDx < 30;
          bool isHorizontalSwipe = dx > 100 && dx.abs() > dy.abs();

          if (fromEdge && isHorizontalSwipe) {
            widget.onWillPop();
          }
        },
        child: WillPopScope(
          child: widget.child,
          onWillPop: () async => false, // 禁用系统返回
        ),
      );
    } else {
      return WillPopScope(
        onWillPop: widget.onWillPop,
        child: widget.child,
      );
    }
  }
}
