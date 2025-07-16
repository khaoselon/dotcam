class DotSettings {
  final int resolution;
  final ColorPalette palette;
  final bool ditheringEnabled;
  final double contrast;
  final double brightness;

  const DotSettings({
    required this.resolution,
    required this.palette,
    required this.ditheringEnabled,
    required this.contrast,
    required this.brightness,
  });

  factory DotSettings.defaultSettings() {
    return const DotSettings(
      resolution: 64,
      palette: ColorPalette.gameboy,
      ditheringEnabled: true,
      contrast: 1.0,
      brightness: 1.0,
    );
  }

  DotSettings copyWith({
    int? resolution,
    ColorPalette? palette,
    bool? ditheringEnabled,
    double? contrast,
    double? brightness,
  }) {
    return DotSettings(
      resolution: resolution ?? this.resolution,
      palette: palette ?? this.palette,
      ditheringEnabled: ditheringEnabled ?? this.ditheringEnabled,
      contrast: contrast ?? this.contrast,
      brightness: brightness ?? this.brightness,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resolution': resolution,
      'palette': palette.index,
      'ditheringEnabled': ditheringEnabled,
      'contrast': contrast,
      'brightness': brightness,
    };
  }

  factory DotSettings.fromJson(Map<String, dynamic> json) {
    return DotSettings(
      resolution: json['resolution'] ?? 64,
      palette: ColorPalette.values[json['palette'] ?? 0],
      ditheringEnabled: json['ditheringEnabled'] ?? true,
      contrast: json['contrast']?.toDouble() ?? 1.0,
      brightness: json['brightness']?.toDouble() ?? 1.0,
    );
  }
}

enum ColorPalette {
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

  List<int> get colors {
    switch (this) {
      case ColorPalette.gameboy:
        return [
          0xFF0F0F0F, // 黒
          0xFF555555, // 濃いグレー
          0xFFAAAAAA, // 薄いグレー
          0xFFFFFFFF, // 白
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
}
