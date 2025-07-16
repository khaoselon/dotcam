import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../providers/app_providers.dart';
import '../utils/constants.dart';

class CameraControls extends ConsumerWidget {
  final VoidCallback onFlashToggle;
  final VoidCallback onCameraSwitch;
  final VoidCallback onQuickSettings;

  const CameraControls({
    Key? key,
    required this.onFlashToggle,
    required this.onCameraSwitch,
    required this.onQuickSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashMode = ref.watch(flashModeProvider);
    final cameraDirection = ref.watch(cameraDirectionProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // フラッシュボタン
          _buildControlButton(
            icon: _getFlashIcon(flashMode),
            onTap: onFlashToggle,
            label: _getFlashLabel(flashMode),
          ),

          // クイック設定ボタン
          _buildControlButton(
            icon: Icons.tune,
            onTap: onQuickSettings,
            label: '設定',
          ),

          // カメラ切り替えボタン
          _buildControlButton(
            icon: cameraDirection == CameraLensDirection.back
                ? Icons.camera_front
                : Icons.camera_rear,
            onTap: onCameraSwitch,
            label: cameraDirection == CameraLensDirection.back ? '前面' : '背面',
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(AppColors.overlayDark),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Color(AppColors.primaryText), size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Color(AppColors.primaryText),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFlashIcon(FlashMode mode) {
    switch (mode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.off:
        return Icons.flash_off;
      default:
        return Icons.flash_auto;
    }
  }

  String _getFlashLabel(FlashMode mode) {
    switch (mode) {
      case FlashMode.auto:
        return '自動';
      case FlashMode.always:
        return 'オン';
      case FlashMode.off:
        return 'オフ';
      default:
        return '自動';
    }
  }
}
