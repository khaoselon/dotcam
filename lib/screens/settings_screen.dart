import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../models/dot_settings.dart';
import '../models/app_settings.dart';
import '../utils/constants.dart';
import '../utils/dot_converter.dart' as dot;
import '../widgets/settings_section.dart';
import '../widgets/settings_item.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: Constants.mediumAnimation,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(AppColors.surfaceColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Constants.cornerRadius),
        ),
      ),
      builder: (context) => _buildLanguageSelector(),
    );
  }

  void _showColorPaletteSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(AppColors.surfaceColor),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Constants.cornerRadius),
        ),
      ),
      builder: (context) => _buildColorPaletteSelector(),
    );
  }

  void _showTutorial() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OnboardingScreen(isFromSettings: true),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(AppColors.surfaceColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.cornerRadius),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(AppColors.primaryBlue),
                    Color(AppColors.primaryPurple),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              Constants.appName,
              style: TextStyle(
                color: Color(AppColors.primaryText),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'バージョン ${Constants.appVersion}',
              style: TextStyle(
                color: Color(AppColors.secondaryText),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ワンタップでゲーム風ドット絵に変換するカメラアプリです。',
              style: TextStyle(
                color: Color(AppColors.primaryText),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '© 2025 DotCam',
              style: TextStyle(
                color: Color(AppColors.secondaryText),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(color: Color(AppColors.primaryBlue)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dotSettings = ref.watch(dotSettingsProvider);
    final appSettings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: Color(AppColors.backgroundColor),
      appBar: AppBar(
        backgroundColor: Color(AppColors.surfaceColor),
        elevation: 0,
        title: Text(
          AppStrings.settingsTitle,
          style: TextStyle(
            color: Color(AppColors.primaryText),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(AppColors.primaryText)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ドット絵設定セクション
            SettingsSection(
              title: AppStrings.dotSettings,
              icon: Icons.grid_on,
              children: [
                SettingsItem(
                  title: AppStrings.resolution,
                  subtitle:
                      '${dotSettings.resolution}x${dotSettings.resolution}',
                  leading: Icons.photo_size_select_large,
                  onTap: () => _showResolutionSelector(),
                ),
                SettingsItem(
                  title: AppStrings.colorPalette,
                  subtitle: dotSettings.palette.displayName,
                  leading: Icons.palette,
                  onTap: _showColorPaletteSelector,
                ),
                SettingsItem(
                  title: AppStrings.dithering,
                  subtitle: dotSettings.ditheringEnabled ? '有効' : '無効',
                  leading: Icons.grain,
                  trailing: Switch(
                    value: dotSettings.ditheringEnabled,
                    onChanged: (value) {
                      ref
                          .read(dotSettingsProvider.notifier)
                          .updateDithering(value);
                    },
                    activeColor: Color(AppColors.primaryBlue),
                  ),
                ),
                _buildSliderItem(
                  title: AppStrings.contrast,
                  value: dotSettings.contrast,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  onChanged: (value) {
                    ref
                        .read(dotSettingsProvider.notifier)
                        .updateContrast(value);
                  },
                ),
                _buildSliderItem(
                  title: AppStrings.brightness,
                  value: dotSettings.brightness,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  onChanged: (value) {
                    ref
                        .read(dotSettingsProvider.notifier)
                        .updateBrightness(value);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // レイアウト設定セクション
            SettingsSection(
              title: AppStrings.layoutSettings,
              icon: Icons.view_quilt,
              children: [
                SettingsItem(
                  title: AppStrings.compareLayout,
                  subtitle: appSettings.compareLayout.displayName,
                  leading: Icons.compare,
                  onTap: () => _showCompareLayoutSelector(),
                ),
                _buildSliderItem(
                  title: AppStrings.previewOpacity,
                  value: appSettings.previewOpacity,
                  min: 0.1,
                  max: 1.0,
                  divisions: 9,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).state = appSettings
                        .copyWith(previewOpacity: value);
                  },
                ),
                SettingsItem(
                  title: AppStrings.showGrid,
                  subtitle: appSettings.showGridOverlay ? '表示' : '非表示',
                  leading: Icons.grid_4x4,
                  trailing: Switch(
                    value: appSettings.showGridOverlay,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).state = appSettings
                          .copyWith(showGridOverlay: value);
                    },
                    activeColor: Color(AppColors.primaryBlue),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 一般設定セクション
            SettingsSection(
              title: AppStrings.generalSettings,
              icon: Icons.settings,
              children: [
                SettingsItem(
                  title: AppStrings.autoSave,
                  subtitle: appSettings.autoSaveEnabled ? '有効' : '無効',
                  leading: Icons.save,
                  trailing: Switch(
                    value: appSettings.autoSaveEnabled,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).updateAutoSave(value);
                    },
                    activeColor: Color(AppColors.primaryBlue),
                  ),
                ),
                SettingsItem(
                  title: AppStrings.saveLocation,
                  subtitle: appSettings.saveLocation.displayName,
                  leading: Icons.folder,
                  onTap: () => _showSaveLocationSelector(),
                ),
                SettingsItem(
                  title: AppStrings.language,
                  subtitle:
                      Constants.supportedLanguages[appSettings.languageCode] ??
                      '日本語',
                  leading: Icons.language,
                  onTap: _showLanguageSelector,
                ),
                SettingsItem(
                  title: AppStrings.hapticFeedback,
                  subtitle: appSettings.enableHapticFeedback ? '有効' : '無効',
                  leading: Icons.vibration,
                  trailing: Switch(
                    value: appSettings.enableHapticFeedback,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).state = appSettings
                          .copyWith(enableHapticFeedback: value);
                      if (value) {
                        HapticFeedback.lightImpact();
                      }
                    },
                    activeColor: Color(AppColors.primaryBlue),
                  ),
                ),
                SettingsItem(
                  title: AppStrings.soundEffects,
                  subtitle: appSettings.enableSoundEffects ? '有効' : '無効',
                  leading: Icons.volume_up,
                  trailing: Switch(
                    value: appSettings.enableSoundEffects,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).state = appSettings
                          .copyWith(enableSoundEffects: value);
                      if (value) {
                        HapticFeedback.mediumImpact();
                      }
                    },
                    activeColor: Color(AppColors.primaryBlue),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // アプリについてセクション
            SettingsSection(
              title: AppStrings.aboutSettings,
              icon: Icons.info,
              children: [
                SettingsItem(
                  title: AppStrings.version,
                  subtitle: Constants.appVersion,
                  leading: Icons.info_outline,
                  onTap: _showAboutDialog,
                ),
                SettingsItem(
                  title: AppStrings.tutorial,
                  subtitle: 'チュートリアルを再表示',
                  leading: Icons.help_outline,
                  onTap: _showTutorial,
                ),
                SettingsItem(
                  title: AppStrings.privacy,
                  subtitle: 'プライバシーポリシーを確認',
                  leading: Icons.privacy_tip,
                  onTap: () => _showInfoDialog('プライバシーポリシー', _getPrivacyText()),
                ),
                SettingsItem(
                  title: AppStrings.terms,
                  subtitle: '利用規約を確認',
                  leading: Icons.description,
                  onTap: () => _showInfoDialog('利用規約', _getTermsText()),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderItem({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Color(AppColors.primaryText),
                  fontSize: 16,
                ),
              ),
              Text(
                value.toStringAsFixed(1),
                style: TextStyle(
                  color: Color(AppColors.primaryBlue),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Color(AppColors.primaryBlue),
              inactiveTrackColor: Color(AppColors.dividerColor),
              thumbColor: Color(AppColors.primaryBlue),
              overlayColor: Color(AppColors.primaryBlue).withOpacity(0.3),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  void _showResolutionSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(AppColors.surfaceColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Constants.cornerRadius),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '解像度を選択',
              style: TextStyle(
                color: Color(AppColors.primaryText),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ...Constants.resolutionOptions.map((resolution) {
              final isSelected =
                  ref.read(dotSettingsProvider).resolution == resolution;
              return ListTile(
                title: Text(
                  '${resolution}x${resolution}',
                  style: TextStyle(
                    color: isSelected
                        ? Color(AppColors.primaryBlue)
                        : Color(AppColors.primaryText),
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: Color(AppColors.primaryBlue))
                    : null,
                onTap: () {
                  ref
                      .read(dotSettingsProvider.notifier)
                      .updateResolution(resolution);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showCompareLayoutSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(AppColors.surfaceColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Constants.cornerRadius),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '比較レイアウトを選択',
              style: TextStyle(
                color: Color(AppColors.primaryText),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ...CompareLayout.values.map((layout) {
              final isSelected =
                  ref.read(settingsProvider).compareLayout == layout;
              return ListTile(
                title: Text(
                  layout.displayName,
                  style: TextStyle(
                    color: isSelected
                        ? Color(AppColors.primaryBlue)
                        : Color(AppColors.primaryText),
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: Color(AppColors.primaryBlue))
                    : null,
                onTap: () {
                  ref
                      .read(settingsProvider.notifier)
                      .updateCompareLayout(layout);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showSaveLocationSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(AppColors.surfaceColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Constants.cornerRadius),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '保存先を選択',
              style: TextStyle(
                color: Color(AppColors.primaryText),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ...SaveLocation.values.map((location) {
              final isSelected =
                  ref.read(settingsProvider).saveLocation == location;
              return ListTile(
                title: Text(
                  location.displayName,
                  style: TextStyle(
                    color: isSelected
                        ? Color(AppColors.primaryBlue)
                        : Color(AppColors.primaryText),
                  ),
                ),
                subtitle: Text(
                  location.description,
                  style: TextStyle(
                    color: Color(AppColors.secondaryText),
                    fontSize: 12,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: Color(AppColors.primaryBlue))
                    : null,
                onTap: () {
                  ref
                      .read(settingsProvider.notifier)
                      .updateSaveLocation(location);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '言語を選択',
            style: TextStyle(
              color: Color(AppColors.primaryText),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ...Constants.supportedLanguages.entries.map((entry) {
            final isSelected =
                ref.read(settingsProvider).languageCode == entry.key;
            return ListTile(
              title: Text(
                entry.value,
                style: TextStyle(
                  color: isSelected
                      ? Color(AppColors.primaryBlue)
                      : Color(AppColors.primaryText),
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check, color: Color(AppColors.primaryBlue))
                  : null,
              onTap: () {
                ref.read(settingsProvider.notifier).updateLanguage(entry.key);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildColorPaletteSelector() {
    return Container(
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          Text(
            'カラーパレットを選択',
            style: TextStyle(
              color: Color(AppColors.primaryText),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: dot.ColorPalette.values.map((palette) {
                final isSelected =
                    ref.read(dotSettingsProvider).palette == palette;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? Color(AppColors.primaryBlue)
                          : Color(AppColors.dividerColor),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    title: Text(
                      palette.displayName,
                      style: TextStyle(
                        color: isSelected
                            ? Color(AppColors.primaryBlue)
                            : Color(AppColors.primaryText),
                      ),
                    ),
                    subtitle: Container(
                      height: 20,
                      margin: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: palette.colors
                            .take(8)
                            .map(
                              (color) => Expanded(
                                child: Container(color: Color(color)),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check, color: Color(AppColors.primaryBlue))
                        : null,
                    onTap: () {
                      ref
                          .read(dotSettingsProvider.notifier)
                          .updatePalette(palette);
                      Navigator.pop(context);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(AppColors.surfaceColor),
        title: Text(
          title,
          style: TextStyle(color: Color(AppColors.primaryText)),
        ),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: TextStyle(
              color: Color(AppColors.secondaryText),
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(color: Color(AppColors.primaryBlue)),
            ),
          ),
        ],
      ),
    );
  }

  String _getPrivacyText() {
    return '''
DotCamプライバシーポリシー

1. 情報の収集
当アプリは以下の情報を収集する場合があります：
- カメラで撮影した画像（端末内でのみ処理）
- アプリの使用状況データ
- 広告配信のための匿名データ

2. 情報の使用
収集した情報は以下の目的で使用されます：
- アプリの機能提供
- アプリの改善
- 広告の配信

3. 情報の共有
ユーザーの個人情報を第三者と共有することはありません。

4. データの保護
適切なセキュリティ対策を講じて情報を保護します。

5. お問い合わせ
プライバシーに関するご質問は、アプリ内のお問い合わせ機能をご利用ください。
''';
  }

  String _getTermsText() {
    return '''
DotCam利用規約

1. サービスの利用
本アプリは無料で提供されており、広告収入により運営されています。

2. 禁止事項
以下の行為を禁止します：
- 違法または有害なコンテンツの作成
- アプリの不正使用
- 他者の権利を侵害する行為

3. 免責事項
アプリの使用により生じた損害について、当方は責任を負いません。

4. 規約の変更
本規約は予告なく変更される場合があります。

5. 準拠法
本規約は日本法に準拠します。
''';
  }
}
