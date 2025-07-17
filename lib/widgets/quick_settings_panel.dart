import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../providers/app_providers.dart';
import '../models/dot_settings.dart';
import '../utils/constants.dart';
import '../utils/anime_converter.dart';
import '../utils/dot_converter.dart' as dot;

class QuickSettingsPanel extends ConsumerWidget {
  final VoidCallback onClose;

  const QuickSettingsPanel({Key? key, required this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dotSettings = ref.watch(dotSettingsProvider);

    return AnimatedContainer(
      duration: Constants.mediumAnimation,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Color(AppColors.surfaceColor).withOpacity(0.95),
        borderRadius: BorderRadius.circular(Constants.cornerRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ヘッダー
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(AppColors.primaryBlue),
                  Color(AppColors.primaryPurple),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Constants.cornerRadius),
                topRight: Radius.circular(Constants.cornerRadius),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.tune, color: Color(AppColors.primaryText), size: 20),
                const SizedBox(width: 8),
                Text(
                  'クイック設定',
                  style: TextStyle(
                    color: Color(AppColors.primaryText),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onClose,
                  child: Icon(
                    Icons.close,
                    color: Color(AppColors.primaryText),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // 設定項目
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 変換スタイル選択
                _buildStyleSelector(ref, dotSettings),
                const SizedBox(height: 20),

                // 解像度設定（ドット絵の場合のみ）
                if (dotSettings.conversionStyle == ConversionStyle.dotArt) ...[
                  _buildResolutionSlider(ref, dotSettings),
                  const SizedBox(height: 20),
                ],

                // カラーパレット設定
                _buildPaletteSelector(ref, dotSettings),
                const SizedBox(height: 20),

                // ディザリング切り替え（ドット絵の場合のみ）
                if (dotSettings.conversionStyle == ConversionStyle.dotArt) ...[
                  _buildDitheringToggle(ref, dotSettings),
                  const SizedBox(height: 16),
                ],

                // 明度・コントラスト調整
                _buildImageAdjustments(ref, dotSettings),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleSelector(WidgetRef ref, DotSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_fix_high,
              color: Color(AppColors.primaryBlue),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              '変換スタイル',
              style: TextStyle(
                color: Color(AppColors.primaryText),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 100,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: ConversionStyle.values.map((style) {
                final isSelected = settings.conversionStyle == style;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      ref
                          .read(dotSettingsProvider.notifier)
                          .updateConversionStyle(style);
                    },
                    child: Container(
                      width: 90,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color(AppColors.primaryBlue)
                            : Color(AppColors.cardColor),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Color(AppColors.primaryBlue)
                              : Color(AppColors.dividerColor),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getStyleIcon(style),
                            color: isSelected
                                ? Color(AppColors.primaryText)
                                : Color(AppColors.secondaryText),
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getStyleName(style),
                            style: TextStyle(
                              color: isSelected
                                  ? Color(AppColors.primaryText)
                                  : Color(AppColors.secondaryText),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getStyleDescription(style),
                            style: TextStyle(
                              color: isSelected
                                  ? Color(
                                      AppColors.primaryText,
                                    ).withOpacity(0.8)
                                  : Color(AppColors.secondaryText),
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getStyleIcon(ConversionStyle style) {
    switch (style) {
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
      default:
        return Icons.help_outline; // 万が一の保険
    }
  }

  String _getStyleName(ConversionStyle style) {
    switch (style) {
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
      default:
        return '不明';
    }
  }

  String _getStyleDescription(ConversionStyle style) {
    switch (style) {
      case ConversionStyle.anime:
        return '美麗仕上げ';
      case ConversionStyle.cartoon:
        return 'ポップ調';
      case ConversionStyle.manga:
        return 'モノクロ';
      case ConversionStyle.chibi:
        return 'かわいい';
      case ConversionStyle.realistic:
        return '美肌効果';
      case ConversionStyle.dotArt:
        return 'レトロドット';
      default:
        return '不明';
    }
  }

  Widget _buildResolutionSlider(WidgetRef ref, DotSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.grid_on, color: Color(AppColors.primaryBlue), size: 16),
            const SizedBox(width: 8),
            Text(
              '解像度: ${settings.resolution}x${settings.resolution}',
              style: TextStyle(
                color: Color(AppColors.primaryText),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Color(AppColors.primaryBlue),
              inactiveTrackColor: Color(AppColors.dividerColor),
              thumbColor: Color(AppColors.primaryBlue),
              overlayColor: Color(AppColors.primaryBlue).withOpacity(0.3),
              trackHeight: 4,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: math
                  .max(
                    0,
                    Constants.resolutionOptions.indexOf(settings.resolution),
                  )
                  .toDouble(),
              min: 0,
              max: (Constants.resolutionOptions.length - 1).toDouble(),
              divisions: Constants.resolutionOptions.length - 1,
              onChanged: (value) {
                final index = value.round();
                if (index >= 0 && index < Constants.resolutionOptions.length) {
                  final resolution = Constants.resolutionOptions[index];
                  ref
                      .read(dotSettingsProvider.notifier)
                      .updateResolution(resolution);
                }
              },
            ),
          ),
        ),
        Container(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: Constants.resolutionOptions.map((res) {
              final isSelected = settings.resolution == res;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    ref
                        .read(dotSettingsProvider.notifier)
                        .updateResolution(res);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(AppColors.primaryBlue)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? Color(AppColors.primaryBlue)
                            : Color(AppColors.dividerColor),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$res',
                      style: TextStyle(
                        color: isSelected
                            ? Color(AppColors.primaryText)
                            : Color(AppColors.secondaryText),
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPaletteSelector(WidgetRef ref, DotSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.palette, color: Color(AppColors.primaryBlue), size: 16),
            const SizedBox(width: 8),
            Text(
              'カラーパレット',
              style: TextStyle(
                color: Color(AppColors.primaryText),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 80,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: dot.ColorPalette.values.map((palette) {
                final isSelected = settings.palette == palette;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      ref
                          .read(dotSettingsProvider.notifier)
                          .updatePalette(palette);
                    },
                    child: Container(
                      width: 80,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color(AppColors.primaryBlue)
                            : Color(AppColors.cardColor),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Color(AppColors.primaryBlue)
                              : Color(AppColors.dividerColor),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            palette.displayName,
                            style: TextStyle(
                              color: isSelected
                                  ? Color(AppColors.primaryText)
                                  : Color(AppColors.secondaryText),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (palette == dot.ColorPalette.adaptive ||
                              palette == dot.ColorPalette.original) ...[
                            const SizedBox(height: 2),
                            Text(
                              palette == dot.ColorPalette.adaptive
                                  ? '自動'
                                  : '元色',
                              style: TextStyle(
                                color: isSelected
                                    ? Color(
                                        AppColors.primaryText,
                                      ).withOpacity(0.8)
                                    : Color(AppColors.secondaryText),
                                fontSize: 9,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          // カラープレビュー
                          const SizedBox(height: 4),
                          Container(
                            height: 16,
                            width: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(
                                color: Color(AppColors.dividerColor),
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              children: palette.colors
                                  .take(4)
                                  .map(
                                    (color) => Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(color),
                                          borderRadius: BorderRadius.circular(
                                            1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDitheringToggle(WidgetRef ref, DotSettings settings) {
    return Row(
      children: [
        Icon(Icons.grain, color: Color(AppColors.primaryBlue), size: 16),
        const SizedBox(width: 8),
        Text(
          'ディザリング',
          style: TextStyle(
            color: Color(AppColors.primaryText),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Switch(
          value: settings.ditheringEnabled,
          onChanged: (value) {
            ref.read(dotSettingsProvider.notifier).updateDithering(value);
          },
          activeColor: Color(AppColors.primaryBlue),
          inactiveThumbColor: Color(AppColors.secondaryText),
          inactiveTrackColor: Color(AppColors.dividerColor),
        ),
      ],
    );
  }

  Widget _buildImageAdjustments(WidgetRef ref, DotSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 明度調整
        Row(
          children: [
            Icon(
              Icons.brightness_6,
              color: Color(AppColors.primaryBlue),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              '明度: ${settings.brightness.toStringAsFixed(1)}',
              style: TextStyle(
                color: Color(AppColors.primaryText),
                fontSize: 12,
              ),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Color(AppColors.primaryBlue),
              inactiveTrackColor: Color(AppColors.dividerColor),
              thumbColor: Color(AppColors.primaryBlue),
              overlayColor: Color(AppColors.primaryBlue).withOpacity(0.3),
              trackHeight: 3,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: settings.brightness,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              onChanged: (value) {
                ref.read(dotSettingsProvider.notifier).updateBrightness(value);
              },
            ),
          ),
        ),
        const SizedBox(height: 8),

        // コントラスト調整
        Row(
          children: [
            Icon(Icons.contrast, color: Color(AppColors.primaryBlue), size: 16),
            const SizedBox(width: 8),
            Text(
              'コントラスト: ${settings.contrast.toStringAsFixed(1)}',
              style: TextStyle(
                color: Color(AppColors.primaryText),
                fontSize: 12,
              ),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Color(AppColors.primaryBlue),
              inactiveTrackColor: Color(AppColors.dividerColor),
              thumbColor: Color(AppColors.primaryBlue),
              overlayColor: Color(AppColors.primaryBlue).withOpacity(0.3),
              trackHeight: 3,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: settings.contrast,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              onChanged: (value) {
                ref.read(dotSettingsProvider.notifier).updateContrast(value);
              },
            ),
          ),
        ),
        const SizedBox(height: 8),

        // 彩度調整（アニメ風変換の場合のみ）
        if (settings.conversionStyle != ConversionStyle.dotArt &&
            settings.conversionStyle != ConversionStyle.manga) ...[
          Row(
            children: [
              Icon(
                Icons.color_lens,
                color: Color(AppColors.primaryBlue),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '彩度: ${settings.saturation.toStringAsFixed(1)}',
                style: TextStyle(
                  color: Color(AppColors.primaryText),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: Color(AppColors.primaryBlue),
                inactiveTrackColor: Color(AppColors.dividerColor),
                thumbColor: Color(AppColors.primaryBlue),
                overlayColor: Color(AppColors.primaryBlue).withOpacity(0.3),
                trackHeight: 3,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
              ),
              child: Slider(
                value: settings.saturation,
                min: 0.5,
                max: 2.0,
                divisions: 15,
                onChanged: (value) {
                  ref
                      .read(dotSettingsProvider.notifier)
                      .updateSaturation(value);
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}
