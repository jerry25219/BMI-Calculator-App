import 'dart:async';
import 'package:flutter/material.dart';

const double width = 40;

class FloatButton extends StatefulWidget {
  const FloatButton({super.key, required this.onBack, required this.onChange});
  final VoidCallback onBack;
  final ValueChanged<bool> onChange;
  @override
  State<FloatButton> createState() => _FloatButtonState();
}

class _FloatButtonState extends State<FloatButton>
    with SingleTickerProviderStateMixin {
  // 拖拽相关变量
  Offset _position = const Offset(20, 20); // 初始位置
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _position = Offset(
        _position.dx + details.delta.dx,
        _position.dy + details.delta.dy,
      );
    });
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });

    widget.onChange(_isDragging);
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

    widget.onChange(_isDragging);

    // 边界检查，确保按钮不会拖出屏幕
    final screenSize = MediaQuery.of(context).size;
    const buttonSize = width;

    double newX = _position.dx;
    double newY = _position.dy;

    // 限制X轴边界
    if (newX < 0) newX = 0;
    if (newX > screenSize.width - buttonSize)
      newX = screenSize.width - buttonSize;

    // 限制Y轴边界
    if (newY < 0) newY = 0;
    if (newY > screenSize.height - buttonSize - 100)
      newY = screenSize.height - buttonSize - 100; // 留出底部空间

    setState(() {
      _position = Offset(newX, newY);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!_isDragging) {
            widget.onBack();
          }
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.amber,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 25,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
