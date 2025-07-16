import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ShutterButton extends StatefulWidget {
  final VoidCallback onPressed;
  final double size;
  final bool isEnabled;

  const ShutterButton({
    Key? key,
    required this.onPressed,
    this.size = 80.0,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  State<ShutterButton> createState() => _ShutterButtonState();
}

class _ShutterButtonState extends State<ShutterButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Constants.shortAnimation,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isEnabled) return;

    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isEnabled) return;

    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    if (!widget.isEnabled) return;

    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: widget.isEnabled
                      ? [
                          Color(AppColors.primaryBlue),
                          Color(AppColors.primaryPurple),
                        ]
                      : [
                          Color(AppColors.disabledText),
                          Color(AppColors.disabledText),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isEnabled
                        ? Color(AppColors.primaryBlue).withOpacity(0.4)
                        : Colors.transparent,
                    blurRadius: _isPressed ? 8 : 12,
                    spreadRadius: _isPressed ? 2 : 4,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 外側の円
                  Container(
                    width: widget.size - 8,
                    height: widget.size - 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color(AppColors.primaryText),
                        width: 3,
                      ),
                    ),
                  ),

                  // 内側の円
                  Container(
                    width: widget.size - 24,
                    height: widget.size - 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(AppColors.primaryText),
                    ),
                  ),

                  // カメラアイコン
                  Icon(
                    Icons.camera_alt,
                    size: widget.size * 0.3,
                    color: Color(AppColors.primaryBlue),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
