import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class SettingsItem extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final Color? color;

  const SettingsItem({
    Key? key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.color,
  }) : super(key: key);

  @override
  State<SettingsItem> createState() => _SettingsItemState();
}

class _SettingsItemState extends State<SettingsItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Constants.shortAnimation,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _colorAnimation =
        ColorTween(
          begin: Colors.transparent,
          end: Color(AppColors.primaryBlue).withOpacity(0.1),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled || widget.onTap == null) return;

    setState(() {
      _isPressed = true;
    });
    _animationController.forward();

    // 軽い触覚フィードバック
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled || widget.onTap == null) return;

    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();

    // 少し遅延してコールバックを実行
    Future.delayed(const Duration(milliseconds: 100), () {
      widget.onTap?.call();
    });
  }

  void _handleTapCancel() {
    if (!widget.enabled || widget.onTap == null) return;

    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              border: Border(
                bottom: BorderSide(
                  color: Color(AppColors.dividerColor),
                  width: 0.5,
                ),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                borderRadius: BorderRadius.circular(0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      // リーディングアイコン
                      if (widget.leading != null) ...[
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                (widget.color ?? Color(AppColors.primaryBlue))
                                    .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            widget.leading!,
                            color: widget.enabled
                                ? (widget.color ?? Color(AppColors.primaryBlue))
                                : Color(AppColors.disabledText),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],

                      // タイトルとサブタイトル
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                color: widget.enabled
                                    ? Color(AppColors.primaryText)
                                    : Color(AppColors.disabledText),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (widget.subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                widget.subtitle!,
                                style: TextStyle(
                                  color: widget.enabled
                                      ? Color(AppColors.secondaryText)
                                      : Color(AppColors.disabledText),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // トレイリングウィジェット
                      if (widget.trailing != null) ...[
                        const SizedBox(width: 16),
                        widget.trailing!,
                      ] else if (widget.onTap != null) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: widget.enabled
                              ? Color(AppColors.secondaryText)
                              : Color(AppColors.disabledText),
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
