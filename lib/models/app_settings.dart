import 'package:flutter/material.dart';

class AppSettings {
  final bool isFirstLaunch;
  final CompareLayout compareLayout;
  final bool autoSaveEnabled;
  final SaveLocation saveLocation;
  final String languageCode;
  final bool enableHapticFeedback;
  final bool enableSoundEffects;
  final double previewOpacity;
  final bool showGridOverlay;

  const AppSettings({
    required this.isFirstLaunch,
    required this.compareLayout,
    required this.autoSaveEnabled,
    required this.saveLocation,
    required this.languageCode,
    required this.enableHapticFeedback,
    required this.enableSoundEffects,
    required this.previewOpacity,
    required this.showGridOverlay,
  });

  factory AppSettings.defaultSettings() {
    return const AppSettings(
      isFirstLaunch: true,
      compareLayout: CompareLayout.rightBottom,
      autoSaveEnabled: true,
      saveLocation: SaveLocation.device,
      languageCode: 'ja',
      enableHapticFeedback: true,
      enableSoundEffects: true,
      previewOpacity: 0.8,
      showGridOverlay: false,
    );
  }

  AppSettings copyWith({
    bool? isFirstLaunch,
    CompareLayout? compareLayout,
    bool? autoSaveEnabled,
    SaveLocation? saveLocation,
    String? languageCode,
    bool? enableHapticFeedback,
    bool? enableSoundEffects,
    double? previewOpacity,
    bool? showGridOverlay,
  }) {
    return AppSettings(
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      compareLayout: compareLayout ?? this.compareLayout,
      autoSaveEnabled: autoSaveEnabled ?? this.autoSaveEnabled,
      saveLocation: saveLocation ?? this.saveLocation,
      languageCode: languageCode ?? this.languageCode,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      enableSoundEffects: enableSoundEffects ?? this.enableSoundEffects,
      previewOpacity: previewOpacity ?? this.previewOpacity,
      showGridOverlay: showGridOverlay ?? this.showGridOverlay,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isFirstLaunch': isFirstLaunch,
      'compareLayout': compareLayout.index,
      'autoSaveEnabled': autoSaveEnabled,
      'saveLocation': saveLocation.index,
      'languageCode': languageCode,
      'enableHapticFeedback': enableHapticFeedback,
      'enableSoundEffects': enableSoundEffects,
      'previewOpacity': previewOpacity,
      'showGridOverlay': showGridOverlay,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isFirstLaunch: json['isFirstLaunch'] ?? true,
      compareLayout: CompareLayout.values[json['compareLayout'] ?? 0],
      autoSaveEnabled: json['autoSaveEnabled'] ?? true,
      saveLocation: SaveLocation.values[json['saveLocation'] ?? 0],
      languageCode: json['languageCode'] ?? 'ja',
      enableHapticFeedback: json['enableHapticFeedback'] ?? true,
      enableSoundEffects: json['enableSoundEffects'] ?? true,
      previewOpacity: json['previewOpacity']?.toDouble() ?? 0.8,
      showGridOverlay: json['showGridOverlay'] ?? false,
    );
  }
}

enum CompareLayout { rightBottom, leftBottom, topRight, topLeft }

extension CompareLayoutExtension on CompareLayout {
  String get displayName {
    switch (this) {
      case CompareLayout.rightBottom:
        return '右下';
      case CompareLayout.leftBottom:
        return '左下';
      case CompareLayout.topRight:
        return '右上';
      case CompareLayout.topLeft:
        return '左上';
    }
  }

  Alignment get alignment {
    switch (this) {
      case CompareLayout.rightBottom:
        return Alignment.bottomRight;
      case CompareLayout.leftBottom:
        return Alignment.bottomLeft;
      case CompareLayout.topRight:
        return Alignment.topRight;
      case CompareLayout.topLeft:
        return Alignment.topLeft;
    }
  }
}

enum SaveLocation { device, icloud, googlePhotos }

extension SaveLocationExtension on SaveLocation {
  String get displayName {
    switch (this) {
      case SaveLocation.device:
        return '端末';
      case SaveLocation.icloud:
        return 'iCloud';
      case SaveLocation.googlePhotos:
        return 'Google フォト';
    }
  }

  String get description {
    switch (this) {
      case SaveLocation.device:
        return '端末のフォトライブラリに保存';
      case SaveLocation.icloud:
        return 'iCloudフォトライブラリに保存';
      case SaveLocation.googlePhotos:
        return 'Google フォトに保存';
    }
  }
}
