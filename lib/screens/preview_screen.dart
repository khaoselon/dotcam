import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/app_providers.dart';
import '../utils/dot_converter.dart';
import 'package:dotcam/utils/anime_converter.dart' as anime;
import '../utils/constants.dart';
import '../widgets/compare_view.dart';
import '../widgets/loading_overlay.dart';

class PreviewScreen extends ConsumerStatefulWidget {
  final String imagePath;

  const PreviewScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  Uint8List? _originalImageBytes;
  Uint8List? _dottedImageBytes;
  bool _isProcessing = false;
  bool _isCompareMode = true;
  String? _savedImagePath;

  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();

    _slideAnimationController = AnimationController(
      duration: Constants.mediumAnimation,
      vsync: this,
    );

    _fadeAnimationController = AnimationController(
      duration: Constants.longAnimation,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _slideAnimationController,
            curve: Curves.easeInOut,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _loadAndProcessImage();
    _loadBannerAd();
    _slideAnimationController.forward();
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
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

  Future<void> _loadAndProcessImage() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // オリジナル画像読み込み
      final imageFile = File(widget.imagePath);
      if (!await imageFile.exists()) {
        throw Exception('画像ファイルが見つかりません');
      }

      _originalImageBytes = await imageFile.readAsBytes();

      // 変換設定を取得
      final dotSettings = ref.read(dotSettingsProvider);

      // 変換スタイルに応じて処理を分岐
      if (dotSettings.conversionStyle ==
          AnimeConverter.ConversionStyle.dotArt) {
        // 従来のドット絵変換
        final converter = ref.read(dotConverterProvider);
        _dottedImageBytes = await converter.convertToDot(
          imageBytes: _originalImageBytes!,
          settings: dotSettings,
          onProgress: (progress) {
            // プログレス表示は今回省略
          },
        );
      } else {
        // 新しいアニメ風変換
        final animeConverter = ref.read(animeConverterProvider);
        _dottedImageBytes = await animeConverter.convertToAnime(
          imageBytes: _originalImageBytes!,
          style: dotSettings.conversionStyle,
          options: {
            'resolution': dotSettings.resolution,
            'brightness': dotSettings.brightness,
            'contrast': dotSettings.contrast,
            'saturation': dotSettings.saturation,
            'smoothing': dotSettings.smoothing,
          },
          onProgress: (progress) {
            // プログレス表示は今回省略
          },
        );
      }

      _fadeAnimationController.forward();

      // 自動保存が有効な場合
      final settings = ref.read(settingsProvider);
      if (settings.autoSaveEnabled) {
        await _saveImages();
      }
    } catch (e) {
      debugPrint('画像処理エラー: $e');
      _showErrorDialog('画像の処理に失敗しました: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _saveImages() async {
    try {
      if (_dottedImageBytes == null) {
        throw Exception('変換された画像データがありません');
      }

      final settings = ref.read(settingsProvider);

      // 一時ファイルに画像を保存
      final tempDir = await getTemporaryDirectory();
      final fileName = 'DotCam_${DateTime.now().millisecondsSinceEpoch}.png';
      final tempFile = File('${tempDir.path}/$fileName');

      // 比較画像または変換済み画像を保存
      Uint8List imageToSave;
      if (_isCompareMode) {
        imageToSave = await _generateCompareImage();
      } else {
        imageToSave = _dottedImageBytes!;
      }

      await tempFile.writeAsBytes(imageToSave);

      // galライブラリを使用してギャラリーに保存
      try {
        await Gal.putImage(tempFile.path);

        _savedImagePath = tempFile.path;
        ref.read(galleryImagesProvider.notifier).addImage(_savedImagePath!);

        if (settings.enableHapticFeedback) {
          HapticFeedback.lightImpact();
        }
        _showSuccessSnackBar('画像を保存しました');
      } catch (galError) {
        debugPrint('Galライブラリエラー: $galError');
        // galが失敗した場合の代替処理
        _showErrorSnackBar('保存に失敗しました: $galError');
      }
    } catch (e) {
      debugPrint('保存エラー: $e');
      _showErrorSnackBar('保存に失敗しました: $e');
    }
  }

  Future<Uint8List> _generateCompareImage() async {
    if (_originalImageBytes == null || _dottedImageBytes == null) {
      throw Exception('画像データが不正です');
    }

    // 簡易実装として、変換済み画像を返す
    // 実際の比較画像生成はより複雑な処理が必要
    return _dottedImageBytes!;
  }

  Future<void> _shareImage() async {
    try {
      if (_dottedImageBytes == null) return;

      // 一時ファイルに保存
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/dotcam_share.png');
      await tempFile.writeAsBytes(_dottedImageBytes!);

      // 共有
      await Share.shareXFiles([
        XFile(tempFile.path),
      ], text: 'DotCamで作成したドット絵 #DotCam');

      // 広告カウンター更新（シェア後）
      ref.read(adCounterProvider.notifier).increment();
    } catch (e) {
      debugPrint('共有エラー: $e');
      _showErrorSnackBar('共有に失敗しました');
    }
  }

  void _toggleCompareMode() {
    setState(() {
      _isCompareMode = !_isCompareMode;
    });
  }

  void _retakePhoto() {
    Navigator.of(context).pop();
  }

  String _getLoadingMessage() {
    final dotSettings = ref.read(dotSettingsProvider);
    switch (dotSettings.conversionStyle) {
      case anime.ConversionStyle.anime:
        return 'アニメ風に変換中...';
      case anime.ConversionStyle.cartoon:
        return 'カートゥーン風に変換中...';
      case anime.ConversionStyle.manga:
        return '漫画風に変換中...';
      case anime.ConversionStyle.chibi:
        return 'ちび風に変換中...';
      case anime.ConversionStyle.realistic:
        return 'リアル調整中...';
      case anime.ConversionStyle.dotArt:
        return 'ドット絵に変換中...';
      default:
        return '変換中...';
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(AppColors.surfaceColor),
        title: Text(
          'エラー',
          style: TextStyle(color: Color(AppColors.primaryText)),
        ),
        content: Text(
          message,
          style: TextStyle(color: Color(AppColors.secondaryText)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // プレビュー画面も閉じる
            },
            child: Text(
              'OK',
              style: TextStyle(color: Color(AppColors.primaryBlue)),
            ),
          ),
        ],
      ),
    );
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // メイン画像表示
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: _buildImageDisplay(),
                );
              },
            ),
          ),

          // ローディングオーバーレイ
          if (_isProcessing) LoadingOverlay(message: _getLoadingMessage()),

          // 上部コントロール
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: _buildTopControls(),
          ),

          // 下部コントロール
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildBottomControls(),
            ),
          ),

          // バナー広告
          if (_isBannerAdReady && _bannerAd != null)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Container(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                alignment: Alignment.center,
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageDisplay() {
    if (_originalImageBytes == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isCompareMode && _dottedImageBytes != null) {
      final dotSettings = ref.read(dotSettingsProvider);
      return CompareView(
        originalImageBytes: _originalImageBytes!,
        dottedImageBytes: _dottedImageBytes!,
        resolution: dotSettings.resolution,
      );
    } else if (_dottedImageBytes != null) {
      return Center(
        child: Image.memory(_dottedImageBytes!, fit: BoxFit.contain),
      );
    } else {
      return Center(
        child: Image.memory(_originalImageBytes!, fit: BoxFit.contain),
      );
    }
  }

  Widget _buildTopControls() {
    return Row(
      children: [
        // 戻るボタン
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(AppColors.overlayDark),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_back,
              color: Color(AppColors.primaryText),
              size: 20,
            ),
          ),
        ),

        const Spacer(),

        // 比較モード切り替え
        if (_dottedImageBytes != null)
          GestureDetector(
            onTap: _toggleCompareMode,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _isCompareMode
                    ? Color(AppColors.primaryBlue)
                    : Color(AppColors.overlayDark),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.compare,
                    color: Color(AppColors.primaryText),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '比較',
                    style: TextStyle(
                      color: Color(AppColors.primaryText),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Color(AppColors.overlayDark)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 再撮影ボタン
          _buildActionButton(
            icon: Icons.camera_alt,
            label: '再撮影',
            onTap: _retakePhoto,
          ),

          // 保存ボタン
          _buildActionButton(icon: Icons.save, label: '保存', onTap: _saveImages),

          // 共有ボタン
          _buildActionButton(
            icon: Icons.share,
            label: '共有',
            onTap: _shareImage,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(AppColors.primaryBlue),
              Color(AppColors.primaryPurple),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Color(AppColors.primaryBlue).withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Color(AppColors.primaryText), size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Color(AppColors.primaryText),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
