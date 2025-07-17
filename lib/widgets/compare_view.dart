import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CompareView extends StatefulWidget {
  final Uint8List originalImageBytes;
  final Uint8List dottedImageBytes;
  final int? resolution;

  const CompareView({
    Key? key,
    required this.originalImageBytes,
    required this.dottedImageBytes,
    this.resolution,
  }) : super(key: key);

  @override
  State<CompareView> createState() => _CompareViewState();
}

class _CompareViewState extends State<CompareView>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _showOriginal = true;

  @override
  void initState() {
    super.initState();

    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleView() {
    setState(() {
      _showOriginal = !_showOriginal;
    });

    if (_showOriginal) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleView,
      child: Stack(
        children: [
          // メイン画像表示（フリップアニメーション）
          Center(
            child: AnimatedBuilder(
              animation: _flipAnimation,
              builder: (context, child) {
                // フリップアニメーションの角度計算
                final isFirstHalf = _flipAnimation.value < 0.5;
                final angle = _flipAnimation.value * math.pi;

                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // 3D効果のため
                    ..rotateY(angle),
                  child: isFirstHalf
                      ? _buildImageCard(
                          imageBytes: widget.originalImageBytes,
                          label: 'オリジナル',
                          labelColor: Color(AppColors.primaryBlue),
                        )
                      : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(math.pi),
                          child: _buildImageCard(
                            imageBytes: widget.dottedImageBytes,
                            label: 'ドット絵',
                            labelColor: Color(AppColors.primaryPurple),
                          ),
                        ),
                );
              },
            ),
          ),

          // 上部ラベル（現在表示中の画像タイプ）
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _flipAnimation,
              builder: (context, child) {
                final isOriginal = _flipAnimation.value < 0.5;
                return Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isOriginal
                            ? [
                                Color(AppColors.primaryBlue),
                                Color(AppColors.primaryBlue).withOpacity(0.8),
                              ]
                            : [
                                Color(AppColors.primaryPurple),
                                Color(AppColors.primaryPurple).withOpacity(0.8),
                              ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isOriginal ? Icons.photo : Icons.grid_on,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isOriginal ? 'オリジナル' : 'ドット絵',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 下部操作ヒント
          Positioned(bottom: 120, left: 0, right: 0, child: _buildTapHint()),

          // 比較ボタン（右上）
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: GestureDetector(
              onTap: _toggleView,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(AppColors.overlayDark),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Color(AppColors.primaryBlue),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flip,
                      color: Color(AppColors.primaryText),
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '比較',
                      style: TextStyle(
                        color: Color(AppColors.primaryText),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard({
    required Uint8List imageBytes,
    required String label,
    required Color labelColor,
  }) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // メイン画像
            AspectRatio(
              aspectRatio: 3.0 / 4.0,
              child: Image.memory(
                imageBytes,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),

            // グラデーションオーバーレイ（下部）
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
            ),

            // 画像タイプラベル
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: labelColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // 解像度表示（ドット絵の場合のみ）
            if (label == 'ドット絵')
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Color(AppColors.overlayDark),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.resolution ?? 64}x${widget.resolution ?? 64}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTapHint() {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: (1.0 - value * 0.3) * (1.0 - _flipAnimation.value * 0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Color(AppColors.overlayDark),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Color(AppColors.primaryBlue).withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app,
                        color: Color(AppColors.primaryText),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'タップして切り替え',
                        style: TextStyle(
                          color: Color(AppColors.primaryText),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
