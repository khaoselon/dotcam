import 'dart:typed_data';
import 'dart:isolate';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// 変換スタイル
enum ConversionStyle {
  anime, // アニメ風
  cartoon, // カートゥーン風
  manga, // 漫画風
  chibi, // ちび風
  realistic, // リアル調整
  dotArt, // ドット絵
}

/// 実用的なアニメ風変換サービス
/// 既存の image パッケージのみを使用した高品質フィルター実装
class AnimeConverter {
  static const int _maxConcurrentTasks = 2;
  int _activeTasks = 0;

  /// メイン変換メソッド
  Future<Uint8List> convertToAnime({
    required Uint8List imageBytes,
    required ConversionStyle style,
    Map<String, dynamic>? options,
    void Function(double)? onProgress,
  }) async {
    if (_activeTasks >= _maxConcurrentTasks) {
      throw Exception('変換処理が混雑しています。しばらくお待ちください。');
    }

    _activeTasks++;

    try {
      onProgress?.call(0.1);

      final result = await compute(_convertAnimeIsolate, {
        'imageBytes': imageBytes,
        'style': style.index,
        'options': options ?? {},
      });

      onProgress?.call(1.0);
      return result;
    } finally {
      _activeTasks--;
    }
  }

  /// Isolateでの変換処理
  static Future<Uint8List> _convertAnimeIsolate(
    Map<String, dynamic> params,
  ) async {
    final Uint8List imageBytes = params['imageBytes'];
    final int styleIndex = params['style'];
    final Map<String, dynamic> options = params['options'];
    final ConversionStyle style = ConversionStyle.values[styleIndex];

    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('画像の読み込みに失敗しました');
    }

    // スタイル別変換
    switch (style) {
      case ConversionStyle.anime:
        image = await _convertToAnimeStyle(image, options);
        break;
      case ConversionStyle.cartoon:
        image = await _convertToCartoonStyle(image, options);
        break;
      case ConversionStyle.manga:
        image = await _convertToMangaStyle(image, options);
        break;
      case ConversionStyle.chibi:
        image = await _convertToChibiStyle(image, options);
        break;
      case ConversionStyle.realistic:
        image = await _convertToRealisticStyle(image, options);
        break;
      case ConversionStyle.dotArt:
        image = await _convertToDotArtStyle(image, options);
        break;
    }

    return Uint8List.fromList(img.encodePng(image));
  }

  /// アニメ風変換
  static Future<img.Image> _convertToAnimeStyle(
    img.Image image,
    Map<String, dynamic> options,
  ) async {
    // 1. 前処理とリサイズ
    image = _preprocessImage(image);

    // 2. 肌質改善
    image = _applySkinSmoothing(image, intensity: 0.6);

    // 3. 色彩調整（アニメ調）
    image = _enhanceAnimeColors(image);

    // 4. 目と髪の強調
    image = _enhanceFacialFeatures(image);

    // 5. 輪郭とディテール
    image = _enhanceEdgesSelective(image);

    // 6. 最終調整
    image = _finalAnimeAdjustments(image);

    return image;
  }

  /// カートゥーン風変換
  static Future<img.Image> _convertToCartoonStyle(
    img.Image image,
    Map<String, dynamic> options,
  ) async {
    image = _preprocessImage(image);

    // 1. 強いブラー
    image = img.gaussianBlur(image, radius: 4);

    // 2. 色数削減
    image = _quantizeColors(image, 32);

    // 3. 輪郭強調
    image = _enhanceEdges(image, strength: 1.5);

    // 4. コントラスト強化
    image = img.adjustColor(image, contrast: 1.4, saturation: 1.3);

    return image;
  }

  /// 漫画風変換
  static Future<img.Image> _convertToMangaStyle(
    img.Image image,
    Map<String, dynamic> options,
  ) async {
    image = _preprocessImage(image);

    // 1. グレースケール変換
    image = img.grayscale(image);

    // 2. コントラスト強化
    image = img.adjustColor(image, contrast: 2.2);

    // 3. ハーフトーン風効果
    image = _applyHalftoneEffect(image);

    // 4. エッジ強調
    image = _enhanceEdges(image, strength: 2.0);

    return image;
  }

  /// ちび風変換
  static Future<img.Image> _convertToChibiStyle(
    img.Image image,
    Map<String, dynamic> options,
  ) async {
    image = _preprocessImage(image);

    // 1. 軽いブラー
    image = img.gaussianBlur(image, radius: 2);

    // 2. パステル調色彩
    image = _applyPastelColors(image);

    // 3. 可愛らしさ強調
    image = _enhanceCuteness(image);

    // 4. 軽い量子化
    image = _quantizeColors(image, 64);

    return image;
  }

  /// リアル調整版
  static Future<img.Image> _convertToRealisticStyle(
    img.Image image,
    Map<String, dynamic> options,
  ) async {
    image = _preprocessImage(image);

    // 1. ノイズ除去
    image = img.gaussianBlur(image, radius: 1);

    // 2. 美肌効果
    image = _applySkinSmoothing(image, intensity: 0.3);

    // 3. シャープネス強化
    image = img.convolution(image, [0, -1, 0, -1, 5, -1, 0, -1, 0]);

    // 4. 色彩補正
    image = img.adjustColor(image, brightness: 0.05, contrast: 1.1);

    return image;
  }

  /// ドット絵風変換
  static Future<img.Image> _convertToDotArtStyle(
    img.Image image,
    Map<String, dynamic> options,
  ) async {
    final resolution = options['resolution'] ?? 64;

    // 1. ダウンサンプリング
    final aspectRatio = image.width / image.height;
    int width, height;

    if (aspectRatio > 1.0) {
      width = resolution;
      height = (resolution / aspectRatio).round();
    } else {
      height = resolution;
      width = (resolution * aspectRatio).round();
    }

    image = img.copyResize(
      image,
      width: width,
      height: height,
      interpolation: img.Interpolation.nearest,
    );

    // 2. 色数削減
    image = _quantizeColors(image, 16);

    // 3. アップスケール
    final scale = 512 ~/ math.max(width, height);
    image = img.copyResize(
      image,
      width: width * scale,
      height: height * scale,
      interpolation: img.Interpolation.nearest,
    );

    return image;
  }

  /// 前処理
  static img.Image _preprocessImage(img.Image image) {
    // 適切なサイズにリサイズ
    const maxSize = 1024;
    if (image.width > maxSize || image.height > maxSize) {
      final scale = math.min(maxSize / image.width, maxSize / image.height);
      final newWidth = (image.width * scale).round();
      final newHeight = (image.height * scale).round();
      image = img.copyResize(image, width: newWidth, height: newHeight);
    }

    return image;
  }

  /// 肌質改善
  static img.Image _applySkinSmoothing(
    img.Image image, {
    double intensity = 0.5,
  }) {
    // ガウシアンブラーを適用
    final blurred = img.gaussianBlur(image, radius: (3 * intensity).round());

    // 肌色領域でのみブラーを適用
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final originalPixel = image.getPixel(x, y);
        final blurredPixel = blurred.getPixel(x, y);

        if (_isSkinColor(originalPixel)) {
          // 肌色の場合はブラー効果を適用
          final mixRatio = intensity;
          final newR = _lerp(originalPixel.r, blurredPixel.r, mixRatio);
          final newG = _lerp(originalPixel.g, blurredPixel.g, mixRatio);
          final newB = _lerp(originalPixel.b, blurredPixel.b, mixRatio);

          image.setPixel(
            x,
            y,
            img.ColorRgb8(
              newR.round().clamp(0, 255),
              newG.round().clamp(0, 255),
              newB.round().clamp(0, 255),
            ),
          );
        }
      }
    }

    return image;
  }

  /// アニメ調色彩強化
  static img.Image _enhanceAnimeColors(img.Image image) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final hsv = _rgbToHsv(pixel.r, pixel.g, pixel.b);

        // 彩度を上げる
        hsv[1] = math.min(hsv[1] * 1.3, 1.0);

        // 明度調整
        hsv[2] = math.min(hsv[2] * 1.1, 1.0);

        // 色相の微調整（アニメ調）
        if (hsv[0] >= 300 || hsv[0] <= 60) {
          // 赤～黄色系
          hsv[1] = math.min(hsv[1] * 1.2, 1.0);
        }

        final rgb = _hsvToRgb(hsv[0], hsv[1], hsv[2]);
        image.setPixel(x, y, img.ColorRgb8(rgb[0], rgb[1], rgb[2]));
      }
    }

    return image;
  }

  /// 顔の特徴強調
  static img.Image _enhanceFacialFeatures(img.Image image) {
    // シンプルな顔特徴強調（目と髪の色を強調）
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);

        if (_isEyeColor(pixel) || _isHairColor(pixel)) {
          // 目や髪の色を強調
          final newR = math.min(pixel.r * 1.2, 255).round();
          final newG = math.min(pixel.g * 1.2, 255).round();
          final newB = math.min(pixel.b * 1.2, 255).round();

          image.setPixel(x, y, img.ColorRgb8(newR, newG, newB));
        }
      }
    }

    return image;
  }

  /// 選択的エッジ強調
  static img.Image _enhanceEdgesSelective(img.Image image) {
    final edges = img.sobel(image);

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final originalPixel = image.getPixel(x, y);
        final edgePixel = edges.getPixel(x, y);

        final edgeStrength =
            (edgePixel.r + edgePixel.g + edgePixel.b) / 3 / 255;

        if (edgeStrength > 0.2) {
          // エッジ部分をわずかに暗く
          final factor = 0.9;
          final newR = (originalPixel.r * factor).round().clamp(0, 255);
          final newG = (originalPixel.g * factor).round().clamp(0, 255);
          final newB = (originalPixel.b * factor).round().clamp(0, 255);

          image.setPixel(x, y, img.ColorRgb8(newR, newG, newB));
        }
      }
    }

    return image;
  }

  /// 最終アニメ調整
  static img.Image _finalAnimeAdjustments(img.Image image) {
    // 軽い色数削減
    image = _quantizeColors(image, 200);

    // 最終コントラスト調整
    image = img.adjustColor(image, contrast: 1.15, brightness: 0.05);

    return image;
  }

  /// エッジ強調
  static img.Image _enhanceEdges(img.Image image, {double strength = 1.0}) {
    final kernel = [
      0,
      -1 * strength,
      0,
      -1 * strength,
      4 * strength + 1,
      -1 * strength,
      0,
      -1 * strength,
      0,
    ];

    return img.convolution(image, kernel);
  }

  /// 色数削減
  static img.Image _quantizeColors(img.Image image, int colorCount) {
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

  /// パステル調色彩
  static img.Image _applyPastelColors(img.Image image) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);

        // パステル調に調整
        final newR = (pixel.r * 0.8 + 255 * 0.2).round().clamp(0, 255);
        final newG = (pixel.g * 0.8 + 255 * 0.2).round().clamp(0, 255);
        final newB = (pixel.b * 0.8 + 255 * 0.2).round().clamp(0, 255);

        image.setPixel(x, y, img.ColorRgb8(newR, newG, newB));
      }
    }

    return image;
  }

  /// 可愛らしさ強調
  static img.Image _enhanceCuteness(img.Image image) {
    // 暖色系を強調
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final hsv = _rgbToHsv(pixel.r, pixel.g, pixel.b);

        // ピンク系の色相を強調
        if ((hsv[0] >= 300 && hsv[0] <= 360) || (hsv[0] >= 0 && hsv[0] <= 60)) {
          hsv[1] = math.min(hsv[1] * 1.4, 1.0);
          hsv[2] = math.min(hsv[2] * 1.1, 1.0);
        }

        final rgb = _hsvToRgb(hsv[0], hsv[1], hsv[2]);
        image.setPixel(x, y, img.ColorRgb8(rgb[0], rgb[1], rgb[2]));
      }
    }

    return image;
  }

  /// ハーフトーン効果
  static img.Image _applyHalftoneEffect(img.Image image) {
    for (int y = 0; y < image.height; y += 4) {
      for (int x = 0; x < image.width; x += 4) {
        if (x + 4 <= image.width && y + 4 <= image.height) {
          // 4x4ブロックの平均値を計算
          int totalR = 0, totalG = 0, totalB = 0;
          for (int dy = 0; dy < 4; dy++) {
            for (int dx = 0; dx < 4; dx++) {
              final pixel = image.getPixel(x + dx, y + dy);
              totalR += pixel.r.toInt();
              totalG += pixel.g.toInt();
              totalB += pixel.b.toInt();
            }
          }

          final avgR = totalR ~/ 16;
          final avgG = totalG ~/ 16;
          final avgB = totalB ~/ 16;

          // ブロック全体を平均値で塗りつぶし
          for (int dy = 0; dy < 4; dy++) {
            for (int dx = 0; dx < 4; dx++) {
              image.setPixel(x + dx, y + dy, img.ColorRgb8(avgR, avgG, avgB));
            }
          }
        }
      }
    }

    return image;
  }

  // ユーティリティメソッド
  static bool _isSkinColor(img.Pixel pixel) {
    final r = pixel.r.toInt();
    final g = pixel.g.toInt();
    final b = pixel.b.toInt();

    return r > 95 && g > 40 && b > 20 && (r - g).abs() > 15 && r > g && r > b;
  }

  static bool _isEyeColor(img.Pixel pixel) {
    final r = pixel.r.toInt();
    final g = pixel.g.toInt();
    final b = pixel.b.toInt();

    // 暗い色（目）の判定
    return r < 100 && g < 100 && b < 100;
  }

  static bool _isHairColor(img.Pixel pixel) {
    final r = pixel.r.toInt();
    final g = pixel.g.toInt();
    final b = pixel.b.toInt();

    // 髪色の判定（暗い色または茶色系）
    return (r < 150 && g < 150 && b < 150) || (r > g && r > b && g > b); // 茶色系
  }

  static double _lerp(num a, num b, double t) {
    return a + (b - a) * t;
  }

  static List<double> _rgbToHsv(num r, num g, num b) {
    final rNorm = r / 255.0;
    final gNorm = g / 255.0;
    final bNorm = b / 255.0;

    final max = math.max(math.max(rNorm, gNorm), bNorm);
    final min = math.min(math.min(rNorm, gNorm), bNorm);
    final delta = max - min;

    double h = 0;
    if (delta != 0) {
      if (max == rNorm) {
        h = 60 * (((gNorm - bNorm) / delta) % 6);
      } else if (max == gNorm) {
        h = 60 * (((bNorm - rNorm) / delta) + 2);
      } else {
        h = 60 * (((rNorm - gNorm) / delta) + 4);
      }
    }

    final s = max == 0 ? 0.0 : delta / max;
    final v = max;

    return [h, s, v];
  }

  static List<int> _hsvToRgb(double h, double s, double v) {
    final c = v * s;
    final x = c * (1 - ((h / 60) % 2 - 1).abs());
    final m = v - c;

    double r = 0, g = 0, b = 0;

    if (h < 60) {
      r = c;
      g = x;
      b = 0;
    } else if (h < 120) {
      r = x;
      g = c;
      b = 0;
    } else if (h < 180) {
      r = 0;
      g = c;
      b = x;
    } else if (h < 240) {
      r = 0;
      g = x;
      b = c;
    } else if (h < 300) {
      r = x;
      g = 0;
      b = c;
    } else {
      r = c;
      g = 0;
      b = x;
    }

    return [
      ((r + m) * 255).round(),
      ((g + m) * 255).round(),
      ((b + m) * 255).round(),
    ];
  }
}
