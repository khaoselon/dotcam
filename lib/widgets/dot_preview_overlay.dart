import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../models/app_settings.dart';
import '../models/dot_settings.dart';
import '../providers/app_providers.dart';
import '../utils/constants.dart';

class DotPreviewOverlay extends ConsumerStatefulWidget {
  final CameraController cameraController;
  final CompareLayout layout;
  final double opacity;
  final bool showGrid;

  const DotPreviewOverlay({
    Key? key,
    required this.cameraController,
    required this.layout,
    required this.opacity,
    required this.showGrid,
  }) : super(key: key);

  @override
  ConsumerState<DotPreviewOverlay> createState() => _DotPreviewOverlayState();
}

class _DotPreviewOverlayState extends ConsumerState<DotPreviewOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Constants.mediumAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotSettings = ref.watch(dotSettingsProvider);
    final size = MediaQuery.of(context).size;
    final position = _getPositionFromLayout(widget.layout, size);

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value * widget.opacity,
          child: Stack(
            children: [
              // ドットプレビュー領域
              Positioned(
                top: position['top'],
                left: position['left'],
                right: position['right'],
                bottom: position['bottom'],
                child: Container(
                  width: size.width / 2,
                  height: size.height / 2,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(AppColors.primaryBlue).withOpacity(0.7),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Stack(
                      children: [
                        // 背景（半透明）
                        Container(color: Color(AppColors.overlayDark)),

                        // ドット絵プレビュー（簡易版）
                        CustomPaint(
                          size: Size(size.width / 2, size.height / 2),
                          painter: DotPreviewPainter(
                            resolution: dotSettings.resolution,
                            palette: dotSettings.palette.colors,
                            showGrid: widget.showGrid,
                          ),
                        ),

                        // ラベル
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Color(AppColors.overlayDark),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ドット絵プレビュー',
                              style: TextStyle(
                                color: Color(AppColors.primaryText),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // 解像度表示
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Color(AppColors.primaryBlue),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${dotSettings.resolution}x${dotSettings.resolution}',
                              style: TextStyle(
                                color: Color(AppColors.primaryText),
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // グリッドオーバーレイ（全画面）
              if (widget.showGrid)
                Positioned.fill(
                  child: CustomPaint(
                    painter: GridOverlayPainter(
                      gridSize: dotSettings.resolution,
                      color: Color(AppColors.primaryBlue).withOpacity(0.3),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Map<String, double> _getPositionFromLayout(CompareLayout layout, Size size) {
    switch (layout) {
      case CompareLayout.rightBottom:
        return {'right': 20.0, 'bottom': 20.0};
      case CompareLayout.leftBottom:
        return {'left': 20.0, 'bottom': 20.0};
      case CompareLayout.topRight:
        return {'right': 20.0, 'top': 80.0};
      case CompareLayout.topLeft:
        return {'left': 20.0, 'top': 80.0};
    }
  }
}

class DotPreviewPainter extends CustomPainter {
  final int resolution;
  final List<int> palette;
  final bool showGrid;

  DotPreviewPainter({
    required this.resolution,
    required this.palette,
    required this.showGrid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final pixelSize = size.width / resolution;

    // 簡易的なドット絵パターンを描画
    for (int y = 0; y < resolution; y++) {
      for (int x = 0; x < resolution; x++) {
        // 簡易的なパターン生成（実際の画像処理ではない）
        final colorIndex = ((x + y) ~/ 4) % palette.length;
        paint.color = Color(palette[colorIndex]);

        final rect = Rect.fromLTWH(
          x * pixelSize,
          y * pixelSize,
          pixelSize,
          pixelSize,
        );

        canvas.drawRect(rect, paint);

        // グリッド線
        if (showGrid) {
          paint.color = Colors.white.withOpacity(0.3);
          paint.strokeWidth = 0.5;
          paint.style = PaintingStyle.stroke;
          canvas.drawRect(rect, paint);
          paint.style = PaintingStyle.fill;
        }
      }
    }
  }

  @override
  bool shouldRepaint(DotPreviewPainter oldDelegate) {
    return oldDelegate.resolution != resolution ||
        oldDelegate.palette != palette ||
        oldDelegate.showGrid != showGrid;
  }
}

class GridOverlayPainter extends CustomPainter {
  final int gridSize;
  final Color color;

  GridOverlayPainter({required this.gridSize, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final cellWidth = size.width / gridSize;
    final cellHeight = size.height / gridSize;

    // 縦線
    for (int i = 0; i <= gridSize; i++) {
      final x = i * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // 横線
    for (int i = 0; i <= gridSize; i++) {
      final y = i * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(GridOverlayPainter oldDelegate) {
    return oldDelegate.gridSize != gridSize || oldDelegate.color != color;
  }
}
