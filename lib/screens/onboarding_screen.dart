import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/app_providers.dart';
import '../utils/constants.dart';
import '../widgets/onboarding_page.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final bool isFromSettings;

  const OnboardingScreen({Key? key, this.isFromSettings = false})
    : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int _currentPage = 0;
  static const int _totalPages = 3;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    _fadeController = AnimationController(
      duration: Constants.mediumAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: Constants.mediumAnimation,
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Constants.mediumAnimation,
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    _finishOnboarding();
  }

  void _finishOnboarding() {
    if (!widget.isFromSettings) {
      ref.read(settingsProvider.notifier).markOnboardingComplete();
    }

    Navigator.of(context).pushReplacementNamed('/camera');
  }

  Future<void> _requestPermissions() async {
    try {
      // カメラ権限
      final cameraStatus = await Permission.camera.request();

      // 写真ライブラリ権限
      final photosStatus = await Permission.photos.request();

      if (cameraStatus.isGranted && photosStatus.isGranted) {
        _showPermissionSuccess();
      } else {
        _showPermissionError();
      }
    } catch (e) {
      debugPrint('権限要求エラー: $e');
      _showPermissionError();
    }
  }

  void _showPermissionSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('権限が許可されました'),
        backgroundColor: Color(AppColors.successColor),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showPermissionError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('権限が必要です。設定から許可してください'),
        backgroundColor: Color(AppColors.errorColor),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '設定',
          textColor: Colors.white,
          onPressed: () => openAppSettings(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.backgroundColor),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // 背景グラデーション
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(AppColors.backgroundColor),
                    Color(AppColors.surfaceColor),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // ページビュー
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
                HapticFeedback.lightImpact();
              },
              children: [
                OnboardingPage(
                  title: 'DotCamへようこそ',
                  subtitle: 'ワンタップでゲーム風ドット絵を作成',
                  description: 'カメラで撮影した写真を\nレトロなドット絵に変換できます',
                  imagePath: 'assets/images/onboarding_1.png',
                  animation: _buildWelcomeAnimation(),
                ),
                OnboardingPage(
                  title: 'かんたん操作',
                  subtitle: '3ステップで完成',
                  description: '1. 写真を撮る\n2. 設定を調整\n3. 保存・共有',
                  imagePath: 'assets/images/onboarding_2.png',
                  animation: _buildStepsAnimation(),
                ),
                OnboardingPage(
                  title: '権限の許可',
                  subtitle: 'カメラと写真へのアクセス',
                  description: 'アプリを使用するために\n必要な権限を許可してください',
                  imagePath: 'assets/images/onboarding_3.png',
                  animation: _buildPermissionsAnimation(),
                  actionButton: _buildPermissionButton(),
                ),
              ],
            ),

            // 上部コントロール
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 戻るボタン（設定から来た場合のみ）
                  if (widget.isFromSettings)
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
                    )
                  else
                    const SizedBox(width: 40),

                  // ページインジケーター
                  Row(
                    children: List.generate(_totalPages, (index) {
                      return AnimatedContainer(
                        duration: Constants.shortAnimation,
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Color(AppColors.primaryBlue)
                              : Color(AppColors.dividerColor),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  // スキップボタン
                  if (!widget.isFromSettings && _currentPage < _totalPages - 1)
                    GestureDetector(
                      onTap: _skipOnboarding,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Color(AppColors.overlayDark),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'スキップ',
                          style: TextStyle(
                            color: Color(AppColors.primaryText),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 60),
                ],
              ),
            ),

            // 下部ナビゲーション
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 30,
              left: 30,
              right: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 前へボタン
                  if (_currentPage > 0)
                    GestureDetector(
                      onTap: _previousPage,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(AppColors.surfaceColor),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Color(AppColors.dividerColor),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: Color(AppColors.primaryText),
                          size: 24,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 56),

                  // 次へ・完了ボタン
                  GestureDetector(
                    onTap: _nextPage,
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
                            blurRadius: 12,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage == _totalPages - 1 ? '開始' : '次へ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentPage == _totalPages - 1
                                ? Icons.check
                                : Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeAnimation() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.5 + (value * 0.5),
          child: Opacity(
            opacity: value,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(AppColors.primaryBlue),
                    Color(AppColors.primaryPurple),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(AppColors.primaryBlue).withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 80, color: Colors.white),
                  // 回転するドット絵フレーム
                  Transform.rotate(
                    angle: value * 2 * 3.14159,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepsAnimation() {
    return Column(
      children: [
        _buildStepItem(1, 'カメラで撮影', Icons.camera_alt, 0),
        const SizedBox(height: 20),
        _buildStepItem(2, '設定を調整', Icons.tune, 500),
        const SizedBox(height: 20),
        _buildStepItem(3, '保存・共有', Icons.share, 1000),
      ],
    );
  }

  Widget _buildStepItem(int step, String title, IconData icon, int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + delay),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(AppColors.surfaceColor),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(AppColors.primaryBlue).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(AppColors.primaryBlue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        step.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Color(AppColors.primaryText),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(icon, color: Color(AppColors.primaryBlue), size: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPermissionsAnimation() {
    return Column(
      children: [
        _buildPermissionItem('カメラ', Icons.camera_alt, 'アプリの中心機能です'),
        const SizedBox(height: 16),
        _buildPermissionItem('写真', Icons.photo_library, '作成した画像を保存します'),
      ],
    );
  }

  Widget _buildPermissionItem(String title, IconData icon, String description) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (value * 0.2),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(AppColors.surfaceColor),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color(AppColors.primaryBlue).withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(AppColors.primaryBlue).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      icon,
                      color: Color(AppColors.primaryBlue),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      color: Color(AppColors.primaryText),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      color: Color(AppColors.secondaryText),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPermissionButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: GestureDetector(
        onTap: _requestPermissions,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
                color: Color(AppColors.primaryBlue).withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.security, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                '権限を許可',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
