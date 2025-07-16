import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/camera_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/onboarding_screen.dart';
import 'providers/app_providers.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // AdMob初期化
  await MobileAds.instance.initialize();

  // 画面向き固定（縦向きのみ）
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'DotCam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'PixelFont',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'PixelFont',
      ),
      themeMode: themeMode,
      home: AppInitializer(),
      routes: {
        '/camera': (context) => CameraScreen(),
        '/gallery': (context) => GalleryScreen(),
        '/settings': (context) => SettingsScreen(),
        '/onboarding': (context) => OnboardingScreen(),
      },
    );
  }
}

class AppInitializer extends ConsumerStatefulWidget {
  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // アプリ初回起動チェック
      final isFirstLaunch = ref.read(settingsProvider).isFirstLaunch;

      if (isFirstLaunch) {
        // 初回起動時の権限許可とオンボーディング
        await _requestPermissions();
        Navigator.of(context).pushReplacementNamed('/onboarding');
      } else {
        // トラッキング許可の確認（適切なタイミングで表示）
        await _checkTrackingPermission();
        Navigator.of(context).pushReplacementNamed('/camera');
      }
    } catch (e) {
      // エラーハンドリング
      debugPrint('初期化エラー: $e');
      Navigator.of(context).pushReplacementNamed('/camera');
    } finally {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    // カメラ権限
    await Permission.camera.request();

    // 写真ライブラリ権限
    await Permission.photos.request();

    // 通知権限（将来の機能拡張用）
    await Permission.notification.request();
  }

  Future<void> _checkTrackingPermission() async {
    // iOS 14.5+でアプリトラッキング許可
    // 他のポップアップと重複しないよう、適切なタイミングで表示
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;

    if (status == TrackingStatus.notDetermined) {
      // ユーザーがアプリに慣れてから表示
      await Future.delayed(Duration(seconds: 2));
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // アプリロゴ
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(Icons.camera_alt, size: 60, color: Colors.white),
              ),
              SizedBox(height: 30),
              Text(
                'DotCam',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'ワンタップでゲーム風ドット絵へ',
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
              SizedBox(height: 50),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ],
          ),
        ),
      );
    }

    return Container(); // 初期化完了後は他の画面に遷移するため空コンテナ
  }
}

class MainTabScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(tabIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [CameraScreen(), GalleryScreen(), SettingsScreen()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(tabIndexProvider.notifier).state = index;
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'カメラ'),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'ギャラリー',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
        ],
      ),
    );
  }
}
