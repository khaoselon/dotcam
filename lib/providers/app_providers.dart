import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:dotcam/models/dot_settings.dart' as model;
import '../models/app_settings.dart';
import '../utils/dot_converter.dart' as dot;
import 'package:dotcam/utils/anime_converter.dart' as anime;

// カメラプロバイダー
final cameraProvider = FutureProvider<List<CameraDescription>>((ref) async {
  return await availableCameras();
});

// カメラコントローラープロバイダー
final cameraControllerProvider =
    StateNotifierProvider<CameraControllerNotifier, CameraController?>((ref) {
      return CameraControllerNotifier();
    });

class CameraControllerNotifier extends StateNotifier<CameraController?> {
  CameraControllerNotifier() : super(null);

  Future<void> initializeCamera(List<CameraDescription> cameras) async {
    if (cameras.isEmpty) return;

    final controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await controller.initialize();
    state = controller;
  }

  void dispose() {
    state?.dispose();
    state = null;
  }
}

// タブインデックスプロバイダー
final tabIndexProvider = StateProvider<int>((ref) => 0);

// テーマプロバイダー
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// ドット絵設定プロバイダー
final dotSettingsProvider =
    StateNotifierProvider<DotSettingsNotifier, model.DotSettings>((ref) {
      return DotSettingsNotifier();
    });

class DotSettingsNotifier extends StateNotifier<model.DotSettings> {
  DotSettingsNotifier() : super(model.DotSettings.defaultSettings());

  void updateResolution(int resolution) {
    state = state.copyWith(resolution: resolution);
  }

  void updateConversionStyle(anime.ConversionStyle style) {
    state = state.copyWith(conversionStyle: style);
  }

  void updatePalette(dot.ColorPalette palette) {
    state = state.copyWith(palette: palette);
  }

  void updateDithering(bool enabled) {
    state = state.copyWith(ditheringEnabled: enabled);
  }

  void updateContrast(double contrast) {
    state = state.copyWith(contrast: contrast);
  }

  void updateBrightness(double brightness) {
    state = state.copyWith(brightness: brightness);
  }

  void updateSaturation(double saturation) {
    state = state.copyWith(saturation: saturation);
  }

  void updateSmoothing(double smoothing) {
    state = state.copyWith(smoothing: smoothing);
  }

  void updateCustomColors(List<int> colors) {
    state = state.copyWith(
      palette: dot.ColorPalette.custom,
      customColors: colors,
    );
  }
}

// アプリ設定プロバイダー
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(AppSettings.defaultSettings());

  void updateCompareLayout(CompareLayout layout) {
    state = state.copyWith(compareLayout: layout);
  }

  void updateAutoSave(bool enabled) {
    state = state.copyWith(autoSaveEnabled: enabled);
  }

  void updateSaveLocation(SaveLocation location) {
    state = state.copyWith(saveLocation: location);
  }

  void markOnboardingComplete() {
    state = state.copyWith(isFirstLaunch: false);
  }

  void updateLanguage(String languageCode) {
    state = state.copyWith(languageCode: languageCode);
  }

  void updatePreviewOpacity(double opacity) {
    state = state.copyWith(previewOpacity: opacity);
  }

  void updateShowGrid(bool show) {
    state = state.copyWith(showGridOverlay: show);
  }

  void updateHapticFeedback(bool enabled) {
    state = state.copyWith(enableHapticFeedback: enabled);
  }

  void updateSoundEffects(bool enabled) {
    state = state.copyWith(enableSoundEffects: enabled);
  }
}

// ドット絵変換プロバイダー
final dotConverterProvider = Provider<dot.DotConverter>((ref) {
  return dot.DotConverter();
});

// アニメ変換プロバイダー
final animeConverterProvider = Provider<anime.AnimeConverter>((ref) {
  return anime.AnimeConverter();
});

// 画像処理中状態プロバイダー
final isProcessingProvider = StateProvider<bool>((ref) => false);

// 現在の画像プロバイダー
final currentImageProvider = StateProvider<String?>((ref) => null);

// 変換済み画像プロバイダー
final convertedImageProvider = StateProvider<String?>((ref) => null);

// ギャラリー画像リストプロバイダー
final galleryImagesProvider =
    StateNotifierProvider<GalleryNotifier, List<String>>((ref) {
      return GalleryNotifier();
    });

class GalleryNotifier extends StateNotifier<List<String>> {
  GalleryNotifier() : super([]);

  void addImage(String imagePath) {
    state = [imagePath, ...state];
  }

  void removeImage(String imagePath) {
    state = state.where((path) => path != imagePath).toList();
  }

  void clearAll() {
    state = [];
  }

  void loadImages(List<String> images) {
    state = images;
  }
}

// 広告表示制御プロバイダー
final adCounterProvider = StateNotifierProvider<AdCounterNotifier, int>((ref) {
  return AdCounterNotifier();
});

class AdCounterNotifier extends StateNotifier<int> {
  AdCounterNotifier() : super(0);

  void increment() {
    state++;
  }

  void reset() {
    state = 0;
  }

  bool shouldShowInterstitial() {
    return state > 0 && state % 5 == 0; // 5回撮影ごとに広告表示
  }
}

// フラッシュモードプロバイダー
final flashModeProvider = StateProvider<FlashMode>((ref) => FlashMode.auto);

// カメラ向きプロバイダー（前面・背面）
final cameraDirectionProvider = StateProvider<CameraLensDirection>(
  (ref) => CameraLensDirection.back,
);

// 色抽出パレットプロバイダー（アダプティブパレット用）
final extractedColorsProvider = StateProvider<List<int>?>((ref) => null);
