import '../utils/anime_converter.dart' as anime;

class DotSettings {
  final int resolution;
  final anime.ConversionStyle conversionStyle;
  final ColorPalette palette;
  final bool ditheringEnabled;
  final double contrast;
  final double brightness;
  final double saturation;
  final double smoothing;
  final List<int>? customColors;

  const DotSettings({
    required this.resolution,
    required this.conversionStyle,
    required this.palette,
    required this.ditheringEnabled,
    required this.contrast,
    required this.brightness,
    required this.saturation,
    required this.smoothing,
    this.customColors,
  });

  factory DotSettings.defaultSettings() {
    return const DotSettings(
      resolution: 64,
      conversionStyle: anime.ConversionStyle.anime,
      palette: ColorPalette.adaptive,
      ditheringEnabled: false,
      contrast: 1.2,
      brightness: 1.1,
      saturation: 1.3,
      smoothing: 0.5,
    );
  }

  DotSettings copyWith({
    int? resolution,
    anime.ConversionStyle? conversionStyle,
    ColorPalette? palette,
    bool? ditheringEnabled,
    double? contrast,
    double? brightness,
    double? saturation,
    double? smoothing,
    List<int>? customColors,
  }) {
    return DotSettings(
      resolution: resolution ?? this.resolution,
      conversionStyle: conversionStyle ?? this.conversionStyle,
      palette: palette ?? this.palette,
      ditheringEnabled: ditheringEnabled ?? this.ditheringEnabled,
      contrast: contrast ?? this.contrast,
      brightness: brightness ?? this.brightness,
      saturation: saturation ?? this.saturation,
      smoothing: smoothing ?? this.smoothing,
      customColors: customColors ?? this.customColors,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resolution': resolution,
      'conversionStyle': conversionStyle.index,
      'palette': palette.index,
      'ditheringEnabled': ditheringEnabled,
      'contrast': contrast,
      'brightness': brightness,
      'saturation': saturation,
      'smoothing': smoothing,
      'customColors': customColors,
    };
  }

  factory DotSettings.fromJson(Map<String, dynamic> json) {
    return DotSettings(
      resolution: json['resolution'] ?? 64,
      conversionStyle:
          anime.ConversionStyle.values[json['conversionStyle'] ?? 0],
      palette: ColorPalette.values[json['palette'] ?? 0],
      ditheringEnabled: json['ditheringEnabled'] ?? false,
      contrast: json['contrast']?.toDouble() ?? 1.2,
      brightness: json['brightness']?.toDouble() ?? 1.1,
      saturation: json['saturation']?.toDouble() ?? 1.3,
      smoothing: json['smoothing']?.toDouble() ?? 0.5,
      customColors: json['customColors'] != null
          ? List<int>.from(json['customColors'])
          : null,
    );
  }
}

enum ColorPalette {
  adaptive, // 元画像から色を抽出
  original, // 元画像の色を保持（減色のみ）
  gameboy,
  gameboyColor,
  snes,
  gba,
  nes,
  c64,
  cga,
  monochrome,
  custom,
}

extension ColorPaletteExtension on ColorPalette {
  String get displayName {
    switch (this) {
      case ColorPalette.adaptive:
        return '自動抽出';
      case ColorPalette.original:
        return '元画像';
      case ColorPalette.gameboy:
        return 'ゲームボーイ';
      case ColorPalette.gameboyColor:
        return 'ゲームボーイカラー';
      case ColorPalette.snes:
        return 'スーパーファミコン';
      case ColorPalette.gba:
        return 'ゲームボーイアドバンス';
      case ColorPalette.nes:
        return 'ファミコン';
      case ColorPalette.c64:
        return 'コモドール64';
      case ColorPalette.cga:
        return 'CGA';
      case ColorPalette.monochrome:
        return 'モノクロ';
      case ColorPalette.custom:
        return 'カスタム';
    }
  }

  String get description {
    switch (this) {
      case ColorPalette.adaptive:
        return '元画像から主要な色を自動抽出';
      case ColorPalette.original:
        return '元画像の色を保持したまま減色';
      case ColorPalette.gameboy:
        return 'クラシックな4色グリーン';
      case ColorPalette.gameboyColor:
        return '16色カラーパレット';
      case ColorPalette.snes:
        return 'レトロな16色パレット';
      case ColorPalette.gba:
        return '明るい16色パレット';
      case ColorPalette.nes:
        return 'ファミコン風16色';
      case ColorPalette.c64:
        return 'コモドール64風16色';
      case ColorPalette.cga:
        return 'CGA風16色';
      case ColorPalette.monochrome:
        return '白黒2色';
      case ColorPalette.custom:
        return 'ユーザー定義色';
    }
  }

  List<int> get colors {
    switch (this) {
      case ColorPalette.adaptive:
        // 実際の色は画像から動的に抽出される
        return [
          0xFF000000,
          0xFF404040,
          0xFF808080,
          0xFFC0C0C0,
          0xFFFFFFFF,
          0xFF800000,
          0xFF008000,
          0xFF000080,
        ];
      case ColorPalette.original:
        // 元画像の色をそのまま使用（プレースホルダー）
        return [
          0xFF000000,
          0xFF333333,
          0xFF666666,
          0xFF999999,
          0xFFCCCCCC,
          0xFFFFFFFF,
        ];
      case ColorPalette.gameboy:
        return [
          0xFF0F380F, // 濃い緑
          0xFF306230, // 中緑
          0xFF8BAC0F, // 薄い緑
          0xFF9BBB0F, // 明るい緑
        ];
      case ColorPalette.gameboyColor:
        return [
          0xFF000000,
          0xFF555555,
          0xFFAAAAAA,
          0xFFFFFFFF,
          0xFF550000,
          0xFF005500,
          0xFF000055,
          0xFF555500,
          0xFF550055,
          0xFF005555,
          0xFFAA0000,
          0xFF00AA00,
          0xFF0000AA,
          0xFFAAAA00,
          0xFFAA00AA,
          0xFF00AAAA,
        ];
      case ColorPalette.snes:
        return [
          0xFF000000,
          0xFF2C2C2C,
          0xFF585858,
          0xFF848484,
          0xFFB0B0B0,
          0xFFDCDCDC,
          0xFFFFFFFF,
          0xFF9C0000,
          0xFFFF7878,
          0xFF009C00,
          0xFF78FF78,
          0xFF00009C,
          0xFF7878FF,
          0xFF9C9C00,
          0xFFFFFF78,
          0xFF9C009C,
        ];
      case ColorPalette.gba:
        return [
          0xFF000000,
          0xFF550000,
          0xFF005500,
          0xFF555500,
          0xFF000055,
          0xFF550055,
          0xFF005555,
          0xFF555555,
          0xFFAAAAAA,
          0xFFFF5555,
          0xFF55FF55,
          0xFFFFFF55,
          0xFF5555FF,
          0xFFFF55FF,
          0xFF55FFFF,
          0xFFFFFFFF,
        ];
      case ColorPalette.nes:
        return [
          0xFF7C7C7C,
          0xFF0000FC,
          0xFF0000BC,
          0xFF4428BC,
          0xFF940084,
          0xFFA80020,
          0xFFA81000,
          0xFF881400,
          0xFF503000,
          0xFF007800,
          0xFF006800,
          0xFF005800,
          0xFF004058,
          0xFF000000,
          0xFF000000,
          0xFF000000,
        ];
      case ColorPalette.c64:
        return [
          0xFF000000,
          0xFFFFFFFF,
          0xFF880000,
          0xFFAAFFEE,
          0xFFCC44CC,
          0xFF00CC55,
          0xFF0000AA,
          0xFFEEEE77,
          0xFFDD8855,
          0xFF664400,
          0xFFFF7777,
          0xFF333333,
          0xFF777777,
          0xFFAAFF66,
          0xFF0088FF,
          0xFFBBBBBB,
        ];
      case ColorPalette.cga:
        return [
          0xFF000000,
          0xFF0000AA,
          0xFF00AA00,
          0xFF00AAAA,
          0xFFAA0000,
          0xFFAA00AA,
          0xFFAA5500,
          0xFFAAAAAA,
          0xFF555555,
          0xFF5555FF,
          0xFF55FF55,
          0xFF55FFFF,
          0xFFFF5555,
          0xFFFF55FF,
          0xFFFFFF55,
          0xFFFFFFFF,
        ];
      case ColorPalette.monochrome:
        return [0xFF000000, 0xFFFFFFFF];
      case ColorPalette.custom:
        return [
          0xFF000000,
          0xFF333333,
          0xFF666666,
          0xFF999999,
          0xFFCCCCCC,
          0xFFFFFFFF,
          0xFFFF0000,
          0xFF00FF00,
          0xFF0000FF,
          0xFFFFFF00,
          0xFFFF00FF,
          0xFF00FFFF,
        ];
    }
  }

  int get maxColors {
    switch (this) {
      case ColorPalette.adaptive:
        return 16; // 動的に調整可能
      case ColorPalette.original:
        return 32; // 元画像から多めに抽出
      case ColorPalette.gameboy:
        return 4;
      case ColorPalette.gameboyColor:
        return 16;
      case ColorPalette.snes:
        return 16;
      case ColorPalette.gba:
        return 16;
      case ColorPalette.nes:
        return 16;
      case ColorPalette.c64:
        return 16;
      case ColorPalette.cga:
        return 16;
      case ColorPalette.monochrome:
        return 2;
      case ColorPalette.custom:
        return 12;
    }
  }

  bool get isAdaptive {
    return this == ColorPalette.adaptive || this == ColorPalette.original;
  }
}
