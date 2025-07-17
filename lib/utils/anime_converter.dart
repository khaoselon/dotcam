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

  /// Isolateでの変換処理（安全版）
  static Future<Uint8List> _convertAnimeIsolate(
    Map<String, dynamic> params,
  ) async {
    try {
      final Uint8List imageBytes = params['imageBytes'];
      final int styleIndex = params['style'];
      final Map<String, dynamic> options = params['options'];
      final ConversionStyle style = ConversionStyle.values[styleIndex];

      print('変換開始: ${style.toString()}'); // デバッグログ

      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('画像の読み込みに失敗しました');
      }

      print('画像サイズ: ${image.width}x${image.height}'); // デバッグログ

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

      print('変換完了'); // デバッグログ

      final result = Uint8List.fromList(img.encodePng(image));
      print('PNG出力完了: ${result.length} bytes'); // デバッグログ

      return result;
    } catch (e, stackTrace) {
      print('変換エラー: $e');
      print('スタックトレース: $stackTrace');

      // エラー時は元画像を軽く調整して返す
      try {
        final Uint8List imageBytes = params['imageBytes'];
        img.Image? image = img.decodeImage(imageBytes);
        if (image != null) {
          image = _safeImageAdjustment(image);
          return Uint8List.fromList(img.encodePng(image));
        }
      } catch (e2) {
        print('フォールバック処理もエラー: $e2');
      }

      // 最悪の場合は元画像をそのまま返す
      return params['imageBytes'];
    }
  }

  /// アニメ風変換
  static Future<img.Image> _convertToAnimeStyle(
    img.Image image,
    Map<String, dynamic> options,
  ) async {
    try {
      // 1. 前処理とリサイズ
      image = _preprocessImage(image);

      // 2. 軽い肌質改善（強度を下げる）
      image = _applySkinSmoothing(image, intensity: 0.3);

      // 3. 色彩調整（アニメ調）- パラメータを安全な範囲に
      image = _enhanceAnimeColors(image);

      // 4. 軽いエッジ強調
      image = _enhanceEdgesSelective(image);

      // 5. 最終調整（パラメータを控えめに）
      image = _finalAnimeAdjustments(image);

      return image;
    } catch (e) {
      print('アニメ風変換エラー: $e');
      // エラー時は元画像を軽く調整して返す
      return _safeImageAdjustment(image);
    }
  }

  /// カートゥーン風変換
  static Future<img.Image> _convertToCartoonStyle(
    img.Image image,
    Map<String, dynamic> options,
  ) async {
    try {
      image = _preprocessImage(image);

      // 1. 軽いブラー - intに変換
      image = img.gaussianBlur(image, radius: 2);

      // 2. 色数削減（控えめに）
      image = _quantizeColors(image, 64);

      // 3. 軽い輪郭強調
      image = _enhanceEdges(image, strength: 1.0);

      // 4. コントラスト強化（控えめに）
      image = img.adjustColor(image, contrast: 1.2, saturation: 1.1);

      return image;
    } catch (e) {
      print('カートゥーン風変換エラー: $e');
      return _safeImageAdjustment(image);
    }
  }

  /// 漫画風変換
  static Future<img.Image> _convertToMangaStyle(
    img.Image image,
    Map<String, dynamic> options,
  ) async {
    try {
      image = _preprocessImage(image);

      // 1. グレースケール変換
      image = img.grayscale(image);

      // 2. コントラスト強化（控えめに）
      image = img.adjustColor(image, contrast: 1.8);

      // 3. ハーフトーン風効果
      image = _applyHalftoneEffect(image);

      // 4. エッジ強調
      image = _enhanceEdges(image, strength: 1.5);

      return image;
    } catch (e) {
      print('漫画風変換エラー: $e');
      return img.grayscale(_safeImageAdjustment(image));
    }
  }

  /// ちび風変換
  static Future<img.Image> _convertToChibiStyle(
    img.Image image,
    Map<String, dynamic> options,
  ) async {
    try {
      image = _preprocessImage(image);

      // 1. 軽いブラー - intに変換
      image = img.gaussianBlur(image, radius: 1);

      // 2. パステル調色彩
      image = _applyPastelColors(image);

      // 3. 可愛らしさ強調（控えめに）
      image = _enhanceCuteness(image);

      // 4. 軽い量子化
      image = _quantizeColors(image, 128);

      return image;
    } catch (e) {
      print('ちび風変換エラー: $e');
      return _safeImageAdjustment(image);
    }
  }

  /// リアル調整版
  static Future<img.Image> _convertToRealisticStyle(
    img.Image image,
    Map<String, dynamic> options,
  ) async {
    try {
      image = _preprocessImage(image);

      // 1. ノイズ除去（軽く）- doubleを整数に変換
      image = img.gaussianBlur(image, radius: 1); // 0.5 -> 1に変更

      // 2. 軽い美肌効果
      image = _applySkinSmoothing(image, intensity: 0.2);

      // 3. シャープネス強化（控えめに）
      image = _applyConvolution(image, [0, -0.5, 0, -0.5, 3, -0.5, 0, -0.5, 0]);

      // 4. 色彩補正（控えめに）
      image = img.adjustColor(image, brightness: 0.02, contrast: 1.05);

      return image;
    } catch (e) {
      print('リアル調整エラー: $e');
      return _safeImageAdjustment(image);
    }
  }

  /// ドット絵風変換（安全版）
  static Future<img.Image> _convertToDotArtStyle(
    img.Image image,
    Map<String, dynamic> options,
  ) async {
    try {
      final resolution = (options['resolution'] ?? 64).clamp(16, 128);

      // 1. ダウンサンプリング
      final aspectRatio = image.width / image.height;
      int width, height;

      if (aspectRatio > 1.0) {
        width = resolution;
        height = (resolution / aspectRatio).round().clamp(8, resolution);
      } else {
        height = resolution;
        width = (resolution * aspectRatio).round().clamp(8, resolution);
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
      final scale = math.max(1, 256 ~/ math.max(width, height));
      image = img.copyResize(
        image,
        width: width * scale,
        height: height * scale,
        interpolation: img.Interpolation.nearest,
      );

      return image;
    } catch (e) {
      debugPrint('ドット絵変換エラー: $e');
      return _safeImageAdjustment(image);
    }
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

  /// 肌質改善（安全版）
  static img.Image _applySkinSmoothing(
    img.Image image, {
    double intensity = 0.5,
  }) {
    try {
      // 安全な範囲にクランプ
      intensity = intensity.clamp(0.0, 1.0);

      // ガウシアンブラーを適用（安全な範囲）- doubleをintに変換
      final blurRadius = (2 * intensity).round().clamp(1, 3);
      final blurred = img.gaussianBlur(image, radius: blurRadius);

      // 簡単な肌色ブレンド処理
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final originalPixel = image.getPixel(x, y);
          final blurredPixel = blurred.getPixel(x, y);

          if (_isSkinColor(originalPixel)) {
            // 肌色の場合は軽くブラー効果を適用
            final mixRatio = intensity * 0.5; // さらに控えめに
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
    } catch (e) {
      print('肌質改善エラー: $e');
      return image; // エラー時は元画像を返す
    }
  }

  /// アニメ調色彩強化（安全版）
  static img.Image _enhanceAnimeColors(img.Image image) {
    try {
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);

          // 安全な色調整
          final newR = math.min(pixel.r * 1.1, 255).round().clamp(0, 255);
          final newG = math.min(pixel.g * 1.1, 255).round().clamp(0, 255);
          final newB = math.min(pixel.b * 1.1, 255).round().clamp(0, 255);

          image.setPixel(x, y, img.ColorRgb8(newR, newG, newB));
        }
      }
      return image;
    } catch (e) {
      debugPrint('色彩強化エラー: $e');
      return image; // エラー時は元画像を返す
    }
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

  /// 最終アニメ調整（安全版）
  static img.Image _finalAnimeAdjustments(img.Image image) {
    try {
      // 軽い色数削減
      image = _quantizeColors(image, 200);

      // 最終コントラスト調整（控えめに）
      image = img.adjustColor(image, contrast: 1.1, brightness: 0.02);

      return image;
    } catch (e) {
      debugPrint('最終調整エラー: $e');
      return image;
    }
  }

  /// 安全な画像調整（エラー時のフォールバック）
  static img.Image _safeImageAdjustment(img.Image image) {
    try {
      // 最小限の安全な調整
      return img.adjustColor(image, contrast: 1.05, brightness: 0.01);
    } catch (e) {
      debugPrint('安全調整エラー: $e');
      return image; // 最悪の場合は元画像をそのまま返す
    }
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

    return _applyConvolution(image, kernel);
  }

  /// コンボリューション適用（安全版）
  static img.Image _applyConvolution(img.Image image, List<num> kernel) {
    try {
      final result = img.Image(width: image.width, height: image.height);

      // 3x3カーネルとして処理
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
    } catch (e) {
      debugPrint('コンボリューションエラー: $e');
      return image;
    }
  }

  /// 色数削減（安全版）
  static img.Image _quantizeColors(img.Image image, int colorCount) {
    try {
      colorCount = colorCount.clamp(4, 256);
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
    } catch (e) {
      debugPrint('色数削減エラー: $e');
      return image;
    }
  }

  /// パステル調色彩（安全版）
  static img.Image _applyPastelColors(img.Image image) {
    try {
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);

          // パステル調に調整（控えめに）
          final newR = (pixel.r * 0.9 + 255 * 0.1).round().clamp(0, 255);
          final newG = (pixel.g * 0.9 + 255 * 0.1).round().clamp(0, 255);
          final newB = (pixel.b * 0.9 + 255 * 0.1).round().clamp(0, 255);

          image.setPixel(x, y, img.ColorRgb8(newR, newG, newB));
        }
      }

      return image;
    } catch (e) {
      debugPrint('パステル調整エラー: $e');
      return image;
    }
  }

  /// 可愛らしさ強調（安全版）
  static img.Image _enhanceCuteness(img.Image image) {
    try {
      // 暖色系を軽く強調
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);

          // ピンク系の色を軽く強調
          if (pixel.r > pixel.g && pixel.r > pixel.b) {
            final newR = math.min(pixel.r * 1.05, 255).round().clamp(0, 255);
            final newG = pixel.g.round().clamp(0, 255);
            final newB = pixel.b.round().clamp(0, 255);

            image.setPixel(x, y, img.ColorRgb8(newR, newG, newB));
          }
        }
      }

      return image;
    } catch (e) {
      debugPrint('可愛らしさ強調エラー: $e');
      return image;
    }
  }

  /// ハーフトーン効果（安全版）
  static img.Image _applyHalftoneEffect(img.Image image) {
    try {
      const blockSize = 3; // ブロックサイズを小さく

      for (int y = 0; y < image.height; y += blockSize) {
        for (int x = 0; x < image.width; x += blockSize) {
          if (x + blockSize <= image.width && y + blockSize <= image.height) {
            // 小さなブロックの平均値を計算
            int totalR = 0, totalG = 0, totalB = 0;
            int pixelCount = 0;

            for (int dy = 0; dy < blockSize; dy++) {
              for (int dx = 0; dx < blockSize; dx++) {
                if (x + dx < image.width && y + dy < image.height) {
                  final pixel = image.getPixel(x + dx, y + dy);
                  totalR += pixel.r.toInt();
                  totalG += pixel.g.toInt();
                  totalB += pixel.b.toInt();
                  pixelCount++;
                }
              }
            }

            if (pixelCount > 0) {
              final avgR = totalR ~/ pixelCount;
              final avgG = totalG ~/ pixelCount;
              final avgB = totalB ~/ pixelCount;

              // ブロック全体を平均値で塗りつぶし
              for (int dy = 0; dy < blockSize; dy++) {
                for (int dx = 0; dx < blockSize; dx++) {
                  if (x + dx < image.width && y + dy < image.height) {
                    image.setPixel(
                      x + dx,
                      y + dy,
                      img.ColorRgb8(avgR, avgG, avgB),
                    );
                  }
                }
              }
            }
          }
        }
      }

      return image;
    } catch (e) {
      debugPrint('ハーフトーンエラー: $e');
      return image;
    }
  }

  // ユーティリティメソッド（安全版）
  static bool _isSkinColor(img.Pixel pixel) {
    try {
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();

      return r > 95 && g > 40 && b > 20 && (r - g).abs() > 15 && r > g && r > b;
    } catch (e) {
      return false;
    }
  }

  static bool _isEyeColor(img.Pixel pixel) {
    try {
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();

      // 暗い色（目）の判定
      return r < 100 && g < 100 && b < 100;
    } catch (e) {
      return false;
    }
  }

  static bool _isHairColor(img.Pixel pixel) {
    try {
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();

      // 髪色の判定（暗い色または茶色系）
      return (r < 150 && g < 150 && b < 150) ||
          (r > g && r > b && g > b); // 茶色系
    } catch (e) {
      return false;
    }
  }

  static double _lerp(num a, num b, double t) {
    try {
      return a + (b - a) * t.clamp(0.0, 1.0);
    } catch (e) {
      return a.toDouble();
    }
  }
}
