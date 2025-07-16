import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../utils/constants.dart';

class CompareView extends StatefulWidget {
  final Uint8List originalImageBytes;
  final Uint8List dottedImageBytes;
  final CompareLayout layout;

  const CompareView({
    Key? key,
    required this.originalImageBytes,
    required this.dottedImageBytes,
    required this.layout,
  }) : super(key: key);

  @override
  State<CompareView> createState() => _CompareViewState();
}

class _CompareViewState extends State<CompareView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  bool _showOriginal = true;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Constants.mediumAnimation,
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleView() {
    setState(() {
      _showOriginal = !_showOriginal;
    });

    if (_showOriginal) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleView,
      child: Stack(
        children: [
          // 2×2レイアウトの比較表示
          _buildQuadrantLayout(),

          // スライドインジケーター
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 0,
            right: 0,
            child: _buildSlideIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuadrantLayout() {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              // 左上
              Expanded(
                child: _buildImageQuadrant(
                  imageBytes: widget.originalImageBytes,
                  label: 'オリジナル',
                  isHighlighted: _getQuadrantHighlight(0),
                ),
              ),
              // 右上
              Expanded(
                child: _buildImageQuadrant(
                  imageBytes: widget.dottedImageBytes,
                  label: 'ドット絵',
                  isHighlighted: _getQuadrantHighlight(1),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              // 左下
              Expanded(
                child: _buildImageQuadrant(
                  imageBytes: widget.originalImageBytes,
                  label: 'オリジナル',
                  isHighlighted: _getQuadrantHighlight(2),
                ),
              ),
              // 右下
              Expanded(
                child: _buildImageQuadrant(
                  imageBytes: widget.dottedImageBytes,
                  label: 'ドット絵',
                  isHighlighted: _getQuadrantHighlight(3),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageQuadrant({
    required Uint8List imageBytes,
    required String label,
    required bool isHighlighted,
  }) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            border: Border.all(
              color: isHighlighted
                  ? Color(AppColors.primaryBlue)
                  : Color(AppColors.dividerColor),
              width: isHighlighted ? 3 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                // 画像
                Positioned.fill(
                  child: Image.memory(imageBytes, fit: BoxFit.cover),
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
                      label,
                      style: TextStyle(
                        color: Color(AppColors.primaryText),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // 半透明フレーム（オリジナル画像の同化防止）
                if (label == 'オリジナル')
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Color(AppColors.overlayLight),
                            blurRadius: 0,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSlideIndicator() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Color(AppColors.overlayDark),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.touch_app,
              color: Color(AppColors.primaryText),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'タップして切り替え',
              style: TextStyle(
                color: Color(AppColors.primaryText),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _getQuadrantHighlight(int quadrant) {
    // レイアウト設定に基づいてハイライトするクアドラントを決定
    switch (widget.layout) {
      case CompareLayout.rightBottom:
        return quadrant == 3; // 右下
      case CompareLayout.leftBottom:
        return quadrant == 2; // 左下
      case CompareLayout.topRight:
        return quadrant == 1; // 右上
      case CompareLayout.topLeft:
        return quadrant == 0; // 左上
    }
  }
}
