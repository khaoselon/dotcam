import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class GalleryItem extends StatefulWidget {
  final String imagePath;
  final bool isSelected;
  final bool isSelectionMode;
  final bool isListView;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const GalleryItem({
    Key? key,
    required this.imagePath,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
    this.isListView = false,
  }) : super(key: key);

  @override
  State<GalleryItem> createState() => _GalleryItemState();
}

class _GalleryItemState extends State<GalleryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Constants.shortAnimation,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();

    // 触覚フィードバック
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
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
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onLongPress: widget.onLongPress,
              child: widget.isListView
                  ? _buildListViewItem()
                  : _buildGridViewItem(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridViewItem() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Constants.cornerRadius),
        border: Border.all(
          color: widget.isSelected
              ? Color(AppColors.primaryBlue)
              : Color(AppColors.dividerColor),
          width: widget.isSelected ? 3 : 1,
        ),
        boxShadow: [
          if (widget.isSelected)
            BoxShadow(
              color: Color(AppColors.primaryBlue).withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Constants.cornerRadius - 1),
        child: Stack(
          children: [
            // 画像
            Positioned.fill(child: _buildImage()),

            // 選択モード時のオーバーレイ
            if (widget.isSelectionMode)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? Color(AppColors.primaryBlue).withOpacity(0.3)
                        : Colors.black.withOpacity(0.3),
                  ),
                ),
              ),

            // 選択チェックマーク
            if (widget.isSelectionMode)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? Color(AppColors.primaryBlue)
                        : Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: widget.isSelected
                      ? Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),

            // ファイル情報
            Positioned(bottom: 0, left: 0, right: 0, child: _buildFileInfo()),
          ],
        ),
      ),
    );
  }

  Widget _buildListViewItem() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Color(AppColors.surfaceColor),
        borderRadius: BorderRadius.circular(Constants.cornerRadius),
        border: Border.all(
          color: widget.isSelected
              ? Color(AppColors.primaryBlue)
              : Color(AppColors.dividerColor),
          width: widget.isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // 画像サムネイル
          Container(
            width: 100,
            height: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Constants.cornerRadius - 1),
                bottomLeft: Radius.circular(Constants.cornerRadius - 1),
              ),
              child: _buildImage(),
            ),
          ),

          // ファイル情報
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getFileName(),
                    style: TextStyle(
                      color: Color(AppColors.primaryText),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _getFileDate(),
                    style: TextStyle(
                      color: Color(AppColors.secondaryText),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _getFileSize(),
                    style: TextStyle(
                      color: Color(AppColors.secondaryText),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 選択チェックボックス
          if (widget.isSelectionMode)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? Color(AppColors.primaryBlue)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.isSelected
                        ? Color(AppColors.primaryBlue)
                        : Color(AppColors.dividerColor),
                    width: 2,
                  ),
                ),
                child: widget.isSelected
                    ? Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final file = File(widget.imagePath);

    return FutureBuilder<bool>(
      future: file.exists(),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget();
            },
          );
        } else {
          return _buildErrorWidget();
        }
      },
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Color(AppColors.cardColor),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              color: Color(AppColors.disabledText),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              '画像を読み込めません',
              style: TextStyle(
                color: Color(AppColors.disabledText),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _getFileName(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _getFileDate(),
            style: TextStyle(color: Colors.white70, fontSize: 8),
          ),
        ],
      ),
    );
  }

  String _getFileName() {
    return widget.imagePath.split('/').last;
  }

  String _getFileDate() {
    try {
      final file = File(widget.imagePath);
      final stats = file.statSync();
      final date = stats.modified;
      return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return '不明';
    }
  }

  String _getFileSize() {
    try {
      final file = File(widget.imagePath);
      final stats = file.statSync();
      final bytes = stats.size;

      if (bytes < 1024) {
        return '${bytes}B';
      } else if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)}KB';
      } else {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
      }
    } catch (e) {
      return '不明';
    }
  }
}
