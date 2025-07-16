import 'dart:typed_data';
import 'dart:isolate';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../models/dot_settings.dart';

class DotConverter {
  static const int _maxConcurrentTasks = 2;
  int _activeTasks = 0;

  /// メイン変換メソッド - isolateで非同期実行
  Future<Uint8List> convertToDot({
    required Uint8List imageBytes,
    required DotSettings settings,
    void Function(double)? onProgress,
  }) async {
    if (_activeTasks >= _maxConcurrentTasks) {
      throw Exception('変換処理が混雑しています。しばらくお待ちください。');
    }

    _activeTasks++;

    try {
      final result = await compute(_convertToDotIsolate, {
        'imageBytes': imageBytes,
        'settings': settings.toJson(),
      });

      return result;
    } finally {
      _activeTasks--;
    }
  }

  /// isolateで実行される変換処理
  static Future<Uint8List> _convertToDotIsolate(
    Map<String, dynamic> params,
  ) async {
    final Uint8List imageBytes = params['imageBytes'];
    final Map<String, dynamic> settingsJson = params['settings'];
    final DotSettings settings = DotSettings.fromJson(settingsJson);

    // 画像を読み込み
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('画像の読み込みに失敗しました');
    }

    // 前処理
    image = _preprocessImage(image, settings);

    // ダウンサンプリング（ドット化）
    image = _downsampleImage(image, settings.resolution);

    // カラーパレット適用
    image = _applyColorPalette(image, settings);

    // ディザリング適用
    if (settings.ditheringEnabled) {
      image = _applyDithering(image, settings);
    }

    // 最終的なドット絵サイズにアップスケール
    image = _upscaleImage(image, settings.resolution);

    // PNG形式で出力
    return Uint8List.fromList(img.encodePng(image));
  }

  /// 画像の前処理（明度・コントラスト調整）
  static img.Image _preprocessImage(img.Image image, DotSettings settings) {
    // アスペクト比を保持しつつ、適切なサイズにリサイズ
    const maxSize = 512;
    if (image.width > maxSize || image.height > maxSize) {
      final scale = min(maxSize / image.width, maxSize / image.height);
      final newWidth = (image.width * scale).round();
      final newHeight = (image.height * scale).round();
      image = img.copyResize(image, width: newWidth, height: newHeight);
    }

    // 明度調整
    if (settings.brightness != 1.0) {
      image = img.adjustColor(image, brightness: settings.brightness - 1.0);
    }

    // コントラスト調整
    if (settings.contrast != 1.0) {
      image = img.adjustColor(image, contrast: settings.contrast);
    }

    return image;
  }

  /// ダウンサンプリング（ピクセル化）
  static img.Image _downsampleImage(img.Image image, int resolution) {
    // 正方形に近いアスペクト比を維持
    final aspectRatio = image.width / image.height;
    int width, height;

    if (aspectRatio > 1.0) {
      width = resolution;
      height = (resolution / aspectRatio).round();
    } else {
      height = resolution;
      width = (resolution * aspectRatio).round();
    }

    width = max(8, width); // 最小サイズ保証
    height = max(8, height);

    return img.copyResize(
      image,
      width: width,
      height: height,
      interpolation: img.Interpolation.nearest,
    );
  }

  /// カラーパレット適用
  static img.Image _applyColorPalette(img.Image image, DotSettings settings) {
    final palette = settings.palette.colors;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final pixelValue =
            pixel.r.toInt() << 16 | pixel.g.toInt() << 8 | pixel.b.toInt();
        final closestColor = _findClosestColor(pixelValue, palette);
        image.setPixel(
          x,
          y,
          img.ColorRgb8(
            (closestColor >> 16) & 0xFF,
            (closestColor >> 8) & 0xFF,
            closestColor & 0xFF,
          ),
        );
      }
    }

    return image;
  }

  /// 最も近い色を見つける
  static int _findClosestColor(int originalColor, List<int> palette) {
    final r1 = (originalColor >> 16) & 0xFF;
    final g1 = (originalColor >> 8) & 0xFF;
    final b1 = originalColor & 0xFF;

    int closestColor = palette[0];
    double minDistance = double.infinity;

    for (final paletteColor in palette) {
      final r2 = (paletteColor >> 16) & 0xFF;
      final g2 = (paletteColor >> 8) & 0xFF;
      final b2 = paletteColor & 0xFF;

      // 色差計算（RGB距離）
      final distance = sqrt(
        pow(r1 - r2, 2) + pow(g1 - g2, 2) + pow(b1 - b2, 2),
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestColor = paletteColor;
      }
    }

    return closestColor;
  }

  /// フロイド-スタインバーグディザリング適用
  static img.Image _applyDithering(img.Image image, DotSettings settings) {
    final palette = settings.palette.colors;
    final width = image.width;
    final height = image.height;

    // エラー拡散マトリックス
    final errorMatrix = List.generate(
      height,
      (i) => List.generate(width, (j) => [0.0, 0.0, 0.0]),
    );

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = image.getPixel(x, y);
        final pixelValue =
            pixel.r.toInt() << 16 | pixel.g.toInt() << 8 | pixel.b.toInt();
        int r = ((pixelValue >> 16) & 0xFF) + errorMatrix[y][x][0].round();
        int g = ((pixelValue >> 8) & 0xFF) + errorMatrix[y][x][1].round();
        int b = (pixelValue & 0xFF) + errorMatrix[y][x][2].round();

        // 値をクランプ
        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        final adjustedColor = (0xFF << 24) | (r << 16) | (g << 8) | b;
        final quantizedColor = _findClosestColor(adjustedColor, palette);

        image.setPixel(
          x,
          y,
          img.ColorRgb8(
            (quantizedColor >> 16) & 0xFF,
            (quantizedColor >> 8) & 0xFF,
            quantizedColor & 0xFF,
          ),
        );

        // 量子化エラーを計算
        final qR = (quantizedColor >> 16) & 0xFF;
        final qG = (quantizedColor >> 8) & 0xFF;
        final qB = quantizedColor & 0xFF;

        final errorR = (r - qR).toDouble();
        final errorG = (g - qG).toDouble();
        final errorB = (b - qB).toDouble();

        // エラーを周囲のピクセルに拡散
        _distributeError(
          errorMatrix,
          x,
          y,
          width,
          height,
          errorR,
          errorG,
          errorB,
        );
      }
    }

    return image;
  }

  /// ディザリングエラーの拡散
  static void _distributeError(
    List<List<List<double>>> errorMatrix,
    int x,
    int y,
    int width,
    int height,
    double errorR,
    double errorG,
    double errorB,
  ) {
    // フロイド-スタインバーグの係数
    final coefficients = [
      [1, 0, 7 / 16], // 右
      [-1, 1, 3 / 16], // 左下
      [0, 1, 5 / 16], // 下
      [1, 1, 1 / 16], // 右下
    ];

    for (final coeff in coefficients) {
      final nx = x + coeff[0].toInt();
      final ny = y + coeff[1].toInt();

      if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
        errorMatrix[ny][nx][0] += errorR * coeff[2];
        errorMatrix[ny][nx][1] += errorG * coeff[2];
        errorMatrix[ny][nx][2] += errorB * coeff[2];
      }
    }
  }

  /// 画像のアップスケール（ピクセルアート風）
  static img.Image _upscaleImage(img.Image image, int targetResolution) {
    // 元画像の短辺を基準にスケール計算
    final minDimension = min(image.width, image.height);
    final scale = max(4, (512 / minDimension).round());

    return img.copyResize(
      image,
      width: image.width * scale,
      height: image.height * scale,
      interpolation: img.Interpolation.nearest,
    );
  }

  /// プレビュー用の小さなサムネイル生成
  Future<Uint8List> generatePreview({
    required Uint8List imageBytes,
    required DotSettings settings,
    int previewSize = 128,
  }) async {
    return await compute(_generatePreviewIsolate, {
      'imageBytes': imageBytes,
      'settings': settings.toJson(),
      'previewSize': previewSize,
    });
  }

  static Future<Uint8List> _generatePreviewIsolate(
    Map<String, dynamic> params,
  ) async {
    final Uint8List imageBytes = params['imageBytes'];
    final Map<String, dynamic> settingsJson = params['settings'];
    final int previewSize = params['previewSize'];
    final DotSettings settings = DotSettings.fromJson(settingsJson);

    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('プレビュー画像の読み込みに失敗しました');
    }

    // プレビュー用の簡易変換
    image = img.copyResize(image, width: previewSize, height: previewSize);
    image = _applyColorPalette(image, settings);

    return Uint8List.fromList(img.encodePng(image));
  }
}
