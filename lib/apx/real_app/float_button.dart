import 'dart:async';
import 'package:flutter/material.dart';

const double width = 40;

class FloatButton extends StatefulWidget {
  const FloatButton({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  State<FloatButton> createState() => _FloatButtonState();
}

class _FloatButtonState extends State<FloatButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _showFirstImage = true;
  Timer? _timer;

  // 拖拽相关变量
  Offset _position = const Offset(20, 20); // 初始位置
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // 初始化淡入淡出动画
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    // 初始化缩放动画
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    // 设置定时器，每2秒切换一次图片
    _startImageSwitching();
  }

  void _startImageSwitching() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isDragging) {
        // 只有在不拖拽时才自动切换
        _switchImage();
      }
    });
  }

  void _switchImage() {
    // 第一阶段：轻微淡出并缩小
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInBack),
    ));

    _animationController.forward().then((_) {
      setState(() {
        _showFirstImage = !_showFirstImage;
      });

      // 第二阶段：淡入并弹性恢复大小
      _fadeAnimation = Tween<double>(
        begin: 0.2,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
      ));

      _scaleAnimation = Tween<double>(
        begin: 0.85,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
      ));

      _animationController.reset();
      _animationController.forward();
    });
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
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

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
    _timer?.cancel();
    _animationController.dispose();
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
        onTap: () {
          if (!_isDragging) {
            widget.onBack();
          }
        },
        child: Container(
          width: width,
          height: width,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.orange,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipOval(
            child: Stack(
              children: [
                // 背景黑色
                Container(
                  width: width,
                  height: width,
                  color: Colors.black.withOpacity(0.1),
                ),
                // 当前显示的图标
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: width,
                      height: width,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange,
                      ),
                      child: Image.asset(
                        _showFirstImage
                            ? 'assets/back1.png'
                            : 'assets/back2.png',
                        width: width,
                        height: width,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
