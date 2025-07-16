# DotCam - ドット絵変換カメラアプリ

ワンタップでゲーム風ドット絵に変換するFlutterアプリです。

## 🎯 主な機能

### カメラ機能
- リアルタイムドット絵プレビュー
- 前面/背面カメラ切り替え
- フラッシュ・フォーカス制御
- ピンチズーム対応

### ドット絵変換
- 16x16〜128x128の解像度選択
- 8種類のレトロゲーム風カラーパレット
- フロイド・スタインバーグディザリング
- 明度・コントラスト調整

### 比較ビュー
- 4分割レイアウト（2×2）
- 配置位置選択（右下/左下/右上/左上）
- オリジナル画像の半透明フレーム

### その他
- ギャラリー機能（グリッド/リスト表示）
- 多言語対応（日本語・英語他8言語）
- Google AdMob広告統合
- 各種権限管理

## 📱 対応環境

- **Flutter**: 3.32.0-0.2.pre (beta)
- **Android**: API 21+ (Android 5.0+)
- **iOS**: iOS 12.0+
- **Xcode**: 16.2+

## 🔧 セットアップ

1. **依存関係のインストール**
   ```bash
   flutter pub get
   ```

2. **実行**
   ```bash
   flutter run
   ```

3. **ビルド**
   ```bash
   # Android
   flutter build apk --release
   
   # iOS
   flutter build ios --release
   ```

## 🐛 エラー修正済み

以下のエラーを修正しました：

### 1. Import不足エラー
- `app_settings.dart`: `import 'package:flutter/material.dart';` を追加
- `Alignment` クラスの未定義エラーを解決

### 2. SystemSound.click エラー
- `SystemSound.click` は正しい値です
- camera_screen.dart と settings_screen.dart で使用

### 3. Image ライブラリ使用法の修正
- `Pixel` クラスの正しい使用方法に修正
- `pixel.toInt()` で int 値に変換
- `img.ColorRgb8()` を使用してピクセル設定

### 4. 構文エラー修正
- `....` を `...` に修正（スプレッド演算子）
- `SliderTheme.of(context).copyWith` を `SliderThemeData` に修正

### 5. テストファイル修正
- 実際のアプリに合わせたテストケースに変更
- `const` 修飾子の不適切な使用を修正

## 📁 ファイル構成

```
lib/
├── main.dart
├── models/
│   ├── dot_settings.dart
│   └── app_settings.dart
├── providers/
│   └── app_providers.dart
├── screens/
│   ├── camera_screen.dart
│   ├── preview_screen.dart
│   ├── gallery_screen.dart
│   ├── settings_screen.dart
│   └── onboarding_screen.dart
├── widgets/
│   ├── shutter_button.dart
│   ├── quick_settings_panel.dart
│   ├── camera_controls.dart
│   ├── dot_preview_overlay.dart
│   ├── compare_view.dart
│   ├── loading_overlay.dart
│   ├── gallery_item.dart
│   ├── empty_gallery.dart
│   ├── settings_section.dart
│   ├── settings_item.dart
│   └── onboarding_page.dart
└── utils/
    ├── constants.dart
    └── dot_converter.dart
```

## 🔐 権限

### Android
- カメラ権限
- ストレージ権限
- インターネット権限（広告用）

### iOS
- カメラ使用許可
- 写真ライブラリアクセス
- App Tracking Transparency

## 💡 開発メモ

### 状態管理
- Riverpod + Hooks を使用
- プロバイダー分離設計

### 画像処理
- Isolate を使用した非同期処理
- メモリ効率を考慮した実装

### UI/UX
- マテリアルデザイン準拠
- ダークテーマ対応
- アニメーション効果

## 🚀 今後の展開

- [ ] カスタムパレット作成機能
- [ ] 動画からのドット絵変換
- [ ] SNS直接投稿機能
- [ ] AR機能統合
- [ ] 機械学習による高品質変換

## 📄 ライセンス

MIT License

## 🤝 貢献

プルリクエストとイシューを歓迎します。

---

© 2025 DotCam - ワンタップでゲーム風ドット絵へ