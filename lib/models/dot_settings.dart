import '../utils/anime_converter.dart' as anime;
import '../utils/dot_converter.dart' as dot;

class DotSettings {
  final int resolution;
  final anime.ConversionStyle conversionStyle;
  final dot.ColorPalette palette;
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
      palette: dot.ColorPalette.adaptive,
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
    dot.ColorPalette? palette,
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
      palette: dot.ColorPalette.values[json['palette'] ?? 0],
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
