import 'package:flutter/material.dart';
import '../utils/constants.dart';

class LoadingOverlay extends StatefulWidget {
  final String message;
  final double? progress;
  final VoidCallback? onCancel;

  const LoadingOverlay({
    Key? key,
    required this.message,
    this.progress,
    this.onCancel,
  }) : super(key: key);

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _dotController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _dotAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: Constants.mediumAnimation,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _dotController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _dotAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _dotController, curve: Curves.easeInOut));

    _fadeController.forward();
    _pulseController.repeat(reverse: true);
    _dotController.repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            color: Colors.black.withOpacity(0.8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: Color(AppColors.surfaceColor),
                  borderRadius: BorderRadius.circular(Constants.cornerRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ローディングアニメーション
                    _buildLoadingAnimation(),

                    const SizedBox(height: 24),

                    // メッセージ
                    _buildMessage(),

                    // プログレスバー（オプション）
                    if (widget.progress != null) ...[
                      const SizedBox(height: 16),
                      _buildProgressBar(),
                    ],

                    // キャンセルボタン（オプション）
                    if (widget.onCancel != null) ...[
                      const SizedBox(height: 24),
                      _buildCancelButton(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingAnimation() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(AppColors.primaryBlue),
                  Color(AppColors.primaryPurple),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Color(AppColors.primaryBlue).withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ピクセルアートアイコン
                Container(
                  width: 40,
                  height: 40,
                  child: CustomPaint(painter: PixelArtPainter()),
                ),

                // 回転するドット
                AnimatedBuilder(
                  animation: _dotController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _dotAnimation.value * 2 * 3.14159,
                      child: Container(
                        width: 60,
                        height: 60,
                        child: CustomPaint(painter: DotCirclePainter()),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessage() {
    return Column(
      children: [
        Text(
          widget.message,
          style: TextStyle(
            color: Color(AppColors.primaryText),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _dotController,
          builder: (context, child) {
            final dotCount = ((_dotAnimation.value * 3) % 3).floor() + 1;
            return Text(
              '処理中${'.' * dotCount}',
              style: TextStyle(
                color: Color(AppColors.secondaryText),
                fontSize: 12,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: widget.progress,
          backgroundColor: Color(AppColors.dividerColor),
          valueColor: AlwaysStoppedAnimation<Color>(
            Color(AppColors.primaryBlue),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(widget.progress! * 100).toInt()}%',
          style: TextStyle(color: Color(AppColors.secondaryText), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCancelButton() {
    return TextButton(
      onPressed: widget.onCancel,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        backgroundColor: Color(AppColors.cardColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        'キャンセル',
        style: TextStyle(color: Color(AppColors.primaryText), fontSize: 14),
      ),
    );
  }
}

class PixelArtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final pixelSize = size.width / 8;

    // 簡単なピクセルアートパターンを描画
    final pattern = [
      [0, 0, 1, 1, 1, 1, 0, 0],
      [0, 1, 1, 1, 1, 1, 1, 0],
      [1, 1, 0, 1, 1, 0, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 0, 0, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1],
      [0, 1, 1, 1, 1, 1, 1, 0],
      [0, 0, 1, 1, 1, 1, 0, 0],
    ];

    for (int y = 0; y < 8; y++) {
      for (int x = 0; x < 8; x++) {
        if (pattern[y][x] == 1) {
          paint.color = Colors.white;
          canvas.drawRect(
            Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DotCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;

    // 回転するドットを描画
    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * 3.14159) / 8;
      final x = center.dx + radius * 0.8 * (angle / (2 * 3.14159));
      final y = center.dy + radius * 0.8 * (angle / (2 * 3.14159));

      canvas.drawCircle(
        Offset(
          center.dx + (radius * 0.8) * (i / 8) * 2 - radius * 0.8,
          center.dy,
        ),
        2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
