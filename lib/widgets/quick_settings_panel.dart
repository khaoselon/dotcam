import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../models/dot_settings.dart';
import '../utils/constants.dart';

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
                // 解像度設定
                _buildResolutionSlider(ref, dotSettings),
                const SizedBox(height: 20),

                // カラーパレット設定
                _buildPaletteSelector(ref, dotSettings),
                const SizedBox(height: 20),

                // プレビューモード切り替え
                _buildPreviewModeToggle(ref),
                const SizedBox(height: 20),

                // ディザリング切り替え
                _buildDitheringToggle(ref, dotSettings),
              ],
            ),
          ),
        ],
      ),
    );
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
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Color(AppColors.primaryBlue),
            inactiveTrackColor: Color(AppColors.dividerColor),
            thumbColor: Color(AppColors.primaryBlue),
            overlayColor: Color(AppColors.primaryBlue).withOpacity(0.3),
            trackHeight: 3,
          ),
          child: Slider(
            value: settings.resolution.toDouble(),
            min: Constants.minResolution.toDouble(),
            max: Constants.maxResolution.toDouble(),
            divisions: Constants.resolutionOptions.length - 1,
            onChanged: (value) {
              final closestResolution = Constants.resolutionOptions.reduce(
                (a, b) => (a - value).abs() < (b - value).abs() ? a : b,
              );
              ref
                  .read(dotSettingsProvider.notifier)
                  .updateResolution(closestResolution);
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: Constants.resolutionOptions.map((res) {
            return GestureDetector(
              onTap: () {
                ref.read(dotSettingsProvider.notifier).updateResolution(res);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: settings.resolution == res
                      ? Color(AppColors.primaryBlue)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$res',
                  style: TextStyle(
                    color: settings.resolution == res
                        ? Color(AppColors.primaryText)
                        : Color(AppColors.secondaryText),
                    fontSize: 10,
                  ),
                ),
              ),
            );
          }).toList(),
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ColorPalette.values.map((palette) {
              final isSelected = settings.palette == palette;
              return GestureDetector(
                onTap: () {
                  ref.read(dotSettingsProvider.notifier).updatePalette(palette);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
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
                    ),
                  ),
                  child: Text(
                    palette.displayName,
                    style: TextStyle(
                      color: isSelected
                          ? Color(AppColors.primaryText)
                          : Color(AppColors.secondaryText),
                      fontSize: 12,
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

  Widget _buildPreviewModeToggle(WidgetRef ref) {
    final previewMode = ref.watch(previewModeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.visibility,
              color: Color(AppColors.primaryBlue),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'プレビューモード',
              style: TextStyle(
                color: Color(AppColors.primaryText),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildModeButton(
              ref,
              PreviewMode.original,
              'オリジナル',
              Icons.photo,
              previewMode == PreviewMode.original,
            ),
            const SizedBox(width: 8),
            _buildModeButton(
              ref,
              PreviewMode.dotted,
              'ドット絵',
              Icons.grid_on,
              previewMode == PreviewMode.dotted,
            ),
            const SizedBox(width: 8),
            _buildModeButton(
              ref,
              PreviewMode.compare,
              '比較',
              Icons.compare,
              previewMode == PreviewMode.compare,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeButton(
    WidgetRef ref,
    PreviewMode mode,
    String label,
    IconData icon,
    bool isSelected,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(previewModeProvider.notifier).state = mode;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Color(AppColors.primaryBlue)
                : Color(AppColors.cardColor),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Color(AppColors.primaryBlue)
                  : Color(AppColors.dividerColor),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Color(AppColors.primaryText)
                    : Color(AppColors.secondaryText),
                size: 16,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Color(AppColors.primaryText)
                      : Color(AppColors.secondaryText),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
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
}
