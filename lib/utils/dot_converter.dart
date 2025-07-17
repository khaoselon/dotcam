import 'package:flutter/material.dart';

class DotSettings {
  final int resolution;
  final ConversionStyle style;
  final ColorPalette palette;
  final bool ditheringEnabled;
  final double contrast;
  final double brightness;
  final double saturation;
  final double smoothing;
  final bool edgeEnhancement;
  final List<int>? customColors;

  const DotSettings({
    required this.resolution,
    required this.style,
    required this.palette,
    required this.ditheringEnabled,
    required this.contrast,
    required this.brightness,
    required this.saturation,
    required this.smoothing,
    required this.edgeEnhancement,
    this.customColors,
  });

  factory DotSettings.defaultSettings() {
    return const DotSettings(
      resolution: 64,
      style: ConversionStyle.anime,
      palette: ColorPalette.adaptive,
      ditheringEnabled: false,
      contrast: 1.2,
      brightness: 1.1,
      saturation: 1.3,
      smoothing: 0.5,
      edgeEnhancement: true,
    );
  }

  DotSettings copyWith({
    int? resolution,
    ConversionStyle? style,
    ColorPalette? palette,
    bool? ditheringEnabled,
    double? contrast,
    double? brightness,
    double? saturation,
    double? smoothing,
    bool? edgeEnhancement,
    List<int>? customColors,
  }) {
    return DotSettings(
      resolution: resolution ?? this.resolution,
      style: style ?? this.style,
      palette: palette ?? this.palette,
      ditheringEnabled: ditheringEnabled ?? this.ditheringEnabled,
      contrast: contrast ?? this.contrast,
      brightness: brightness ?? this.brightness,
      saturation: saturation ?? this.saturation,
      smoothing: smoothing ?? this.smoothing,
      edgeEnhancement: edgeEnhancement ?? this.edgeEnhancement,
      customColors: customColors ?? this.customColors,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resolution': resolution,
      'style': style.index,
      'palette': palette.index,
      'ditheringEnabled': ditheringEnabled,
      'contrast': contrast,
      'brightness': brightness,
      'saturation': saturation,
      'smoothing': smoothing,
      'edgeEnhancement': edgeEnhancement,
      'customColors': customColors,
    };
  }

  factory DotSettings.fromJson(Map<String, dynamic> json) {
    return DotSettings(
      resolution: json['resolution'] ?? 64,
      style: ConversionStyle.values[json['style'] ?? 0],
      palette: ColorPalette.values[json['palette'] ?? 0],
      ditheringEnabled: json['ditheringEnabled'] ?? false,
      contrast: json['contrast']?.toDouble() ?? 1.2,
      brightness: json['brightness']?.toDouble() ?? 1.1,
      saturation: json['saturation']?.toDouble() ?? 1.3,
      smoothing: json['smoothing']?.toDouble() ?? 0.5,
      edgeEnhancement: json['edgeEnhancement'] ?? true,
      customColors: json['customColors'] != null
          ? List<int>.from(json['customColors'])
          : null,
    );
  }
}

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
}
