import 'dart:io';

class Constants {
  // アプリ情報
  static const String appName = 'DotCam';
  static const String appVersion = '1.0.0';

  // AdMob テストID
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // テスト用バナー広告ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // テスト用バナー広告ID
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // テスト用インタースティシャル広告ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // テスト用インタースティシャル広告ID
    }
    return '';
  }

  // 画像設定
  static const int maxImageSize = 2048; // 最大画像サイズ
  static const int minResolution = 16; // 最小ドット解像度
  static const int maxResolution = 128; // 最大ドット解像度
  static const List<int> resolutionOptions = [16, 24, 32, 48, 64, 96, 128];

  // ファイルパス
  static const String imagesFolder = 'DotCam';
  static const String originalPrefix = 'original_';
  static const String dottedPrefix = 'dotted_';
  static const String comparePrefix = 'compare_';

  // UI設定
  static const double cornerRadius = 12.0;
  static const double buttonHeight = 48.0;
  static const double iconSize = 24.0;
  static const double previewAspectRatio = 4.0 / 3.0;

  // アニメーション設定
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // カメラ設定
  static const double shutterButtonSize = 80.0;
  static const double quickButtonSize = 44.0;

  // 広告設定
  static const int interstitialShowInterval = 5; // 5回撮影ごと
  static const Duration adLoadTimeout = Duration(seconds: 10);

  // 権限メッセージ
  static const String cameraPermissionMessage = 'カメラの使用を許可してください';
  static const String photosPermissionMessage = '写真ライブラリへのアクセスを許可してください';
  static const String trackingPermissionMessage = 'より良い体験のため、トラッキングを許可してください';

  // エラーメッセージ
  static const String cameraInitError = 'カメラの初期化に失敗しました';
  static const String imageProcessError = '画像の処理に失敗しました';
  static const String saveError = '画像の保存に失敗しました';
  static const String shareError = '共有に失敗しました';

  // 多言語対応
  static const Map<String, String> supportedLanguages = {
    'ja': '日本語',
    'en': 'English',
    'it': 'Italiano',
    'pt': 'Português',
    'es': 'Español',
    'de': 'Deutsch',
    'ko': '한국어',
    'zh': '繁體中文',
  };
}

class AppColors {
  // プライマリカラー
  static const int primaryBlue = 0xFF2196F3;
  static const int primaryPurple = 0xFF9C27B0;

  // グラデーション
  static const List<int> primaryGradient = [primaryBlue, primaryPurple];
  static const List<int> darkGradient = [0xFF1565C0, 0xFF7B1FA2];

  // UI カラー
  static const int backgroundColor = 0xFF000000;
  static const int surfaceColor = 0xFF1E1E1E;
  static const int cardColor = 0xFF2C2C2C;
  static const int dividerColor = 0xFF404040;

  // テキストカラー
  static const int primaryText = 0xFFFFFFFF;
  static const int secondaryText = 0xFFB0B0B0;
  static const int disabledText = 0xFF666666;

  // ステータスカラー
  static const int successColor = 0xFF4CAF50;
  static const int warningColor = 0xFFFF9800;
  static const int errorColor = 0xFFF44336;

  // オーバーレイ
  static const int overlayLight = 0x80000000;
  static const int overlayDark = 0xB3000000;
}

class AppStrings {
  // メイン画面
  static const String cameraTitle = 'カメラ';
  static const String galleryTitle = 'ギャラリー';
  static const String settingsTitle = '設定';

  // カメラ画面
  static const String takePhoto = '撮影';
  static const String switchCamera = 'カメラ切り替え';
  static const String flashAuto = '自動';
  static const String flashOn = 'オン';
  static const String flashOff = 'オフ';

  // プレビュー画面
  static const String save = '保存';
  static const String share = '共有';
  static const String retake = '再撮影';
  static const String originalImage = 'オリジナル';
  static const String dottedImage = 'ドット絵';

  // 設定画面
  static const String dotSettings = 'ドット絵設定';
  static const String resolution = '解像度';
  static const String colorPalette = 'カラーパレット';
  static const String dithering = 'ディザリング';
  static const String contrast = 'コントラスト';
  static const String brightness = '明度';

  static const String layoutSettings = 'レイアウト設定';
  static const String compareLayout = '比較レイアウト';
  static const String previewOpacity = 'プレビュー透明度';
  static const String showGrid = 'グリッド表示';

  static const String generalSettings = '一般設定';
  static const String autoSave = '自動保存';
  static const String saveLocation = '保存先';
  static const String language = '言語';
  static const String hapticFeedback = '触覚フィードバック';
  static const String soundEffects = '効果音';

  static const String aboutSettings = 'アプリについて';
  static const String version = 'バージョン';
  static const String tutorial = 'チュートリアル';
  static const String privacy = 'プライバシーポリシー';
  static const String terms = '利用規約';
}
