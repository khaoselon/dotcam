import 'package:flutter/material.dart';
import '../utils/constants.dart';

class EmptyGallery extends StatefulWidget {
  final VoidCallback onTakePhoto;

  const EmptyGallery({Key? key, required this.onTakePhoto}) : super(key: key);

  @override
  State<EmptyGallery> createState() => _EmptyGalleryState();
}

class _EmptyGalleryState extends State<EmptyGallery>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _rotateController;
  late AnimationController _fadeController;

  late Animation<double> _bounceAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: Constants.longAnimation,
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _rotateController, curve: Curves.linear));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _rotateController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _fadeController.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      _bounceController.forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      _rotateController.repeat();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // アニメーション付きアイコン
              AnimatedBuilder(
                animation: _bounceController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _bounceAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(AppColors.primaryBlue),
                            Color(AppColors.primaryPurple),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(
                              AppColors.primaryBlue,
                            ).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 回転するドット絵アイコン
                          AnimatedBuilder(
                            animation: _rotateController,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _rotateAnimation.value * 2 * 3.14159,
                                child: CustomPaint(
                                  size: const Size(60, 60),
                                  painter: PixelGridPainter(),
                                ),
                              );
                            },
                          ),

                          // カメラアイコン
                          Icon(Icons.camera_alt, size: 40, color: Colors.white),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // メインメッセージ
              Text(
                'ギャラリーが空です',
                style: TextStyle(
                  color: Color(AppColors.primaryText),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // サブメッセージ
              Text(
                '最初のドット絵を作成して\nあなたのコレクションを始めましょう！',
                style: TextStyle(
                  color: Color(AppColors.secondaryText),
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // 撮影ボタン
              AnimatedBuilder(
                animation: _bounceController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.5 + (_bounceAnimation.value * 0.5),
                    child: GestureDetector(
                      onTap: widget.onTakePhoto,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(AppColors.primaryBlue),
                              Color(AppColors.primaryPurple),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Color(
                                AppColors.primaryBlue,
                              ).withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '写真を撮る',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 60),

              // ヒント
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(AppColors.surfaceColor),
                  borderRadius: BorderRadius.circular(Constants.cornerRadius),
                  border: Border.all(
                    color: Color(AppColors.primaryBlue).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Color(AppColors.primaryBlue),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ヒント',
                          style: TextStyle(
                            color: Color(AppColors.primaryBlue),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• 人物や風景、オブジェクトなど、様々な被写体でドット絵を楽しめます\n'
                      '• 設定でドットサイズやカラーパレットを調整できます\n'
                      '• 作成したドット絵はSNSで簡単にシェアできます',
                      style: TextStyle(
                        color: Color(AppColors.secondaryText),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PixelGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final gridSize = 8;
    final cellSize = size.width / gridSize;

    // グリッド線を描画
    for (int i = 0; i <= gridSize; i++) {
      // 縦線
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, size.height),
        paint,
      );

      // 横線
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(size.width, i * cellSize),
        paint,
      );
    }

    // いくつかのピクセルを塗りつぶし
    paint.style = PaintingStyle.fill;
    paint.color = Colors.white.withOpacity(0.6);

    final pixels = [
      [2, 1],
      [3, 1],
      [4, 1],
      [5, 1],
      [1, 2],
      [6, 2],
      [1, 3],
      [6, 3],
      [1, 4],
      [6, 4],
      [1, 5],
      [6, 5],
      [2, 6],
      [3, 6],
      [4, 6],
      [5, 6],
    ];

    for (final pixel in pixels) {
      final x = pixel[0];
      final y = pixel[1];
      final rect = Rect.fromLTWH(
        x * cellSize + 1,
        y * cellSize + 1,
        cellSize - 2,
        cellSize - 2,
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
