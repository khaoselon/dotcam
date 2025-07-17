import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/app_providers.dart';
import '../utils/constants.dart';
import '../widgets/shutter_button.dart';
import '../widgets/quick_settings_panel.dart';
import '../widgets/camera_controls.dart';
import 'preview_screen.dart';

class CameraScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? _cameraController;
  late AnimationController _zoomAnimationController;
  late AnimationController _focusAnimationController;
  late AnimationController _slideAnimationController;

  bool _isInitialized = false;
  bool _isQuickSettingsVisible = false;
  double _currentZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  double _minZoomLevel = 1.0;

  Offset? _focusPoint;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _zoomAnimationController = AnimationController(
      duration: Constants.shortAnimation,
      vsync: this,
    );

    _focusAnimationController = AnimationController(
      duration: Constants.mediumAnimation,
      vsync: this,
    );

    _slideAnimationController = AnimationController(
      duration: Constants.mediumAnimation,
      vsync: this,
    );

    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _zoomAnimationController.dispose();
    _focusAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await ref.read(cameraProvider.future);
      if (cameras.isEmpty) return;

      final cameraDirection = ref.read(cameraDirectionProvider);
      final selectedCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == cameraDirection,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      _maxZoomLevel = await _cameraController!.getMaxZoomLevel();
      _minZoomLevel = await _cameraController!.getMinZoomLevel();
      _currentZoomLevel = _minZoomLevel;

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('カメラ初期化エラー: $e');
      _showErrorSnackBar(Constants.cameraInitError);
    }
  }

  Future<void> _takePicture() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      // 触覚フィードバック
      final settings = ref.read(settingsProvider);
      if (settings.enableHapticFeedback) {
        HapticFeedback.lightImpact();
      }

      // シャッター音効果（設定で有効な場合）
      if (settings.enableSoundEffects) {
        HapticFeedback.mediumImpact();
      }

      // 撮影実行
      final XFile image = await controller.takePicture();

      // 広告カウンター更新
      ref.read(adCounterProvider.notifier).increment();

      // プレビュー画面に遷移
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PreviewScreen(imagePath: image.path),
          ),
        );
      }

      // インタースティシャル広告表示チェック
      final shouldShowAd = ref
          .read(adCounterProvider.notifier)
          .shouldShowInterstitial();
      if (shouldShowAd) {
        _showInterstitialAd();
      }
    } catch (e) {
      debugPrint('撮影エラー: $e');
      _showErrorSnackBar('撮影に失敗しました');
    }
  }

  void _showInterstitialAd() {
    InterstitialAd.load(
      adUnitId: Constants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          ad.show();
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent:
                (InterstitialAd ad, AdError error) {
                  ad.dispose();
                },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('インタースティシャル広告読み込み失敗: $error');
        },
      ),
    );
  }

  Future<void> _switchCamera() async {
    final currentDirection = ref.read(cameraDirectionProvider);
    final newDirection = currentDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;

    ref.read(cameraDirectionProvider.notifier).state = newDirection;

    await _cameraController?.dispose();
    setState(() {
      _isInitialized = false;
    });

    await _initializeCamera();
  }

  Future<void> _toggleFlash() async {
    final controller = _cameraController;
    if (controller == null) return;

    final currentMode = ref.read(flashModeProvider);
    FlashMode newMode;

    switch (currentMode) {
      case FlashMode.auto:
        newMode = FlashMode.always;
        break;
      case FlashMode.always:
        newMode = FlashMode.off;
        break;
      case FlashMode.off:
        newMode = FlashMode.auto;
        break;
      default:
        newMode = FlashMode.auto;
    }

    await controller.setFlashMode(newMode);
    ref.read(flashModeProvider.notifier).state = newMode;
  }

  Future<void> _setFocusPoint(Offset point) async {
    final controller = _cameraController;
    if (controller == null) return;

    try {
      await controller.setFocusPoint(point);
      setState(() {
        _focusPoint = point;
      });

      _focusAnimationController.forward().then((_) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _focusAnimationController.reverse();
          }
        });
      });
    } catch (e) {
      debugPrint('フォーカス設定エラー: $e');
    }
  }

  Future<void> _handleZoom(double scale) async {
    final controller = _cameraController;
    if (controller == null) return;

    final zoom = (_currentZoomLevel * scale).clamp(
      _minZoomLevel,
      _maxZoomLevel,
    );
    await controller.setZoomLevel(zoom);
    setState(() {
      _currentZoomLevel = zoom;
    });
  }

  void _toggleQuickSettings() {
    setState(() {
      _isQuickSettingsVisible = !_isQuickSettingsVisible;
    });

    if (_isQuickSettingsVisible) {
      _slideAnimationController.forward();
    } else {
      _slideAnimationController.reverse();
    }
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
    if (!_isInitialized || _cameraController == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(AppColors.primaryBlue),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'カメラを初期化中...',
                style: TextStyle(
                  color: Color(AppColors.primaryText),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final camera = _cameraController!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // カメラプレビュー（フルスクリーン）
          Positioned.fill(
            child: GestureDetector(
              onTapUp: (details) {
                final offset = Offset(
                  details.localPosition.dx / size.width,
                  details.localPosition.dy / size.height,
                );
                _setFocusPoint(offset);
              },
              onScaleUpdate: (details) {
                _handleZoom(details.scale);
              },
              child: CameraPreview(camera),
            ),
          ),

          // フォーカスインジケーター
          if (_focusPoint != null)
            Positioned(
              left: _focusPoint!.dx * size.width - 50,
              top: _focusPoint!.dy * size.height - 50,
              child: AnimatedBuilder(
                animation: _focusAnimationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: 1.0 - _focusAnimationController.value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(AppColors.primaryBlue),
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // 上部コントロール
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 0,
            right: 0,
            child: CameraControls(
              onFlashToggle: _toggleFlash,
              onCameraSwitch: _switchCamera,
              onQuickSettings: _toggleQuickSettings,
            ),
          ),

          // クイック設定パネル
          if (_isQuickSettingsVisible)
            Positioned(
              top: MediaQuery.of(context).padding.top + 70,
              left: 16,
              right: 16,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, -1),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _slideAnimationController,
                        curve: Curves.easeInOut,
                      ),
                    ),
                child: QuickSettingsPanel(
                  onClose: () => _toggleQuickSettings(),
                ),
              ),
            ),

          // ズームレベル表示
          if (_currentZoomLevel > _minZoomLevel)
            Positioned(
              top: MediaQuery.of(context).padding.top + 120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Color(AppColors.overlayDark),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_currentZoomLevel.toStringAsFixed(1)}x',
                    style: TextStyle(
                      color: Color(AppColors.primaryText),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // 下部コントロール
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 30,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // ギャラリーボタン
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/gallery');
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(AppColors.surfaceColor),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Color(AppColors.primaryBlue),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.photo_library,
                        color: Color(AppColors.primaryText),
                        size: 24,
                      ),
                    ),
                  ),

                  // シャッターボタン
                  ShutterButton(
                    onPressed: _takePicture,
                    size: Constants.shutterButtonSize,
                  ),

                  // 設定ボタン
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(AppColors.surfaceColor),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Color(AppColors.primaryBlue),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.settings,
                        color: Color(AppColors.primaryText),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
