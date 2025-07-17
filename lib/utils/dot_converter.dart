import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:isolate';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

// 新しい変換スタイル enum
enum ConversionStyle {
  anime, // アニメ風（メイン機能）
  cartoon, // カートゥーン風
  manga, // 漫画風（モノクロ）
  chibi, // ちび・デフォルメ風
  realistic, // リアル調整版
  dotArt, // 従来のドット絵
}

extension ConversionStyleExtension on ConversionStyle {
  String get displayName {
    switch (this) {
      case ConversionStyle.anime:
        return 'アニメ風';
      case ConversionStyle.cartoon:
        return 'カートゥーン';
      case ConversionStyle.manga:
        return '漫画風';
      case ConversionStyle.chibi:
        return 'ちび風';
      case ConversionStyle.realistic:
        return 'リアル調整';
      case ConversionStyle.dotArt:
        return 'ドット絵';
    }
  }

  String get description {
    switch (this) {
      case ConversionStyle.anime:
        return '日本アニメ風の美麗な仕上がり';
      case ConversionStyle.cartoon:
        return '西洋カートゥーン風のポップな仕上がり';
      case ConversionStyle.manga:
        return '漫画風のモノクロ・トーン処理';
      case ConversionStyle.chibi:
        return 'デフォルメ強化でかわいい仕上がり';
      case ConversionStyle.realistic:
        return '写真の品質向上・美肌効果';
      case ConversionStyle.dotArt:
        return 'レトロなピクセルアート風';
    }
  }

  IconData get icon {
    switch (this) {
      case ConversionStyle.anime:
        return Icons.face;
      case ConversionStyle.cartoon:
        return Icons.emoji_emotions;
      case ConversionStyle.manga:
        return Icons.auto_stories;
      case ConversionStyle.chibi:
        return Icons.child_friendly;
      case ConversionStyle.realistic:
        return Icons.photo_camera;
      case ConversionStyle.dotArt:
        return Icons.grid_on;
    }
  }

  Color get themeColor {
    switch (this) {
      case ConversionStyle.anime:
        return Colors.pink;
      case ConversionStyle.cartoon:
        return Colors.orange;
      case ConversionStyle.manga:
        return Colors.blueGrey;
      case ConversionStyle.chibi:
        return Colors.purple;
      case ConversionStyle.realistic:
        return Colors.green;
      case ConversionStyle.dotArt:
        return Colors.blue;
    }
  }

  bool get requiresAI {
    switch (this) {
      case ConversionStyle.anime:
      case ConversionStyle.cartoon:
        return true; // AI推奨
      case ConversionStyle.manga:
      case ConversionStyle.chibi:
      case ConversionStyle.realistic:
      case ConversionStyle.dotArt:
        return false; // フィルターで対応可能
    }
  }

  List<String> get availableOptions {
    switch (this) {
      case ConversionStyle.anime:
        return ['肌質調整', '目の強調', '髪の質感', '色彩強化'];
      case ConversionStyle.cartoon:
        return ['輪郭強調', '色数削減', 'ポップ調整'];
      case ConversionStyle.manga:
        return ['コントラスト', 'スクリーントーン', 'モノクロ調整'];
      case ConversionStyle.chibi:
        return ['デフォルメ度', '可愛さ強調', 'パステル調整'];
      case ConversionStyle.realistic:
        return ['美肌効果', 'シャープネス', 'ノイズ除去'];
      case ConversionStyle.dotArt:
        return ['解像度', 'ディザリング', 'パレット'];
    }
  }
}

// 拡張されたカラーパレット
enum ColorPalette {
  adaptive, // 自動抽出
  original, // 元画像
  anime, // アニメ調パレット
  pastel, // パステル調
  vibrant, // ビビッド
  vintage, // ビンテージ
  gameboy, // ゲームボーイ
  manga, // 漫画用モノクロ
  custom, // カスタム
}

extension ColorPaletteExtension on ColorPalette {
  String get displayName {
    switch (this) {
      case ColorPalette.adaptive:
        return '自動抽出';
      case ColorPalette.original:
        return '元画像';
      case ColorPalette.anime:
        return 'アニメ調';
      case ColorPalette.pastel:
        return 'パステル';
      case ColorPalette.vibrant:
        return 'ビビッド';
      case ColorPalette.vintage:
        return 'ビンテージ';
      case ColorPalette.gameboy:
        return 'レトロ';
      case ColorPalette.manga:
        return 'モノクロ';
      case ColorPalette.custom:
        return 'カスタム';
    }
  }

  List<int> get colors {
    switch (this) {
      case ColorPalette.adaptive:
        return [0xFF000000, 0xFF404040, 0xFF808080, 0xFFC0C0C0, 0xFFFFFFFF];
      case ColorPalette.original:
        return [
          0xFF000000,
          0xFF333333,
          0xFF666666,
          0xFF999999,
          0xFFCCCCCC,
          0xFFFFFFFF,
        ];
      case ColorPalette.anime:
        return [
          0xFFFFE4E1, // 薄いピンク（肌色）
          0xFFFFB6C1, // ライトピンク
          0xFF87CEEB, // スカイブルー
          0xFF98FB98, // ライトグリーン
          0xFFDDA0DD, // プラム
          0xFFFFDAB9, // ピーチパフ
          0xFF000000, // 黒
          0xFFFFFFFF, // 白
        ];
      case ColorPalette.pastel:
        return [
          0xFFFFB3BA,
          0xFFFFDFBA,
          0xFFFFFFBA,
          0xFFBAFFBA,
          0xFFBAFFFF,
          0xFFBABAFF,
          0xFFFFBAFF,
          0xFFFFFFFF,
        ];
      case ColorPalette.vibrant:
        return [
          0xFFFF0000,
          0xFFFF8000,
          0xFFFFFF00,
          0xFF80FF00,
          0xFF00FF00,
          0xFF00FF80,
          0xFF00FFFF,
          0xFF0080FF,
        ];
      case ColorPalette.vintage:
        return [
          0xFF8B4513,
          0xFFCD853F,
          0xFFDAA520,
          0xFFBDB76B,
          0xFF9ACD32,
          0xFF6B8E23,
          0xFF556B2F,
          0xFF2F4F4F,
        ];
      case ColorPalette.gameboy:
        return [0xFF0F380F, 0xFF306230, 0xFF8BAC0F, 0xFF9BBB0F];
      case ColorPalette.manga:
        return [0xFF000000, 0xFF404040, 0xFF808080, 0xFFFFFFFF];
      case ColorPalette.custom:
        return [
          0xFF000000,
          0xFF333333,
          0xFF666666,
          0xFF999999,
          0xFFCCCCCC,
          0xFFFFFFFF,
        ];
    }
  }

  bool get isMonochrome {
    return this == ColorPalette.manga;
  }

  bool get isAdaptive {
    return this == ColorPalette.adaptive || this == ColorPalette.original;
  }
}

/// ドット絵変換クラス
class DotConverter {
  static const int _maxConcurrentTasks = 2;
  int _activeTasks = 0;

  /// メインのドット絵変換メソッド
  Future<Uint8List> convertToDot({
    required Uint8List imageBytes,
    required Map<String, dynamic> settings,
    void Function(double)? onProgress,
  }) async {
    if (_activeTasks >= _maxConcurrentTasks) {
      throw Exception('変換処理が混雑しています。しばらくお待ちください。');
    }

    _activeTasks++;

    try {
      onProgress?.call(0.1);

      final result = await compute(_convertDotIsolate, {
        'imageBytes': imageBytes,
        'settings': settings,
      });

      onProgress?.call(1.0);
      return result;
    } finally {
      _activeTasks--;
    }
  }

  /// Isolateでのドット絵変換処理
  static Future<Uint8List> _convertDotIsolate(
    Map<String, dynamic> params,
  ) async {
    final Uint8List imageBytes = params['imageBytes'];
    final Map<String, dynamic> settings = params['settings'];

    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('画像の読み込みに失敗しました');
    }

    final resolution = settings['resolution'] ?? 64;
    final brightness = settings['brightness']?.toDouble() ?? 1.1;
    final contrast = settings['contrast']?.toDouble() ?? 1.2;
    final saturation = settings['saturation']?.toDouble() ?? 1.3;
    final smoothing = settings['smoothing']?.toDouble() ?? 0.5;
    final ditheringEnabled = settings['ditheringEnabled'] ?? false;
    final paletteIndex = settings['palette'] ?? 0;
    final customColors = settings['customColors'];

    // 1. 前処理
    image = _preprocessImage(image, smoothing);

    // 2. 解像度調整（ダウンサンプリング）
    image = _resizeToPixelArt(image, resolution);

    // 3. 色彩調整
    image = _adjustColors(image, brightness, contrast, saturation);

    // 4. カラーパレット適用
    final palette = ColorPalette.values[paletteIndex];
    final colors = customColors != null
        ? List<int>.from(customColors)
        : palette.colors;

    if (palette.isAdaptive) {
      // 適応的パレットの場合は元画像から色を抽出
      image = _quantizeToNearestColors(image, colors.length);
    } else {
      // 固定パレットの場合は最近接色にマッピング
      image = _mapToFixedPalette(image, colors);
    }

    // 5. ディザリング（オプション）
    if (ditheringEnabled) {
      image = _applyDithering(image, colors);
    }

    // 6. エッジ強調
    image = _enhanceEdges(image);

    // 7. 最終アップスケール
    image = _upscalePixelArt(image);

    return Uint8List.fromList(img.encodePng(image));
  }

  /// 前処理
  static img.Image _preprocessImage(img.Image image, double smoothing) {
    // 適切なサイズにリサイズ（処理負荷軽減）
    const maxSize = 1024;
    if (image.width > maxSize || image.height > maxSize) {
      final scale = math.min(maxSize / image.width, maxSize / image.height);
      final newWidth = (image.width * scale).round();
      final newHeight = (image.height * scale).round();
      image = img.copyResize(image, width: newWidth, height: newHeight);
    }

    // スムージング
    if (smoothing > 0) {
      image = img.gaussianBlur(image, radius: smoothing.round());
    }

    return image;
  }

  /// ピクセルアート解像度にリサイズ
  static img.Image _resizeToPixelArt(img.Image image, int resolution) {
    final aspectRatio = image.width / image.height;
    int width, height;

    if (aspectRatio > 1.0) {
      width = resolution;
      height = (resolution / aspectRatio).round();
    } else {
      height = resolution;
      width = (resolution * aspectRatio).round();
    }

    // ニアレストネイバー補間でリサイズ
    return img.copyResize(
      image,
      width: width,
      height: height,
      interpolation: img.Interpolation.nearest,
    );
  }

  /// 色彩調整
  static img.Image _adjustColors(
    img.Image image,
    double brightness,
    double contrast,
    double saturation,
  ) {
    return img.adjustColor(
      image,
      brightness: brightness - 1.0,
      contrast: contrast,
      saturation: saturation,
    );
  }

  /// 最近接色マッピング
  static img.Image _mapToFixedPalette(img.Image image, List<int> palette) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final nearestColor = _findNearestColor(pixel, palette);
        image.setPixel(x, y, nearestColor);
      }
    }
    return image;
  }

  /// 最近接色を見つける
  static img.Color _findNearestColor(img.Pixel pixel, List<int> palette) {
    double minDistance = double.infinity;
    int nearestColor = palette.first;

    for (final colorValue in palette) {
      final color = img.ColorRgb8(
        (colorValue >> 16) & 0xFF,
        (colorValue >> 8) & 0xFF,
        colorValue & 0xFF,
      );

      final distance = _colorDistance(pixel, color);
      if (distance < minDistance) {
        minDistance = distance;
        nearestColor = colorValue;
      }
    }

    return img.ColorRgb8(
      (nearestColor >> 16) & 0xFF,
      (nearestColor >> 8) & 0xFF,
      nearestColor & 0xFF,
    );
  }

  /// 色距離計算
  static double _colorDistance(img.Pixel a, img.Color b) {
    final dr = a.r - b.r;
    final dg = a.g - b.g;
    final db = a.b - b.b;
    return math.sqrt(dr * dr + dg * dg + db * db);
  }

  /// 色数削減（量子化）
  static img.Image _quantizeToNearestColors(img.Image image, int colorCount) {
    final factor = 256 / colorCount;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);

        final newR = ((pixel.r ~/ factor) * factor).clamp(0, 255).toInt();
        final newG = ((pixel.g ~/ factor) * factor).clamp(0, 255).toInt();
        final newB = ((pixel.b ~/ factor) * factor).clamp(0, 255).toInt();

        image.setPixel(x, y, img.ColorRgb8(newR, newG, newB));
      }
    }

    return image;
  }

  /// ディザリング適用
  static img.Image _applyDithering(img.Image image, List<int> palette) {
    // Floyd-Steinbergディザリング
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final oldPixel = image.getPixel(x, y);
        final newPixel = _findNearestColor(oldPixel, palette);

        image.setPixel(x, y, newPixel);

        // 誤差を周囲のピクセルに分散
        final errorR = oldPixel.r - newPixel.r;
        final errorG = oldPixel.g - newPixel.g;
        final errorB = oldPixel.b - newPixel.b;

        _distributeError(image, x + 1, y, errorR, errorG, errorB, 7 / 16);
        _distributeError(image, x - 1, y + 1, errorR, errorG, errorB, 3 / 16);
        _distributeError(image, x, y + 1, errorR, errorG, errorB, 5 / 16);
        _distributeError(image, x + 1, y + 1, errorR, errorG, errorB, 1 / 16);
      }
    }

    return image;
  }

  /// 誤差分散
  static void _distributeError(
    img.Image image,
    int x,
    int y,
    num errorR,
    num errorG,
    num errorB,
    double factor,
  ) {
    if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
      final pixel = image.getPixel(x, y);
      final newR = (pixel.r + errorR * factor).clamp(0, 255).round();
      final newG = (pixel.g + errorG * factor).clamp(0, 255).round();
      final newB = (pixel.b + errorB * factor).clamp(0, 255).round();

      image.setPixel(x, y, img.ColorRgb8(newR, newG, newB));
    }
  }

  /// エッジ強調
  static img.Image _enhanceEdges(img.Image image) {
    final result = img.Image(width: image.width, height: image.height);

    // シャープニングカーネル
    final kernel = [0, -1, 0, -1, 5, -1, 0, -1, 0];
    const kernelSize = 3;
    const offset = kernelSize ~/ 2;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        double sumR = 0, sumG = 0, sumB = 0;

        for (int ky = 0; ky < kernelSize; ky++) {
          for (int kx = 0; kx < kernelSize; kx++) {
            final px = (x + kx - offset).clamp(0, image.width - 1);
            final py = (y + ky - offset).clamp(0, image.height - 1);

            final pixel = image.getPixel(px, py);
            final kernelValue = kernel[ky * kernelSize + kx];

            sumR += pixel.r * kernelValue;
            sumG += pixel.g * kernelValue;
            sumB += pixel.b * kernelValue;
          }
        }

        result.setPixel(
          x,
          y,
          img.ColorRgb8(
            sumR.round().clamp(0, 255),
            sumG.round().clamp(0, 255),
            sumB.round().clamp(0, 255),
          ),
        );
      }
    }

    return result;
  }

  /// ピクセルアートアップスケール
  static img.Image _upscalePixelArt(img.Image image) {
    // 適切なスケールファクターを計算
    const targetSize = 512;
    final scale = math.max(
      1,
      targetSize ~/ math.max(image.width, image.height),
    );

    return img.copyResize(
      image,
      width: image.width * scale,
      height: image.height * scale,
      interpolation: img.Interpolation.nearest,
    );
  }
}
