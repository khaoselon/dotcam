import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Color? color;

  const SettingsSection({
    Key? key,
    required this.title,
    required this.icon,
    required this.children,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(AppColors.surfaceColor),
        borderRadius: BorderRadius.circular(Constants.cornerRadius),
        border: Border.all(color: Color(AppColors.dividerColor), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // セクションヘッダー
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color ?? Color(AppColors.primaryBlue),
                  color?.withOpacity(0.8) ?? Color(AppColors.primaryPurple),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Constants.cornerRadius - 1),
                topRight: Radius.circular(Constants.cornerRadius - 1),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // セクション内容
          Column(children: children),
        ],
      ),
    );
  }
}
