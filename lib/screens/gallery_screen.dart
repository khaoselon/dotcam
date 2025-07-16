import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/app_providers.dart';
import '../utils/constants.dart';
import '../widgets/gallery_item.dart';
import '../widgets/empty_gallery.dart';
import 'preview_screen.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  bool _isGridView = true;
  bool _isSelectionMode = false;
  Set<String> _selectedItems = {};

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: Constants.mediumAnimation,
      vsync: this,
    );

    _slideController = AnimationController(
      duration: Constants.longAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _loadBannerAd();
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: Constants.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('バナー広告読み込み失敗: $err');
          ad.dispose();
        },
      ),
    );

    _bannerAd?.load();
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedItems.clear();
      }
    });
  }

  void _selectItem(String imagePath) {
    setState(() {
      if (_selectedItems.contains(imagePath)) {
        _selectedItems.remove(imagePath);
      } else {
        _selectedItems.add(imagePath);
      }
    });
  }

  void _selectAll() {
    final images = ref.read(galleryImagesProvider);
    setState(() {
      _selectedItems = Set.from(images);
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedItems.clear();
    });
  }

  Future<void> _deleteSelected() async {
    final confirmed = await _showDeleteConfirmDialog();
    if (!confirmed) return;

    try {
      for (final imagePath in _selectedItems) {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
        ref.read(galleryImagesProvider.notifier).removeImage(imagePath);
      }

      setState(() {
        _selectedItems.clear();
        _isSelectionMode = false;
      });

      _showSuccessSnackBar('${_selectedItems.length}件の画像を削除しました');
    } catch (e) {
      debugPrint('削除エラー: $e');
      _showErrorSnackBar('削除に失敗しました');
    }
  }

  Future<void> _shareSelected() async {
    try {
      final files = _selectedItems.map((path) => XFile(path)).toList();
      await Share.shareXFiles(files, text: 'DotCamで作成したドット絵 #DotCam');

      // 広告カウンター更新
      ref.read(adCounterProvider.notifier).increment();
    } catch (e) {
      debugPrint('共有エラー: $e');
      _showErrorSnackBar('共有に失敗しました');
    }
  }

  Future<bool> _showDeleteConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Color(AppColors.surfaceColor),
            title: Text(
              '削除確認',
              style: TextStyle(color: Color(AppColors.primaryText)),
            ),
            content: Text(
              '${_selectedItems.length}件の画像を削除しますか？\nこの操作は取り消せません。',
              style: TextStyle(color: Color(AppColors.secondaryText)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'キャンセル',
                  style: TextStyle(color: Color(AppColors.secondaryText)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  '削除',
                  style: TextStyle(color: Color(AppColors.errorColor)),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(AppColors.successColor),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(AppColors.errorColor),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = ref.watch(galleryImagesProvider);

    return Scaffold(
      backgroundColor: Color(AppColors.backgroundColor),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // メインコンテンツ
          Column(
            children: [
              // ギャラリー内容
              Expanded(
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: images.isEmpty
                            ? EmptyGallery(
                                onTakePhoto: () {
                                  Navigator.of(context).pushNamed('/camera');
                                },
                              )
                            : _buildGalleryContent(images),
                      ),
                    );
                  },
                ),
              ),

              // バナー広告
              if (_isBannerAdReady && _bannerAd != null)
                Container(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  alignment: Alignment.center,
                  child: AdWidget(ad: _bannerAd!),
                ),
            ],
          ),

          // 選択モード時の下部ツールバー
          if (_isSelectionMode)
            Positioned(
              bottom:
                  (_isBannerAdReady ? 60 : 0) +
                  MediaQuery.of(context).padding.bottom,
              left: 0,
              right: 0,
              child: _buildSelectionToolbar(),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Color(AppColors.surfaceColor),
      elevation: 0,
      title: Text(
        _isSelectionMode
            ? '${_selectedItems.length}件選択中'
            : AppStrings.galleryTitle,
        style: TextStyle(
          color: Color(AppColors.primaryText),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: _isSelectionMode
          ? IconButton(
              icon: Icon(Icons.close, color: Color(AppColors.primaryText)),
              onPressed: _toggleSelectionMode,
            )
          : IconButton(
              icon: Icon(Icons.arrow_back, color: Color(AppColors.primaryText)),
              onPressed: () => Navigator.of(context).pop(),
            ),
      actions: [
        if (!_isSelectionMode) ...[
          // 表示モード切り替え
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: Color(AppColors.primaryText),
            ),
            onPressed: _toggleViewMode,
          ),
          // 選択モード開始
          IconButton(
            icon: Icon(Icons.select_all, color: Color(AppColors.primaryText)),
            onPressed: _toggleSelectionMode,
          ),
        ] else ...[
          // 全選択/全解除
          IconButton(
            icon: Icon(
              _selectedItems.length == ref.read(galleryImagesProvider).length
                  ? Icons.deselect
                  : Icons.select_all,
              color: Color(AppColors.primaryText),
            ),
            onPressed:
                _selectedItems.length == ref.read(galleryImagesProvider).length
                ? _deselectAll
                : _selectAll,
          ),
        ],
      ],
    );
  }

  Widget _buildGalleryContent(List<String> images) {
    if (_isGridView) {
      return _buildGridView(images);
    } else {
      return _buildListView(images);
    }
  }

  Widget _buildGridView(List<String> images) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.0,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          final imagePath = images[index];
          return GalleryItem(
            imagePath: imagePath,
            isSelected: _selectedItems.contains(imagePath),
            isSelectionMode: _isSelectionMode,
            onTap: () {
              if (_isSelectionMode) {
                _selectItem(imagePath);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PreviewScreen(imagePath: imagePath),
                  ),
                );
              }
            },
            onLongPress: () {
              if (!_isSelectionMode) {
                _toggleSelectionMode();
                _selectItem(imagePath);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildListView(List<String> images) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final imagePath = images[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: GalleryItem(
            imagePath: imagePath,
            isSelected: _selectedItems.contains(imagePath),
            isSelectionMode: _isSelectionMode,
            isListView: true,
            onTap: () {
              if (_isSelectionMode) {
                _selectItem(imagePath);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PreviewScreen(imagePath: imagePath),
                  ),
                );
              }
            },
            onLongPress: () {
              if (!_isSelectionMode) {
                _toggleSelectionMode();
                _selectItem(imagePath);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildSelectionToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(AppColors.surfaceColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 共有ボタン
          _buildToolbarButton(
            icon: Icons.share,
            label: '共有',
            onPressed: _selectedItems.isNotEmpty ? _shareSelected : null,
          ),

          // 削除ボタン
          _buildToolbarButton(
            icon: Icons.delete,
            label: '削除',
            color: Color(AppColors.errorColor),
            onPressed: _selectedItems.isNotEmpty ? _deleteSelected : null,
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    Color? color,
  }) {
    final isEnabled = onPressed != null;
    final buttonColor = color ?? Color(AppColors.primaryBlue);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isEnabled ? buttonColor : Color(AppColors.disabledText),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Color(AppColors.primaryText), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Color(AppColors.primaryText),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
